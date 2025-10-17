import SwiftUI

struct MedicineDetailView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.verticalSizeClass) var verticalSize
    @StateObject var viewModel: MedicineDetailViewModel
    @FocusState private var stockIsFocused: Bool
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
                HStack(spacing: 0) {
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
                Task { await viewModel.updateStock() }
                stockIsFocused = false
                hideKeyboard()
            }
        }
        .mediBackground()
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
                    Task { await viewModel.updateName() }
                }

                // Medicine Aisle
                TextFieldWithTitleView(
                    title: "Aisle",
                    text: $viewModel.aisle,
                    error: $viewModel.aisleError,
                    loading: $viewModel.updatingAisle
                ) {
                    Task { await viewModel.updateAilse() }
                }

                // Medicine Stock
                HStack(alignment: .bottom, spacing: 0) {
                    TextFieldWithTitleView("Stock", value: $viewModel.stock, isFocused: _stockIsFocused)
                    Spacer()
                    stockButton(increase: false)
                    stockButton(increase: true)
                }
                .buttonLoader(isLoading: $viewModel.updatingStock)
                .textFieldError(value: $viewModel.stock, error: $viewModel.stockError, isFocused: _stockIsFocused)
            }
            .roundedBackground()
        }
    }
}

// MARK: Stock buttons

private extension MedicineDetailView {

    func stockButton(increase: Bool) -> some View {
        Button {
            Task {
                await increase ? viewModel.increaseStock() : viewModel.decreaseStock()
            }
        } label: {
            Image(systemName: increase ? "plus" : "minus")
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(.plainButton, in: Circle())
        }
        .accessibilityIdentifier(increase ? "increaseStockButton" : "decreaseStockButton")
        .padding(.trailing, increase ? 0 : 24)
    }
}

// MARK: Delete

private extension MedicineDetailView {

    var deleteButtonToolbar: some View {
        Button("Delete", systemImage: "trash.fill", role: .destructive) {
            showDeleteAlert.toggle()
        }
        .accessibilityIdentifier("DeleteButtonToolbar")
    }

    var deleteButtonAlert: some View {
        Button("Delete", role: .destructive) {
            Task {
                try await viewModel.deleteMedicine()
                dismiss()
            }
        }
        .accessibilityIdentifier("DeleteButtonAlert")
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
                error: $viewModel.loadHistoryError
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
