//
//  UpdateMedicineUITests.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 26/09/2025.
//

import XCTest

final class UpdateMedicineUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTesting)
        app.launch()
    }

    func test_GivenOnMedicineDetailView_WhenUpdatingData_ThenNewHistoryExist() {
        // Given
        app.firstCell(matching: "AisleItemName").tap()
        app.firstCell(matching: "MedicineItemName").tap()

        // When update name
        let newName = "New name"
        app.editTextField("Name", text: newName, tapOn: .send)

        // Then
        app.assertStaticTextExists("Updated \(newName)")

        // And when update aisle
        app.editTextField("Aisle", text: "New aisle", tapOn: .send)

        // Then
        app.assertStaticTextExists("Updated New aisle")

        // And when update stock
        let oldStock = Int(app.getTextFieldValue("Stock"))!
        app.buttons["increaseStockButton"].tap()
        app.assertStockActionExists(new: oldStock + 1, old: oldStock, name: newName)
        app.buttons["decreaseStockButton"].tap()
        app.assertStockActionExists(new: oldStock, old: oldStock + 1, name: newName)
        app.editTextField("Stock", text: "1")
        app.staticTexts["Stock"].tap() // to close numeric keyboard

        // Then
        app.assertStockActionExists(new: 1, old: oldStock, name: newName)
    }
}

final class UpdateMedicineErrorUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTesting)
    }

    func test_GivenNetworkError_WhenUpdatingName_ThenNameIsRestoredAndErrorExists() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingUpdateError)
        app.launch()
        app.firstCell(matching: "AisleItemName").tap()
        app.firstCell(matching: "MedicineItemName").tap()

        // When
        let oldName = app.getTextFieldValue("Name")
        app.editTextField("Name", text: "New name", tapOn: .send)

        // Then
        app.assertField("Name", equalTo: oldName)
        app.assertStaticTextExists("* A network error occurred. Please check your internet connection and try again")
    }

    func test_GivenListenHistoryNetworkError_WhenOpenningDetails_ThenHistoryErrorExists() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingListenHistoryError)
        app.launch()
        app.firstCell(matching: "AisleItemName").tap()

        // When
        app.firstCell(matching: "MedicineItemName").tap()

        // Then
        app.assertStaticTextExists("A network error occurred. Please check your internet connection and try again")
    }

    func test_GivenSendHistoryNetworkError_WhenUpdatingStock_ThenRetryButtonAndErrorExist() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingSendHistoryError)
        app.launch()
        app.firstCell(matching: "AisleItemName").tap()
        app.firstCell(matching: "MedicineItemName").tap()
        let medicineName = app.getTextFieldValue("Name")
        let stock = Int(app.getTextFieldValue("Stock"))!

        // When
        app.buttons["increaseStockButton"].tap()

        // Then
        app.assertStaticTextExists("An error occured when send history: A network error occurred. Please check your internet connection and try again")

        // And when retry
        app.buttons["RetrySendHistoryButton"].tap()

        // Then
        app.assertStockActionExists(new: stock + 1, old: stock, name: medicineName)
    }
}
