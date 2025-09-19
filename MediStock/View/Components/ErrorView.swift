//
//  ErrorView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 19/09/2025.
//

import SwiftUI

struct ErrorView: View {

    let message: String?
    @State private var isPresented: Bool = false

    @ViewBuilder var body: some View {
        if let error = message {
            Text(error)
                .font(.headline)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
}

#Preview {
    ErrorView(message: AppError.weakPassword.userMessage)
}
