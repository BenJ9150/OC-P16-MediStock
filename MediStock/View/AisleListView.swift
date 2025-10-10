import SwiftUI

struct AisleListView: View {

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: SessionViewModel
    @ObservedObject var viewModel: MedicineStockViewModel
    @State private var selectedAisle: String?

    var body: some View {
        NavigationStack {
            aislesList
                .displayLoaderOrError(loading: $viewModel.isLoading, error: $viewModel.loadError)
                .navigationTitle("Aisles")
                .addMedicineButton(medicineStockVM: viewModel)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            session.signOut()
                        } label: {
                            Text("Sign out")
                                .font(.caption)
                                .bold()
                        }
                        .accessibilityIdentifier("SignOutButton")
                    }
                }
                .navigationDestination(item: $selectedAisle) { aisle in
                    AisleContentView(viewModel: viewModel, aisle: aisle)
                }
        }
    }
}

// MARK: Aisles list

private extension AisleListView {

    var aislesList: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.aisles, id: \.self) { aisle in
                    Button {
                        selectedAisle = aisle
                    } label: {
                        aisleItem(aisle)
                    }
                    .foregroundStyle(.accent)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .background(alignment: .center) {
            Image("MedicineBoxBackground")
                .resizable()
                .scaledToFill()
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .opacity(colorScheme == .dark ? 0.05 : 0.02)
                .ignoresSafeArea()
        }
    }

    func aisleItem(_ aisle: String) -> some View {
        HStack {
            Image(systemName: "tray.2.fill")
            Text(aisle)
                .fontWeight(.semibold)
                .accessibilityIdentifier("AisleItemName")
            Spacer()
        }
        .padding()
        .background(alignment: .center) {
            Capsule().fill(.mainBackground)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    @Previewable @State var selectedTab: Int = 0
    @Previewable @StateObject var medicineStockVM = MedicineStockViewModel(
//        dbRepo: PreviewDatabaseRepo(listenError: AppError.networkError)
        dbRepo: PreviewDatabaseRepo(listenError: nil)
    )
    TabView(selection: $selectedTab) {
        Tab("Aisles", systemImage: "list.dash", value: 0) {
            AisleListView(viewModel: medicineStockVM)
        }
        Tab("All Medicines", systemImage: "square.grid.2x2", value: 1) {
            EmptyView()
        }
    }
}
