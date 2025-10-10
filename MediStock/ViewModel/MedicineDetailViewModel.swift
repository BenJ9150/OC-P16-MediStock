//
//  MedicineDetailViewModel.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 08/08/2025.
//

import SwiftUI

@MainActor class MedicineDetailViewModel: ObservableObject {

    private enum UpdateType: String {
        case name
        case stock
        case aisle
    }

    // MARK: Public properties

    let medicineId: String

    @Published var name: String
    @Published var stock: Int
    @Published var aisle: String
    @Published var history: [HistoryEntry] = []

    @Published var historyIsLoading = true
    @Published var loadHistoryError: String?
    @Published var sendHistoryError: SendHistoryError?

    @Published var updatingName = false
    @Published var updatingAisle = false
    @Published var updatingStock = false
    @Published var deleting = false

    @Published var nameError: String?
    @Published var aisleError: String?
    @Published var stockError: String?
    @Published var deleteError: String?

    // MARK: Private properties
    
    private var nameBackup: String
    private var stockBackup: Int
    private var aisleBackup: String
    private let userId: String

    private let dbRepo: DatabaseRepository

    // MARK: Init

    init(medicine: Medicine, medicineId: String, userId: String, dbRepo: DatabaseRepository) {
        self.dbRepo = dbRepo
        self.userId = userId
        self.medicineId = medicineId

        self.name = medicine.name
        self.stock = medicine.stock
        self.aisle = medicine.aisle

        self.nameBackup = medicine.name
        self.stockBackup = medicine.stock
        self.aisleBackup = medicine.aisle

        self.listenHistory()
    }

    deinit {
        dbRepo.stopListeningHistories()
    }
}

// MARK: Update

extension MedicineDetailViewModel {

    func increaseStock() async {
        await updateStock(with: stock + 1)
    }

    func decreaseStock() async {
        guard stock > 0 else {
            return
        }
        await updateStock(with: stock - 1)
    }

    func updateStock() async {
        guard stock != stockBackup else {
            return
        }
        await updateStock(with: stock)
    }

    func updateName() async {
        guard name != nameBackup else {
            return
        }
        updatingName = true
        defer { updatingName = false }

        let action = "Updated \(name)"
        let details = "Updated medicine details"
        await update(.name, newValue: name, action: action, details: details)
    }

    func updateAilse() async {
        guard aisle != aisleBackup else {
            return
        }
        updatingAisle = true
        defer { updatingAisle = false }

        let action = "Updated \(aisle)"
        let details = "Updated medicine details"
        await update(.aisle, newValue: aisle, action: action, details: details)
    }

    func sendHistoryAfterError() async {
        if let historyError = sendHistoryError {
            historyIsLoading = true
            defer { historyIsLoading = false }
            await newHistoryEntry(action: historyError.action, details: historyError.details)
        }
    }
}

// MARK: Delete

extension MedicineDetailViewModel {

    func deleteMedicine() async {
        deleteError = nil
        deleting = true
        defer { deleting = false }
        do {
            try await dbRepo.deleteMedicine(withId: medicineId)
        } catch let nsError as NSError {
            print("💥 deleteMedicines error \(nsError.code): \(nsError.localizedDescription)")
            deleteError = AppError(forCode: nsError.code).userMessage
        }
    }
}

// MARK: private

private extension MedicineDetailViewModel {

    private func updateStock(with newStock: Int) async {
        updatingStock = true
        defer { updatingStock = false }

        let amount = newStock - stockBackup
        let action = "\(amount > 0 ? "Increased" : "Decreased") stock of \(name) by \(amount)"
        let details = "Stock changed from \(stockBackup) to \(newStock)"
        await update(.stock, newValue: newStock, action: action, details: details)
    }

    private func update(_ type: UpdateType, newValue: Any, action: String, details: String) async {
        cleanError(for: type)
        do {
            try await dbRepo.updateMedicine(withId: medicineId, field: type.rawValue, value: newValue)
            saveNewValueForNextUpdate(type, newValue: newValue)

        } catch let nsError as NSError {
            print("💥 update of \(type.rawValue) error \(nsError.code): \(nsError.localizedDescription)")
            // Failure, backup to old value
            backupValuesAndDisplayError(for: type, nsError: nsError)
            return
        }
        // Send new history entry
        await newHistoryEntry(action: action, details: details)
    }

    private func saveNewValueForNextUpdate(_ type: UpdateType, newValue: Any) {
        switch type {
        case .name:
            if let newName = newValue as? String {
                nameBackup = newName
            }
        case .stock:
            if let newStock = newValue as? Int {
                stockBackup = newStock
                // Update local stock (in case the stock has been changed with buttons)
                stock = newStock
            }
        case .aisle:
            if let newAisle = newValue as? String {
                aisleBackup = newAisle
            }
        }
    }

    private func backupValuesAndDisplayError(for type: UpdateType, nsError: NSError) {
        let userMessage = AppError(forCode: nsError.code).userMessage
        switch type {
        case .name:
            name = nameBackup
            nameError = userMessage
        case .stock:
            stock = stockBackup
            stockError = userMessage
        case .aisle:
            aisle = aisleBackup
            aisleError = userMessage
        }
    }

    private func cleanError(for type: UpdateType) {
        switch type {
        case .name: nameError = nil
        case .stock: stockError = nil
        case .aisle: aisleError = nil
        }
    }

    private func newHistoryEntry(action: String, details: String) async {
        sendHistoryError = nil
        do {
            try await dbRepo.addHistory(
                medicineId: medicineId,
                userId: userId,
                action: action,
                details: details
            )
        } catch let nsError as NSError {
            print("💥 Update medicine, send history error \(nsError.code): \(nsError.localizedDescription)")
            let message = AppError(forCode: nsError.code).userMessage
            sendHistoryError = SendHistoryError(error: message, action: action, details: details)
        }
    }

    private func listenHistory() {
        dbRepo.listenHistories(medicineId: medicineId) { [weak self] fetchedHistory, error in
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
