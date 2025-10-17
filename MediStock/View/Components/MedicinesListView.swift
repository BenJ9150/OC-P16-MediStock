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

    @Environment(\.dynamicTypeSize) var dynamicSize
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
                    Color
                        .clear
                        .accessibilityHidden(true)
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
}

// MARK: Item

private extension MedicinesListView {

    @ViewBuilder func medicineItem(_ medicine: Medicine) -> some View {
        if dynamicSize.isAccessibilitySize {
            VStack(alignment: .leading) {
                medicineName(medicine.name)
                medicineStock(medicine.stock)
            }
        } else {
            HStack {
                medicineName(medicine.name)
                Spacer()
                medicineStock(medicine.stock)
            }
        }
    }

    func medicineName(_ name: String) -> some View {
        Text(name)
            .font(.callout)
            .fontWeight(.semibold)
            .accessibilityIdentifier("MedicineItemName")
            .foregroundStyle(.accent)
    }

    func medicineStock(_ stock: Int) -> some View {
        HStack {
            Text("\(stock)")
                .font(.subheadline)
                .bold()
                .foregroundStyle(.accent)
                .accessibilityIdentifier("MedicineItemStock")
                .frame(minWidth: 16)
                .accessibilityLabel("\(stock) \(stock > 1 ? "units" : "unit")")
            
            Image(systemName: "pill.fill")
                .foregroundStyle(stockColor(for: stock))
                .accessibilityHidden(true)
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
        MedicinesListView(PreviewDatabase.medicines)
            .mediBackground()
    }
}
