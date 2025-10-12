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
    @Published var nameError: String?
    @Published var aisleError: String?
    @Published var addError: String?

    @Published var sendingHistory = false
    @Published var sendHistoryError: SendHistoryError?

    // MARK: Init

    private let dbRepo: DatabaseRepository

    init(dbRepo: DatabaseRepository) {
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

    func addMedicine(userId: String, name: String, aisle: String, stock: Int) async throws {
        guard validCredentials(name: name, aisle: aisle) else {
            throw AppError.emptyField
        }
        addingMedicine = true
        defer { addingMedicine = false }
        let medicineId = try await sendMedicine(userId: userId, name: name, aisle: aisle, stock: stock)
        try await sendHistory(userId: userId, medicineId: medicineId, name: name)
    }

    func sendHistoryAfterError() async throws {
        if let historyError = sendHistoryError {
            sendingHistory = true
            defer { sendingHistory = false }
            try await sendHistory(
                userId: historyError.userId,
                medicineId: historyError.medicineId,
                name: historyError.medicineName
            )
        }
    }
}

// MARK: Private

private extension MedicineStockViewModel {

    func validCredentials(name: String, aisle: String) -> Bool {
        cleanErrors()
        nameError = name.isEmpty ? AppError.emptyField.userMessage : nil
        aisleError = aisle.isEmpty ? AppError.emptyField.userMessage : nil
        return !name.isEmpty && !aisle.isEmpty
    }

    func cleanErrors() {
        nameError = nil
        aisleError = nil
        addError = nil
    }

    /// - Returns: The medicine Id just created
    func sendMedicine(userId: String, name: String, aisle: String, stock: Int) async throws -> String {
        do {
            return try await dbRepo.addMedicine(
                name: name,
                stock: stock,
                aisle: aisle
            )
        } catch let nsError as NSError {
            print("💥 addMedicine error \(nsError.code): \(nsError.localizedDescription)")
            addError = AppError(forCode: nsError.code).userMessage
            throw nsError
        }
    }

    func sendHistory(userId: String, medicineId: String, name: String) async throws {
        sendHistoryError = nil
        let action = "Added \(name)"
        let details = "Added new medicine"
        do {
            try await dbRepo.addHistory(
                medicineId: medicineId,
                userId: userId,
                action: action,
                details: details
            )
        } catch let nsError as NSError {
            print("💥 Add medicine, send history error \(nsError.code): \(nsError.localizedDescription)")
            let message = AppError(forCode: nsError.code).sendHistoryErrorMessage
            sendHistoryError = SendHistoryError(
                userId: userId,
                medicineId: medicineId,
                medicineName: name, error: message
            )
            throw nsError
        }
    }
}
