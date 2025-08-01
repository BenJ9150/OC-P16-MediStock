import SwiftUI

struct AisleListView: View {

    @EnvironmentObject var session: SessionViewModel
    @ObservedObject var viewModel = MedicineStockViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.aisles, id: \.self) { aisle in
                    NavigationLink(destination: MedicineListView(aisle: aisle)) {
                        Text(aisle)
                    }
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

struct AisleListView_Previews: PreviewProvider {
    static var previews: some View {
        AisleListView()
            .environmentObject(SessionViewModel())
    }
}
