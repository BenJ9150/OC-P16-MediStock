import SwiftUI

struct MedicineListView: View {

    @EnvironmentObject var session: SessionViewModel
    @ObservedObject var viewModel: MedicineStockViewModel

    var aisle: String

    var body: some View {
        List(viewModel.medicines.filter { $0.aisle == aisle }, id: \.id) { medicine in
            if let userId = session.session?.uid, let medicineId = medicine.id {
                NavigationLink(
                    destination: MedicineDetailView(for: medicine, id: medicineId, userId: userId)
                ) {
                    MedicineItemView(medicine: medicine)
                }
            }
        }
        .navigationBarTitle(aisle)
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    @Previewable @StateObject var viewModel = MedicineStockViewModel(dbRepo: PreviewDatabaseRepo())
    NavigationStack {
        MedicineListView(viewModel: viewModel, aisle: "Aisle 1")
    }
}
