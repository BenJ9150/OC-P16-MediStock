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
        app.launch()
    }

    func test_GivenOnMedicineDetailView_WhenDeleting_ThenMedicineIsDeleted() {
        // Given
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
}
