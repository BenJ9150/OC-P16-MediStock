//
//  UITestsExtensions.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 25/09/2025.
//

import XCTest

extension XCUIApplication {

    enum KeyboardLabel: String {
        case next = "Next:"
        case done = "Done"
        case send = "Send"
        case search = "Search"
    }

    enum FieldType {
        case secureField
        case textField
        case searchField
    }

    func assertStaticTextExists(_ label: String) {
        let element = staticTexts[label]
        XCTAssertTrue(element.waitForExistence(timeout: 2), "\"\(label)\" doesn't exist")
    }

    func assertStaticTextsCount(_ matching: String, count: Int) {
        let texts = staticTexts.matching(identifier: matching)
        _ = texts.firstMatch.waitForExistence(timeout: 2)
        XCTAssertEqual(texts.count, count)
    }

    func assertField(_ identifier: String, equalTo value: String, type: FieldType = .textField) {
        let field = getField(identifier, type: type)
        XCTAssertEqual(field.value as? String ?? "", value)
    }

    func firstCell() -> XCUIElement {
        let cell = self.cells.firstMatch
        _ = cell.waitForExistence(timeout: 2)
        return cell
    }

    func cellLabels(matching identifier: String) -> [String] {
        let elements = self.cells.staticTexts.matching(identifier: identifier)
        _ = elements.firstMatch.waitForExistence(timeout: 2)

        var values: [String] = []
        for i in 0..<elements.count {
            values.append(elements.element(boundBy: i).label)
        }
        return values
    }

    /// - Returns: Old value
    func editTextField(_ identifier: String, text: String, tapOn: KeyboardLabel? = nil, type: FieldType = .textField) -> String {
        let field = getField(identifier, type: type)
        let currentValue = field.value as? String ?? ""

        if !currentValue.isEmpty {
            cleanTextField(identifier, type: type)
        } else {
            field.tap()
        }
        field.typeText(text)
        if let submitIdentifier = tapOn {
            self.keyboards.buttons[submitIdentifier.rawValue].tap()
        }
        return currentValue
    }

    func cleanTextField(_ identifier: String, type: FieldType = .textField) {
        let field = getField(identifier, type: type)
        field.tap()
        let currentValue = field.value as? String ?? ""
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
        field.typeText(deleteString)
    }

    private func getField(_ identifier: String, type: FieldType) -> XCUIElement {
        let field: XCUIElement
        switch type {
        case .secureField: field = self.secureTextFields[identifier]
        case .textField: field = self.textFields[identifier]
        case .searchField: field = self.searchFields[identifier]
        }
        _ = field.waitForExistence(timeout: 2)
        return field
    }
}
