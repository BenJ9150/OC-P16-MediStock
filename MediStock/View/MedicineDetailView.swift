import SwiftUI

struct MedicineDetailView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.verticalSizeClass) var verticalSize
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    @StateObject var viewModel: MedicineDetailViewModel
    @FocusState private var stockIsFocused: Bool

    @State private var editNameOrAisle: Bool = false
    @State private var showNameAlert: Bool = false
    @State private var showAisleAlert: Bool = false
    @State private var showStockAlert: Bool = false
    @State private var showDeleteAlert: Bool = false

    init(for medicine: Medicine, id medicineId: String, user: AuthUser) {
        self._viewModel = StateObject(
            wrappedValue: MedicineDetailViewModel(
                medicine: medicine,
                medicineId: medicineId,
                user: user,
                dbRepo: RepoSettings().getDbRepo()
            )
        )
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            if UIDevice.current.userInterfaceIdiom == .pad || verticalSize == .compact {
                HStack(alignment: .top, spacing: 0) {
                    medicineDetails
                        .frame(maxWidth: 400)
                    historySection
                }
            } else {
                VStack(spacing: 0) {
                    medicineDetails
                    historySection
                }
            }
        }
        .displayLoaderOrError(loading: $viewModel.deleting, error: $viewModel.deleteError)
        .navigationTitle(viewModel.name)
        .navigationBarBackButtonHidden(viewModel.sendHistoryError != nil)
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbar { deleteButtonToolbar }
        .onTapGesture {
            if stockIsFocused {
                stockIsFocused = false
                hideKeyboard()
            }
        }
        .mediBackground()
        .alert(.newNameUpdateThisName(viewModel.name), isPresented: $showNameAlert) {
            updateNameButtonAlert
            cancelNameButtonAlert
        }
        .alert(.newAisleUpdateThisAisle(viewModel.aisle), isPresented: $showAisleAlert) {
            updateAisleButtonAlert
            cancelAisleButtonAlert
        }
        .alert(.newStockUpdateThisStock(viewModel.stock), isPresented: $showStockAlert) {
            updateStockButtonAlert
            cancelStockButtonAlert
        }
        .alert(.deleteThisMedicine, isPresented: $showDeleteAlert) {
            deleteButtonAlert
        }
    }
}

// MARK: Details

private extension MedicineDetailView {

    @ViewBuilder var medicineDetails: some View {
        if viewModel.sendHistoryError == nil {
            VStack(spacing: 0) {
                if editNameOrAisle {
                    Group {
                        medicineName
                            .padding(.bottom)
                        medicineAisle
                            .padding(.bottom, 24)
                    }
                    .transition(.opacity.combined(with: .scale))
                } else {
                    HStack(spacing: 0) {
                        Button {
                            editNameOrAisle = true
                        } label: {
                            Image(systemName: "pencil")
                                .imageScale(.large)
                                .bold()
                                .frame(minWidth: 44, minHeight: 40)
                        }
                        .accessibilityIdentifier("editNameOrAisleButton")
                        .accessibilityLabel(.editNameOrAisle)

                        Text(.in(viewModel.name, viewModel.aisle))
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.bottom)
                    .transition(.opacity.combined(with: .scale))
                }
                medicineStock
            }
            .roundedBackground()
            .animation(reduceMotion ? .none : .default, value: viewModel.stock)
            .animation(reduceMotion ? .none : .default, value: editNameOrAisle)
        }
    }
}

// MARK: Name

private extension MedicineDetailView {

    var medicineName: some View {
        TextFieldWithTitleView(
            title: .name,
            text: $viewModel.name,
            error: $viewModel.nameError,
            loading: $viewModel.updatingName
        ) {
            if viewModel.name != viewModel.nameBackup {
                showNameAlert.toggle()
            }
        }
    }
    
    var updateNameButtonAlert: some View {
        Button(.update, role: .destructive) {
            Task { await viewModel.updateName() }
        }
        .accessibilityIdentifier("updateNameButtonAlert")
    }

    var cancelNameButtonAlert: some View {
        Button(.cancel, role: .cancel) {
            viewModel.name = viewModel.nameBackup
        }
        .accessibilityIdentifier("cancelNameButtonAlert")
    }
}

// MARK: Aisle

private extension MedicineDetailView {

    var medicineAisle: some View {
        TextFieldWithTitleView(
            title: .aisle,
            text: $viewModel.aisle,
            error: $viewModel.aisleError,
            loading: $viewModel.updatingAisle
        ) {
            if viewModel.aisle != viewModel.aisleBackup {
                showAisleAlert.toggle()
            }
        }
    }

    var updateAisleButtonAlert: some View {
        Button(.update, role: .destructive) {
            Task { await viewModel.updateAisle() }
        }
        .accessibilityIdentifier("updateAisleButtonAlert")
    }

    var cancelAisleButtonAlert: some View {
        Button(.cancel, role: .cancel) {
            viewModel.aisle = viewModel.aisleBackup
        }
        .accessibilityIdentifier("cancelAisleButtonAlert")
    }
}

// MARK: Stock

private extension MedicineDetailView {

    var medicineStock: some View {
        VStack(spacing: 24) {
            // Medicine Stock
            HStack(alignment: .bottom, spacing: 0) {
                TextFieldWithTitleView(.stock, value: $viewModel.stock, isFocused: _stockIsFocused)
                stockButton(increase: false)
                stockButton(increase: true)
            }
            .buttonLoader(isLoading: $viewModel.updatingStock)
            .textFieldError(value: $viewModel.stock, error: $viewModel.stockError, isFocused: _stockIsFocused)
            
            if viewModel.stock != viewModel.stockBackup && !viewModel.updatingStock {
                updateStockButton
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(reduceMotion ? .none : .default, value: viewModel.stock)
    }

    func stockButton(increase: Bool) -> some View {
        Button {
            increase ? viewModel.increaseStock() : viewModel.decreaseStock()
        } label: {
            Image(systemName: increase ? "plus" : "minus")
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(.plainButton, in: Circle())
        }
        .accessibilityIdentifier(increase ? "increaseStockButton" : "decreaseStockButton")
        .accessibilityLabel(increase ? .addOneToStock : .removeOneFromStock)
        .padding(.horizontal, increase ? 0 : 16)
    }

    var updateStockButton: some View {
        Button(.updateStock) {
            hideKeyboard()
            showStockAlert.toggle()
        }
        .buttonStyle(MediPlainButtonStyle())
        .accessibilityIdentifier("updateStockButton")
        .accessibilityFocusOnAppear()
    }

    var updateStockButtonAlert: some View {
        Button(.update, role: .destructive) {
            Task { await viewModel.updateStock() }
        }
        .accessibilityIdentifier("updateStockButtonAlert")
    }

    var cancelStockButtonAlert: some View {
        Button(.cancel, role: .cancel) {
            viewModel.stock = viewModel.stockBackup
        }
        .accessibilityIdentifier("cancelStockButtonAlert")
    }
}

// MARK: Delete

private extension MedicineDetailView {

    var deleteButtonToolbar: some ToolbarContent {
        ToolbarItem(id: "ToolbarItemMedicineDelete", placement: .topBarTrailing) {
            Button(.delete, systemImage: "trash.fill", role: .destructive) {
                showDeleteAlert.toggle()
            }
            .accessibilityIdentifier("deleteButtonToolbar")
        }
    }

    var deleteButtonAlert: some View {
        Button(.delete, role: .destructive) {
            Task {
                try await viewModel.deleteMedicine()
                dismiss()
            }
        }
        .accessibilityIdentifier("deleteButtonAlert")
    }
}

// MARK: History

private extension MedicineDetailView {

    var historySection: some View {
        VStack {
            Text(.history)
                .font(.headline)
            
            RetrySendHistoryView(error: viewModel.sendHistoryError) {
                Task { await viewModel.sendHistoryAfterError() }
            }
 
            LazyVStack {
                ForEach(viewModel.history, id: \.id) { entry in
                    HistoryItemView(item: entry)
                }
            }
            .displayLoaderOrError(
                loading: $viewModel.historyIsLoading,
                error: $viewModel.loadHistoryError,
                errorColor: .red
            )
        }
        .roundedBackground()
    }
}

// MARK: - Preview

#Preview(traits: .previewEnvironment()) {
    let medicine = PreviewDatabase.medicines.first!
    NavigationStack {
        MedicineDetailView(for: medicine, id: medicine.id!, user: PreviewAuthUser.user)
    }
}
