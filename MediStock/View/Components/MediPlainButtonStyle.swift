//
//  MediPlainButtonStyle.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 03/10/2025.
//

import SwiftUI

struct MediPlainButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
            .background(.plainButton, in: RoundedRectangle(cornerRadius: 16))
            .foregroundStyle(.white)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
