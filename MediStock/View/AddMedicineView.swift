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

    var body: some View {
        VStack {
            Spacer()
            
            ErrorView(message: viewModel.addError)
            Button("Add medicine") {
                if let userId = session.session?.uid {
                    Task {
                        await viewModel.addRandomMedicine(userId: userId) {
                            dismiss()
                        }
                    }
                }
            }
            .buttonStyle(MediPlainButtonStyle())
            .accessibilityIdentifier("AddMedicineButton")
            .buttonLoader(isLoading: $viewModel.addingMedicine)
            .padding()
        }
        .padding()
        .navigationTitle("Add medicine")
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    @Previewable @StateObject var viewModel = MedicineStockViewModel(
        dbRepo: PreviewDatabaseRepo(updateError: AppError.networkError)
//        dbRepo: PreviewDatabaseRepo(updateError: nil)
    )
    NavigationStack {
        AddMedicineView(viewModel: viewModel)
    }
}
