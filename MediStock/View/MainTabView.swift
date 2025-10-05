import SwiftUI

struct MainTabView: View {

    @StateObject var medicineStockVM: MedicineStockViewModel

    @State private var selectedTab: Int = 0
    @State private var showAddMedicine = false

    init() {
        self._medicineStockVM = StateObject(
            wrappedValue: MedicineStockViewModel(dbRepo: RepoSettings().getDbRepo())
        )
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            mediTabView
                .tabBarMinimizeBehavior(.onScrollDown)
                .tabViewBottomAccessory {
                    Button("Add medicine") {
                        showAddMedicine.toggle()
                    }
                    .accessibilityIdentifier("ShowAddMedicineButton")
                }
        } else {
            mediTabView
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        showAddMedicine.toggle()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.plainButton)
                                .frame(width: 56, height: 56)
                            Image(systemName: "plus")
                                .bold()
                                .foregroundStyle(.white)
                        }
                    }
                    .padding()
                    .padding(.bottom, 56)
                    .accessibilityIdentifier("ShowAddMedicineButton")
                }
        }
    }

    private var mediTabView: some View {
        TabView(selection: $selectedTab) {
            Tab("Aisles", systemImage: "list.dash", value: 0) {
                AisleListView(viewModel: medicineStockVM)
            }
            Tab("All Medicines", systemImage: "square.grid.2x2", value: 1) {
                AllMedicinesView(viewModel: medicineStockVM)
            }
        }
        .onChange(of: selectedTab) {
            if selectedTab == 0 {
                // Clean AllMedicinesView filter to have all aisles
                if !medicineStockVM.medicineFilter.isEmpty {
                    medicineStockVM.medicineFilter.removeAll()
                }
            }
        }
        .sheet(isPresented: $showAddMedicine) {
            AddMedicineView(viewModel: medicineStockVM)
        }
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    MainTabView()
}
