//
//  UITestsExtensions.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 25/09/2025.
//

import XCTest

extension XCUIApplication {

    func assertStaticTextExists(_ label: String) {
        let element = staticTexts[label]
        XCTAssertTrue(element.waitForExistence(timeout: 2), "\"\(label)\" doesn't exist")
    }

    func assertStaticTextsCount(_ matching: String, count: Int) {
        let texts = staticTexts.matching(identifier: matching)
        _ = texts.firstMatch.waitForExistence(timeout: 2)
        XCTAssertEqual(texts.count, count)
    }
}
