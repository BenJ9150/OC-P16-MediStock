import SwiftUI

struct AisleContentView: View {

    @EnvironmentObject var viewModel: MedicineStockViewModel
    @State private var showHistory: Bool = false

    var aisle: String

    var body: some View {
        MedicinesListView(viewModel.medicines.filter { $0.aisle == aisle })
            .mediBackground()
            .navigationTitle(aisle)
            .toolbar {
                ToolbarItem(id: "ToolbarItemAisleHistory", placement: .topBarTrailing) {
                    Button(.aisleHistory, systemImage: "list.clipboard.fill") {
                        showHistory.toggle()
                    }
                    .accessibilityIdentifier("aisleHistoryButton")
                }
            }
            .sheet(isPresented: $showHistory) {
                AisleHistoryView(for: aisle)
            }
    }
}

// MARK: - Preview

#Preview(traits: .previewEnvironment()) {
    NavigationStack {
        AisleContentView(aisle: "Aisle 1")
    }
}
