import SwiftUI

struct MedicineDetailView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.verticalSizeClass) var verticalSize
    @Environment(\.dynamicTypeSize) var dynamicSize
    @StateObject var viewModel: MedicineDetailViewModel
    @FocusState private var stockIsFocused: Bool

    @State private var editName: Bool = false
    @State private var showNameAlert: Bool = false
    @State private var editAisle: Bool = false
    @State private var showAisleAlert: Bool = false
    @State private var showStockAlert: Bool = false
    @State private var showDeleteAlert: Bool = false

    init(for medicine: Medicine, id medicineId: String, user: AuthUser) {
        self._viewModel = StateObject(
            wrappedValue: MedicineDetailViewModel(
                medicine: medicine,
                medicineId: medicineId,
                user: user,
                dbRepo: RepoSettings().getDbRepo(updateError: AppError.networkError)
            )
        )
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            if UIDevice.current.userInterfaceIdiom == .pad && verticalSize == .compact {
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
        .alert("New name:\n'\(viewModel.name)'\n\nUpdate this name?", isPresented: $showNameAlert) {
            updateNameButtonAlert
            cancelNameButtonAlert
        }
        .alert("New aisle:\n'\(viewModel.aisle)'\n\nUpdate this aisle?", isPresented: $showAisleAlert) {
            updateAisleButtonAlert
            cancelAisleButtonAlert
        }
        .alert("New stock = \(viewModel.stock)\n\nUpdate this stock?", isPresented: $showStockAlert) {
            updateStockButtonAlert
            cancelStockButtonAlert
        }
        .alert("Delete this medicine?", isPresented: $showDeleteAlert) {
            deleteButtonAlert
        }
    }
}

// MARK: Details

private extension MedicineDetailView {

    @ViewBuilder var medicineDetails: some View {
        if viewModel.sendHistoryError == nil {
            VStack(spacing: 0) {
                medicineName
                    .padding(.bottom, editName ? 16 : 2)
                medicineAisle
                    .padding(.bottom, 24)
                medicineStock
            }
            .roundedBackground()
            .animation(.default, value: viewModel.stock)
        }
    }

    struct DetailsWithEditBtn: ViewModifier {
        let identifier: String
        let text: String
        @Binding var isEditing: Bool

        init(_ identifier: String, text: String, isEditing: Binding<Bool>) {
            self.identifier = identifier
            self.text = text
            self._isEditing = isEditing
        }
        @ViewBuilder func body(content: Content) -> some View {
            if isEditing {
                content
            } else {
                HStack {
                    Text(text)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityIdentifier("\(identifier)CurrentValue")
                    Button {
                        isEditing = true
                    } label: {
                        Image(systemName: "pencil")
                            .frame(minWidth: 44, minHeight: 40)
                    }
                    .accessibilityIdentifier("\(identifier)EditButton")
                    .foregroundStyle(.primary)
                }
                
            }
        }
    }
}

// MARK: Name

private extension MedicineDetailView {

    var medicineName: some View {
        TextFieldWithTitleView(
            title: "Name",
            text: $viewModel.name,
            error: $viewModel.nameError,
            loading: $viewModel.updatingName
        ) {
            if viewModel.name != viewModel.nameBackup {
                showNameAlert.toggle()
            }
        }
        .modifier(DetailsWithEditBtn("name", text: viewModel.name, isEditing: $editName))
    }
    
    var updateNameButtonAlert: some View {
        Button("Update", role: .destructive) {
            Task { await viewModel.updateName() }
        }
        .accessibilityIdentifier("updateNameButtonAlert")
    }

    var cancelNameButtonAlert: some View {
        Button("Cancel", role: .cancel) {
            viewModel.name = viewModel.nameBackup
        }
        .accessibilityIdentifier("cancelNameButtonAlert")
    }
}

// MARK: Aisle

private extension MedicineDetailView {

    var medicineAisle: some View {
        TextFieldWithTitleView(
            title: "Aisle",
            text: $viewModel.aisle,
            error: $viewModel.aisleError,
            loading: $viewModel.updatingAisle
        ) {
            if viewModel.aisle != viewModel.aisleBackup {
                showAisleAlert.toggle()
            }
        }
        .modifier(DetailsWithEditBtn("aisle", text: viewModel.aisle, isEditing: $editAisle))
    }

    var updateAisleButtonAlert: some View {
        Button("Update", role: .destructive) {
            Task { await viewModel.updateAilse() }
        }
        .accessibilityIdentifier("updateAisleButtonAlert")
    }

    var cancelAisleButtonAlert: some View {
        Button("Cancel", role: .cancel) {
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
                TextFieldWithTitleView("Stock", value: $viewModel.stock, isFocused: _stockIsFocused)
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
        .animation(.default, value: viewModel.stock)
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
        .padding(.horizontal, increase ? 0 : 16)
    }

    var updateStockButton: some View {
        Button("Update stock") {
            showStockAlert.toggle()
        }
        .buttonStyle(MediPlainButtonStyle())
        .accessibilityIdentifier("updateStockButton")
    }

    var updateStockButtonAlert: some View {
        Button("Update", role: .destructive) {
            Task { await viewModel.updateStock() }
        }
        .accessibilityIdentifier("updateStockButtonAlert")
    }

    var cancelStockButtonAlert: some View {
        Button("Cancel", role: .cancel) {
            viewModel.stock = viewModel.stockBackup
        }
        .accessibilityIdentifier("cancelStockButtonAlert")
    }
}

// MARK: Delete

private extension MedicineDetailView {

    var deleteButtonToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Delete", systemImage: "trash.fill", role: .destructive) {
                showDeleteAlert.toggle()
            }
            .accessibilityIdentifier("deleteButtonToolbar")
        }
    }

    var deleteButtonAlert: some View {
        Button("Delete", role: .destructive) {
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
            Text("History")
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

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    let medicine = PreviewDatabase.medicines.first!
    NavigationStack {
        MedicineDetailView(for: medicine, id: medicine.id!, user: PreviewAuthUser.user)
    }
}
