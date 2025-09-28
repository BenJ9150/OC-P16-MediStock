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
        _ = app.editTextField("Email", text: "uitest@medistock.com")
        _ = app.editTextField("Password", text: "xxxxxxx", type: .secureField)
        app.buttons["SignInButton"].tap()

        // Then
        app.assertStaticTextExists("Aisles")
    }

    func test_GivenEmptyField_WhenSigningIn_ThenErrorsExist() {
        // Given
        app.launch()

        // When
        app.buttons["SignInButton"].tap()

        // Then
        app.assertStaticTextsCount("* This field is required.", count: 2)
    }

    func test_GivenNetworkError_WhenSigningIn_ThenErrorExists() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingAuthError)
        app.launch()

        // When
        _ = app.editTextField("Email", text: "uitest@medistock.com")
        _ = app.editTextField("Password", text: "xxxxxxx", type: .secureField)
        app.buttons["SignInButton"].tap()

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
        _ = app.editTextField("Email", text: "uitest@medistock.com", tapOn: .next)
        _ = app.editTextField("Password", text: "xxxxxxx", tapOn: .done, type: .secureField)
        app.buttons["SignUpButton"].tap()

        // Then
        app.assertStaticTextExists("Aisles")
    }
}

final class SignOutUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTesting)
    }
    
    func test_GivenUserIsConnected_WhenSigningOut_ThenLoginViewAppears() {
        // Given
        app.launch()

        // When
        app.buttons["SignOutButton"].tap()

        // Then
        XCTAssertTrue(app.buttons["SignInButton"].waitForExistence(timeout: 2))
    }
}
