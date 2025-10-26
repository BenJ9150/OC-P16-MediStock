//
//  PreviewDatabaseRepo.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 08/08/2025.
//

import Foundation

class PreviewDatabase {

    @MainActor static var medicineCompletion: (([Medicine]?, (any Error)?) -> Void)?

    /// Property used for UI Tests
    /// - Attention: Do not change the values
    static var medicines: [Medicine] = [
        Medicine(id: "medicine_3", name: "Medicine 3", stock: 8, aisle: "Aisle 1"),
        Medicine(id: "medicine_2", name: "Medicine 2", stock: 1, aisle: "Aisle 1"),
        Medicine(id: "medicine_1", name: "Medicine 1", stock: 6, aisle: "Aisle 2"),
        Medicine(id: "medicine_5", name: "Medicine 5", stock: 2, aisle: "Aisle 2"),
        Medicine(id: "medicine_4", name: "Medicine 4", stock: 9, aisle: "Aisle 3")
    ]

    /// Property used for UI Tests
    /// - Attention: Do not change the values
    static var histories: [HistoryEntry] = [
        HistoryEntry(id: "history_1", medicineId: "medicine_1", user: PreviewAuthUser.user, action: "Created", details: "Creation details"),
        HistoryEntry(id: "history_2", medicineId: "medicine_2", user: PreviewAuthUser.user, action: "Created", details: "Creation details"),
        HistoryEntry(id: "history_3", medicineId: "medicine_3", user: PreviewAuthUser.user, action: "Created", details: "Creation details"),
        HistoryEntry(id: "history_4", medicineId: "medicine_4", user: PreviewAuthUser.user, action: "Created", details: "Creation details"),
        HistoryEntry(id: "history_5", medicineId: "medicine_5", user: PreviewAuthUser.user, action: "Created", details: "Creation details")
    ]

    static var previewHistories: [HistoryEntry] = [
        HistoryEntry(id: "history_1", medicineId: "medicine_1", user: PreviewAuthUser.userWithName, action: "Created", details: "Creation details"),
        HistoryEntry(id: "history_2", medicineId: "medicine_2", user: PreviewAuthUser.userWithName, action: "Created", details: "Creation details"),
        HistoryEntry(id: "history_3", medicineId: "medicine_3", user: PreviewAuthUser.userWithName, action: "Created", details: "Creation details"),
        HistoryEntry(id: "history_4", medicineId: "medicine_4", user: PreviewAuthUser.userWithName, action: "Created", details: "Creation details"),
        HistoryEntry(id: "history_5", medicineId: "medicine_5", user: PreviewAuthUser.userWithName, action: "Created", details: "Creation details")
    ]
}

class PreviewDatabaseRepo: DatabaseRepository {

    private var listenMedicineError: AppError?
    private var listenHistoryError: AppError?
    private var updateError: AppError?
    private var sendHistoryError: AppError?
    private var sendHistoryErrorCount: Int = 1

    @MainActor private var historyCompletion: (([HistoryEntry]?, (any Error)?) -> Void)?

    init(listenError: AppError? = nil, updateError: AppError? = nil, sendHistoryError: AppError? = nil) {
        self.listenMedicineError = listenError
        self.listenHistoryError = listenError
        self.updateError = updateError
        self.sendHistoryError = sendHistoryError
    }

    init(listenMedicineError: Bool, listenHistoryError: Bool, updateError: Bool, sendHistoryError: Bool) {
        self.listenMedicineError = listenMedicineError ? AppError.networkError : nil
        self.listenHistoryError = listenHistoryError ? AppError.networkError : nil
        self.updateError = updateError ? AppError.networkError : nil
        self.sendHistoryError = sendHistoryError ? AppError.networkError : nil
    }

    // MARK: Medicines

    func listenMedicines(sort: MedicineSort, matching name: String?, _ completion: @escaping ([Medicine]?, (any Error)?) -> Void) {
        Task { @MainActor in
            PreviewDatabase.medicineCompletion = completion
            var result = PreviewDatabase.medicines
            // Search
            if let value = name, !value.isEmpty {
                result = PreviewDatabase.medicines.filter { $0.name == value }
            }
            // Sort
            switch sort {
            case .none: break
            case .name: result.sort { $0.name < $1.name }
            case .stock: result.sort { $0.stock < $1.stock }
            }
            completion(result, self.listenMedicineError)
        }
    }
    
    func stopListeningMedicines() {
        Task { @MainActor in
            PreviewDatabase.medicineCompletion = nil
        }
    }
    
    func addMedicine(name: String, stock: Int, aisle: String) async throws -> String {
        try await canPerform()
        return await MainActor.run {
            let id = UUID().uuidString
            PreviewDatabase.medicines.append(Medicine(id: id, name: name, stock: stock, aisle: aisle))
            PreviewDatabase.medicineCompletion?(PreviewDatabase.medicines, nil)
            return id
        }
    }
    
    func deleteMedicine(withId medicineId: String) async throws {
        try await canPerform()
        await MainActor.run {
            PreviewDatabase.medicines.removeAll(where: { $0.id == medicineId })
            PreviewDatabase.medicineCompletion?(PreviewDatabase.medicines, nil)
        }
    }
    
    func updateMedicine(withId medicineId: String, field: String, value: Any) async throws {
        try await canPerform()
        guard let index = PreviewDatabase.medicines.firstIndex(where: { $0.id == medicineId }) else {
            throw NSError(domain: "DatabaseRepoMock", code: 404, userInfo: [NSLocalizedDescriptionKey: "Medicine not found"])
        }
        var updated = PreviewDatabase.medicines[index]
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
        PreviewDatabase.medicines[index] = updated

        await MainActor.run {
            PreviewDatabase.medicineCompletion?(PreviewDatabase.medicines, nil)
        }
    }

    // MARK: History

    func listenHistories(medicineId: String, _ completion: @escaping ([HistoryEntry]?, (any Error)?) -> Void) {
        Task { @MainActor in
            historyCompletion = completion
            PreviewDatabase.histories = PreviewDatabase.histories
                .filter { $0.medicineId == medicineId }
                .sorted { $0.timestamp > $1.timestamp }

            completion(PreviewDatabase.histories, listenHistoryError)
        }
    }
    
    func stopListeningHistories() {
        Task { @MainActor in
            historyCompletion = nil
        }
    }
    
    func addHistory(medicineId: String, user: AuthUser, action: String, details: String) async throws {
        try await canPerform()
        if let sendError = sendHistoryError {
            if sendHistoryErrorCount > 0 {
                sendHistoryErrorCount -= 1
                throw sendError
            }
        }
        await MainActor.run {
            PreviewDatabase.histories.append(HistoryEntry(id: UUID().uuidString, medicineId: medicineId, user: user, action: action, details: details))
            PreviewDatabase.histories = PreviewDatabase.histories
                .filter { $0.medicineId == medicineId }
                .sorted { $0.timestamp > $1.timestamp }

            historyCompletion?(PreviewDatabase.histories, nil)
        }
    }
}

// MARK: Mock data

extension PreviewDatabaseRepo {

    private func canPerform() async throws {
        if !AppFlags.isUITests {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        if let error = updateError {
            throw error
        }
    }
}
