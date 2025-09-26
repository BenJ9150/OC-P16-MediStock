//
//  AllMedicinesViewUITests.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 26/09/2025.
//

import XCTest

final class AllMedicinesViewUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTesting)
        app.launch()
    }
    
    func test_GivenUserIsOnAllMedicinesView_WhenSortingByNameAndStock_ThenMedicinesAreSorted() {
        // Given
        app.buttons["All Medicines"].tap()

        // When
        app.buttons["SortByPicker"].tap()
        app.buttons["Name"].tap()

        // Then
        assertListIsSorted(by: "MedicineItemName")

        // And when
        app.buttons["SortByPicker"].tap()
        app.buttons["Stock"].tap()

        // Then
        assertListIsSorted(by: "MedicineItemStock")
    }

    func test_GivenUserIsOnAllMedicinesView_WhenSearching_ThenMedicineIsFound() {
        // Given
        app.buttons["All Medicines"].tap()

        // When
        app.searchFields["Search"].tap()
        app.searchFields["Search"].typeText("Medicine 1")
        app.keyboards.buttons["Search"].tap()

        // Then
        let foundLabels = app.cellLabels(matching: "MedicineItemName")
        for label in foundLabels {
            XCTAssertEqual(label, "Medicine 1")
        }

        // And when clean search
        let searchField = app.searchFields["Search"]
        searchField.tap()

        let currentValue = searchField.value as? String ?? ""
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
        searchField.typeText(deleteString)

        // Then
        app.assertStaticTextExists("Medicine 2")
    }
}

private extension AllMedicinesViewUITests {

    func assertListIsSorted(by identifier: String) {
        let values = app.cellLabels(matching: identifier)
        XCTAssertEqual(values, values.sorted())
    }
}
