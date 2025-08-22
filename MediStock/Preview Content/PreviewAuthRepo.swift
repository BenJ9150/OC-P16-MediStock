//
//  PreviewAuthRepo.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 08/08/2025.
//

import Foundation

class PreviewAuthRepo: AuthRepository {

    var user: AuthUser?
    
    init() {
        self.user = PreviewAuthUser(uid: "preview_user_id")
    }

    func listen(_ completion: @escaping ((AuthUser)?) -> ()) {
        completion(nil)
    }
    
    func stopListening() {}
    
    func signUp(email: String, password: String) async throws -> AuthUser {
        user!
    }
    
    func signIn(email: String, password: String) async throws -> AuthUser {
        user!
    }
    
    func signOut() throws {
        user = nil
    }
}
