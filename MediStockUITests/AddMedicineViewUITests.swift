//
//  AddMedicineViewUITests.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 26/09/2025.
//

import XCTest

final class AddMedicineViewUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTesting)
    }
    
    func test_GivenOnAddMedicineView_WhenAdding_ThenNewMedicineExists() {
        // Given
        app.launch()
        app.buttons["All Medicines"].tap()
        let medicinesCount = app.cellLabels(matching: "MedicineItemName").count
        app.buttons["ShowAddMedicineButton"].tap()

        // When
        app.buttons["AddMedicineButton"].tap()

        // Then
        let newMedicinesCount = app.cellLabels(matching: "MedicineItemName").count
        XCTAssertEqual(medicinesCount + 1, newMedicinesCount)
    }

    func test_GivenOnAisleListView_WhenTapOnAddButton_ThenAddMedicineViewIsPresented() {
        // Given
        app.launch()

        // When
        app.buttons["ShowAddMedicineButton"].tap()

        // Then
        app.assertStaticTextExists("Add medicine")
    }
}
