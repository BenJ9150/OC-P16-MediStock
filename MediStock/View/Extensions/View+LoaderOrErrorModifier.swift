//
//  View+LoaderOrErrorModifier.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 20/09/2025.
//

import SwiftUI

extension View {

    func displayLoaderOrError(
        loading: Binding<Bool>,
        error: Binding<String?>
    ) -> some View {
        self.modifier(LoaderOrErrorViewModifier(loading: loading, error: error))
    }
}

struct LoaderOrErrorViewModifier: ViewModifier {
    
    @Binding var loading: Bool
    @Binding var error: String?

    func body(content: Content) -> some View {
        if loading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let loadError = error {
            ErrorView(message: loadError, color: .primary)
                .padding(.horizontal, 50)
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
    
    Text("Preview")
        .displayLoaderOrError(loading: $viewModel.isLoading, error: $viewModel.loadError)
        .mediBackground()
}
