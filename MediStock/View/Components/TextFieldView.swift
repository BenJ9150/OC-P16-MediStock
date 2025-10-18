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
    private let submitLabel: SubmitLabel

    @Binding private var text: String
    @Binding private var error: String?
    @Binding private var loading: Bool

    @FocusState private var isFocused: Bool

    init(
        _ prompt: String,
        text: Binding<String>,
        error: Binding<String?>,
        label: SubmitLabel,
        loading: Binding<Bool> = .constant(false),
        isSecure: Bool = false
    ) {
        self.prompt = prompt
        self._text = text
        self._error = error
        self.submitLabel = label
        self._loading = loading
        self.isSecure = isSecure
    }

    var body: some View {
        textOrSecureField
            .font(.footnote)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($isFocused)
            .submitLabel(submitLabel)
            .buttonLoader(isLoading: $loading)
            .textFieldError(text: $text, error: $error, isFocused: _isFocused)
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
        TextFieldView("Email", text: $email, error: $error, label: .next, loading: $loading)
        TextFieldView("Password", text: $pwd, error: .constant(nil), label: .done, isSecure: true)

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
    .padding(.horizontal, 48)
}

