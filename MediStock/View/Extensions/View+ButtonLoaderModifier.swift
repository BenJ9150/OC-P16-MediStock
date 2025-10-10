//
//  View+ButtonLoaderModifier.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 05/10/2025.
//

import SwiftUI

extension View {

    func buttonLoader(isLoading: Binding<Bool>) -> some View {
        self.modifier(ButtonLoaderModifier(isLoading: isLoading))
    }
}

struct ButtonLoaderModifier: ViewModifier {

    @Binding var isLoading: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isLoading ? 0 : 1)
            .overlay {
                ProgressView()
                    .opacity(isLoading ? 1 : 0)
            }
    }
}
