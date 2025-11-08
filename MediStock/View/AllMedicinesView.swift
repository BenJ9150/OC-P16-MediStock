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
                .navigationTitle("Medicines")
                .addMedicineButton(fromView: .medicineList)
                .toolbar {
                    ToolbarItem(id: "ToolbarItemAllMedicineMenu", placement: .topBarTrailing) {
                        Menu {
                            Picker("Sort by", selection: $viewModel.medicineSort) {
                                Text("None").tag(MedicineSort.none)
                                Text("Name").tag(MedicineSort.name)
                                Text("Stock").tag(MedicineSort.stock)
                            }
                        } label: {
                            Image(systemName: "arrow.up.and.down.text.horizontal")
                                .font(.footnote)
                        }
                        .accessibilityIdentifier("SortByPicker")
                        .accessibilityLabel("Sort by")
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
        Tab("Aisles", systemImage: "list.dash", value: 0) {
            EmptyView()
        }
        Tab("All Medicines", systemImage: "square.grid.2x2", value: 1) {
            AllMedicinesView()
        }
    }
}
