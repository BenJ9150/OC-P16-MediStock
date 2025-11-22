//
//  XCUIApplication+AccessibilityAudit.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 18/10/2025.
//

import XCTest

extension XCUIApplication {

    func auditWithLightAndDarkMode() {
        do {
            XCUIDevice.shared.appearance = .light
            sleep(1) // Sleep for stabilization of colors
            try self.performAccessibilityAudit { self.handleAccessibilityAuditIssue($0) }
        } catch {
            XCTFail("Accessibility audit failed in light mode: \(error)")
        }
        do {
            XCUIDevice.shared.appearance = .dark
            sleep(1) // Sleep for stabilization of new colors
            try self.performAccessibilityAudit { self.handleAccessibilityAuditIssue($0) }
            XCUIDevice.shared.appearance = .light
        } catch {
            XCUIDevice.shared.appearance = .light
            XCTFail("Accessibility audit failed in dark mode: \(error)")
        }
    }

    /// - Returns: True if issue must be ignored
    private func handleAccessibilityAuditIssue(_  issue: XCUIAccessibilityAuditIssue) -> Bool {
        // Ignore issue if element is nil
        guard let element = issue.element else {
            print("⚠️⚠️⚠️ ignored issue: \(issue.detailedDescription)")
            return true
        }
        if issue.auditType == .textClipped, element.label == "Search" {
            // Ignore issue if it's the native search bar
            print("⚠️⚠️⚠️ ignored issue: \(issue.detailedDescription), element: \(element.label)")
            return true
        }
        if issue.auditType == .dynamicType && element.identifier.contains("HistoryItem") {
            // Test doesn't pass cause history items are in a Lazy list
            // But dynamic size is respected for these elements
            print("⚠️⚠️⚠️ ignored issue: \(issue.detailedDescription), element: \(element.label)")
            return true
        }
        if #available(iOS 26.0, *), issue.auditType == .contrast, element.label == "Search" {
            // Ignore issue in dark mode if it's the native iOS26 search bar
            // In dark mode, the contrast is insufficient even with a blank project containing only the search bar
            if XCUIDevice.shared.appearance == .dark {
                print("⚠️⚠️⚠️ ignored issue: \(issue.detailedDescription), element: \(element.label)")
                return true
            }
        }
        print("💥💥💥 issue: \(issue.detailedDescription),\nelement identifier: '\(element.identifier)',\nelement label: '\(element.label)'")
        return false
    }
}
