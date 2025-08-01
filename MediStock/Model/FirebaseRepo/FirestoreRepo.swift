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

    /// - Returns: An array of medicines, an array of aisles and any Error
    func listenMedicinesAndAisles(_ completion: @escaping ([Medicine], [String], (any Error)?) -> Void) {
        medicinesListener?.remove()

        medicinesListener = medicineCollection.addSnapshotListener { snapshot, error in
            let medicines = snapshot?.documents.compactMap {
                try? $0.data(as: Medicine.self)
            } ?? []
            let aisles = Array(Set(medicines.map { $0.aisle })).sorted()

            completion(medicines, aisles, error)
        }
    }

    /// - Returns: The document ID of the created medicine
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

    func updateMedicine(withId medicineId: String, new medicine: Medicine) async throws {
        let encodedData = try Firestore.Encoder().encode(medicine)
        try await medicineCollection.document(medicineId).setData(encodedData, merge: true)
    }
}

// MARK: History

extension FirestoreRepo {

    /// - Returns: An array of history entry  and any Error
    func listenHistories(medicineId: String, _ completion: @escaping ([HistoryEntry], (any Error)?) -> Void) {
        historiesListener?.remove()
        historiesListener = historyCollection.whereField("medicineId", isEqualTo: medicineId).addSnapshotListener { snapshot, error in
            let histories = snapshot?.documents.compactMap {
                try? $0.data(as: HistoryEntry.self)
            } ?? []

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
