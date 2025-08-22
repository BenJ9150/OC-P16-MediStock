//
//  MedicineDetailViewModel.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 08/08/2025.
//

import SwiftUI

class MedicineDetailViewModel: ObservableObject {

    private enum UpdateType: String {
        case name
        case stock
        case aisle
    }

    // MARK: Public properties

    @Published var name: String
    @Published var stock: Int
    @Published var aisle: String
    @Published var history: [HistoryEntry] = []

    // MARK: Private properties

    private var nameBackup: String
    private var stockBackup: Int
    private var aisleBackup: String

    private let medicineId: String
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
        await updateStock(with: stock - 1)
    }

    func updateStock() async {
        await updateStock(with: stock)
    }

    func updateName() async {
        let action = "Updated \(name)"
        let details = "Updated medicine details"
        await update(.name, newValue: name, action: action, details: details)
    }

    func updateAilse() async {
        let action = "Updated \(name)"
        let details = "Updated medicine details"
        await update(.aisle, newValue: aisle, action: action, details: details)
    }
}

// MARK: Delete

extension MedicineDetailViewModel {

    func deleteMedicine() async {
        do {
            try await dbRepo.deleteMedicine(withId: medicineId)
        } catch {
            print("💥 deleteMedicines error: \(error.localizedDescription)")
        }
    }
}

// MARK: private

private extension MedicineDetailViewModel {

    private func updateStock(with newStock: Int) async {
        let amount = newStock - stockBackup
        let action = "\(amount > 0 ? "Increased" : "Decreased") stock of \(name) by \(amount)"
        let details = "Stock changed from \(stockBackup) to \(newStock)"
        await update(.stock, newValue: newStock, action: action, details: details)
    }

    private func update(_ type: UpdateType, newValue: Any, action: String, details: String) async {
        do {
            try await dbRepo.updateMedicine(withId: medicineId, field: type.rawValue, value: newValue)

            // Success! Save new value for next update
            await saveNewValueForNextUpdate(type, newValue: newValue)

            // Send new history entry
            await newHistoryEntry(action: action, details: details)

        } catch {
            print("💥 update of \(type.rawValue) error: \(error.localizedDescription)")
            // Failure, backup to old value
            await backupValues(for: type)
        }
    }

    private func saveNewValueForNextUpdate(_ type: UpdateType, newValue: Any) async {
        switch type {
        case .name:
            if let newName = newValue as? String {
                nameBackup = newName
            }
        case .stock:
            if let newStock = newValue as? Int {
                stockBackup = newStock
                // Update local stock (in case the stock has been changed with buttons)
                await MainActor.run { stock = newStock }
            }
        case .aisle:
            if let newAisle = newValue as? String {
                aisleBackup = newAisle
            }
        }
    }

    @MainActor private func backupValues(for type: UpdateType) {
        switch type {
        case .name: name = nameBackup
        case .stock: stock = stockBackup
        case .aisle: aisle = aisleBackup
        }
    }

    private func newHistoryEntry(action: String, details: String) async {
        do {
            try await dbRepo.addHistory(
                medicineId: medicineId,
                userId: userId,
                action: action,
                details: details
            )
        } catch {
            print("💥 newHistoryEntry error: \(error.localizedDescription)")
        }
    }

    private func listenHistory() {
        dbRepo.listenHistories(medicineId: medicineId) { fetchedHistory, error in
            if let fetchError = error {
                print("💥 fetchHistory error: \(fetchError.localizedDescription)")
                return
            }
            self.history = fetchedHistory ?? []
        }
    }

    private func stopListeningHistories() {
        dbRepo.stopListeningHistories()
    }
}
