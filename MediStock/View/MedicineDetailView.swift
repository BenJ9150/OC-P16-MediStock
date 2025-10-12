import SwiftUI

struct MedicineDetailView: View {

    @Environment(\.verticalSizeClass) var verticalSize
    @StateObject var viewModel: MedicineDetailViewModel
    @FocusState private var stockIsFocused: Bool

    init(for medicine: Medicine, id medicineId: String, userId: String) {
        self._viewModel = StateObject(
            wrappedValue: MedicineDetailViewModel(
                medicine: medicine,
                medicineId: medicineId,
                userId: userId,
                dbRepo: RepoSettings().getDbRepo()
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
        .navigationTitle(viewModel.name)
        .navigationBarBackButtonHidden(viewModel.sendHistoryError != nil)
        .onTapGesture {
            if stockIsFocused {
                Task { await viewModel.updateStock() }
                stockIsFocused = false
                hideKeyboard()
            }
        }
        .mediBackground()
    }
}

// MARK: Details

extension MedicineDetailView {

    @ViewBuilder private var medicineDetails: some View {
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

extension MedicineDetailView {

    private func stockButton(increase: Bool) -> some View {
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

// MARK: History

extension MedicineDetailView {

    private var historySection: some View {
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
