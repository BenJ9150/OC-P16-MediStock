//
//  PreviewDatabaseRepo.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 08/08/2025.
//

import Foundation

class PreviewDatabaseRepo: DatabaseRepository {

    var medicines: [Medicine]?
    private var histories: [HistoryEntry]?

    private var listenError: AppError?
    private var stockError: AppError?

    @MainActor private var medicineCompletion: (([Medicine]?, (any Error)?) -> Void)?
    @MainActor private var historyCompletion: (([HistoryEntry]?, (any Error)?) -> Void)?

    init(listenError: AppError? = nil, stockError: AppError? = nil) {
        self.listenError = listenError
        self.stockError = stockError
        self.medicines = getMedicines()
        self.histories = getHistories()
    }

    // MARK: Medicines

    func listenMedicines(
        sort: MedicineSort,
        matching name: String?,
        _ completion: @MainActor @escaping ([Medicine]?, (any Error)?) -> Void
    ) {
        Task { @MainActor in
            self.medicineCompletion = completion
            guard let medicines = self.medicines else {
                completion(nil, self.listenError)
                return
            }
            var result = medicines
            // Search
            if let value = name, !value.isEmpty {
                result = medicines.filter { $0.name == value }
            }
            // Sort
            switch sort {
            case .none: break
            case .name: result.sort { $0.name < $1.name }
            case .stock: result.sort { $0.stock < $1.stock }
            }
            completion(result, self.listenError)
        }
    }
    
    func stopListeningMedicines() {
        Task { @MainActor in
            medicineCompletion = nil
        }
    }
    
    func addMedicine(name: String, stock: Int, aisle: String) async throws -> String {
        try await canPerform()
        return await MainActor.run {
            let id = UUID().uuidString
            medicines?.append(Medicine(id: id, name: name, stock: stock, aisle: aisle))
            medicineCompletion?(medicines, nil)
            return id
        }
    }
    
    func deleteMedicine(withId medicineId: String) async throws {
        try await canPerform()
    }
    
    func updateMedicine(withId medicineId: String, field: String, value: Any) async throws {
        try await canPerform()
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

        await MainActor.run {
            medicineCompletion?(medicines, nil)
        }
    }

    // MARK: History

    func listenHistories(medicineId: String, _ completion: @MainActor @escaping ([HistoryEntry]?, (any Error)?) -> Void) {
        Task { @MainActor in
            self.historyCompletion = completion
            completion(self.histories, self.listenError)
        }
    }
    
    func stopListeningHistories() {
        Task { @MainActor in
            historyCompletion = nil
        }
    }
    
    func addHistory(medicineId: String, userId: String, action: String, details: String) async throws {
        try await canPerform()
        histories?.append(HistoryEntry(medicineId: medicineId, user: userId, action: action, details: details))
        await MainActor.run {
            historyCompletion?(histories, nil)
        }
    }
}

// MARK: Mock data

extension PreviewDatabaseRepo {

    func medicine() -> Medicine {
        Medicine(id: "1", name: "Medicine 1", stock: 1, aisle: "Aisle 2")
    }

    func historyEntry() -> HistoryEntry {
        HistoryEntry(medicineId: "1", user: "user_1", action: "Created", details: "Creation details")
    }

    private func canPerform() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        if let error = listenError {
            throw error
        }
        if let error = stockError {
            throw error
        }
    }

    
    /// Method used for UI Tests
    /// - Attention: Do not change the values
    private func getMedicines() -> [Medicine] {
        return [
            Medicine(id: "3", name: "Medicine 3", stock: 8, aisle: "Aisle 1"),
            Medicine(id: "2", name: "Medicine 2", stock: 1, aisle: "Aisle 1"),
            Medicine(id: "1", name: "Medicine 1", stock: 6, aisle: "Aisle 2"),
            Medicine(id: "5", name: "Medicine 5", stock: 2, aisle: "Aisle 2"),
            Medicine(id: "4", name: "Medicine 4", stock: 9, aisle: "Aisle 3")
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
