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
    @EnvironmentObject var viewModel: MedicineStockViewModel

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
            .navigationTitle(.addMedicine)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(id: "ToolbarItemAddMedicineClose", placement: .topBarTrailing) {
                    Button(.close, systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .mediBackground()
            .alert(.addInWithUnit(name, aisle, stock), isPresented: $showAddAlert) {
                addButtonAlert
            }
            .onAppear {
                // Clean old errors
                viewModel.nameError = nil
                viewModel.aisleError = nil
                viewModel.addError = nil
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
                title: .name,
                text: $name,
                error: $viewModel.nameError,
                label: .next
            ) {
                aisleIsFocused = true
            }
            // Medicine Aisle
            TextFieldWithTitleView(
                title: .aisle,
                text: $aisle,
                error: $viewModel.aisleError,
                label: .next,
                isFocused: _aisleIsFocused
            ) {
                stockIsFocused = true
            }
            // Medicine Stock
            TextFieldWithTitleView(.stock, value: $stock, isFocused: _stockIsFocused)
                .padding(.bottom, 10)
        }
    }
}

// MARK: Add button

private extension AddMedicineView {

    @ViewBuilder var addButton: some View {
        if showAddButtonAndtextField {
            Button(.addMedicine) {
                hideKeyboard()
                showAddAlert.toggle()
            }
            .buttonStyle(MediPlainButtonStyle())
            .accessibilityIdentifier("addMedicineButton")
            .buttonLoader(isLoading: $viewModel.addingMedicine)
            .padding(.all, 24)
        }
    }

    var addButtonAlert: some View {
        Button(.add, role: .destructive) {
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

#Preview(traits: .previewEnvironment()) {
    @Previewable @State var isPresented = true

    Text("Preview")
        .sheet(isPresented: $isPresented) {
            AddMedicineView()
        }
}
