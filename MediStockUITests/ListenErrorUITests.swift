//
//  ListenErrorUITests.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 05/10/2025.
//

import XCTest

final class ListenErrorUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        XCUIDevice.shared.orientation = .portrait
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func test_GivenNetworkError_WhenViewIsPresented_ThenErrorExists() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingListenMedicineError)
        app.launch()
        app.auditWithLightAndDarkMode()
        app.assertStaticTextExists(Bundle.uiLocalizedError("networkError"))

        // When
        app.buttons["allMedicinesTab"].tap()

        // Then
        app.auditWithLightAndDarkMode()
        app.assertStaticTextExists(Bundle.uiLocalizedError("networkError"))
    }
}
