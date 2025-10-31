//
//  AisleViewModel.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 26/10/2025.
//

import SwiftUI

class AisleViewModel: ObservableObject {
    
    @Published var history: [HistoryEntry] = []
    @Published var historyIsLoading = true
    @Published var loadHistoryError: String?
    @Published var sendHistoryError: SendHistoryError?
    
    let aisle: String
    private let dbRepo: DatabaseRepository
    
    // MARK: Init
    
    init(aisle: String, dbRepo: DatabaseRepository) {
        self.dbRepo = dbRepo
        self.aisle = aisle
        self.listenHistory()
    }

    deinit {
        dbRepo.stopListeningHistories()
    }
}

private extension AisleViewModel {

    private func listenHistory() {
        dbRepo.listenHistories(field: "aisle", value: aisle) { [weak self] fetchedHistory, error in
            defer { self?.historyIsLoading = false }

            if let nsError = error as? NSError {
                print("💥 listenHistory error \(nsError.code): \(nsError.localizedDescription)")
                self?.loadHistoryError = AppError(forCode: nsError.code).userMessage
                return
            }
            if let history = fetchedHistory {
                self?.history = history
            }
            self?.loadHistoryError = nil
        }
    }
}
