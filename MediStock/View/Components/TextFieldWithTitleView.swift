//
//  TextFieldWithTitleView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 18/09/2025.
//

import SwiftUI

struct TextFieldWithTitleView: View {

    private let isForValue: Bool
    private let title: String
    private let submitLabel: SubmitLabel
    private let onSubmit: () -> Void
    
    @Binding var text: String
    @Binding var value: Int
    @Binding var error: String?
    @Binding var loading: Bool
    @FocusState var isFocused: Bool

    // MARK: Init for text

    init(
        title: String,
        text: Binding<String>,
        error: Binding<String?>,
        label: SubmitLabel = .send,
        loading: Binding<Bool> = .constant(false),
        isFocused: FocusState<Bool> = .init(),
        onSubmit: @escaping () -> Void
    ) {
        self.isForValue = false
        self.title = title
        self._text = text
        self._value = .constant(0)
        self._error = error
        self.submitLabel = label
        self._loading = loading
        self._isFocused = isFocused
        self.onSubmit = onSubmit
    }

    // MARK: Init for value

    init(_ title: String, value: Binding<Int>, isFocused: FocusState<Bool>) {
        self.isForValue = true
        self.title = title
        self._text = .constant("")
        self._value = value
        self._error = .constant("")
        self.submitLabel = .done
        self._loading = .constant(false)
        self._isFocused = isFocused
        self.onSubmit = {}
    }

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)

            fieldForTextOrValue
                .focused($isFocused)
        }
    }

    @ViewBuilder private var fieldForTextOrValue: some View {
        if isForValue {
            TextField(title, value: $value, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 100)
        } else {
            TextFieldView(
                title,
                text: $text,
                error: $error,
                label: submitLabel,
                loading: $loading
            )
            .onSubmit { onSubmit() }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var error: String? = AppError.networkError.userMessage
    @Previewable @State var loading = false
    VStack {
        TextFieldWithTitleView(title: "My title", text: .constant(""), error: $error, loading: $loading) {}
        Button {
            loading.toggle()
        } label: {
            Text("Toggle loading")
        }
        .padding(.top, 100)
    }
}
