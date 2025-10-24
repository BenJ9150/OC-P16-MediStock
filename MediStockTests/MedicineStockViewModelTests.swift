//
//  MedicineStockViewModelTests.swift
//  MediStockTests
//
//  Created by Benjamin LEFRANCOIS on 22/08/2025.
//

import XCTest
@testable import MediStock

@MainActor final class MedicineStockViewModelTests: XCTestCase {

    // MARK: Listen medicines

    func test_GivenMedicinesExists_WhenListening_ThenMedicinesAreLoaded() {
        // Given
        let dbRepo = DatabaseRepoMock()

        // When starting the listener in the initialization of ViewModel
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)

        // Then
        XCTAssertFalse(viewModel.medicines.isEmpty)
        XCTAssertFalse(viewModel.aisles.isEmpty)
    }

    func test_GivenThereIsAnError_WhenListening_ThenMedicinesAreEmptyAndErrorExists() {
        // Given
        let dbRepo = DatabaseRepoMock(listenError: AppError(forCode: 111111))

        // When starting the listener in the initialization of ViewModel
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)

        // Then
        XCTAssertTrue(viewModel.medicines.isEmpty)
        XCTAssertTrue(viewModel.aisles.isEmpty)
        XCTAssertEqual(viewModel.loadError, AppError.unknown.userMessage)
    }

    func test_GivenListenerIsActive_WhenViewModelDeinitialized_ThenStopListening() {
        // Given
        let dbRepo = DatabaseRepoMock()
        var viewModel: MedicineStockViewModel! = MedicineStockViewModel(dbRepo: dbRepo)
        XCTAssertNotNil(dbRepo.medicineCompletion)

        // When
        viewModel = nil

        // Then
        XCTAssertNil(viewModel)
        XCTAssertNil(dbRepo.medicineCompletion)
    }
}

// MARK: Add

extension MedicineStockViewModelTests {

    func test_GivenMedicineIsAdded_WhenCheckingCount_ThenCountIsOneMore() async throws {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)
        let initialCount = viewModel.medicines.count

        // When
        try await viewModel.addMedicine(user: AuthUserMock.user, name: "new_name_test", aisle: "new_aisle_test", stock: 0)

        // Then
        XCTAssertEqual(viewModel.medicines.count, initialCount + 1)
        XCTAssertTrue(dbRepo.histories!.contains { $0.action == addMedicineAction(name: "new_name_test") })
    }

    func test_GivenEmptyField_WhenAddingMedicine_ThenCountNotChangedAndErrorExists() async {
        // Given
        let dbRepo = DatabaseRepoMock(stockError: AppError.networkError)
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)
        let initialCount = viewModel.medicines.count

        // When
        try? await viewModel.addMedicine(user: AuthUserMock.user, name: "", aisle: "", stock: 0)

        // Then
        XCTAssertEqual(viewModel.medicines.count, initialCount)
        XCTAssertEqual(viewModel.nameError, AppError.emptyField.userMessage)
        XCTAssertEqual(viewModel.aisleError, AppError.emptyField.userMessage)
    }

    func test_GivenThereIsAnError_WhenAddingMedicine_ThenCountNotChangedAndErrorExists() async {
        // Given
        let dbRepo = DatabaseRepoMock(stockError: AppError.networkError)
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)
        let initialCount = viewModel.medicines.count

        // When
        try? await viewModel.addMedicine(user: AuthUserMock.user, name: "new_name_test", aisle: "new_aisle_test", stock: 0)

        // Then
        XCTAssertEqual(viewModel.medicines.count, initialCount)
        XCTAssertEqual(viewModel.addError, AppError.networkError.userMessage)
    }
}

// MARK: Send history error

extension MedicineStockViewModelTests {

    func test_GivenErrorWithHistory_WhenRetrying_ThenNewHistoryExists() async throws {
        // Given
        let action = addMedicineAction(name: "new_name_test")
        let dbRepo = DatabaseRepoMock(addHistoryError: 1)
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)
        try? await viewModel.addMedicine(user: AuthUserMock.user, name: "new_name_test", aisle: "new_aisle_test", stock: 0)
        XCTAssertTrue(dbRepo.medicines!.contains { $0.name == "new_name_test" })
        XCTAssertFalse(dbRepo.histories!.contains { $0.action == action })
        XCTAssertNotNil(viewModel.newMedicineHistoryError)

        // When
        try await viewModel.sendHistoryAfterError()

        // Then
        XCTAssertNil(viewModel.newMedicineHistoryError)
        XCTAssertTrue(dbRepo.histories!.contains { $0.action == action })
    }
}

// MARK: Filter and sort

extension MedicineStockViewModelTests {

    @MainActor func test_GivenMedicinesExists_WhenFilteringByName_ThenFilteredCountIsOne() {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)
        XCTAssertTrue(viewModel.medicines.count > 1)

        // When
        viewModel.medicineFilter = "Medicine 1"
        viewModel.listenMedicines()

        // Then
        XCTAssertTrue(viewModel.medicines.count == 1)
        XCTAssertEqual(viewModel.medicines[0].name, "Medicine 1")
    }

    @MainActor func test_GivenMedicinesExists_WhenSortingByName_ThenMedicinesAreSorted() {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)

        // When
        viewModel.medicineSort = .name

        // Then
        let expectedOrder = ["Medicine 1", "Medicine 2", "Medicine 3", "Medicine 4", "Medicine 5"]
        let sortedNames = viewModel.medicines.map { $0.name }
        XCTAssertEqual(sortedNames, expectedOrder)
    }

    @MainActor func test_GivenMedicinesExists_WhenSortingByStock_ThenMedicinesAreSorted() {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)

        // When
        viewModel.medicineSort = .stock

        // Then
        let expectedOrder = ["Medicine 1", "Medicine 2", "Medicine 3", "Medicine 4", "Medicine 5"]
        let sortedNames = viewModel.medicines.map { $0.name }
        XCTAssertEqual(sortedNames, expectedOrder)
    }
}

// MARK: private

private extension MedicineStockViewModelTests {

    func addMedicineAction(name: String) -> String {
        return "Added \(name)"
    }
}
