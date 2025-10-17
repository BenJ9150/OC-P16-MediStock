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

    @Environment(\.dynamicTypeSize) var dynamicSize

    func body(content: Content) -> some View {
        content
            .padding(.all, dynamicSize.isAccessibilitySize ? 8 : 24)
            .background(
                Color(uiColor: .systemBackground),
                in: RoundedRectangle(cornerRadius: dynamicSize.isAccessibilitySize ? 16 : 24)
            )
            .padding(.horizontal, dynamicSize.isAccessibilitySize ? 8 : 24)
            .padding(.vertical, 12)
    }
}
