import Foundation

class MedicineStockViewModel: ObservableObject {

    @Published var medicines: [Medicine] = []
    @Published var aisles: [String] = []
    @Published var history: [HistoryEntry] = []

    private let dbRepo: DatabaseRepository

    // MARK: Init

    init(dbRepo: DatabaseRepository = FirestoreRepo()) {
        self.dbRepo = dbRepo
        listenMedicinesAndAisles()
    }
}

// MARK: Public

extension MedicineStockViewModel {

    func addRandomMedicine(userId: String) async {
        let medicineName = "Medicine \(Int.random(in: 1...100))"
        do {
            let medicineId = try await dbRepo.addMedicine(
                name: medicineName,
                stock: Int.random(in: 1...100),
                aisle: "Aisle \(Int.random(in: 1...10))"
            )
            try await dbRepo.addHistory(
                medicineId: medicineId,
                userId: userId,
                action: "Added \(medicineName)",
                details: "Added new medicine"
            )
        } catch let error {
            print("💥 addRandomMedicine error: \(error.localizedDescription)")
        }
    }

    func deleteMedicines(withId medicineId: String) async {
        do {
            try await dbRepo.deleteMedicine(withId: medicineId)
        } catch {
            print("💥 deleteMedicines error: \(error.localizedDescription)")
        }
    }

    func increaseStock(_ medicine: Medicine, userId: String) async {
        await updateStock(medicine, by: 1, userId: userId)
    }

    func decreaseStock(_ medicine: Medicine, userId: String) async {
        await updateStock(medicine, by: -1, userId: userId)
    }
    
    func updateMedicine(_ medicine: Medicine, userId: String) async {
        guard let medicineId = medicine.id else {
            print("💥 updateMedicine error: no medicine id")
            return
        }
        do {
            try await dbRepo.updateMedicine(withId: medicineId, new: medicine)
            try await dbRepo.addHistory(
                medicineId: medicineId,
                userId: userId,
                action: "Updated \(medicine.name)",
                details: "Updated medicine details"
            )
        } catch {
            print("💥 updateMedicine error: \(error.localizedDescription)")
        }
    }

    func listenHistory(medicineId: String) {
        dbRepo.listenHistories(medicineId: medicineId) { history, error in
            Task { @MainActor in
                if let fetchError = error {
                    print("💥 fetchHistory error: \(fetchError.localizedDescription)")
                }
                self.history = history
            }
        }
    }

    func stopListeningHistories() {
        dbRepo.stopListeningHistories()
    }
}

// MARK: private

private extension MedicineStockViewModel {

    func listenMedicinesAndAisles() {
        dbRepo.listenMedicinesAndAisles { medicines, aisles, error in
            Task { @MainActor in
                if let fetchError = error {
                    print("💥 fetchMedicinesAndAisles error: \(fetchError.localizedDescription)")
                }
                self.medicines = medicines
                self.aisles = aisles
            }
        }
    }

    func updateStock(_ medicine: Medicine, by amount: Int, userId: String) async {
        guard let medicineId = medicine.id else {
            print("💥 updateStock error: no medicine id")
            return
        }
        let newStock = medicine.stock + amount
        do {
            try await dbRepo.updateMedicine(withId: medicineId, field: "stock", value: newStock)
            try await dbRepo.addHistory(
                medicineId: medicineId,
                userId: userId,
                action: "\(amount > 0 ? "Increased" : "Decreased") stock of \(medicine.name) by \(amount)",
                details: "Stock changed from \(medicine.stock - amount) to \(newStock)"
            )
        } catch {
            print("💥 updateStock error: \(error.localizedDescription)")
        }
    }
}
