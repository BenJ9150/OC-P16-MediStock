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
        XCUIDevice.shared.orientation = .portrait
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
        app.tapOnScreenToCloseKeyboard(staticText: "MediStock")
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
        app.auditWithLightAndDarkMode()
        app.assertStaticTextsCount("Error: This field is required.", count: 2)

        // And when complete field
        app.setTextField("Email", text: "uitest@medi.com", tapOn: .next)
        app.setTextField("Password", type: .secureField, isFocused: true, text: "xxxxxxx")
        app.tapOnScreenToCloseKeyboard(staticText: "MediStock")
        app.buttons["SignInButton"].tap()

        // Then
        app.auditWithLightAndDarkMode()
        app.assertStaticTextExists("Error: A network error occurred. Please check your internet connection and try again")
    }
}

final class SignUpUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        XCUIDevice.shared.orientation = .portrait
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTestingAuth)
    }
    
    func test_GivenUserIsNotConnected_WhenSigningUp_ThenAisleListViewAppears() {
        // Given
        app.launch()

        // When
        app.setTextField("Email", text: "uitest@medistock.com", tapOn: .next)
        app.setTextField("Password", type: .secureField, isFocused: true, text: "xxxxxxx", tapOn: .done)
        app.tapOnScreenToCloseKeyboard(staticText: "MediStock")
        app.buttons["SignUpButton"].tap()

        // Then
        app.assertStaticTextExists("Aisles")
    }
}

final class AccountUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        XCUIDevice.shared.orientation = .portrait
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(AppFlags.uiTesting)
    }
    
    func test_GivenOnAccountView_WhenSigningOut_ThenLoginViewIsPresented() {
        // Given
        app.launch()
        app.buttons["ShowAccountButton"].tap()

        // When
        app.buttons["SignOutButton"].tap()
        app.tapOnAlertButton("signOutButtonAlert")

        // Then
        XCTAssertTrue(app.buttons["SignInButton"].waitForExistence(timeout: 2))
    }

    func test_GivenNetworkError_WhenUpdatingUserName_ThenOldNameIsRestoredAndErrorExists() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingAuthError)
        app.launch()
        app.buttons["ShowAccountButton"].tap()

        // When
        app.setTextField("Display name", text: "New name", tapOn: .send)
        app.tapOnAlertButton("updateNameButtonAlert")

        // Then
        app.auditWithLightAndDarkMode()
        app.assertStaticTextExists("Error: A network error occurred. Please check your internet connection and try again")
        app.assertField("Display name", equalTo: "Display name") // equal to placeholder cause no name at the begining of the test
    }

    func test_GivenUpdateName_WhenCancelUpdate_ThenNameAreRestored_AndWhenUpdating_ThenNewNameExits() {
        // Given
        app.launch()
        app.buttons["ShowAccountButton"].tap()
        app.setTextField("Display name", text: "New name", tapOn: .send)

        // When
        app.tapOnAlertButton("cancelNameButtonAlert")

        // Then
        app.assertField("Display name", equalTo: "Display name") // equal to placeholder cause no name at the begining of the test

        // And when
        app.setTextField("Display name", text: "New name", tapOn: .send)
        app.tapOnAlertButton("updateNameButtonAlert")

        // Then
        app.assertField("Display name", equalTo: "New name")
    }
}
