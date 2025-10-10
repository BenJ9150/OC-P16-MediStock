//
//  AuthUITests.swift
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
        app.setTextField("Email", text: "uitest@medistock.com")
        app.setTextField("Password", type: .secureField, text: "xxxxxxx")
        app.staticTexts["MediStock"].tap() // to close keyboard
        app.buttons["SignInButton"].tap()

        // Then
        app.assertStaticTextExists("Aisles")
    }

    func test_GivenEmptyFieldAndNetworkError_WhenSigningIn_ThenErrorsExist() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingAuthError)
        app.launch()

        // When
        app.buttons["SignInButton"].tap()

        // Then
        app.assertStaticTextsCount("* This field is required.", count: 2)

        // And when complete field
        app.setTextField("Email", text: "uitest@medistock.com", tapOn: .next)
        app.setTextField("Password", type: .secureField, isFocused: true, text: "xxxxxxx")
        app.staticTexts["MediStock"].tap() // to close keyboard
        app.buttons["SignInButton"].tap()

        // Then
        app.assertStaticTextExists("A network error occurred. Please check your internet connection and try again")
    }
}

final class SignUpAndSignOutUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTestingAuth)
    }
    
    func test_GivenUserSignUp_WhenSigningOut_ThenLoginViewIsPresented() {
        // Given
        app.launch()
        app.setTextField("Email", text: "uitest@medistock.com", tapOn: .next)
        app.setTextField("Password", type: .secureField, isFocused: true, text: "xxxxxxx", tapOn: .done)
        app.staticTexts["MediStock"].tap() // to close keyboard
        app.buttons["SignUpButton"].tap()

        // When
        app.buttons["SignOutButton"].tap()

        // Then
        XCTAssertTrue(app.buttons["SignInButton"].waitForExistence(timeout: 2))
    }
}
