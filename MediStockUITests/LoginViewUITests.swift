//
//  LoginViewUITests.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 25/09/2025.
//

import XCTest

final class SignInUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTestingAuth)
    }
    
    func test_GivenUserIsNotConnected_WhenSigningIn_ThenAisleListViewAppears() {
        // Given
        app.launch()

        // When
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("uitest@medistock.com")
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("xxxxxxx")
        app.buttons["Login"].tap()

        // Then
        app.assertStaticTextExists("Aisles")
    }

    func test_GivenEmptyField_WhenSigningIn_ThenErrorsExist() {
        // Given
        app.launch()

        // When
        app.buttons["Login"].tap()

        // Then
        app.assertStaticTextsCount("* This field is required.", count: 2)
    }

    func test_GivenNetworkError_WhenSigningIn_ThenErrorExists() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingAuthError)
        app.launch()

        // When
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("uitest@medistock.com")
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("xxxxxxx")
        app.buttons["Login"].tap()

        // Then
        app.assertStaticTextExists("A network error occurred. Please check your internet connection and try again")
    }
}

final class SignUpUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTestingAuth)
    }
    
    func test_GivenUserIsNotConnected_WhenSigningUp_ThenAisleListViewAppears() {
        // Given
        app.launch()

        // When
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("uitest@medistock.com")
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("xxxxxxx")
        app.buttons["Sign Up"].tap()

        // Then
        app.assertStaticTextExists("Aisles")
    }
}
