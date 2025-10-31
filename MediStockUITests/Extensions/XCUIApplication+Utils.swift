//
//  XCUIApplication+Utils.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 25/09/2025.
//

import XCTest

extension XCUIApplication {

    static let timeout: TimeInterval = 3

    func firstCell(matching identifier: String) -> XCUIElement {
        let cell = self.staticTexts.matching(identifier: identifier).firstMatch
        XCTAssertTrue(
            cell.waitForExistence(timeout: XCUIApplication.timeout),
            "Cell with identifier '\(identifier)' does not exist or did not appear in time."
        )
        return cell
    }

    func cellLabels(matching identifier: String, isLazyStack: Bool = false) -> [String] {
        let elements = isLazyStack ? self.staticTexts.matching(identifier: identifier) : self.cells.staticTexts.matching(identifier: identifier)
        XCTAssertTrue(
            elements.firstMatch.waitForExistence(timeout: XCUIApplication.timeout),
            "No cells found matching identifier '\(identifier)'."
        )
        var values: [String] = []
        for i in 0..<elements.count {
            values.append(elements.element(boundBy: i).label)
        }
        return values
    }

    func editTextField(_ identifier: String, type: FieldType = .textField, text: String, tapOn: KeyboardLabel? = nil) {
        let field = cleanTextField(identifier, type: type)
        field.typeText(text)
        tapOnkeyboardButton(label: tapOn)
    }

    func setTextField(_ identifier: String, type: FieldType = .textField, isFocused: Bool = false, text: String, tapOn: KeyboardLabel? = nil) {
        let field = getField(identifier, type: type)
        if !isFocused {
            field.tap()
        }
        field.typeText(text)
        tapOnkeyboardButton(label: tapOn)
    }

    func getTextFieldValue(_ identifier: String, type: FieldType = .textField) -> String {
        let field = getField(identifier, type: type)
        return field.value as? String ?? ""
    }

    func cleanTextField(_ identifier: String, type: FieldType = .textField) -> XCUIElement {
        let field = getField(identifier, type: type)
        field.tap()
        let currentValue = field.value as? String ?? ""
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
        field.typeText(deleteString)
        return field
    }

    func tapOnScreenToCloseKeyboard(staticText: String) {
        self.staticTexts[staticText].tap()
        XCTAssertTrue(
            self.keyboards.element.waitForNonExistence(timeout: 1),
            "Keyboard did not close after tapping '\(staticText)'."
        )
    }

    func tapOnAlertButton(_ identifier: String) {
        let button = self.buttons[identifier].firstMatch
        XCTAssertTrue(
            button.waitForExistence(timeout: XCUIApplication.timeout),
            "Button alert with identifier '\(identifier)' does not exist or did not appear in time."
        )
        button.tap()
    }
}

// MARK: Private

extension XCUIApplication {

    private func groupLabelsToArray(_ identifier: String, elements: XCUIElementQuery) -> [String] {
        XCTAssertTrue(
            elements.firstMatch.waitForExistence(timeout: XCUIApplication.timeout),
            "No cells found matching identifier '\(identifier)'."
        )
        var values: [String] = []
        for i in 0..<elements.count {
            values.append(elements.element(boundBy: i).label)
        }
        return values
    }

    private func tapOnkeyboardButton(label: KeyboardLabel?) {
        if let submitIdentifier = label {
            dismissKeyboardIntroIfNeeded()
            let button = self.keyboards.buttons[submitIdentifier.rawValue]
            XCTAssertTrue(
                button.waitForExistence(timeout: XCUIApplication.timeout),
                "Keyboard button '\(submitIdentifier.rawValue)' not found."
            )
            button.tap()
        }
    }

    private func dismissKeyboardIntroIfNeeded() {
        let keyboardIntroFR = self.staticTexts["Type français et anglais"]
        let keyboardIntroEN = self.staticTexts["Type English and French"]
        if keyboardIntroFR.exists || keyboardIntroEN.exists {
            let continueButtonFR = self.buttons["Continuer"]
            if continueButtonFR.exists {
                continueButtonFR.tap()
            }
            let continueButtonEN = self.buttons["Continue"]
            if continueButtonEN.exists {
                continueButtonEN.tap()
            }
        }
    }
}
