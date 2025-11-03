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
        VStack(spacing: 4) {
            historyInfo
            user
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label())
        .accessibilityIdentifier("HistoryItem")
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(colorScheme == .dark ? 0.4 : 0.1))
        }
        .padding(.top)
    }

    private func label() -> String {
        // Name and email
        let createdBy: String = {
            guard let email = item.userEmail else { return "" }
            guard let name = item.userName else {
                return "By \(email)"
            }
            return "By \(name), \(email)"
        }()
        // Aisle
        let aisle: String = {
            if let aisle = item.aisle {
                return ", in \(aisle), "
            }
            return ""
        }()
        // Date
        let historyDate = formattedDate("d MMMM yyyy, HH'h'mm")
        return "\(item.action), \(item.details)\(aisle), \(createdBy), the \(historyDate)"
    }
    
    private func formattedDate(_ format: String = "dd/MM/yyyy, HH:mm") -> String {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en_US"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: preferredLanguage)
        return dateFormatter.string(from: item.timestamp)
    }
}

// MARK: User

private extension HistoryItemView {

    var historyInfo: some View {
        VStack(spacing: 2) {
            item("Action", text: item.action)
                .font(.headline)
                .foregroundStyle(.background)
                .background(alignment: .center) {
                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: 10, topTrailing: 10))
                        .fill(Color.primary)
                }
            item("Details", text: "Details: \(item.details)")
                .font(.subheadline)
                .padding(.top, 6)

            if let aisle = item.aisle {
                item("Aisle", text: "Aisle: \(aisle)")
                    .font(.subheadline)
            }

            item("Date", text: formattedDate(), alignment: .trailing)
                .font(.caption)
        }
    }

    func item(_ identifier: String, text: String, alignment: Alignment = .leading) -> some View {
        Text(text)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, alignment: alignment)
            .accessibilityIdentifier("HistoryItem\(identifier)")
    }
}

// MARK: User

private extension HistoryItemView {

    var user: some View {
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
                            .accessibilityIdentifier("HistoryItemUserName")
                        Text(item.userEmail ?? "")
                            .accessibilityIdentifier("HistoryItemEmail")
                    }
                    .font(.caption)
                    .bold()
                    Text(item.user)
                        .font(.caption2)
                        .accessibilityIdentifier("HistoryItemUserId")
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .foregroundStyle(.white)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary)
                    .brightness(colorScheme == .dark ? -0.5 : -0.1)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack {
            Text("History")
                .font(.headline)
            
            ForEach(PreviewDatabase.histories, id: \.id) { entry in
                HistoryItemView(item: entry)
            }
        }
        .roundedBackground()
    }
    .mediBackground()
}
