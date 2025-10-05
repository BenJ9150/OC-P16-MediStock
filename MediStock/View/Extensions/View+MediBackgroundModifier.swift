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

    func body(content: Content) -> some View {
        content
            .background(alignment: .center) {
                Color.mainBackground
                    .ignoresSafeArea()
            }
    }
}
