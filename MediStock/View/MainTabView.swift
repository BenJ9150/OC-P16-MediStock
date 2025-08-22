import SwiftUI

struct MainTabView: View {

    @StateObject var medicineStockVM: MedicineStockViewModel

    init(dbRepo: DatabaseRepository = FirestoreRepo()) {
        self._medicineStockVM = StateObject(
            wrappedValue: MedicineStockViewModel(dbRepo: dbRepo)
        )
    }

    var body: some View {
        TabView {
            AisleListView(viewModel: medicineStockVM)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Aisles")
                }

            AllMedicinesView(viewModel: medicineStockVM)
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("All Medicines")
                }
        }
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    MainTabView(dbRepo: PreviewDatabaseRepo())
}
