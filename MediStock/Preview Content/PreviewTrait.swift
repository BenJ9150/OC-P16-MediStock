//
//  PreviewTrait.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 22/08/2025.
//

import SwiftUI

extension PreviewTrait where T == Preview.ViewTraits {

    static func previewEnvironment() -> Self {
        .modifier(PreviewEnvironment())
    }
}

struct PreviewEnvironment: PreviewModifier {

    @StateObject var medicineStockVM = MedicineStockViewModel(
        dbRepo: PreviewDatabaseRepo(
            listenMedicineError: false,
            listenHistoryError: false,
            updateError: true,
            sendHistoryError: false
        )
    )

    static func makeSharedContext() async throws -> SessionViewModel {
        let authRepo = PreviewAuthRepo(error: AppError.weakPassword)
        return SessionViewModel(authRepo: authRepo)
    }

    func body(content: Content, context: SessionViewModel) -> some View {
        content
            .environmentObject(context)
            .environmentObject(medicineStockVM)
    }
}
