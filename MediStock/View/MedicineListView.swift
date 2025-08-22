import SwiftUI

struct MedicineListView: View {

    @Environment(\.dbRepo) var dbRepo
    @EnvironmentObject var session: SessionViewModel
    @ObservedObject var viewModel: MedicineStockViewModel

    var aisle: String

    var body: some View {
        List {
            ForEach(viewModel.medicines.filter { $0.aisle == aisle }, id: \.id) { medicine in
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
