import SwiftUI

struct AisleContentView: View {

    @ObservedObject var viewModel: MedicineStockViewModel
    @State private var showHistory: Bool = false

    var aisle: String

    var body: some View {
        MedicinesListView(viewModel.medicines.filter { $0.aisle == aisle })
            .mediBackground()
            .navigationTitle(aisle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Aisle history", systemImage: "list.clipboard.fill") {
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

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    @Previewable @StateObject var viewModel = MedicineStockViewModel(dbRepo: PreviewDatabaseRepo())
    NavigationStack {
        AisleContentView(viewModel: viewModel, aisle: "Aisle 1")
    }
}
