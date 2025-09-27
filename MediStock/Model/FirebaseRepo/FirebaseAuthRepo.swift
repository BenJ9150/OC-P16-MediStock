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

    func listen(_ completion: @MainActor @escaping (AuthUser?) -> ()) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            Task { @MainActor in
                completion(user)
            }
        }
    }

    func stopListening() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signUp(email: String, password: String) async throws {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch let nsError as NSError {
            if internalErrorContains("PASSWORD_DOES_NOT_MEET_REQUIREMENTS", nsError: nsError) {
                throw AuthErrorCode(.weakPassword)
            }
            throw nsError
        }
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}

// MARK: Firebase internal error

extension FirebaseAuthRepo {

    private func internalErrorContains(_ key: String, nsError: NSError) -> Bool {
        guard nsError.code == 17999 else {
            /// Not a Firebase internal error
            return false
        }
        /// Firebase error 17999: "An internal error has occurred, print and inspect the error details for more information."
        /// Try to find the given key in the internal error:

        let firebaseAuthErrorKey = "FIRAuthErrorUserInfoDeserializedResponseKey"
        if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError,
           let firebaseAuthError = underlyingError.userInfo[firebaseAuthErrorKey] as? [String: Any],
           let message = firebaseAuthError["message"] as? String {
            return message.contains(key)
        }
        return false
    }
}

// MARK: Extension for User

extension FirebaseAuth.User: AuthUser {}
