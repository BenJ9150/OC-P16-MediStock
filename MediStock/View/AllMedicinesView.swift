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
                medicinesList
            }
            .navigationTitle("All Medicines")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if let userId = session.session?.uid {
                            Task { await viewModel.addRandomMedicine(userId: userId) }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

// MARK: Medicines list

private extension AllMedicinesView {

    @ViewBuilder var medicinesList: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
        } else {
            List(viewModel.filteredAndSortedMedicines, id: \.id) { medicine in
                if let userId = session.session?.uid, let medicineId = medicine.id {
                    NavigationLink(
                        destination: MedicineDetailView(for: medicine, id: medicineId, userId: userId)
                    ) {
                        MedicineItemView(medicine: medicine)
                    }
                }
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
