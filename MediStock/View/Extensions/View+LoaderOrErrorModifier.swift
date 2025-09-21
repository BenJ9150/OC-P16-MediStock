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
        error: Binding<String?>,
        background: Color = Color(uiColor: .systemGroupedBackground)
    ) -> some View {
        self.modifier(LoaderOrErrorViewModifier(loading: loading, error: error, background: background))
    }
}

struct LoaderOrErrorViewModifier: ViewModifier {
    
    @Binding var loading: Bool
    @Binding var error: String?
    let background: Color

    func body(content: Content) -> some View {
        if loading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(background)
        } else if let loadError = error {
            ErrorView(message: loadError)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(background)
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
        .displayLoaderOrError(loading: $viewModel.isLoading, error: $viewModel.loadError)
}
