//
//  XCUIApplication+XCTAssert.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 05/10/2025.
//

import XCTest

extension XCUIApplication {

    func assertButtonExists(_ identifier: String) {
        let button = buttons[identifier]
        XCTAssertTrue(
            button.waitForExistence(timeout: XCUIApplication.timeout),
            "Button '\(identifier)' does not exist or did not appear in time."
        )
    }

    func assertStaticTextExists(_ label: String) {
        let statictext = staticTexts[label]
        XCTAssertTrue(
            statictext.waitForExistence(timeout: XCUIApplication.timeout),
            "Static text '\(label)' does not exist or did not appear in time."
        )
    }

    func assertStockActionExists(new: Int, old: Int, name: String) {
        let amount = new - old
        let label = "\(amount > 0 ? "Increased" : "Decreased") stock by \(amount)"
        let staticStockAction = staticTexts[label]
        XCTAssertTrue(
            staticStockAction.waitForExistence(timeout: XCUIApplication.timeout),
            "Stock action label '\(label)' does not exist or did not appear in time."
        )
    }

    func assertStaticTextsCount(_ matching: String, count: Int) {
        let texts = staticTexts.matching(identifier: matching)
        XCTAssertTrue(
            texts.firstMatch.waitForExistence(timeout: XCUIApplication.timeout),
            "No static text found matching identifier '\(matching)'."
        )
        XCTAssertEqual(
            texts.count,
            count,
            "Expected \(count) static texts matching identifier '\(matching)', but found \(texts.count)."
        )
    }

    func assertField(_ identifier: String, equalTo value: String, type: FieldType = .textField) {
        let field = getField(identifier, type: type)
        XCTAssertEqual(
            field.value as? String ?? "",
            value,
            "Field '\(identifier)' value does not match expected value '\(value)'."
        )
    }

    func assertFieldEqualToPlaceholder(_ identifier: String, type: FieldType = .textField) {
        let field = getField(identifier, type: type)
        let placeholderValue = field.placeholderValue ?? ""
        XCTAssertEqual(
            field.value as? String ?? "",
            placeholderValue,
            "Field '\(identifier)' value does not match expected value '\(placeholderValue)'."
        )
    }
}
