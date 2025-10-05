//
//  View+RoundedBackgroundModifier.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 05/10/2025.
//

import SwiftUI

extension View {

    func roundedBackground() -> some View {
        self.modifier(RoundedBackgroundModifier())
    }
}

struct RoundedBackgroundModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .padding(.all, 24)
            .background(
                Color(uiColor: .systemBackground),
                in: RoundedRectangle(cornerRadius: 24)
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
    }
}
