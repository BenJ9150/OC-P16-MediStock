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

    @State private var errIsPresented = false

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
        VStack(spacing: 5) {
            textOrSecureField
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .opacity(loading ? 0 : 1)
                .overlay {
                    ProgressView()
                        .opacity(loading ? 1 : 0)
                }
            
            if let textFieldError = error {
                Text("* \(textFieldError)")
                    .foregroundColor(.red)
                    .font(.caption)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .offset(y: errIsPresented ? 0 : -10)
                    .onAppear {
                        withAnimation(.spring(bounce: 0.3)) {
                            errIsPresented = true
                        }
                    }
                    .onDisappear {
                        errIsPresented = false
                    }
            }
        }
        .padding(.horizontal)
        .dynamicTypeSize(.xSmall ... .accessibility2)
        .onChange(of: text) {
            if error != nil {
                error = nil
            }
        }
    }

    @ViewBuilder private var textOrSecureField: some View {
        if isSecure {
            SecureField(prompt, text: $text)
        } else {
            TextField(prompt, text: $text)
        }
    }
}

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

