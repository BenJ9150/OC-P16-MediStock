//
//  PreviewAuthRepo.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 08/08/2025.
//

import Foundation

class PreviewAuthRepo: AuthRepository {

    private var user: AuthUser?

    private var error: AppError?
    private var completion: ((AuthUser?) -> ())?
    
    init(isConnected: Bool = true, error: AppError? = nil) {
        self.error = error
        self.user = isConnected ? user() : nil
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
        user = user(email: email)
        completion?(user)
    }
    
    func signIn(email: String, password: String) async throws {
        try canPerform()
        user = user(email: email)
        completion?(user)
    }
    
    func signOut() throws {
        try canPerform()
        user = nil
        completion?(user)
    }
}

private extension PreviewAuthRepo {

    func canPerform() throws {
        if let appError = error {
            throw appError
        }
    }

    func user(email: String? = nil) -> AuthUser {
        PreviewAuthUser(uid: "user_id_mock")
    }
}
