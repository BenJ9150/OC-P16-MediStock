//
//  DatabaseRepository.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 01/08/2025.
//

import Foundation

protocol DatabaseRepository {

    /// The completion is guaranteed to be called on the main thread.
    /// - Returns: An optional array of medicines and any Error
    func listenMedicines(_ completion: @escaping ([Medicine]?, (any Error)?) -> Void)

    func stopListeningMedicines()

    /// - Returns: The document ID of the created medicine
    func addMedicine(name: String, stock: Int, aisle: String) async throws -> String

    func deleteMedicine(withId medicineId: String) async throws
    func updateMedicine(withId medicineId: String, field: String, value: Any) async throws
    func updateMedicine(withId medicineId: String, new medicine: Medicine) async throws

    /// The completion is guaranteed to be called on the main thread.
    /// - Returns: An optional array of history entries and any Error
    func listenHistories(medicineId: String, _ completion: @escaping ([HistoryEntry]?, (any Error)?) -> Void)

    func stopListeningHistories()

    func addHistory(medicineId: String, userId: String, action: String, details: String) async throws
}
