import Foundation

@MainActor class MedicineStockViewModel: ObservableObject {

    @Published var aisles: [String] = []
    @Published var medicines: [Medicine] = []
    @Published var medicineFilter: String = ""

    @Published var medicineSort: MedicineSort = .none {
        didSet {
            // Launch sort
            listenMedicines()
        }
    }

    @Published var isLoading = true
    @Published var loadError: String?

    @Published var addingMedicine = false
    @Published var addError: String?

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

// MARK: Listen

extension MedicineStockViewModel {

    func listenMedicines() {
        loadError = nil
        isLoading = true

        dbRepo.listenMedicines(sort: medicineSort, matching: medicineFilter) { [weak self] fetchedMedicines, error in
            defer { self?.isLoading = false }
            
            if let nsError = error as? NSError {
                print("💥 listenMedicines error \(nsError.code): \(nsError.localizedDescription)")
                self?.loadError = AppError(forCode: nsError.code).userMessage
                return
            }
            if let medicines = fetchedMedicines {
                self?.medicines = medicines
                self?.aisles = Array(Set(medicines.map { $0.aisle })).sorted()
            }
            self?.loadError = nil
        }
    }
}

// MARK: Add

extension MedicineStockViewModel {

    func addRandomMedicine(userId: String, success: @escaping () -> Void = {}) async {
        addError = nil
        addingMedicine = true
        defer { addingMedicine = false }

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
            success()
        } catch let nsError as NSError {
            print("💥 addRandomMedicine error \(nsError.code): \(nsError.localizedDescription)")
            addError = AppError(forCode: nsError.code).userMessage
        }
    }
}
