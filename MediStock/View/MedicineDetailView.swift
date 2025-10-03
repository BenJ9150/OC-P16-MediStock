import SwiftUI

struct MedicineDetailView: View {

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
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(viewModel.name)
                    .font(.largeTitle)
                    .padding(.top, 20)

                if viewModel.sendHistoryError == nil {
                    medicineDetails
                }
                historySection
            }
            .padding(.vertical)
        }
        .navigationTitle("Medicine Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.sendHistoryError != nil)
        .onTapGesture {
            if stockIsFocused {
                Task { await viewModel.updateStock() }
                stockIsFocused = false
            }
        }
    }
}

extension MedicineDetailView {

    private var medicineDetails: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Medicine Name
            TextFieldWithTitleView(
                title: "Name",
                text: $viewModel.name,
                error: $viewModel.nameError,
                loading: $viewModel.updatingName
            ) {
                await viewModel.updateName()
            }

            // Medicine Stock
            medicineStockSection

            // Medicine Aisle
            TextFieldWithTitleView(
                title: "Aisle",
                text: $viewModel.aisle,
                error: $viewModel.aisleError,
                loading: $viewModel.updatingAisle
            ) {
                await viewModel.updateAilse()
            }
        }
    }
    private var medicineStockSection: some View {
        VStack(alignment: .leading) {
            Text("Stock")
                .font(.headline)
            
            HStack {
                Button {
                    Task { await viewModel.decreaseStock() }
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.title)
                        .foregroundColor(.red)
                }
                .accessibilityIdentifier("decreaseStockButton")

                TextField("Stock", value: $viewModel.stock, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .focused($stockIsFocused)
                    .frame(width: 100)

                Button {
                    Task { await viewModel.increaseStock() }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .foregroundColor(.green)
                }
                .accessibilityIdentifier("increaseStockButton")
            }
            .opacity(viewModel.updatingStock ? 0 : 1)
            .overlay {
                ProgressView()
                    .opacity(viewModel.updatingStock ? 1 : 0)
            }
            .textFieldError(value: $viewModel.stock, error: $viewModel.stockError, isFocused: _stockIsFocused)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    private var historySection: some View {
        VStack(alignment: .leading) {
            Text("History")
                .font(.headline)
                .padding(.top, 20)
            
            if let historyError = viewModel.sendHistoryError {
                ErrorView(message: "An error occured when send history: \(historyError.error)")
                Button("RETRY") {
                    Task { await viewModel.sendHistoryAfterError() }
                }
                .accessibilityIdentifier("RetrySendHistoryButton")
            }
            
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.history, id: \.id) { entry in
                    HistoryItemView(item: entry)
                }
            }
            .displayLoaderOrError(
                loading: $viewModel.historyIsLoading,
                error: $viewModel.loadHistoryError,
                background: .clear
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    let medicine = PreviewDatabaseRepo().medicine()
    MedicineDetailView(for: medicine, id: medicine.id!, userId: "preview_id")
}
