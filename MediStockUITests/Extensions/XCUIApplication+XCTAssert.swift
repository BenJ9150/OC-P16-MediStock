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
        XCTAssertEqual(element.label, label)
    }

    func assertStockActionExists(new: Int, old: Int, name: String) {
        let amount = new - old
        let label = "\(amount > 0 ? "Increased" : "Decreased") stock of \(name) by \(amount)"
        let element = staticTexts[label]
        XCTAssertEqual(element.label, label)
    }

    func assertStaticTextsCount(_ matching: String, count: Int) {
        let texts = staticTexts.matching(identifier: matching)
        XCTAssertEqual(texts.count, count)
    }

    func assertField(_ identifier: String, equalTo value: String, type: FieldType = .textField) {
        let field = getField(identifier, type: type)
        XCTAssertEqual(field.value as? String ?? "", value)
    }
}

