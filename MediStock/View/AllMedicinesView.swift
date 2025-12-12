import SwiftUI

struct AllMedicinesView: View {

    @EnvironmentObject var session: SessionViewModel
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @State private var showAddMedicine: Bool = false

    var body: some View {
        NavigationStack {
            MedicinesListView(viewModel.medicines)
                .displayLoaderOrError(loading: $viewModel.isLoading, error: $viewModel.loadError)
                .mediBackground()
                .navigationTitle(.medicines)
                .addMedicineButton(fromView: .medicineList)
                .toolbar {
                    ToolbarItem(id: "ToolbarItemAllMedicineMenu", placement: .topBarTrailing) {
                        Menu {
                            Picker(.sortBy, selection: $viewModel.medicineSort) {
                                Text(.none)
                                    .tag(MedicineSort.none)
                                    .accessibilityIdentifier("MedicineSort_none")
                                Text(.name)
                                    .tag(MedicineSort.name)
                                    .accessibilityIdentifier("MedicineSort_name")
                                Text(.stock)
                                    .tag(MedicineSort.stock)
                                    .accessibilityIdentifier("MedicineSort_stock")
                            }
                        } label: {
                            Image(systemName: "arrow.up.and.down.text.horizontal")
                                .font(.footnote)
                        }
                        .accessibilityIdentifier("SortByPicker")
                        .accessibilityLabel(.sortBy)
                    }
                }
                .navigationDestination(isPresented: $showAddMedicine) {
                    AddMedicineView()
                }
                .searchable(text: $viewModel.medicineFilter)
                .submitLabel(.search)
                .onSubmit(of: .search) {
                    viewModel.listenMedicines()
                }
                .onChange(of: viewModel.medicineFilter) { oldValue, newValue in
                    if !oldValue.isEmpty && newValue.isEmpty {
                        viewModel.listenMedicines() // to clean search
                    }
                }
        }
    }
}

// MARK: - Preview

#Preview(traits: .previewEnvironment()) {
    @Previewable @State var selectedTab: Int = 1

    TabView(selection: $selectedTab) {
        Tab(String(localized: .aisles), systemImage: "list.dash", value: 0) {
            EmptyView()
        }
        Tab(String(localized: .allMedicines), systemImage: "square.grid.2x2", value: 1) {
            AllMedicinesView()
        }
    }
}
