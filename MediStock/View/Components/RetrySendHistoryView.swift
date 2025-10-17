//
//  RetrySendHistoryView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 10/10/2025.
//

import SwiftUI

struct RetrySendHistoryView: View {

    private let historyError: SendHistoryError?
    @Binding private var isLoading: Bool
    private let action: () -> Void

    init(error: SendHistoryError?, isLoading: Binding<Bool> = .constant(false), action: @escaping () -> Void) {
        self.historyError = error
        self._isLoading = isLoading
        self.action = action
    }

    var body: some View {
        if isLoading || historyError != nil {
            VStack {
                ErrorView(message: historyError?.error)
                Button("RETRY") {
                    action()
                }
                .accessibilityIdentifier("RetrySendHistoryButton")
                .buttonStyle(MediPlainButtonStyle())
                .buttonLoader(isLoading: $isLoading)
                .padding(.horizontal, 48)
                .padding(.bottom)
            }
        }
    }
}

#Preview {
    let error = SendHistoryError(error: AppError.networkError.sendHistoryErrorMessage, action: "", details: "")
    RetrySendHistoryView(error: error, action: {})
}
