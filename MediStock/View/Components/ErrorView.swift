//
//  ErrorView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 19/09/2025.
//

import SwiftUI

struct ErrorView: View {

    @Environment(\.colorScheme) var colorScheme

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
                .brightness(colorScheme == .dark || color != .red ? 0 : -0.1) // for contrast
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(color == .red ? Color.clear : Color.mainBackground)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        ErrorView(message: AppError.weakPassword.userMessage)
        ErrorView(message: AppError.weakPassword.userMessage, color: .primary)
    }
}
