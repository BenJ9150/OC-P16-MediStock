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
        let stringResource: LocalizedStringResource = {
            switch self {
            case .emptyField: return .Errors.emptyFieldError
            case .invalidCredentials: return .Errors.invalidCredentialsError
            case .emailAlreadyInUse: return .Errors.emailAlreadyInUseError
            case .invalidEmailFormat: return .Errors.invalidEmailFormatError
            case .networkError: return .Errors.networkError
            case .weakPassword: return .Errors.weakPasswordError
            case .unknown: return .Errors.unknownError
            }
        }()
        return String(localized: stringResource)
    }

    var deleteErrorMessage: String {
        return String(localized: .Errors.deleteErrorMessage(userMessage))
    }

    var sendHistoryErrorMessage: String {
        return String(localized: .Errors.sendHistoryErrorMessage(userMessage))
    }
}
