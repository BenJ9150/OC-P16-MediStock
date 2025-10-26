//
//  HistoryItemView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 18/09/2025.
//

import SwiftUI

struct HistoryItemView: View {
    
    @Environment(\.dynamicTypeSize) var dynamiceSize
    @Environment(\.colorScheme) var colorScheme
    
    let item: HistoryEntry
    
    var body: some View {
        VStack(spacing: 2) {
            item(item.action)
                .font(.headline)
                .foregroundStyle(.background)
                .background(alignment: .center) {
                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: 10, topTrailing: 10))
                        .fill(Color.primary)
                }
            
            item("Details: \(item.details)")
                .font(.subheadline)
                .padding(.top, 6)
            
            item(item.timestamp.formatted(), alignment: .trailing)
                .font(.caption)
            
            HStack {
                Spacer()
                HStack {
                    if !dynamiceSize.isHigh {
                        Image(systemName: "person.fill")
                            .font(.largeTitle)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Group {
                            Text(item.userName ?? "")
                            Text(item.userEmail ?? "")
                        }
                        .font(.caption)
                        .bold()
                        Text(item.user)
                            .font(.caption2)
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .foregroundStyle(.white)
                .background(alignment: .center) {
                    UnevenRoundedRectangle(cornerRadii: .init(bottomTrailing: 10))
                        .fill(Color.secondary)
                        .brightness(colorScheme == .dark ? -0.5 : -0.1)
                }
            }
        }
        .background(alignment: .center) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(colorScheme == .dark ? 0.4 : 0.1))
        }
        .padding(.top)
        .accessibilityIdentifier("HistoryItem")
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label())
    }
}

private extension HistoryItemView {

    func item(_ text: String, alignment: Alignment = .leading) -> some View {
        Text(text)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, alignment: alignment)
    }

    func label() -> String {
        let createdBy: String = {
            guard let email = item.userEmail else { return "" }
            guard let name = item.userName else {
                return "created by \(email)"
            }
            return "created by \(name), email: \(email)"
        }()
        return "\(item.action), \(item.details), \(createdBy)"
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack {
            Text("History")
                .font(.headline)
            
            ForEach(PreviewDatabase.previewHistories, id: \.id) { entry in
                HistoryItemView(item: entry)
            }
        }
        .roundedBackground()
    }
    .mediBackground()
}
