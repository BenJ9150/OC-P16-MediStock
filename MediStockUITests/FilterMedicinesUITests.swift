//
//  FilterMedicinesUITests.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 26/09/2025.
//

import XCTest

final class SearchMedicinesUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTesting)
        app.launch()
    }

    func test_GivenUserIsOnAllMedicinesView_WhenSearching_ThenMedicineIsFound() {
        // Given
        app.buttons["All Medicines"].tap()

        // When
        app.setTextField("Search", type: .searchField, text: "Medicine 1", tapOn: .search)

        // Then
        let foundLabels = app.cellLabels(matching: "MedicineItemName")
        for label in foundLabels {
            XCTAssertEqual(label, "Medicine 1")
        }

        // And when clean search
        app.cleanTextField("Search", type: .searchField)

        // Then
        app.assertStaticTextExists("Medicine 2")
    }

    func test_GivenUserSearchMedicine_WhenChangingView_ThenSearchIsCleaned() {
        // Given
        app.buttons["All Medicines"].tap()
        app.setTextField("Search", type: .searchField, text: "Medicine 1", tapOn: .search)

        // When
        app.buttons["Aisles"].tap()

        // Then
        app.assertStaticTextsCount("AisleItemName", count: 3)
    }
}

final class SortMedicinesUITests: XCTestCase {

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
}

private extension SortMedicinesUITests {

    func assertListIsSorted(by identifier: String) {
        let values = app.cellLabels(matching: identifier)
        XCTAssertEqual(values, values.sorted())
    }
}
