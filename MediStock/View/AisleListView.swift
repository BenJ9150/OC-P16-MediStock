import SwiftUI

struct AisleListView: View {

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: SessionViewModel
    @ObservedObject var viewModel: MedicineStockViewModel
    @State private var selectedAisle: String?
    @State private var showSignOutAlert = false

    var body: some View {
        NavigationStack {
            aislesList
                .displayLoaderOrError(loading: $viewModel.isLoading, error: $viewModel.loadError)
                .mediClearBackground()
                .navigationTitle("Aisles")
                .addMedicineButton(medicineStockVM: viewModel)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showSignOutAlert.toggle()
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
                .alert("Sign out?", isPresented: $showSignOutAlert) {
                    signOutButtonAlert
                }
        }
    }

    private var signOutButtonAlert: some View {
        Button("Sign out", role: .destructive) {
            session.signOut()
        }
        .accessibilityIdentifier("signOutButtonAlert")
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
