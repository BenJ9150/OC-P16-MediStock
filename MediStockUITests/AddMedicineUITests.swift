//
//  AddMedicineUITests.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 26/09/2025.
//

import XCTest

final class AddMedicineUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        XCUIDevice.shared.orientation = .portrait
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTesting)
    }

    func test_GivenSendHistoryNetworkError_WhenAddingMedicine_ThenRetryButtonAndErrorExist() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingSendHistoryError)
        app.launch()
        app.buttons["All Medicines"].tap()
        app.buttons["ShowAddMedicineButton"].tap()
        app.setTextField("Name", text: "New name", tapOn: .next)
        app.setTextField("Aisle", isFocused: true, text: "New aisle", tapOn: .next)
        app.setTextField("Stock", isFocused: true, text: "1")
        app.tapOnScreenToCloseKeyboard(staticText: "Name")

        // When
        app.buttons["addMedicineButton"].tap()
        app.tapOnAlertButton("addButtonAlert")

        // Then
        app.auditWithLightAndDarkMode()
        app.assertStaticTextExists("Error: An error occurred while sending history:\nA network error occurred. Please check your internet connection and try again")

        // And when retry
        app.buttons["RetrySendHistoryButton"].tap()

        // Then
        let medicines = app.cellLabels(matching: "MedicineItemName")
        XCTAssertTrue(medicines.contains(where: { $0 == "New name" }))
    }

    func test_GivenEmptyFieldAndNetworkError_WhenAddingMedicine_ThenErrorsExist() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingUpdateError)
        app.launch()
        app.buttons["ShowAddMedicineButton"].tap()

        // When
        app.buttons["addMedicineButton"].tap()
        app.tapOnAlertButton("addButtonAlert")

        // Then
        app.auditWithLightAndDarkMode()
        app.assertStaticTextsCount("Error: This field is required.", count: 2)

        // And when complete field
        app.setTextField("Name", text: "New name", tapOn: .next)
        app.setTextField("Aisle", isFocused: true, text: "New aisle")
        app.tapOnScreenToCloseKeyboard(staticText: "Name")
        app.buttons["addMedicineButton"].tap()
        app.tapOnAlertButton("addButtonAlert")

        // Then
        app.auditWithLightAndDarkMode()
        app.assertStaticTextExists("Error: A network error occurred. Please check your internet connection and try again")
    }
}
