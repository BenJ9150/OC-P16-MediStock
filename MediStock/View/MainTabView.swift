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
            Tab("Aisles", systemImage: "list.dash", value: 0) {
                AisleListView(viewModel: medicineStockVM)
            }
            Tab("All Medicines", systemImage: "square.grid.2x2", value: 1) {
                AllMedicinesView(viewModel: medicineStockVM)
            }
        }
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

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    MainTabView()
}
