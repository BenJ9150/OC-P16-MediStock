//
//  AuthRepoMock.swift
//  MediStockTests
//
//  Created by Benjamin LEFRANCOIS on 22/08/2025.
//

import Foundation
@testable import MediStock

class AuthRepoMock: AuthRepository {

    private var user: AuthUser?

    private var error: AppError?
    var completion: ((AuthUser?) -> ())?
    
    init(isConnected: Bool, error: AppError? = nil, userName: String? = "user_display_name_mock") {
        self.error = error
        self.user = isConnected ? AuthUserMock(displayName: userName) : nil
    }

    func listen(_ completion: @escaping ((AuthUser)?) -> ()) {
        self.completion = completion
        completion(user)
    }
    
    func stopListening() {
        completion = nil
    }
    
    func signUp(email: String, password: String) async throws {
        try canPerform()
        user = AuthUserMock(email: email)
        completion?(user)
    }
    
    func signIn(email: String, password: String) async throws {
        try canPerform()
        user = AuthUserMock(email: email)
        completion?(user)
    }
    
    func signOut() throws {
        try canPerform()
        user = nil
        completion?(user)
    }

    func updateDisplayName(_ displayName: String) async throws {
        try canPerform()
        user = AuthUserMock(displayName: displayName)
        completion?(user)
    }
}

private extension AuthRepoMock {

    func canPerform() throws {
        if let appError = error {
            throw appError
        }
    }
}
