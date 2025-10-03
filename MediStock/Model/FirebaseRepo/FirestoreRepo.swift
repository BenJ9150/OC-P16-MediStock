//
//  FirestoreRepo.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 01/08/2025.
//

import Foundation
import FirebaseFirestore

class FirestoreRepo: DatabaseRepository {

    private var medicineCollection: CollectionReference {
        Firestore.firestore().collection("medicines")
    }

    private var historyCollection: CollectionReference {
        Firestore.firestore().collection("history")
    }

    private var medicinesListener: ListenerRegistration?
    private var historiesListener: ListenerRegistration?
}

// MARK: Medicines

extension FirestoreRepo {

    func listenMedicines(sort: MedicineSort, matching name: String?, _ completion: @escaping ([Medicine]?, (any Error)?) -> Void) {
        medicinesListener?.remove()
        var query: Query = medicineCollection

        // Search
        if let value = name, !value.isEmpty {
            query = query.whereField("name", isEqualTo: value)
        }
        // Sort
        switch sort {
        case .none: break
        case .name: query = query.order(by: "name")
        case .stock: query = query.order(by: "stock")
        }

        // Listen result
        medicinesListener = query.addSnapshotListener { snapshot, error in
            let medicines = snapshot?.documents.compactMap { try? $0.data(as: Medicine.self) }
            completion(medicines, error)
        }
    }

    func stopListeningMedicines() {
        medicinesListener?.remove()
        medicinesListener = nil
    }

    func addMedicine(name: String, stock: Int, aisle: String) async throws -> String {
        let newMedecine = Medicine(name: name, stock: stock, aisle: aisle)
        let encodedData = try Firestore.Encoder().encode(newMedecine)
        return try await medicineCollection.addDocument(data: encodedData).documentID
    }

    func deleteMedicine(withId medicineId: String) async throws {
        try await medicineCollection.document(medicineId).delete()
    }

    func updateMedicine(withId medicineId: String, field: String, value: Any) async throws {
        try await medicineCollection.document(medicineId).updateData([field: value])
    }
}

// MARK: History

extension FirestoreRepo {

    func listenHistories(medicineId: String, _ completion: @escaping ([HistoryEntry]?, (any Error)?) -> Void) {
        historiesListener?.remove()
        var query: Query = historyCollection.whereField("medicineId", isEqualTo: medicineId)
        query = query.order(by: "timestamp", descending: true)

        historiesListener = query.addSnapshotListener { snapshot, error in
            let histories = snapshot?.documents.compactMap { try? $0.data(as: HistoryEntry.self) }
            completion(histories, error)
        }
    }

    func stopListeningHistories() {
        historiesListener?.remove()
        historiesListener = nil
    }

    func addHistory(medicineId: String, userId: String, action: String, details: String) async throws {
        let history = HistoryEntry(medicineId: medicineId, user: userId, action: action, details: details)
        let encodedData = try Firestore.Encoder().encode(history)
        try await historyCollection.addDocument(data: encodedData)
    }
}
