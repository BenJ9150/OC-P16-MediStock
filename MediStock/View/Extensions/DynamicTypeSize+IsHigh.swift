//
//  DynamicTypeSize+IsHigh.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 24/10/2025.
//

import SwiftUI

extension DynamicTypeSize {

    var isHigh: Bool {
        self == .xxLarge || self == .xxxLarge || self.isAccessibilitySize
    }
}
