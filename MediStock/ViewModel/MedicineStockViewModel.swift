import Foundation

@MainActor class MedicineStockViewModel: ObservableObject {

    enum MedicineSort: String, CaseIterable, Identifiable {
        case none
        case name
        case stock

        var id: String { self.rawValue }
    }

    @Published var aisles: [String] = []
    @Published var medicines: [Medicine] = []
    @Published var medicineFilter: String = ""
    @Published var medicineSort: MedicineSort = .none
    
    var filteredAndSortedMedicines: [Medicine] {
        applyFilterAndSort()
    }

    @Published var isLoading = false

    // MARK: Init

    private let dbRepo: DatabaseRepository

    init(dbRepo: DatabaseRepository = FirestoreRepo()) {
        self.dbRepo = dbRepo
        self.listenMedicines()
    }

    deinit {
        dbRepo.stopListeningMedicines()
    }
}

// MARK: Add

extension MedicineStockViewModel {

    func addRandomMedicine(userId: String) async {
        isLoading = true
        defer { isLoading = false }

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
}

// MARK: private

private extension MedicineStockViewModel {

    func listenMedicines() {
        dbRepo.listenMedicines { [weak self] fetchedMedicines, error in
            if let fetchError = error {
                print("💥 listenMedicines error: \(fetchError.localizedDescription)")
                return
            }
            if let medicines = fetchedMedicines {
                self?.medicines = medicines
                self?.aisles = Array(Set(medicines.map { $0.aisle })).sorted()
            }
        }
    }

    func applyFilterAndSort() -> [Medicine] {
        var filteredMedicine = medicines

        if !medicineFilter.isEmpty {
            filteredMedicine = medicines.filter { $0.name.lowercased().contains(medicineFilter.lowercased()) }
        }

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
