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

    @Published var isLoading = false

    @Published var emailError: String?
    @Published var pwdError: String?
    @Published var signUpError: String?
    @Published var signInError: String?
    @Published var signOutError: String?

    @Published var displayName = ""
    @Published var updatingUserName = false
    @Published var updateNameError: String?

    private let authRepo: AuthRepository
    
    // MARK: Init
    
    init(authRepo: AuthRepository) {
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
        guard validCredentials(email: email, password: password) else {
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try await authRepo.signUp(email: email, password: password)
        } catch let nsError as NSError {
            print("💥 signUp error \(nsError.code): \(nsError.localizedDescription)")
            signUpError = AppError(forCode: nsError.code).userMessage
        }
    }

    func signIn(email: String, password: String) async {
        guard validCredentials(email: email, password: password) else {
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try await authRepo.signIn(email: email, password: password)
        } catch let nsError as NSError {
            print("💥 signIn error \(nsError.code): \(nsError.localizedDescription)")
            signInError = AppError(forCode: nsError.code).userMessage
        }
    }

    func signOut() {
        signOutError = nil
        do {
            try authRepo.signOut()
        } catch let nsError as NSError {
            print("💥 signOut error \(nsError.code): \(nsError.localizedDescription)")
            signOutError = AppError(forCode: nsError.code).userMessage
        }
    }

    func updateName() async {
        updateNameError = nil
        updatingUserName = true
        defer { updatingUserName = false }
        do {
            try await authRepo.updateDisplayName(displayName)
        } catch let nsError as NSError {
            print("💥 updateUserName error \(nsError.code): \(nsError.localizedDescription)")
            updateNameError = AppError(forCode: nsError.code).userMessage
            displayName = session?.displayName ?? ""
        }
    }
}

// MARK: private

private extension SessionViewModel {

    func listen() {
        authRepo.listen { [weak self] user in
            self?.session = user
            self?.displayName = user?.displayName ?? ""
            self?.firstLoading = false
        }
    }

    func validCredentials(email: String, password: String) -> Bool {
        cleanErrors()
        emailError = email.isEmpty ? AppError.emptyField.userMessage : nil
        pwdError = password.isEmpty ? AppError.emptyField.userMessage : nil
        return !email.isEmpty && !password.isEmpty
    }

    func cleanErrors() {
        emailError = nil
        pwdError = nil
        signUpError = nil
        signInError = nil
        signOutError = nil
    }
}
