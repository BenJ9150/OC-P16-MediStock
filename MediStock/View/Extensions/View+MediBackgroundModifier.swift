//
//  View+MediBackgroundModifier.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 03/10/2025.
//

import SwiftUI

extension View {

    func mediBackground() -> some View {
        self.modifier(MediBackgroundModifier())
    }

    func mediClearBackground() -> some View {
        self.modifier(MediClearBackgroundModifier())
    }
}

struct MediBackgroundModifier: ViewModifier {

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    Color.mainBackground
                    Image("MedicineBackground")
                        .resizable()
                        .scaledToFill()
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                        .opacity(reduceTransparency ? 0 : colorScheme == .dark ? 0.04 : 0.1)
                }
                .ignoresSafeArea()
                .accessibilityHidden(true)
            }
    }
}

struct MediClearBackgroundModifier: ViewModifier {

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    func body(content: Content) -> some View {
        content
            .background {
                Image("MedicineBoxBackground")
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .opacity(reduceTransparency ? 0 : colorScheme == .dark ? 0.05 : 0.02)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            }
    }
}
