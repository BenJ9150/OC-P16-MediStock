//
//  AppFlags.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 25/09/2025.
//

import Foundation

#if DEBUG

struct AppFlags {

    static let uiTesting = "--ui_testing"
    static let uiTestingAuth = "--ui_testing_auth"
    static let uiTestingAuthError = "--ui_testing_auth_error"
    static let uiTestingUpdateError = "--ui_testing_update_error"
    static let uiTestingListenMedicineError = "--ui_testing_listen_medicine_error"
    static let uiTestingListenHistoryError = "--ui_testing_listen_history_error"
    static let uiTestingSendHistoryError = "--ui_testing_send_history_error"

    static var isTestingAuth: Bool {
        CommandLine.arguments.contains(uiTestingAuth)
    }

    static var isTestingAuthError: Bool {
        CommandLine.arguments.contains(uiTestingAuthError)
    }

    static var isTestingUpdateError: Bool {
        CommandLine.arguments.contains(uiTestingUpdateError)
    }

    static var isTestingListenMedicineError: Bool {
        CommandLine.arguments.contains(uiTestingListenMedicineError)
    }

    static var isTestingListenHistoryError: Bool {
        CommandLine.arguments.contains(uiTestingListenHistoryError)
    }

    static var isTestingSendHistoryError: Bool {
        CommandLine.arguments.contains(uiTestingSendHistoryError)
    }

    static var isUITests: Bool {
        if CommandLine.arguments.contains(uiTesting) { return true }
        if CommandLine.arguments.contains(uiTestingAuth) { return true }
        if CommandLine.arguments.contains(uiTestingAuthError) { return true }
        if CommandLine.arguments.contains(uiTestingUpdateError) { return true }
        if CommandLine.arguments.contains(uiTestingListenMedicineError) { return true }
        if CommandLine.arguments.contains(uiTestingListenHistoryError) { return true }
        if CommandLine.arguments.contains(uiTestingSendHistoryError) { return true }
        return false
    }
}

#endif
