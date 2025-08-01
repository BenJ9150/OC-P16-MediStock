//
//  AuthRepository.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 01/08/2025.
//

import Foundation

protocol AuthRepository {
    func listen(_ completion: @escaping (AuthUser?) -> ())
    func signUp(email: String, password: String) async throws -> AuthUser
    func signIn(email: String, password: String) async throws -> AuthUser
    func signOut() throws
    func unbind()
}

protocol AuthUser {
    var uid: String { get }
    var email: String? { get }
}
