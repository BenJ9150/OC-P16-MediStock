//
//  TextFieldView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 19/09/2025.
//

import SwiftUI

struct TextFieldView: View {

    private let prompt: String
    private let isSecure: Bool

    @Binding private var text: String
    @Binding private var error: String?
    @Binding private var loading: Bool

    @FocusState private var isFocused: Bool

    init(
        _ prompt: String,
        text: Binding<String>,
        error: Binding<String?>,
        loading: Binding<Bool> = .constant(false),
        isSecure: Bool = false
    ) {
        self.prompt = prompt
        self._text = text
        self._error = error
        self._loading = loading
        self.isSecure = isSecure
    }

    var body: some View {
        textOrSecureField
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($isFocused)
            .opacity(loading ? 0 : 1)
            .overlay {
                ProgressView()
                    .opacity(loading ? 1 : 0)
            }
            .textFieldError(text: $text, error: $error, isFocused: _isFocused)
            .padding(.horizontal)
    }

    @ViewBuilder private var textOrSecureField: some View {
        if isSecure {
            SecureField(prompt, text: $text)
        } else {
            TextField(prompt, text: $text)
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var email = ""
    @Previewable @State var pwd = "xxxxx"
    @Previewable @State var loading = false
    @Previewable @State var error: String? = nil

    VStack {
        TextFieldView("Email", text: $email, error: $error, loading: $loading)
        TextFieldView("Password", text: $pwd, error: .constant(nil), isSecure: true)

        Button {
            loading.toggle()
        } label: {
            Text("Toggle loading")
        }
        .padding(.top, 100)
        
        Button {
            error = error == nil ? AppError.emptyField.userMessage : nil
        } label: {
            Text("Toggle error")
        }
        .padding(.top)
    }
}

