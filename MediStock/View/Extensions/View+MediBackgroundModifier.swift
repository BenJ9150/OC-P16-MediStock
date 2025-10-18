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

    func body(content: Content) -> some View {
        content
            .background(alignment: .center) {
                ZStack {
                    Color.mainBackground
                    Image("MedicineBackground")
                        .resizable()
                        .scaledToFill()
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                        .opacity(colorScheme == .dark ? 0.04 : 0.1)
                }
                .ignoresSafeArea()
                .accessibilityHidden(true)
            }
    }
}

struct MediClearBackgroundModifier: ViewModifier {

    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(alignment: .center) {
                Image("MedicineBoxBackground")
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .opacity(colorScheme == .dark ? 0.05 : 0.02)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            }
    }
}
