import SwiftUI

struct MedicineDetailView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.verticalSizeClass) var verticalSize
    @StateObject var viewModel: MedicineDetailViewModel
    @FocusState private var stockIsFocused: Bool

    @State private var showNameAlert: Bool = false
    @State private var showAisleAlert: Bool = false
    @State private var showStockAlert: Bool = false
    @State private var showDeleteAlert: Bool = false

    init(for medicine: Medicine, id medicineId: String, userId: String) {
        self._viewModel = StateObject(
            wrappedValue: MedicineDetailViewModel(
                medicine: medicine,
                medicineId: medicineId,
                userId: userId,
                dbRepo: RepoSettings().getDbRepo(updateError: AppError.networkError)
            )
        )
    }

    var body: some View {
        ScrollView {
            if verticalSize == .compact {
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                deleteButtonToolbar
            }
        }
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
            VStack(alignment: .leading, spacing: 24) {
                // Medicine Name
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

                // Medicine Aisle
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
            .roundedBackground()
            .animation(.default, value: viewModel.stock)
        }
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

// MARK: Stock buttons

private extension MedicineDetailView {

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

    var deleteButtonToolbar: some View {
        Button("Delete", systemImage: "trash.fill", role: .destructive) {
            showDeleteAlert.toggle()
        }
        .accessibilityIdentifier("deleteButtonToolbar")
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
        VStack(alignment: .leading) {
            Text("History")
                .font(.headline)
            
            RetrySendHistoryView(error: viewModel.sendHistoryError) {
                Task { await viewModel.sendHistoryAfterError() }
            }
 
            LazyVStack(alignment: .leading) {
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
    let medicine = PreviewDatabaseRepo().medicine()
    NavigationStack {
        MedicineDetailView(for: medicine, id: medicine.id!, userId: "preview_id")
    }
}
