//
//  AisleContentUITests.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 31/10/2025.
//

import XCTest

final class AisleContentUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        XCUIDevice.shared.orientation = .portrait
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTesting)
    }

    func test_GivenOnAisleContentView_WhenTappingOnHistory_ThenAisleHistoryIsPresented() throws {
        // Given
        app.launch()
        app.firstCell(matching: "AisleItemName").tap()
        app.auditWithLightAndDarkMode()

        // When
        app.buttons["aisleHistoryButton"].tap()
        app.auditWithLightAndDarkMode()

        // Then
        let navigationBar = app.navigationBars.element(boundBy: 0)
        let aisleName = navigationBar.staticTexts.element(boundBy: 0).label

        let labels = app.cellLabels(matching: "HistoryItemAisle", isLazyStack: true)
        for label in labels {
            XCTAssertTrue(label.contains(aisleName))
        }
    }

    func test_GivenListenHistoryError_WhenGoingToAisleHistory_ThenErrorIsPresented() throws {
        // Given
        app.launchArguments.append(AppFlags.uiTestingListenHistoryError)
        app.launch()
        app.firstCell(matching: "AisleItemName").tap()

        // When
        app.buttons["aisleHistoryButton"].tap()

        // Then
        app.auditWithLightAndDarkMode()
        app.assertStaticTextExists("Error: A network error occurred. Please check your internet connection and try again")
    }
}
