//
//  UpdateMedicineUITests.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 26/09/2025.
//

import XCTest

final class MedicineDetailViewUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTesting)
    }

    func test_GivenOnMedicineDetailView_WhenUpdatingData_ThenNewHistoryExist() {
        // Given
        app.launch()
        app.firstCell().tap()
        app.firstCell().tap()
        app.assertStaticTextExists("Medicine Details")

        // When update name
        _ = app.editTextField("Name", text: "New name", tapOn: .send)

        // Then
        app.assertField("Name", equalTo: "New name")
        app.assertStaticTextExists("Updated New name")

        // And when update stock
        let oldStock = app.editTextField("Stock", text: "1")
        app.staticTexts["New name"].tap() // to close numeric keyboard
        app.assertStaticTextExists(stockAction(new: 1, old: Int(oldStock)!, name: "New name"))
        app.buttons["increaseStockButton"].tap()
        app.assertStaticTextExists(stockAction(new: 2, old: 1, name: "New name"))
        app.buttons["decreaseStockButton"].tap()

        // Then
        app.assertField("Stock", equalTo: "1")
        app.assertStaticTextExists(stockAction(new: 1, old: 2, name: "New name"))

        // And when update aisle
        _ = app.editTextField("Aisle", text: "New aisle", tapOn: .send)

        // Then
        app.assertField("Aisle", equalTo: "New aisle")
        app.assertStaticTextExists("Updated New aisle")
    }

    func test_GivenNetworkError_WhenUpdatingName_ThenNameIsRestoredAndErrorExists() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingUpdateError)
        app.launch()
        app.firstCell().tap()
        app.firstCell().tap()
        app.assertStaticTextExists("Medicine Details")

        // When
        let oldName = app.editTextField("Name", text: "New name", tapOn: .send)

        // Then
        app.assertField("Name", equalTo: oldName)
        app.assertStaticTextExists("* A network error occurred. Please check your internet connection and try again")
    }

    func test_GivenListenHistoryNetworkError_WhenOpenningDetails_ThenHistoryErrorExists() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingListenHistoryError)
        app.launch()
        app.firstCell().tap()

        // When
        app.firstCell().tap()

        // Then
        app.assertStaticTextExists("A network error occurred. Please check your internet connection and try again")
    }

    func test_GivenSendHistoryNetworkError_WhenUpdatingStock_ThenRetryButtonAndErrorExist() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingSendHistoryError)
        app.launch()
        app.firstCell().tap()
        app.firstCell().tap()

        // When
        app.buttons["increaseStockButton"].tap()

        // Then
        app.assertStaticTextExists("An error occured when send history: A network error occurred. Please check your internet connection and try again")
        app.buttons["RetrySendHistoryButton"].tap()
    }
}

private extension MedicineDetailViewUITests {

    func stockAction(new: Int, old: Int, name: String) -> String {
        let amount = new - old
        return "\(amount > 0 ? "Increased" : "Decreased") stock of \(name) by \(amount)"
    }
}
