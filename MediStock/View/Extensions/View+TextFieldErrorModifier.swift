//
//  View+TextFieldErrorModifier.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 21/09/2025.
//

import SwiftUI

extension View {

    func textFieldError(text: Binding<String>, error: Binding<String?>, isFocused: FocusState<Bool>) -> some View {
        self.modifier(TextFieldErrorViewModifier(text: text, error: error, isFocused: isFocused))
    }

    func textFieldError(value: Binding<Int>, error: Binding<String?>, isFocused: FocusState<Bool>) -> some View {
        self.modifier(TextFieldErrorViewModifier(value: value, error: error, isFocused: isFocused))
    }
}

struct TextFieldErrorViewModifier: ViewModifier {

    @Environment(\.colorScheme) var colorScheme
    private let isValue: Bool

    @Binding var text: String
    @Binding var value: Int
    @Binding var error: String?
    @FocusState var isFocused: Bool

    init(text: Binding<String>, error: Binding<String?>, isFocused: FocusState<Bool>) {
        self._text = text
        self._value = .constant(0)
        self._error = error
        self._isFocused = isFocused
        self.isValue = false
    }

    init(value: Binding<Int>, error: Binding<String?>, isFocused: FocusState<Bool>) {
        self._text = .constant("")
        self._value = value
        self._error = error
        self._isFocused = isFocused
        self.isValue = true
    }

    func body(content: Content) -> some View {
        VStack(spacing: 5) {
            content
            
            if let textFieldError = error {
                Text("* \(textFieldError)")
                    .foregroundStyle(.red)
                    .brightness(colorScheme == .dark ? 0 : -0.1) // for contrast
                    .font(.caption)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.2), value: error)
        .onChange(of: text) {
            cleanError()
        }
        .onChange(of: value) {
            cleanError()
        }
    }

    private func cleanError() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if isFocused, error != nil {
                error = nil
            }
        }
    }
}
