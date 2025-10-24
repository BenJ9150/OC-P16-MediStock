//
//  HistoryItemView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 18/09/2025.
//

import SwiftUI

struct HistoryItemView: View {

    let item: HistoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(item.action)
                .font(.headline)
            Text("User: \(item.user)")
                .font(.subheadline)
            Text("Date: \(item.timestamp.formatted())")
                .font(.subheadline)
            Text("Details: \(item.details)")
                .font(.subheadline)
        }
        .padding()
        .background(Color(.systemGray6))
        .background(in: .rect(cornerRadius: 10))
        .padding(.bottom, 5)
        .accessibilityIdentifier("HistoryItem")
    }
}

// MARK: - Preview

#Preview {
    HistoryItemView(item: PreviewDatabase.histories.first!)
        .roundedBackground()
        .background(.cyan)
}
