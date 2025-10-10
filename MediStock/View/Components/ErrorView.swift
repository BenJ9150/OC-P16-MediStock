//
//  ErrorView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 19/09/2025.
//

import SwiftUI

struct ErrorView: View {

    private let message: String?
    private let color: Color

    init(message: String?, color: Color = .red) {
        self.message = message
        self.color = color
    }

    @ViewBuilder var body: some View {
        if let error = message {
            Text(error)
                .font(.headline)
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        }
    }
}

// MARK: - Preview

#Preview {
    ErrorView(message: AppError.weakPassword.userMessage)
}
