import SwiftUI

struct AisleListView: View {

    @EnvironmentObject var session: SessionViewModel
    @ObservedObject var viewModel: MedicineStockViewModel

    var body: some View {
        NavigationStack {
            aislesList
                .navigationTitle("Aisles")
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
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            session.signOut()
                        } label: {
                            Text("Sign out")
                                .font(.caption)
                        }
                    }
                }
        }
    }
}

// MARK: Aisles list

private extension AisleListView {

    @ViewBuilder var aislesList: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
        } else {
            List(viewModel.aisles, id: \.self) { aisle in
                NavigationLink(destination: MedicineListView(viewModel: viewModel, aisle: aisle)) {
                    Text(aisle)
                }
            }
        }
    }
}


// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    @Previewable @StateObject var viewModel = MedicineStockViewModel(dbRepo: PreviewDatabaseRepo())
    AisleListView(viewModel: viewModel)
}
