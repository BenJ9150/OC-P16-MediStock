//
//  PreviewDatabaseRepo.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 08/08/2025.
//

import Foundation

class PreviewDatabaseRepo: DatabaseRepository {

    func listenMedicines(_ completion: @escaping ([Medicine]?, (any Error)?) -> Void) {
        completion(medicines(), nil)
    }
    
    func stopListeningMedicines() {}
    
    func addMedicine(name: String, stock: Int, aisle: String) async throws -> String {
        return "1"
    }
    
    func deleteMedicine(withId medicineId: String) async throws {}
    
    func updateMedicine(withId medicineId: String, field: String, value: Any) async throws {}
    
    func updateMedicine(withId medicineId: String, new medicine: Medicine) async throws {}
    
    func listenHistories(medicineId: String, _ completion: @escaping ([HistoryEntry]?, (any Error)?) -> Void) {
        completion(histories(), nil)
    }
    
    func stopListeningHistories() {}
    
    func addHistory(medicineId: String, userId: String, action: String, details: String) async throws {}
}

private extension PreviewDatabaseRepo {

    func medicines() -> [Medicine] {
        return [
            Medicine(id: "1", name: "Medicine 1", stock: 10, aisle: "Aisle 1"),
            Medicine(id: "2", name: "Medicine 2", stock: 10, aisle: "Aisle 1"),
            Medicine(id: "3", name: "Medicine 3", stock: 10, aisle: "Aisle 2"),
            Medicine(id: "4", name: "Medicine 4", stock: 10, aisle: "Aisle 2"),
            Medicine(id: "5", name: "Medicine 5", stock: 10, aisle: "Aisle 3")
        ]
    }

    func histories() -> [HistoryEntry] {
        return [
            HistoryEntry(medicineId: "1", user: "user_1", action: "Created", details: "Creation details"),
            HistoryEntry(medicineId: "2", user: "user_1", action: "Created", details: "Creation details"),
            HistoryEntry(medicineId: "3", user: "user_1", action: "Created", details: "Creation details"),
            HistoryEntry(medicineId: "4", user: "user_1", action: "Created", details: "Creation details"),
            HistoryEntry(medicineId: "5", user: "user_1", action: "Created", details: "Creation details")
        ]
    }
}
