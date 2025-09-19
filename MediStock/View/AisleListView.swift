import SwiftUI

struct AisleListView: View {

    @EnvironmentObject var session: SessionViewModel
    @ObservedObject var viewModel: MedicineStockViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.aisles, id: \.self) { aisle in
                NavigationLink(destination: MedicineListView(viewModel: viewModel, aisle: aisle)) {
                    Text(aisle)
                }
            }
            .navigationBarTitle("Aisles")
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

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    @Previewable @StateObject var viewModel = MedicineStockViewModel(dbRepo: PreviewDatabaseRepo())
    AisleListView(viewModel: viewModel)
}
