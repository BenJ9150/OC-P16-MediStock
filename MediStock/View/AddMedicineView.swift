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
            Button("Add a medicine") {
                if let userId = session.session?.uid {
                    Task {
                        await viewModel.addRandomMedicine(userId: userId) {
                            dismiss()
                        }
                    }
                }
            }
            .accessibilityIdentifier("AddMedicineButton")
            .opacity(viewModel.addingMedicine ? 0 : 1)
            .overlay {
                ProgressView()
                    .opacity(viewModel.addingMedicine ? 1 : 0)
            }
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
        dbRepo: PreviewDatabaseRepo(stockError: AppError.networkError)
    )
//    @Previewable @StateObject var viewModel = MedicineStockViewModel(dbRepo: PreviewDatabaseRepo())

    NavigationStack {
        AddMedicineView(viewModel: viewModel)
    }
}
