//
//  AuthRepository.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 01/08/2025.
//

import Foundation

protocol AuthRepository {

    /// The completion is guaranteed to be called on the main thread.
    func listen(_ completion: @MainActor @escaping (AuthUser?) -> ())
    func stopListening()

    func signUp(email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() throws
}

protocol AuthUser {
    var uid: String { get }
    var email: String? { get }
}
