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
        XCUIDevice.shared.orientation = .portrait
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
        app.buttons["editNameOrAisleButton"].tap()
        sleep(1) // Sleep for animation
        app.editTextField("Name", text: newName, tapOn: .send)
        app.tapOnAlertButton("updateNameButtonAlert")

        // Then
        app.assertStaticTextExists("Updated \(newName)")

        // And when update aisle
        app.editTextField("Aisle", text: "New aisle", tapOn: .send)
        app.tapOnAlertButton("updateAisleButtonAlert")

        // Then
        app.assertStaticTextExists("Updated New aisle")

        // And when update stock
        let oldStock = Int(app.getTextFieldValue("Stock"))!
        var newStock = 1
        app.editTextField("Stock", text: "\(newStock)")
        app.tapOnScreenToCloseKeyboard(staticText: "Stock")
        app.buttons["increaseStockButton"].tap()
        newStock += 1
        app.buttons["updateStockButton"].tap()
        app.tapOnAlertButton("updateStockButtonAlert")
        
        // Then
        app.assertStockActionExists(new: newStock, old: oldStock, name: newName)
    }

    func test_GivenUpdatedData_WhenCancelUpdate_ThenDataAreRestored() {
        // Given
        app.launch()
        app.firstCell(matching: "AisleItemName").tap()
        app.firstCell(matching: "MedicineItemName").tap()

        // When
        app.buttons["editNameOrAisleButton"].tap()
        sleep(1) // Sleep for animation
        let oldName = app.getTextFieldValue("Name")
        app.editTextField("Name", text: "New name", tapOn: .send)
        app.tapOnAlertButton("cancelNameButtonAlert")

        let oldAisle = app.getTextFieldValue("Aisle")
        app.editTextField("Aisle", text: "New aisle", tapOn: .send)
        app.tapOnAlertButton("cancelAisleButtonAlert")

        let oldStock = app.getTextFieldValue("Stock")
        app.buttons["decreaseStockButton"].tap()
        sleep(1) // Sleep for animation
        app.buttons["updateStockButton"].tap()
        app.tapOnAlertButton("cancelStockButtonAlert")

        // Then
        app.assertField("Name", equalTo: oldName)
        app.assertField("Aisle", equalTo: oldAisle)
        app.assertField("Stock", equalTo: oldStock)
    }
}

final class UpdateMedicineErrorUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        XCUIDevice.shared.orientation = .portrait
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTesting)
    }

    func test_GivenNetworkError_WhenUpdatingData_ThenDataAreRestoredAndErrorExists() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingUpdateError)
        app.launch()
        app.firstCell(matching: "AisleItemName").tap()
        app.firstCell(matching: "MedicineItemName").tap()

        // When
        app.buttons["editNameOrAisleButton"].tap()
        sleep(1) // Sleep for animation
        let oldName = app.getTextFieldValue("Name")
        app.editTextField("Name", text: "New name", tapOn: .send)
        app.tapOnAlertButton("updateNameButtonAlert")

        let oldAisle = app.getTextFieldValue("Aisle")
        app.editTextField("Aisle", text: "New aisle", tapOn: .send)
        app.tapOnAlertButton("updateAisleButtonAlert")

        let oldStock = app.getTextFieldValue("Stock")
        app.buttons["increaseStockButton"].tap()
        sleep(1) // Sleep for animation
        app.buttons["updateStockButton"].tap()
        app.tapOnAlertButton("updateStockButtonAlert")

        // Then
        app.auditWithLightAndDarkMode()
        app.assertStaticTextsCount("Error: A network error occurred. Please check your internet connection and try again", count: 3)
        app.assertField("Name", equalTo: oldName)
        app.assertField("Aisle", equalTo: oldAisle)
        app.assertField("Stock", equalTo: oldStock)
    }

    func test_GivenListenHistoryNetworkError_WhenOpenningDetails_ThenHistoryErrorExists() {
        // Given
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launchArguments.append(AppFlags.uiTestingListenHistoryError)
        app.launch()
        app.firstCell(matching: "AisleItemName").tap()

        // When
        app.firstCell(matching: "MedicineItemName").tap()

        // Then
        app.auditWithLightAndDarkMode()
        app.assertStaticTextExists("Error: A network error occurred. Please check your internet connection and try again")
    }

    func test_GivenSendHistoryNetworkError_WhenUpdatingStock_ThenRetryButtonAndErrorExist() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingSendHistoryError)
        app.launch()
        app.firstCell(matching: "AisleItemName").tap()
        app.firstCell(matching: "MedicineItemName").tap()
        let navigationBar = app.navigationBars.element(boundBy: 0)
        let medicineName = navigationBar.staticTexts.element(boundBy: 0).label
        let stock = Int(app.getTextFieldValue("Stock"))!

        // When
        app.buttons["decreaseStockButton"].tap()
        sleep(1) // Sleep for animation
        app.buttons["updateStockButton"].tap()
        app.tapOnAlertButton("updateStockButtonAlert")

        // Then
        app.auditWithLightAndDarkMode()
        app.assertStaticTextExists("Error: An error occurred while sending history:\nA network error occurred. Please check your internet connection and try again")

        // And when retry
        app.buttons["RetrySendHistoryButton"].tap()

        // Then
        app.assertStockActionExists(new: stock - 1, old: stock, name: medicineName)
    }
}
