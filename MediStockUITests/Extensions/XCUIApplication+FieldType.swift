//
//  XCUIApplication+FieldType.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 05/10/2025.
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

    func getField(_ identifier: String, type: FieldType) -> XCUIElement {
        let field: XCUIElement
        switch type {
        case .secureField: field = self.secureTextFields[identifier]
        case .textField: field = self.textFields[identifier]
        case .searchField: field = self.searchFields[identifier]
        }
        XCTAssertTrue(
            field.waitForExistence(timeout: XCUIApplication.timeout),
            "Field '\(identifier)' of type \(type) does not exist or did not appear in time."
        )
        return field
    }
}
