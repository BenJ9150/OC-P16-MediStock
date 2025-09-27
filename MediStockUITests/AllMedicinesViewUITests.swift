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
    }
    
    func test_GivenUserIsOnAllMedicinesView_WhenSortingByNameAndStock_ThenMedicinesAreSorted() {
        // Given
        app.launch()
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
        app.launch()
        app.buttons["All Medicines"].tap()

        // When
        _ = app.editTextField("Search", text: "Medicine 1", tapOn: .search, type: .searchField)

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

    func test_GivenNetworkError_WhenViewIsPresented_ThenErrorExists() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingListenMedicineError)
        app.launch()
        app.assertStaticTextExists("A network error occurred. Please check your internet connection and try again")

        // When
        app.buttons["All Medicines"].tap()

        // Then
        app.assertStaticTextExists("A network error occurred. Please check your internet connection and try again")
    }
}

private extension AllMedicinesViewUITests {

    func assertListIsSorted(by identifier: String) {
        let values = app.cellLabels(matching: identifier)
        XCTAssertEqual(values, values.sorted())
    }
}
