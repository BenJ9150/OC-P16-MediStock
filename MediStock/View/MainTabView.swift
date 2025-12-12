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
            Tab(String(localized: .aisles), systemImage: "list.dash", value: 0) {
                AisleListView()
            }
            .accessibilityIdentifier("aislesTab")
            Tab(String(localized: .allMedicines), systemImage: "square.grid.2x2", value: 1) {
                AllMedicinesView()
            }
            .accessibilityIdentifier("allMedicinesTab")
        }
        .environmentObject(medicineStockVM)
        .minimizeTabBar()
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

#Preview(traits: .previewEnvironment()) {
    MainTabView()
}
