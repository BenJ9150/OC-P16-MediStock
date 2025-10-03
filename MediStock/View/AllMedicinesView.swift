import SwiftUI

struct AllMedicinesView: View {

    @EnvironmentObject var session: SessionViewModel
    @ObservedObject var viewModel: MedicineStockViewModel
    @State private var showAddMedicine: Bool = false

    var body: some View {
        NavigationStack {
            MedicinesListView(viewModel.medicines)
                .displayLoaderOrError(loading: $viewModel.isLoading, error: $viewModel.loadError)
                .navigationTitle("All Medicines")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Picker("Sort by", selection: $viewModel.medicineSort) {
                            Text("None").tag(MedicineSort.none)
                            Text("Name").tag(MedicineSort.name)
                            Text("Stock").tag(MedicineSort.stock)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accessibilityIdentifier("SortByPicker")
                    }
                    AddMedicineToolbarItem(showAddView: $showAddMedicine)
                }
                .navigationDestination(isPresented: $showAddMedicine) {
                    AddMedicineView(viewModel: viewModel)
                }
                .searchable(text: $viewModel.medicineFilter)
                .submitLabel(.search)
                .onSubmit(of: .search) {
                    viewModel.listenMedicines()
                }
                .onChange(of: viewModel.medicineFilter) { oldValue, newValue in
                    if !oldValue.isEmpty && newValue.isEmpty {
                        viewModel.listenMedicines() // to clean search
                    }
                }
        }
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
//    @Previewable @StateObject var viewModel = MedicineStockViewModel(
//        dbRepo: PreviewDatabaseRepo(listenError: AppError.networkError)
//    )
    @Previewable @StateObject var viewModel = MedicineStockViewModel(dbRepo: PreviewDatabaseRepo())
    AllMedicinesView(viewModel: viewModel)
}



