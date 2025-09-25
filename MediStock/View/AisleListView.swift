import SwiftUI

struct AisleListView: View {

    @EnvironmentObject var session: SessionViewModel
    @ObservedObject var viewModel: MedicineStockViewModel
    @State private var showAddMedicine: Bool = false

    var body: some View {
        NavigationStack {
            aislesList
                .displayLoaderOrError(loading: $viewModel.isLoading, error: $viewModel.loadError)
                .navigationTitle("Aisles")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showAddMedicine.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            session.signOut()
                        } label: {
                            Text("Sign out")
                                .font(.caption)
                        }
                    }
                }
                .navigationDestination(isPresented: $showAddMedicine) {
                    AddMedicineView(viewModel: viewModel)
                }
        }
    }
}

// MARK: Aisles list

private extension AisleListView {

    var aislesList: some View {
        List(viewModel.aisles, id: \.self) { aisle in
            NavigationLink(destination: AisleContentView(viewModel: viewModel, aisle: aisle)) {
                Text(aisle)
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
    AisleListView(viewModel: viewModel)
}
