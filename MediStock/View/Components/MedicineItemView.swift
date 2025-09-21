//
//  MedicineItemView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 18/09/2025.
//

import SwiftUI

struct MedicineItemView: View {

    let medicine: Medicine

    var body: some View {
        VStack(alignment: .leading) {
            Text(medicine.name)
                .font(.headline)
            Text("Stock: \(medicine.stock)")
                .font(.subheadline)
        }
    }
}

// MARK: - Preview

#Preview {
    MedicineItemView(medicine: PreviewDatabaseRepo().medicine())
}
