import SwiftUI

struct AllMedicinesView: View {

    @Environment(\.dbRepo) var dbRepo
    @EnvironmentObject var session: SessionViewModel
    @ObservedObject var viewModel = MedicineStockViewModel()

    var body: some View {
        NavigationView {
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
                List {
                    ForEach(viewModel.filteredAndSortedMedicines, id: \.id) { medicine in
                        if let userId = session.session?.uid, let medicineId = medicine.id {
                            NavigationLink(
                                destination: MedicineDetailView(
                                    for: medicine,
                                    medicineId: medicineId,
                                    userId: userId,
                                    dbRepo: dbRepo
                                )
                            ) {
                                VStack(alignment: .leading) {
                                    Text(medicine.name)
                                        .font(.headline)
                                    Text("Stock: \(medicine.stock)")
                                        .font(.subheadline)
                                }
                            }
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

struct AllMedicinesView_Previews: PreviewProvider {
    static var previews: some View {
        AllMedicinesView()
            .environmentObject(SessionViewModel())
    }
}
