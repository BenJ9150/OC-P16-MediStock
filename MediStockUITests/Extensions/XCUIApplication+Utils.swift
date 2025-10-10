//
//  XCUIApplication+Utils.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 25/09/2025.
//

import XCTest

extension XCUIApplication {

    func firstCell(matching identifier: String) -> XCUIElement {
        let cell = self.staticTexts.matching(identifier: identifier).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 1), "Cell with identifier '\(identifier)' does not exist or did not appear in time.")
        return cell
    }

    func cellLabels(matching identifier: String) -> [String] {
        let elements = self.cells.staticTexts.matching(identifier: identifier)
        XCTAssertTrue(elements.firstMatch.waitForExistence(timeout: 1), "No cells found matching identifier '\(identifier)'.")
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

    private func tapOnkeyboardButton(label: KeyboardLabel?) {
        if let submitIdentifier = label {
            let button = self.keyboards.buttons[submitIdentifier.rawValue]
            XCTAssertTrue(button.waitForExistence(timeout: 1), "Keyboard button '\(submitIdentifier.rawValue)' not found.")
            button.tap()
        }
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
}
