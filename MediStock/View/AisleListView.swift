import SwiftUI

struct AisleListView: View {

    @EnvironmentObject var session: SessionViewModel
    @EnvironmentObject var viewModel: MedicineStockViewModel

    @State private var selectedAisle: String?
    @State private var showAccountView = false

    var body: some View {
        NavigationStack {
            aislesList
                .displayLoaderOrError(loading: $viewModel.isLoading, error: $viewModel.loadError)
                .mediClearBackground()
                .navigationTitle(.aisles)
                .addMedicineButton(fromView: .aisleList)
                .toolbar {
                    ToolbarItem(id: "ToolbarItemShowAccount", placement: .topBarLeading) {
                        Button(.account, systemImage: "person.fill") {
                            showAccountView.toggle()
                        }
                        .accessibilityIdentifier("ShowAccountButton")
                    }
                }
                .navigationDestination(item: $selectedAisle) { aisle in
                    AisleContentView(aisle: aisle)
                }
                .navigationDestination(isPresented: $showAccountView) {
                    AccountView()
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

#Preview(traits: .previewEnvironment()) {
    @Previewable @State var selectedTab: Int = 0

    TabView(selection: $selectedTab) {
        Tab(String(localized: .aisles), systemImage: "list.dash", value: 0) {
            AisleListView()
        }
        Tab(String(localized: .allMedicines), systemImage: "square.grid.2x2", value: 1) {
            EmptyView()
        }
    }
}
