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
        app.assertButtonExists("ShowAccountButton")
    }

    func test_GivenEmptyFieldAndNetworkError_WhenSigningIn_ThenErrorsExist() {
        // Given
        app.launchArguments.append(AppFlags.uiTestingAuthError)
        app.launch()

        // When
        app.buttons["SignInButton"].tap()

        // Then
        app.auditWithLightAndDarkMode()
        app.assertStaticTextsCount(Bundle.uiLocalizedError("emptyFieldError"), count: 2)

        // And when complete field
        app.setTextField("Email", text: "uitest@medi.com", tapOn: .next)
        app.setTextField("Password", type: .secureField, isFocused: true, text: "xxxxxxx")
        app.tapOnScreenToCloseKeyboard(staticText: "MediStock")
        app.buttons["SignInButton"].tap()

        // Then
        app.auditWithLightAndDarkMode()
        app.assertStaticTextExists(Bundle.uiLocalizedError("networkError"))
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
        app.assertButtonExists("ShowAccountButton")
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
        app.assertStaticTextExists(Bundle.uiLocalizedError("networkError"))
        app.assertFieldEqualToPlaceholder("Display name") // equal to placeholder cause no name at the begining of the test
    }

    func test_GivenUpdateName_WhenCancelUpdate_ThenNameAreRestored_AndWhenUpdating_ThenNewNameExits() {
        // Given
        app.launch()
        app.buttons["ShowAccountButton"].tap()
        app.setTextField("Display name", text: "New name", tapOn: .send)

        // When
        app.tapOnAlertButton("cancelNameButtonAlert")

        // Then
        app.assertFieldEqualToPlaceholder("Display name") // equal to placeholder cause no name at the begining of the test

        // And when
        app.setTextField("Display name", text: "New name", tapOn: .send)
        app.tapOnAlertButton("updateNameButtonAlert")

        // Then
        app.assertField("Display name", equalTo: "New name")
    }
}
