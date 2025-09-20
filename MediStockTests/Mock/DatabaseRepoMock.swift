//
//  DatabaseRepoMock.swift
//  MediStockTests
//
//  Created by Benjamin LEFRANCOIS on 22/08/2025.
//

import Foundation
@testable import MediStock

class DatabaseRepoMock: DatabaseRepository {

    var medicines: [Medicine]?
    private var histories: [HistoryEntry]?

    private var listenError: AppError?
    private var stockError: AppError?

    var medicineCompletion: (([Medicine]?, (any Error)?) -> Void)?
    var historyCompletion: (([HistoryEntry]?, (any Error)?) -> Void)?

    init(listenError: AppError? = nil, stockError: AppError? = nil) {
        self.listenError = listenError
        self.stockError = stockError
        self.medicines = getMedicines()
        self.histories = getHistories()
    }

    // MARK: Medicines

    func listenMedicines(_ completion: @escaping ([Medicine]?, (any Error)?) -> Void) {
        self.medicineCompletion = completion
        completion(medicines, listenError)
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
        guard let currentMedicines = medicines,
              let index = currentMedicines.firstIndex(where: { $0.id == medicineId }) else {
            throw NSError(domain: "DatabaseRepoMock", code: 404, userInfo: [NSLocalizedDescriptionKey: "Medicine not found"])
        }
        var updated = currentMedicines[index]
        switch field {
        case "name":
            updated.name = value as? String ?? updated.name
        case "stock":
            updated.stock = value as? Int ?? updated.stock
        case "aisle":
            updated.aisle = value as? String ?? updated.aisle
        default:
            break
        }
        medicines?[index] = updated
        medicineCompletion?(medicines, nil)
    }

    // MARK: History

    func listenHistories(medicineId: String, _ completion: @escaping ([HistoryEntry]?, (any Error)?) -> Void) {
        self.historyCompletion = completion
        completion(histories, listenError)
    }
    
    func stopListeningHistories() {
        historyCompletion = nil
    }
    
    func addHistory(medicineId: String, userId: String, action: String, details: String) async throws {
        try canPerform()
        histories?.append(HistoryEntry(medicineId: medicineId, user: userId, action: action, details: details))
        historyCompletion?(histories, nil)
    }
}

// MARK: Mock data

extension DatabaseRepoMock {

    func medicine() -> Medicine {
        Medicine(id: "1", name: "Medicine 1", stock: 1, aisle: "Aisle 2")
    }

    private func canPerform() throws {
        if let error = listenError {
            throw error
        }
        if let error = stockError {
            throw error
        }
    }

    private func getMedicines() -> [Medicine] {
        return [
            Medicine(id: "3", name: "Medicine 3", stock: 3, aisle: "Aisle 1"),
            Medicine(id: "2", name: "Medicine 2", stock: 2, aisle: "Aisle 1"),
            Medicine(id: "1", name: "Medicine 1", stock: 1, aisle: "Aisle 2"),
            Medicine(id: "5", name: "Medicine 5", stock: 5, aisle: "Aisle 2"),
            Medicine(id: "4", name: "Medicine 4", stock: 4, aisle: "Aisle 3")
        ]
    }

    private func getHistories() -> [HistoryEntry] {
        return [
            HistoryEntry(medicineId: "1", user: "user_1", action: "Created", details: "Creation details"),
            HistoryEntry(medicineId: "1", user: "user_1", action: "Created", details: "Creation details"),
            HistoryEntry(medicineId: "1", user: "user_1", action: "Created", details: "Creation details"),
            HistoryEntry(medicineId: "1", user: "user_1", action: "Created", details: "Creation details"),
            HistoryEntry(medicineId: "1", user: "user_1", action: "Created", details: "Creation details")
        ]
    }
}
