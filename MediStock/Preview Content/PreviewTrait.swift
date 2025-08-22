//
//  PreviewTrait.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 22/08/2025.
//

import SwiftUI

@available(iOS 18.0, *)
extension PreviewTrait where T == Preview.ViewTraits {

    static func previewEnvironment() -> Self {
        .modifier(PreviewEnvironment())
    }
}

struct PreviewEnvironment: PreviewModifier {

    static func makeSharedContext() async throws -> SessionViewModel {
        let authRepo = PreviewAuthRepo()
        return SessionViewModel(authRepo: authRepo)
    }

    func body(content: Content, context: SessionViewModel) -> some View {
        content.environmentObject(context)
    }
}
