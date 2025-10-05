import SwiftUI

struct AisleContentView: View {

    @ObservedObject var viewModel: MedicineStockViewModel

    var aisle: String

    var body: some View {
        MedicinesListView(viewModel.medicines.filter { $0.aisle == aisle })
            .mediBackground()
            .navigationTitle(aisle)
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    @Previewable @StateObject var viewModel = MedicineStockViewModel(dbRepo: PreviewDatabaseRepo())
    NavigationStack {
        AisleContentView(viewModel: viewModel, aisle: "Aisle 1")
    }
}
