//
//  SessionViewModel.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 01/08/2025.
//

import SwiftUI

@MainActor class SessionViewModel: ObservableObject {
    
    @Published var session: AuthUser?
    @Published var firstLoading = true
    
    private let authRepo: AuthRepository
    
    // MARK: Init
    
    init(authRepo: AuthRepository = FirebaseAuthRepo()) {
        self.authRepo = authRepo
        listen()
    }
    
    deinit {
        authRepo.stopListening()
    }
}

// MARK: Public

extension SessionViewModel {

    func signUp(email: String, password: String) async {
        do {
            try await authRepo.signUp(email: email, password: password)
        } catch {
            print("💥 signUp error: \(error.localizedDescription)")
        }
    }

    func signIn(email: String, password: String) async {
        do {
            try await authRepo.signIn(email: email, password: password)
        } catch {
            print("💥 signIn error: \(error.localizedDescription)")
        }
    }

    func signOut() {
        do {
            try authRepo.signOut()
        } catch {
            print("💥 signOut error: \(error.localizedDescription)")
        }
    }
}

// MARK: private

private extension SessionViewModel {

    func listen() {
        authRepo.listen { user in
            self.session = user
            self.firstLoading = false
        }
    }
}
