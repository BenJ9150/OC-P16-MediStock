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

    static var isTestingAuth: Bool {
        CommandLine.arguments.contains(uiTestingAuth)
    }

    static var isTestingAuthError: Bool {
        CommandLine.arguments.contains(uiTestingAuthError)
    }

    static var isUITests: Bool {
        if CommandLine.arguments.contains(uiTesting) { return true }
        if CommandLine.arguments.contains(uiTestingAuth) { return true }
        if CommandLine.arguments.contains(uiTestingAuthError) { return true }
        return false
    }
}

#endif
