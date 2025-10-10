//
//  View+AddMedicineButtonModifier.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 10/10/2025.
//

import SwiftUI

extension View {

    func addMedicineButton(medicineStockVM: MedicineStockViewModel) -> some View {
        self.modifier(AddMedicineButtonModifier(medicineStockVM: medicineStockVM))
    }
}

struct AddMedicineButtonModifier: ViewModifier {

    @State private var showAddMedicine = false
    @ObservedObject var medicineStockVM: MedicineStockViewModel

    func body(content: Content) -> some View {
        content
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarSpacer(placement: .topBarTrailing)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add medicine", systemImage: "plus") {
                        showAddMedicine.toggle()
                    }
                    .accessibilityIdentifier("ShowAddMedicineButton")
                }
            }
            .sheet(isPresented: $showAddMedicine) {
                AddMedicineView(viewModel: medicineStockVM)
            }
    }
}
