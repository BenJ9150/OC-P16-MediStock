//
//  MedicineDetailViewModelTests.swift
//  MediStockTests
//
//  Created by Benjamin LEFRANCOIS on 22/08/2025.
//

import XCTest
@testable import MediStock

@MainActor final class MedicineDetailViewModelTests: XCTestCase {

    // MARK: Listen history

    func test_GivenHistoryExists_WhenListening_ThenHistoryAreLoaded() {
        // Given
        let dbRepo = DatabaseRepoMock()

        // When starting the listener in the initialization of ViewModel
        let viewModel = viewModel(dbRepo: dbRepo)

        // Then
        XCTAssertFalse(viewModel.history.isEmpty)
    }

    func test_GivenThereIsAnError_WhenListening_ThenHistoryIsEmptyAndErrorExists() {
        // Given
        let dbRepo = DatabaseRepoMock(listenError: AppError.networkError)

        // When starting the listener in the initialization of ViewModel
        let viewModel = viewModel(dbRepo: dbRepo)

        // Then
        XCTAssertTrue(viewModel.history.isEmpty)
        XCTAssertEqual(viewModel.loadHistoryError, AppError.networkError.userMessage)
    }

    func test_GivenListenerIsActive_WhenViewModelDeinitialized_ThenStopListening() {
        // Given
        let dbRepo = DatabaseRepoMock()
        var viewModel: MedicineDetailViewModel! = viewModel(dbRepo: dbRepo)
        XCTAssertNotNil(dbRepo.historyCompletion)

        // When
        viewModel = nil

        // Then
        XCTAssertNil(viewModel)
        XCTAssertNil(dbRepo.historyCompletion)
    }
}

// MARK: Update name

extension MedicineDetailViewModelTests {

    func test_GivenMedicineName_WhenUpdating_ThenIsUpdatedAndNewHistoryExists() async {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = viewModel(dbRepo: dbRepo)
        let newName = "NewNameTest"
        let action = "Updated \(newName)"
        
        XCTAssertFalse(dbRepo.medicines!.contains { $0.name == newName })
        XCTAssertFalse(viewModel.history.contains { $0.action == action })
        XCTAssertNotEqual(viewModel.name, newName)

        // When
        viewModel.name = newName
        await viewModel.updateName()

        // Then
        XCTAssertTrue(dbRepo.medicines!.contains { $0.name == newName })
        XCTAssertTrue(viewModel.history.contains { $0.action == action })
    }

    func test_GivenThereIsAnError_WhenUpdatingName_ThenOldNameIsRestored() async {
        // Given
        let dbRepo = DatabaseRepoMock(stockError: AppError.networkError)
        let viewModel = viewModel(dbRepo: dbRepo)
        let newName = "NewNameTest"
        let oldName = viewModel.name
        let action = "Updated \(newName)"

        // When
        viewModel.name = newName
        await viewModel.updateName()

        // Then
        XCTAssertEqual(viewModel.name, oldName)
        XCTAssertFalse(viewModel.history.contains { $0.action == action })
    }

    func test_GivenSameName_WhenUpdating_ThenNewHistoryDoesNotExist() async {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = viewModel(dbRepo: dbRepo)
        let action = "Updated \(viewModel.name)"

        // When
        await viewModel.updateName()

        // Then
        XCTAssertFalse(viewModel.history.contains { $0.action == action })
    }
}

// MARK: Update ailse

extension MedicineDetailViewModelTests {

    func test_GivenMedicineAilse_WhenUpdating_ThenNewHistoryExists() async {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = viewModel(dbRepo: dbRepo)
        let newAilse = "NewAilseTest"
        let action = "Updated \(newAilse)"

        XCTAssertFalse(dbRepo.medicines!.contains { $0.aisle == newAilse })
        XCTAssertFalse(viewModel.history.contains { $0.action == action })
        XCTAssertNotEqual(viewModel.aisle, newAilse)

        // When
        viewModel.aisle = newAilse
        await viewModel.updateAilse()

        // Then
        XCTAssertTrue(dbRepo.medicines!.contains { $0.aisle == newAilse })
        XCTAssertTrue(viewModel.history.contains { $0.action == action })
    }

    func test_GivenThereIsAnError_WhenUpdatingAilse_ThenOldAilseIsRestored() async {
        // Given
        let dbRepo = DatabaseRepoMock(stockError: AppError.networkError)
        let viewModel = viewModel(dbRepo: dbRepo)
        let newAilse = "NewAilseTest"
        let oldAilse = viewModel.aisle
        let action = "Updated \(newAilse)"

        // When
        viewModel.aisle = newAilse
        await viewModel.updateAilse()

        // Then
        XCTAssertEqual(viewModel.aisle, oldAilse)
        XCTAssertFalse(viewModel.history.contains { $0.action == action })
    }

    func test_GivenSameAisle_WhenUpdating_ThenNewHistoryDoesNotExist() async {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = viewModel(dbRepo: dbRepo)
        let action = "Updated \(viewModel.aisle)"

        // When
        await viewModel.updateAilse()

        // Then
        XCTAssertFalse(viewModel.history.contains { $0.action == action })
    }

}

// MARK: Update stock

extension MedicineDetailViewModelTests {

    func test_GivenMedicineStock_WhenUpdating_ThenNewHistoryExists() async {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = viewModel(dbRepo: dbRepo)
        let stock = 1000
        let action = stockAction(new: stock, old: viewModel.stock, name: viewModel.name)

        XCTAssertFalse(dbRepo.medicines!.contains { $0.stock == stock })
        XCTAssertFalse(viewModel.history.contains { $0.action == action })
        XCTAssertNotEqual(viewModel.stock, stock)

        // When
        viewModel.stock = stock
        await viewModel.updateStock()

        // Then
        XCTAssertTrue(dbRepo.medicines!.contains { $0.stock == stock })
        XCTAssertTrue(viewModel.history.contains { $0.action == action })
    }

    func test_GivenThereIsAnError_WhenUpdatingStock_ThenOldStockIsRestored() async {
        // Given
        let dbRepo = DatabaseRepoMock(stockError: AppError.networkError)
        let viewModel = viewModel(dbRepo: dbRepo)
        let oldStock = viewModel.stock
        let stock = 1000
        let action = stockAction(new: stock, old: viewModel.stock, name: viewModel.name)

        // When
        viewModel.stock = stock
        await viewModel.updateStock()

        // Then
        XCTAssertEqual(viewModel.stock, oldStock)
        XCTAssertFalse(viewModel.history.contains { $0.action == action })
    }

    func test_GivenMedicineStock_WhenAddingOne_ThenNewStockAndNewHistoryExists() async {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = viewModel(dbRepo: dbRepo)
        let oldStock = viewModel.stock

        // When
        await viewModel.increaseStock()

        // Then
        let action = stockAction(new: oldStock + 1, old: oldStock, name: viewModel.name)
        XCTAssertEqual(viewModel.stock, oldStock + 1)
        XCTAssertTrue(viewModel.history.contains { $0.action == action })
    }

    func test_GivenMedicineStock_WhenRemovingOne_ThenNewStockAndNewHistoryExists() async {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = viewModel(dbRepo: dbRepo)
        let oldStock = viewModel.stock

        // When
        await viewModel.decreaseStock()

        // Then
        let action = stockAction(new: oldStock - 1, old: oldStock, name: viewModel.name)
        XCTAssertEqual(viewModel.stock, oldStock - 1)
        XCTAssertTrue(viewModel.history.contains { $0.action == action })
    }

    func test_GivenSameStock_WhenUpdating_ThenNewHistoryDoesNotExist() async {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = viewModel(dbRepo: dbRepo)
        let action = stockAction(new: viewModel.stock, old: viewModel.stock, name: viewModel.name)

        // When
        await viewModel.updateStock()

        // Then
        XCTAssertFalse(viewModel.history.contains { $0.action == action })
    }
}

// MARK: Send history error

extension MedicineDetailViewModelTests {

    func test_GivenErrorWithHistory_WhenRetrying_ThenNewHistoryExists() async {
        // Given
        let dbRepo = DatabaseRepoMock(addHistoryError: 1)
        let viewModel = viewModel(dbRepo: dbRepo)
        let newName = "NewNameTest"
        let action = "Updated \(newName)"
        viewModel.name = newName
        await viewModel.updateName()
        XCTAssertTrue(dbRepo.medicines!.contains { $0.name == newName })
        XCTAssertFalse(viewModel.history.contains { $0.action == action })
        XCTAssertNotNil(viewModel.sendHistoryError)

        // When
        await viewModel.sendHistoryAfterError()

        // Then
        XCTAssertTrue(viewModel.history.contains { $0.action == action })
    }
}

// MARK: Delete medicine

extension MedicineDetailViewModelTests {

    func test_GivenMedicine_WhenDeleting_ThenMedicineDoesNotExist() async {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = viewModel(dbRepo: dbRepo)
        let medicineId = viewModel.medicineId

        XCTAssertTrue(dbRepo.medicines!.contains { $0.id == medicineId })

        // When
        await viewModel.deleteMedicine()

        // Then
        XCTAssertFalse(dbRepo.medicines!.contains { $0.id == medicineId })
    }

    func test_GivenThereIsAnError_WhenDeleting_ThenMedicineAnErrorExist() async {
        // Given
        let dbRepo = DatabaseRepoMock(stockError: AppError.unknown)
        let viewModel = viewModel(dbRepo: dbRepo)
        let medicineId = viewModel.medicineId

        // When
        await viewModel.deleteMedicine()

        // Then
        XCTAssertTrue(dbRepo.medicines!.contains { $0.id == medicineId })
        XCTAssertEqual(viewModel.deleteError, AppError.unknown.userMessage)
    }
}

// MARK: private

private extension MedicineDetailViewModelTests {

    func viewModel(dbRepo: DatabaseRepoMock) -> MedicineDetailViewModel {
        let medicine = dbRepo.medicine()
        return MedicineDetailViewModel(
            medicine: medicine,
            medicineId: medicine.id!,
            userId: "user_id_mock",
            dbRepo: dbRepo
        )
    }

    func stockAction(new: Int, old: Int, name: String) -> String {
        let amount = new - old
        return "\(amount > 0 ? "Increased" : "Decreased") stock of \(name) by \(amount)"
    }
}
