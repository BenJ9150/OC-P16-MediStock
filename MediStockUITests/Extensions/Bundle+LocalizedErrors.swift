//
//  Bundle+LocalizedErrors.swift
//  MediStockUITests
//
//  Created by Benjamin LEFRANCOIS on 12/12/2025.
//

import Foundation

extension Bundle {

    static func uiLocalizedError(_ key: String) -> String {
        return Bundle(for: SignInUITests.self).localizedString(
            forKey: key,
            value: nil,
            table: "Errors"
        )
    }

    static func uiLocalizedDeleteError(_ appError: String) -> String {
        let baseMessage = uiLocalizedError(appError)
        let template = uiLocalizedError("deleteErrorMessage %@")
        return String(format: template, baseMessage)
    }

    static func uiLocalizedSendHistoryError(_ appError: String) -> String {
        let baseMessage = uiLocalizedError(appError)
        let template = uiLocalizedError("sendHistoryErrorMessage %@")
        return String(format: template, baseMessage)
    }
}
