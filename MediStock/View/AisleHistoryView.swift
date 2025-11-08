//
//  AisleHistoryView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 26/10/2025.
//

import SwiftUI

struct AisleHistoryView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AisleViewModel

    init(for aisle: String) {
        self._viewModel = StateObject(
            wrappedValue: AisleViewModel(aisle: aisle, dbRepo: RepoSettings().getDbRepo())
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("History")
                        .font(.headline)
         
                    LazyVStack {
                        ForEach(viewModel.history, id: \.id) { entry in
                            HistoryItemView(item: entry)
                        }
                    }
                    .displayLoaderOrError(
                        loading: $viewModel.historyIsLoading,
                        error: $viewModel.loadHistoryError,
                        errorColor: .red
                    )
                }
                .roundedBackground()
            }
            .scrollIndicators(.hidden)
            .mediBackground()
            .navigationTitle(viewModel.aisle)
            .toolbar {
                ToolbarItem(id: "ToolbarItemAisleHistoryClose", placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }

                }
            }
        }
    }
}

// MARK: - Preview

#Preview(traits: .previewEnvironment()) {
    NavigationStack {
        AisleHistoryView(for: "Aisle 1")
    }
}
