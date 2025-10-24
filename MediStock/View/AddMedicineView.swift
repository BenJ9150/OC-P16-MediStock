//
//  AddMedicineView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 20/09/2025.
//

import SwiftUI

struct AddMedicineView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var session: SessionViewModel
    @ObservedObject var viewModel: MedicineStockViewModel

    @State private var showAddAlert = false
    @FocusState private var aisleIsFocused: Bool
    @FocusState private var stockIsFocused: Bool

    @State private var name = ""
    @State private var aisle = ""
    @State private var stock = 0

    private var showAddButtonAndtextField: Bool {
        !viewModel.sendingHistory && viewModel.newMedicineHistoryError == nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    medicineDetails
                    ErrorView(message: viewModel.addError, color: .primary)
                    addButton
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Add medicine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .mediBackground()
            .alert("Add '\(name)' in '\(aisle)' with \(stock) \(stock < 2 ? "unit" : "units")?", isPresented: $showAddAlert) {
                addButtonAlert
            }
        }
    }
}

// MARK: Medicine details

private extension AddMedicineView {

    var medicineDetails: some View {
        VStack(alignment: .leading, spacing: 24) {
            RetrySendHistoryView(
                error: viewModel.newMedicineHistoryError,
                isLoading: $viewModel.sendingHistory
            ) {
                Task {
                    try await viewModel.sendHistoryAfterError()
                    dismiss()
                }
            }
            if showAddButtonAndtextField {
                textFields
            }
        }
        .roundedBackground()
    }

    var textFields: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Medicine Name
            TextFieldWithTitleView(
                title: "Name",
                text: $name,
                error: $viewModel.nameError,
                label: .next
            ) {
                aisleIsFocused = true
            }
            // Medicine Aisle
            TextFieldWithTitleView(
                title: "Aisle",
                text: $aisle,
                error: $viewModel.aisleError,
                label: .next,
                isFocused: _aisleIsFocused
            ) {
                stockIsFocused = true
            }
            // Medicine Stock
            TextFieldWithTitleView("Stock", value: $stock, isFocused: _stockIsFocused)
                .padding(.bottom, 10)
        }
    }
}

// MARK: Add button

private extension AddMedicineView {

    @ViewBuilder var addButton: some View {
        if showAddButtonAndtextField {
            Button("Add medicine") {
                showAddAlert.toggle()
            }
            .buttonStyle(MediPlainButtonStyle())
            .accessibilityIdentifier("addMedicineButton")
            .buttonLoader(isLoading: $viewModel.addingMedicine)
            .padding(.all, 24)
        }
    }

    var addButtonAlert: some View {
        Button("Add", role: .destructive) {
            if let user = session.session {
                hideKeyboard()
                Task {
                    // dismiss only if adding succeeds
                    try await viewModel.addMedicine(user: user, name: name, aisle: aisle, stock: stock)
                    dismiss()
                }
            }
        }
        .accessibilityIdentifier("addButtonAlert")
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    @Previewable @State var isPresented = true
    @Previewable @StateObject var viewModel = MedicineStockViewModel(
//        dbRepo: PreviewDatabaseRepo(updateError: AppError.networkError, sendHistoryError: AppError.networkError)
        dbRepo: PreviewDatabaseRepo(sendHistoryError: AppError.networkError)
//        dbRepo: PreviewDatabaseRepo(updateError: nil)
    )
    Text("Preview")
        .sheet(isPresented: $isPresented) {
            AddMedicineView(viewModel: viewModel)
        }
}
