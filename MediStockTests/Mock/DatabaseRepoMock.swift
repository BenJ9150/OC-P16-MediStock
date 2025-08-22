//
//  DatabaseRepoMock.swift
//  MediStockTests
//
//  Created by Benjamin LEFRANCOIS on 22/08/2025.
//

import Foundation
@testable import MediStock

class DatabaseRepoMock: DatabaseRepository {

    private var medicines: [Medicine]?
    private var histories: [HistoryEntry]?

    private var listenError: Bool
    private var stockError: Bool
    private var medicineCompletion: (([Medicine]?, (any Error)?) -> Void)?
    private var historyCompletion: (([HistoryEntry]?, (any Error)?) -> Void)?

    init(listenError: Bool = false, stockError: Bool = false, withStock: Bool = true) {
        self.listenError = listenError
        self.stockError = stockError
        self.medicines = withStock ? getMedicines() : nil
        self.histories = withStock ? getHistories() : nil
    }

    // MARK: Medicines

    func listenMedicines(_ completion: @escaping ([Medicine]?, (any Error)?) -> Void) {
        self.medicineCompletion = completion
        completion(medicines, listenError ? NSError(domain: "", code: 0, userInfo: nil) : nil)
    }
    
    func stopListeningMedicines() {
        medicineCompletion = nil
    }
    
    func addMedicine(name: String, stock: Int, aisle: String) async throws -> String {
        try canPerform()
        let id = UUID().uuidString
        medicines?.append(Medicine(id: id, name: name, stock: stock, aisle: aisle))
        medicineCompletion?(medicines, nil)
        return id
    }
    
    func deleteMedicine(withId medicineId: String) async throws {
        try canPerform()
    }
    
    func updateMedicine(withId medicineId: String, field: String, value: Any) async throws {
        try canPerform()
    }
    
    func updateMedicine(withId medicineId: String, new medicine: Medicine) async throws {
        try canPerform()
    }

    // MARK: History

    func listenHistories(medicineId: String, _ completion: @escaping ([HistoryEntry]?, (any Error)?) -> Void) {
        self.historyCompletion = completion
        completion(histories, listenError ? NSError(domain: "", code: 0, userInfo: nil) : nil)
    }
    
    func stopListeningHistories() {
        historyCompletion = nil
    }
    
    func addHistory(medicineId: String, userId: String, action: String, details: String) async throws {
        try canPerform()
    }
}

// MARK: Mock data

private extension DatabaseRepoMock {

    func canPerform() throws {
        if listenError || stockError {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
    }

    func getMedicines() -> [Medicine] {
        return [
            Medicine(id: "3", name: "Medicine 3", stock: 3, aisle: "Aisle 1"),
            Medicine(id: "2", name: "Medicine 2", stock: 2, aisle: "Aisle 1"),
            Medicine(id: "1", name: "Medicine 1", stock: 1, aisle: "Aisle 2"),
            Medicine(id: "5", name: "Medicine 5", stock: 5, aisle: "Aisle 2"),
            Medicine(id: "4", name: "Medicine 4", stock: 4, aisle: "Aisle 3")
        ]
    }

    func getHistories() -> [HistoryEntry] {
        return [
            HistoryEntry(medicineId: "1", user: "user_1", action: "Created", details: "Creation details"),
            HistoryEntry(medicineId: "2", user: "user_1", action: "Created", details: "Creation details"),
            HistoryEntry(medicineId: "3", user: "user_1", action: "Created", details: "Creation details"),
            HistoryEntry(medicineId: "4", user: "user_1", action: "Created", details: "Creation details"),
            HistoryEntry(medicineId: "5", user: "user_1", action: "Created", details: "Creation details")
        ]
    }
}
