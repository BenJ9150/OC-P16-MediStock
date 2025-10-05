//
//  MedicinesListView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 20/09/2025.
//

import SwiftUI

struct MedicinesListView: View {

    private struct MedicineItem {
        let id: String
        let medicine: Medicine
    }

    @EnvironmentObject var session: SessionViewModel
    private let medicines: [MedicineItem]
    private let maxStock: Int

    init(_ medicines: [Medicine]) {
        self.medicines = medicines.compactMap { medicine in
            guard let id = medicine.id else { return nil }
            return MedicineItem(id: id, medicine: medicine)
        }
        self.maxStock = medicines.map(\.stock).max() ?? 0
    }

    var body: some View {
        if let userId = session.session?.uid {
            List {
                Section {
                    ForEach(medicines, id: \.id) { item in
                        NavigationLink {
                            MedicineDetailView(for: item.medicine, id: item.id, userId: userId)
                        } label: {
                            medicineItem(item.medicine)
                        }
                    }
                } header: {
                    Color.clear
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
}

// MARK: Item

private extension MedicinesListView {

    func medicineItem(_ medicine: Medicine) -> some View {
        HStack {
            Text(medicine.name)
                .accessibilityIdentifier("MedicineItemName")
                .foregroundStyle(.accent)
            Spacer()

            Text("\(medicine.stock)")
                .font(.subheadline)
                .bold()
                .foregroundStyle(.accent)
                .accessibilityIdentifier("MedicineItemStock")
                .frame(minWidth: 16)
            
            Image(systemName: "pill.fill")
                .foregroundStyle(stockColor(for: medicine.stock))
        }
    }

    func stockColor(for stock: Int) -> Color {
        guard maxStock > 0 else { return .gray }
        let ratio = Double(stock) / Double(maxStock)
        
        switch ratio {
        case 0..<0.33: return .red
        case 0.33..<0.66: return .orange
        default: return .green
        }
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    NavigationStack {
        MedicinesListView(PreviewDatabaseRepo().medicines!)
            .mediBackground()
    }
}
