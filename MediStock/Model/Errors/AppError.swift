//
//  AppError.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 19/09/2025.
//

import Foundation

enum AppError: Int, Error {
    case emptyField
    case invalidCredentials = 17004
    case emailAlreadyInUse = 17007
    case invalidEmailFormat = 17008
    case networkError = 17020
    case weakPassword = 17026
    case unknown

    init(forCode code: Int) {
        self = AppError(rawValue: code) ?? .unknown
    }

    var userMessage: String {
        switch self {
        case .emptyField: return "This field is required."
        case .invalidCredentials: return "Incorrect email or password"
        case .emailAlreadyInUse: return "This email is already linked to an account"
        case .invalidEmailFormat: return "Please enter a valid email address"
        case .networkError: return "A network error occurred. Please check your internet connection and try again"
        case .weakPassword: return "Password must have at least 8 characters, an uppercase letter, a number, and a special character"
        case .unknown: return "An error has occured, please try again later"
        }
    }

    var deleteErrorMessage: String {
        "An error occurred while deleting:\n\(userMessage)"
    }

    var sendHistoryErrorMessage: String {
        "An error occurred while sending history:\n\(userMessage)"
    }
}
