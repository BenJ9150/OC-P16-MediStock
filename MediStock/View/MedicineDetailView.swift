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
                    await viewModel.updateName()
                }

                // Medicine Aisle
                TextFieldWithTitleView(
                    title: "Aisle",
                    text: $viewModel.aisle,
                    error: $viewModel.aisleError,
                    loading: $viewModel.updatingAisle
                ) {
                    await viewModel.updateAilse()
                }

                // Medicine Stock
                medicineStockSection
            }
            .roundedBackground()
        }
    }

    private var medicineStockSection: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading) {
                Text("Stock")
                    .font(.headline)
                    .padding(.horizontal)

                TextField("Stock", value: $viewModel.stock, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .focused($stockIsFocused)
                    .frame(width: 100)
            }
            
            Spacer()
            
            Button {
                Task { await viewModel.decreaseStock() }
            } label: {
                Image(systemName: "minus")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(.plainButton, in: Circle())
            }
            .accessibilityIdentifier("decreaseStockButton")
            .padding(.trailing, 24)

            Button {
                Task { await viewModel.increaseStock() }
            } label: {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(.plainButton, in: Circle())
            }
            .accessibilityIdentifier("increaseStockButton")
        }
        .buttonLoader(isLoading: $viewModel.updatingStock)
        .textFieldError(value: $viewModel.stock, error: $viewModel.stockError, isFocused: _stockIsFocused)
    }

    private var historySection: some View {
        VStack(alignment: .leading) {
            Text("History")
                .font(.headline)
            
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
