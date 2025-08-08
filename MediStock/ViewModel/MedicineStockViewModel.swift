import Foundation

class MedicineStockViewModel: ObservableObject {

    @Published var medicines: [Medicine] = []
    @Published var aisles: [String] = []
    @Published var history: [HistoryEntry] = []

    // Filter
    
    enum MedicineSort: String, CaseIterable, Identifiable {
        case none
        case name
        case stock

        var id: String { self.rawValue }
    }
    
    @Published var medicineFilter: String = ""
    @Published var medicineSort: MedicineSort = .none
    
    @MainActor var filteredAndSortedMedicines: [Medicine] {
        applyFilterAndSort()
    }

    // MARK: Init

    private let dbRepo: DatabaseRepository

    init(dbRepo: DatabaseRepository = FirestoreRepo()) {
        self.dbRepo = dbRepo
        self.listenMedicines()
    }

    deinit {
        dbRepo.stopListeningMedicines()
        dbRepo.stopListeningHistories()
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
        dbRepo.listenHistories(medicineId: medicineId) { fetchedHistory, error in
            if let fetchError = error {
                print("💥 fetchHistory error: \(fetchError.localizedDescription)")
                return
            }
            self.history = fetchedHistory ?? []
        }
    }

    func stopListeningHistories() {
        dbRepo.stopListeningHistories()
    }
}

// MARK: private

private extension MedicineStockViewModel {

    func listenMedicines() {
        dbRepo.listenMedicines { fetchedMedicines, error in
            if let fetchError = error {
                print("💥 fetchMedicinesAndAisles error: \(fetchError.localizedDescription)")
                return
            }
            self.medicines = fetchedMedicines ?? []
            self.aisles = Array(Set(self.medicines.map { $0.aisle })).sorted()
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

    func applyFilterAndSort() -> [Medicine] {
        var filteredMedicine = medicines

        // Filtrage
        if !medicineFilter.isEmpty {
            filteredMedicine = medicines.filter { $0.name.lowercased().contains(medicineFilter.lowercased()) }
        }

        // Tri
        switch medicineSort {
        case .name:
            filteredMedicine.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .stock:
            filteredMedicine.sort { $0.stock < $1.stock }
        case .none:
            break
        }
        return filteredMedicine
    }
}
