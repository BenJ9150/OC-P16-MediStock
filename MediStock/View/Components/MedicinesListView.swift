//
//  MedicinesListView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 20/09/2025.
//

import SwiftUI

struct MedicinesListView: View {

    @EnvironmentObject var session: SessionViewModel
    let list: [Medicine]

    init(_ medicines: [Medicine]) {
        self.list = medicines
    }

    private var medicines: [(medicine: Medicine, id: String)] {
        list.compactMap { medicine in
            guard let id = medicine.id else { return nil }
            return (medicine, id)
        }
    }

    var body: some View {
        if let userId = session.session?.uid {
            List(medicines, id: \.id) { medicine, medicineId in
                NavigationLink {
                    MedicineDetailView(for: medicine, id: medicineId, userId: userId)
                } label: {
                    MedicineItemView(medicine: medicine)
                }
            }
        }
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    MedicinesListView(PreviewDatabaseRepo().medicines!)
}
