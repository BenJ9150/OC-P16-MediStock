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
        XCUIDevice.shared.orientation = .portrait
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTesting)
    }

    func test_GivenOnMedicineDetailView_WhenDeleting_ThenMedicineIsDeleted() {
        // Given
        app.launch()
        app.buttons["All Medicines"].tap()

        app.auditWithLightAndDarkMode()

        app.firstCell(matching: "MedicineItemName").tap()
        let navigationBar = app.navigationBars.element(boundBy: 0)
        let medicineName = navigationBar.staticTexts.element(boundBy: 0).label

        // When
        app.buttons["deleteButtonToolbar"].tap()
        app.tapOnAlertButton("deleteButtonAlert")

        // Then
        let medicines = app.cellLabels(matching: "MedicineItemName")
        XCTAssertFalse(medicines.contains(where: { $0 == medicineName }))
    }

    func test_NetworkError_WhenDeleting_ThenErrorExists() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingUpdateError)
        app.launch()

        app.auditWithLightAndDarkMode()
        app.firstCell(matching: "AisleItemName").tap()
        app.firstCell(matching: "MedicineItemName").tap()

        // When
        app.buttons["deleteButtonToolbar"].tap()
        app.tapOnAlertButton("deleteButtonAlert")

        // Then
        app.auditWithLightAndDarkMode()
        app.assertStaticTextExists("Error: An error occurred while deleting:\nA network error occurred. Please check your internet connection and try again")
    }
}
