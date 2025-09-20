import SwiftUI

struct AllMedicinesView: View {

    @EnvironmentObject var session: SessionViewModel
    @ObservedObject var viewModel: MedicineStockViewModel
    @State private var showAddMedicine: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                // Filtrage et Tri
                HStack {
                    TextField("Filter by name", text: $viewModel.medicineFilter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 10)
                    
                    Spacer()

                    Picker("Sort by", selection: $viewModel.medicineSort) {
                        Text("None").tag(MedicineStockViewModel.MedicineSort.none)
                        Text("Name").tag(MedicineStockViewModel.MedicineSort.name)
                        Text("Stock").tag(MedicineStockViewModel.MedicineSort.stock)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.trailing, 10)
                }
                .padding(.top, 10)
                
                // Liste des Médicaments
                MedicinesListView(viewModel.filteredAndSortedMedicines)
                    .loadingViewModifier(loading: $viewModel.isLoading, error: $viewModel.loadError)
            }
            .navigationTitle("All Medicines")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddMedicine.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(isPresented: $showAddMedicine) {
                AddMedicineView(viewModel: viewModel)
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



