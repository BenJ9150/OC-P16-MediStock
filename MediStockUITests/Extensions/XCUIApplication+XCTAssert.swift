//
//  XCUIApplication+XCTAssert.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 05/10/2025.
//

import XCTest

extension XCUIApplication {

    func assertStaticTextExists(_ label: String) {
        let element = staticTexts[label]
        XCTAssertTrue(element.waitForExistence(timeout: 1), "Static text '\(label)' does not exist or did not appear in time.")
        XCTAssertEqual(element.label, label, "Static text label does not match expected value '\(label)'.")
    }

    func assertStockActionExists(new: Int, old: Int, name: String) {
        let amount = new - old
        let label = "\(amount > 0 ? "Increased" : "Decreased") stock of \(name) by \(amount)"
        let element = staticTexts[label]
        XCTAssertTrue(element.waitForExistence(timeout: 1), "Stock action label '\(label)' does not exist or did not appear in time.")
        XCTAssertEqual(element.label, label, "Stock action label does not match expected value '\(label)'.")
    }

    func assertStaticTextsCount(_ matching: String, count: Int) {
        let texts = staticTexts.matching(identifier: matching)
        XCTAssertTrue(texts.firstMatch.waitForExistence(timeout: 1), "No static text found matching identifier '\(matching)'.")
        XCTAssertEqual(texts.count, count, "Expected \(count) static texts matching identifier '\(matching)', but found \(texts.count).")
    }

    func assertField(_ identifier: String, equalTo value: String, type: FieldType = .textField) {
        let field = getField(identifier, type: type)
        XCTAssertEqual(field.value as? String ?? "", value, "Field '\(identifier)' value does not match expected value '\(value)'.")
    }
}
