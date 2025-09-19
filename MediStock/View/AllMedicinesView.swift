import SwiftUI

struct AllMedicinesView: View {

    @EnvironmentObject var session: SessionViewModel
    @ObservedObject var viewModel: MedicineStockViewModel

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
                List(viewModel.filteredAndSortedMedicines, id: \.id) { medicine in
                    if let userId = session.session?.uid, let medicineId = medicine.id {
                        NavigationLink(
                            destination: MedicineDetailView(for: medicine, id: medicineId, userId: userId)
                        ) {
                            MedicineItemView(medicine: medicine)
                        }
                    }
                }
                .navigationBarTitle("All Medicines")
                .navigationBarItems(trailing: Button(action: {
                    if let userId = session.session?.uid {
                        Task { await viewModel.addRandomMedicine(userId: userId) }
                    }
                }) {
                    Image(systemName: "plus")
                })
            }
        }
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    @Previewable @StateObject var viewModel = MedicineStockViewModel(dbRepo: PreviewDatabaseRepo())
    AllMedicinesView(viewModel: viewModel)
}
