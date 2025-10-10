//
//  View+MinimizeTabBarModifier.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 10/10/2025.
//

import SwiftUI

extension View {

    @ViewBuilder func minimizeTabBar() -> some View {
        if #available(iOS 26.0, *) {
            self.modifier(MinimizeTabBarModifier())
        } else {
            self
        }
    }
}

@available(iOS 26.0, *)
struct MinimizeTabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .tabBarMinimizeBehavior(.onScrollDown)
    }
}
