//
//  AisleViewModelTests.swift
//  MediStockTests
//
//  Created by Benjamin LEFRANCOIS on 31/10/2025.
//

import XCTest
@testable import MediStock

final class AisleViewModelTests: XCTestCase {

    func test_GivenHistoryExists_WhenListening_ThenHistoryAreLoaded() {
        // Given
        let dbRepo = DatabaseRepoMock()

        // When starting the listener in the initialization of ViewModel
        let viewModel = AisleViewModel(aisle: "Aisle 2", dbRepo: dbRepo)

        // Then
        XCTAssertFalse(viewModel.history.isEmpty)
    }

    func test_GivenThereIsAnError_WhenListening_ThenHistoryIsEmptyAndErrorExists() {
        // Given
        let dbRepo = DatabaseRepoMock(listenError: AppError.networkError)

        // When starting the listener in the initialization of ViewModel
        let viewModel = AisleViewModel(aisle: "Aisle 2", dbRepo: dbRepo)

        // Then
        XCTAssertTrue(viewModel.history.isEmpty)
        XCTAssertEqual(viewModel.loadHistoryError, AppError.networkError.userMessage)
    }

    func test_GivenListenerIsActive_WhenViewModelDeinitialized_ThenStopListening() {
        // Given
        let dbRepo = DatabaseRepoMock()
        var viewModel: AisleViewModel! = AisleViewModel(aisle: "Aisle 2", dbRepo: dbRepo)
        XCTAssertNotNil(dbRepo.historyCompletion)

        // When
        viewModel = nil

        // Then
        XCTAssertNil(viewModel)
        XCTAssertNil(dbRepo.historyCompletion)
    }
}
