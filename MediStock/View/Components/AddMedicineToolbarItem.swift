//
//  AddMedicineToolbarItem.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 26/09/2025.
//

import SwiftUI

struct AddMedicineToolbarItem: ToolbarContent {

    @Binding var showAddView: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showAddView.toggle()
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityIdentifier("ShowAddMedicineButton")
        }
    }
}
