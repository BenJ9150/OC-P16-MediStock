//
//  MedicineStockViewModelTests.swift
//  MediStockTests
//
//  Created by Benjamin LEFRANCOIS on 22/08/2025.
//

import XCTest
@testable import MediStock

final class MedicineStockViewModelTests: XCTestCase {

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

    func test_GivenStockIsEmpty_WhenListening_ThenMedicinesIsEmpty() {
        // Given
        let dbRepo = DatabaseRepoMock(withStock: false)

        // When starting the listener in the initialization of ViewModel
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)

        // Then
        XCTAssertTrue(viewModel.medicines.isEmpty)
        XCTAssertTrue(viewModel.aisles.isEmpty)
    }

    func test_GivenThereIsAnError_WhenListening_ThenMedicinesAreEmpty() {
        // Given
        let dbRepo = DatabaseRepoMock(listenError: true)

        // When starting the listener in the initialization of ViewModel
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)

        // Then
        XCTAssertTrue(viewModel.medicines.isEmpty)
        XCTAssertTrue(viewModel.aisles.isEmpty)
    }
}

// MARK: Add

extension MedicineStockViewModelTests {

    func test_GivenMedicineIsAdded_WhenCheckingCount_ThenCountIsOneMore() async {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)
        let initialCount = viewModel.medicines.count

        // When
        await viewModel.addRandomMedicine(userId: "user_id_mock")

        // Then
        XCTAssertEqual(viewModel.medicines.count, initialCount + 1)
    }

    func test_GivenThereIsAnError_WhenAddingMedicine_ThenCountNotChanged() async {
        // Given
        let dbRepo = DatabaseRepoMock(stockError: true)
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)
        let initialCount = viewModel.medicines.count

        // When
        await viewModel.addRandomMedicine(userId: "user_id_mock")

        // Then
        XCTAssertEqual(viewModel.medicines.count, initialCount)
    }
}

// MARK: Filter and sort

extension MedicineStockViewModelTests {

    @MainActor func test_GivenMedicinesExists_WhenFilteringByName_ThenFilteredCountIsOne() {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)
        XCTAssertTrue(viewModel.filteredAndSortedMedicines.count > 1)

        // When
        viewModel.medicineFilter = "Medicine 1"

        // Then
        XCTAssertTrue(viewModel.filteredAndSortedMedicines.count == 1)
        XCTAssertEqual(viewModel.filteredAndSortedMedicines[0].name, "Medicine 1")
    }

    @MainActor func test_GivenMedicinesExists_WhenSortingByName_ThenMedicinesAreSorted() {
        // Given
        let dbRepo = DatabaseRepoMock()
        let viewModel = MedicineStockViewModel(dbRepo: dbRepo)

        // When
        viewModel.medicineSort = .name

        // Then
        let expectedOrder = ["Medicine 1", "Medicine 2", "Medicine 3", "Medicine 4", "Medicine 5"]
        let sortedNames = viewModel.filteredAndSortedMedicines.map { $0.name }
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
        let sortedNames = viewModel.filteredAndSortedMedicines.map { $0.name }
        XCTAssertEqual(sortedNames, expectedOrder)
    }
}
