//
//  View+HideKeyboard.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 03/10/2025.
//

import SwiftUI

extension View {

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
