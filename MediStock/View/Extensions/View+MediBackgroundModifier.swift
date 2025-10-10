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
            }
    }
}
