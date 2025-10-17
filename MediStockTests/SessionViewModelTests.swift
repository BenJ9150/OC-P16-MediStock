//
//  SessionViewModelTests.swift
//  MediStockTests
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

import XCTest
@testable import MediStock

@MainActor final class SessionViewModelTests: XCTestCase {

    // MARK: Listen Session

    func test_GivenUserIsNotConnected_WhenListening_ThenSessionIsNil() {
        // Given
        let authRepo = AuthRepoMock(isConnected: false)

        // When starting the listener in the initialization of ViewModel
        let viewModel = SessionViewModel(authRepo: authRepo)

        // Then
        XCTAssertNil(viewModel.session)
        XCTAssertFalse(viewModel.firstLoading)
    }

    func test_GivenUserIsConnected_WhenListening_ThenSessionExists() {
        // Given
        let authRepo = AuthRepoMock(isConnected: true)

        // When starting the listener in the initialization of ViewModel
        let viewModel = SessionViewModel(authRepo: authRepo)

        // Then
        XCTAssertNotNil(viewModel.session)
    }

    func test_GivenListenerIsActive_WhenViewModelDeinitialized_ThenStopListening() {
        // Given
        let authRepo = AuthRepoMock(isConnected: true)
        var viewModel: SessionViewModel! = SessionViewModel(authRepo: authRepo)
        XCTAssertNotNil(authRepo.completion)

        // When
        viewModel = nil

        // Then
        XCTAssertNil(viewModel)
        XCTAssertNil(authRepo.completion)
    }
}

// MARK: Sign up

extension SessionViewModelTests {

    func test_GivenUserIsNotConnected_WhenSigningUp_ThenSessionExists() async {
        // Given
        let authRepo = AuthRepoMock(isConnected: false)
        let viewModel = SessionViewModel(authRepo: authRepo)
        XCTAssertNil(viewModel.session)

        // When
        await viewModel.signUp(email: "test@medistock.com", password: "123456")

        // Then
        XCTAssertNotNil(viewModel.session)
    }

    func test_GivenEmailAlreadyUsed_WhenSigningUp_ThenSessionIsNilAndErrorExists() async {
        // Given
        let authRepo = AuthRepoMock(isConnected: false, error: AppError.emailAlreadyInUse)
        let viewModel = SessionViewModel(authRepo: authRepo)

        // When
        await viewModel.signUp(email: "test@medistock.com", password: "123456")

        // Then
        XCTAssertNil(viewModel.session)
        XCTAssertEqual(viewModel.signUpError, AppError.emailAlreadyInUse.userMessage)
    }

    func test_GivenWeakPassword_WhenSigningUp_ThenSessionIsNilAndErrorExists() async {
        // Given
        let authRepo = AuthRepoMock(isConnected: false, error: AppError.weakPassword)
        let viewModel = SessionViewModel(authRepo: authRepo)

        // When
        await viewModel.signUp(email: "test@medistock.com", password: "12")

        // Then
        XCTAssertNil(viewModel.session)
        XCTAssertEqual(viewModel.signUpError, AppError.weakPassword.userMessage)
    }

    func test_GivenEmptyfields_WhenSigningUp_ThenErrorsExist() async {
        // Given
        let authRepo = AuthRepoMock(isConnected: false)
        let viewModel = SessionViewModel(authRepo: authRepo)

        // When
        await viewModel.signUp(email: "", password: "")

        // Then
        XCTAssertEqual(viewModel.emailError, AppError.emptyField.userMessage)
        XCTAssertEqual(viewModel.pwdError, AppError.emptyField.userMessage)
    }
}

// MARK: Sign in

extension SessionViewModelTests {

    func test_GivenUserIsNotConnected_WhenSigningIn_ThenSessionExists() async {
        // Given
        let authRepo = AuthRepoMock(isConnected: false)
        let viewModel = SessionViewModel(authRepo: authRepo)
        XCTAssertNil(viewModel.session)

        // When
        await viewModel.signIn(email: "test@medistock.com", password: "123456")

        // Then
        XCTAssertNotNil(viewModel.session)
    }

    func test_GivenInvalidCredentials_WhenSigningIn_ThenSessionIsNilAndErrorExists() async {
        // Given
        let authRepo = AuthRepoMock(isConnected: false, error: AppError.invalidCredentials)
        let viewModel = SessionViewModel(authRepo: authRepo)

        // When
        await viewModel.signIn(email: "test@medistock.com", password: "123456")

        // Then
        XCTAssertNil(viewModel.session)
        XCTAssertEqual(viewModel.signInError, AppError.invalidCredentials.userMessage)
    }

    func test_GivenInvalidEmailFormat_WhenSigningIn_ThenSessionIsNilAndErrorExists() async {
        // Given
        let authRepo = AuthRepoMock(isConnected: false, error: AppError.invalidEmailFormat)
        let viewModel = SessionViewModel(authRepo: authRepo)

        // When
        await viewModel.signIn(email: "test@medistock", password: "123456")

        // Then
        XCTAssertNil(viewModel.session)
        XCTAssertEqual(viewModel.signInError, AppError.invalidEmailFormat.userMessage)
    }

    func test_GivenEmptyfields_WhenSigningIn_ThenErrorsExist() async {
        // Given
        let authRepo = AuthRepoMock(isConnected: false)
        let viewModel = SessionViewModel(authRepo: authRepo)

        // When
        await viewModel.signIn(email: "", password: "")

        // Then
        XCTAssertEqual(viewModel.emailError, AppError.emptyField.userMessage)
        XCTAssertEqual(viewModel.pwdError, AppError.emptyField.userMessage)
    }
}

// MARK: Sign out

extension SessionViewModelTests {

    func test_GivenUserIsConnected_WhenSigningOut_ThenSessionIsNil() {
        // Given
        let authRepo = AuthRepoMock(isConnected: true)
        let viewModel = SessionViewModel(authRepo: authRepo)
        XCTAssertNotNil(viewModel.session)

        // When
        viewModel.signOut()

        // Then
        XCTAssertNil(viewModel.session)
    }

    func test_GivenThereIsAnError_WhenSigningOut_ThenSessionAndErrorExist() {
        // Given
        let authRepo = AuthRepoMock(isConnected: true, error: AppError.networkError)
        let viewModel = SessionViewModel(authRepo: authRepo)

        // When
        viewModel.signOut()

        // Then
        XCTAssertNotNil(viewModel.session)
        XCTAssertEqual(viewModel.signOutError, AppError.networkError.userMessage)
    }
}

// MARK: Update user name

extension SessionViewModelTests {

    func test_GivenUserIsConnected_WhenUpdatingName_ThenNewNameExist() async {
        // Given
        let authRepo = AuthRepoMock(isConnected: true)
        let viewModel = SessionViewModel(authRepo: authRepo)
        XCTAssertNotNil(viewModel.session)

        // When
        viewModel.displayName = "Test New Name"
        await viewModel.updateName()

        // Then
        XCTAssertEqual(viewModel.session?.displayName, "Test New Name")
    }

    func test_GivenThereIsAnError_WhenUpdatingName_ThenOldNameIsRestoredAndErrorExist() async {
        // Given
        let authRepo = AuthRepoMock(isConnected: true, error: AppError.networkError)
        let viewModel = SessionViewModel(authRepo: authRepo)
        XCTAssertNotNil(viewModel.session)

        // When
        viewModel.displayName = "Test New Name"
        await viewModel.updateName()

        // Then
        XCTAssertEqual(viewModel.displayName, "user_display_name_mock")
        XCTAssertEqual(viewModel.updateNameError, AppError.networkError.userMessage)
    }
}
