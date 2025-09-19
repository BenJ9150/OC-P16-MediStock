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
            .padding(.bottom, 10)
        }
        .padding(.horizontal)
    }
}

#Preview {
    TextFieldWithTitleView(title: "My title", text: .constant("")) {}
}
