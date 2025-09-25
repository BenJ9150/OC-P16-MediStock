//
//  TextFieldWithTitleView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 18/09/2025.
//

import SwiftUI

struct TextFieldWithTitleView: View {

    let title: String
    @Binding var text: String
    @Binding var error: String?
    @Binding var loading: Bool
    let onCommit: () async -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            TextFieldView(
                title,
                text: $text,
                error: $error,
                loading: $loading
            )
            .submitLabel(.send)
            .onSubmit { Task { await onCommit() } }
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
