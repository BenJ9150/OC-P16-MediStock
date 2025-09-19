import SwiftUI

struct MedicineDetailView: View {

    @StateObject var viewModel: MedicineDetailViewModel
    @FocusState private var stockFieldFocused: Bool

    init(for medicine: Medicine, id medicineId: String, userId: String) {
#if DEBUG
        let dbRepo: DatabaseRepository = ProcessInfo.isPreview ? PreviewDatabaseRepo() : FirestoreRepo()
#else
        let dbRepo: DatabaseRepository = FirestoreRepo()
#endif
        self._viewModel = StateObject(
            wrappedValue: MedicineDetailViewModel(
                medicine: medicine,
                medicineId: medicineId,
                userId: userId,
                dbRepo: dbRepo
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

                // Medicine Name
                TextFieldWithTitleView(title: "Name", text: $viewModel.name, loading: $viewModel.updatingName) {
                    await viewModel.updateName()
                }

                // Medicine Stock
                medicineStockSection

                // Medicine Aisle
                TextFieldWithTitleView(title: "Aisle", text: $viewModel.aisle, loading: $viewModel.updatingAilse) {
                    await viewModel.updateAilse()
                }

                // History Section
                historySection
            }
            .padding(.vertical)
        }
        .navigationTitle("Medicine Details")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            stockFieldFocused = false
        }
    }
}

extension MedicineDetailView {

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

                TextField("Stock", value: $viewModel.stock, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .focused($stockFieldFocused)
                .frame(width: 100)
                .toolbar {
                    if stockFieldFocused {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button("Update") {
                                Task { await viewModel.updateStock() }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }

                Button {
                    Task { await viewModel.increaseStock() }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .foregroundColor(.green)
                }
            }
            .opacity(viewModel.updatingStock ? 0 : 1)
            .overlay {
                ProgressView()
                    .opacity(viewModel.updatingStock ? 1 : 0)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    private var historySection: some View {
        VStack(alignment: .leading) {
            Text("History")
                .font(.headline)
                .padding(.top, 20)
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.history, id: \.id) { entry in
                    HistoryItemView(item: entry)
                }
            }
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
