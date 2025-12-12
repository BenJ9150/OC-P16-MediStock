//
//  View+AddMedicineButtonModifier.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 10/10/2025.
//

import SwiftUI

extension View {

    func addMedicineButton(fromView: AddMedicineButtonModifier.FromView) -> some View {
        self.modifier(AddMedicineButtonModifier(fromView: fromView))
    }
}

struct AddMedicineButtonModifier: ViewModifier {

    @EnvironmentObject var medicineStockVM: MedicineStockViewModel
    @State private var showAddMedicine = false

    internal enum FromView: String {
        case medicineList
        case aisleList
    }

    let fromView: FromView

    func body(content: Content) -> some View {
        content
            .toolbar {
                if #available(iOS 26.0, *), fromView == .medicineList {
                    ToolbarSpacer(placement: .topBarTrailing)
                }
                ToolbarItem(id: "ToolbarItemAddMedicine\(fromView.rawValue)", placement: .topBarTrailing) {
                    Button(.addMedicine, systemImage: "plus") {
                        showAddMedicine.toggle()
                    }
                    .accessibilityIdentifier("ShowAddMedicineButton")
                }
            }
            .sheet(isPresented: $showAddMedicine) {
                AddMedicineView()
            }
    }
}
