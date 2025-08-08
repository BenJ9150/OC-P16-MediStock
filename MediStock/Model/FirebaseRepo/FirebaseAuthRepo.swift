//
//  FirebaseAuthRepo.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 01/08/2025.
//

import Foundation
import FirebaseAuth

class FirebaseAuthRepo: AuthRepository {

    private var handle: AuthStateDidChangeListenerHandle?

    func listen(_ completion: @escaping (AuthUser?) -> ()) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            completion(user)
        }
    }

    func stopListening() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signUp(email: String, password: String) async throws -> AuthUser {
        try await Auth.auth().createUser(withEmail: email, password: password).user
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        try await Auth.auth().signIn(withEmail: email, password: password).user
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}

// MARK: Extension for User

extension FirebaseAuth.User: AuthUser {}
