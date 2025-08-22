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

    func test_GivenThereIsAnError_WhenSigningUp_ThenSessionIsNil() async {
        // Given
        let authRepo = AuthRepoMock(isConnected: false, error: true)
        let viewModel = SessionViewModel(authRepo: authRepo)

        // When
        await viewModel.signUp(email: "test@medistock.com", password: "123456")

        // Then
        XCTAssertNil(viewModel.session)
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

    func test_GivenThereIsAnError_WhenSigningIn_ThenSessionIsNil() async {
        // Given
        let authRepo = AuthRepoMock(isConnected: false, error: true)
        let viewModel = SessionViewModel(authRepo: authRepo)

        // When
        await viewModel.signIn(email: "test@medistock.com", password: "123456")

        // Then
        XCTAssertNil(viewModel.session)
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

    func test_GivenThereIsAnError_WhenSigningOut_ThenSessionExists() {
        // Given
        let authRepo = AuthRepoMock(isConnected: true, error: true)
        let viewModel = SessionViewModel(authRepo: authRepo)

        // When
        viewModel.signOut()

        // Then
        XCTAssertNotNil(viewModel.session)
    }
}
