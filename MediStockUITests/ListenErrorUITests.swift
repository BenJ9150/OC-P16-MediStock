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
        app.assertStaticTextExists("A network error occurred. Please check your internet connection and try again")

        // When
        app.buttons["All Medicines"].tap()

        // Then
        app.assertStaticTextExists("A network error occurred. Please check your internet connection and try again")
    }
}
