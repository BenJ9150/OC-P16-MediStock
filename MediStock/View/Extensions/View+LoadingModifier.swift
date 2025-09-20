//
//  View+LoadingModifier.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 20/09/2025.
//

import SwiftUI

extension View {

    func loadingViewModifier(loading: Binding<Bool>, error: Binding<String?>) -> some View {
        self.modifier(LoadingViewModifier(loading: loading, error: error))
    }
}

struct LoadingViewModifier: ViewModifier {
    
    @Binding var loading: Bool
    @Binding var error: String?

    func body(content: Content) -> some View {
        if loading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
        } else if let loadError = error {
            ErrorView(message: loadError)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
        } else {
            content
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @StateObject var viewModel = MedicineStockViewModel(
        dbRepo: PreviewDatabaseRepo(listenError: AppError.networkError)
    )
//    @Previewable @StateObject var viewModel = MedicineStockViewModel(dbRepo: PreviewDatabaseRepo())
    
    Text("Preview")
        .loadingViewModifier(loading: $viewModel.isLoading, error: $viewModel.loadError)
}
