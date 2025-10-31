//
//  View+AccessibilityFocus.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 31/10/2025.
//

import SwiftUI

extension View {

    func accessibilityFocusOnAppear() -> some View {
        self.modifier(AccessibilityFocusOnAppearModifier())
    }
}

struct AccessibilityFocusOnAppearModifier: ViewModifier {
    @AccessibilityFocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .accessibilityFocused($isFocused)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocused = true
                }
            }
    }
}
