//
//  DeleteMedicineUITests.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 12/10/2025.
//

import XCTest

final class DeleteMedicineUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTesting)
    }

    func test_GivenOnMedicineDetailView_WhenDeleting_ThenMedicineIsDeleted() {
        // Given
        app.launch()
        app.buttons["All Medicines"].tap()
        app.firstCell(matching: "MedicineItemName").tap()
        let medicineName = app.getTextFieldValue("Name")

        // When
        app.buttons["DeleteButtonToolbar"].tap()
        app.buttons["DeleteButtonAlert"].tap()

        // Then
        let medicines = app.cellLabels(matching: "MedicineItemName")
        XCTAssertFalse(medicines.contains(where: { $0 == medicineName }))
    }

    func test_NetworkError_WhenDeleting_ThenErrorExists() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingUpdateError)
        app.launch()
        app.firstCell(matching: "AisleItemName").tap()
        app.firstCell(matching: "MedicineItemName").tap()

        // When
        app.buttons["DeleteButtonToolbar"].tap()
        app.buttons["DeleteButtonAlert"].tap()

        // Then
        app.assertStaticTextExists("An error occurred while deleting:\nA network error occurred. Please check your internet connection and try again")
    }
}
