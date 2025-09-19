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
    @Binding var loading: Bool
    let onCommit: () async -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)

            TextField("Name", text: $text, onCommit: {
                Task { await onCommit() }
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .submitLabel(.send)
            .opacity(loading ? 0 : 1)
            .overlay {
                ProgressView()
                    .opacity(loading ? 1 : 0)
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var loading = false
    VStack {
        TextFieldWithTitleView(title: "My title", text: .constant(""), loading: $loading) {}
        Button {
            loading.toggle()
        } label: {
            Text("Toggle loading")
        }
        .padding(.top, 100)
    }
}
