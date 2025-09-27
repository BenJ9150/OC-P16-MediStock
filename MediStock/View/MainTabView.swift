import SwiftUI

struct MainTabView: View {

    @StateObject var medicineStockVM: MedicineStockViewModel
    @State private var selectedTab: Int = 0

    init() {
        self._medicineStockVM = StateObject(
            wrappedValue: MedicineStockViewModel(dbRepo: RepoSettings().getDbRepo())
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            AisleListView(viewModel: medicineStockVM)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Aisles")
                }
                .tag(0)

            AllMedicinesView(viewModel: medicineStockVM)
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("All Medicines")
                }
                .tag(1)
        }
        .onChange(of: selectedTab) {
            if selectedTab == 0 {
                // Clean AllMedicinesView filter to have all aisles
                if !medicineStockVM.medicineFilter.isEmpty {
                    medicineStockVM.medicineFilter.removeAll()
                }
            }
        }
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    MainTabView()
}
