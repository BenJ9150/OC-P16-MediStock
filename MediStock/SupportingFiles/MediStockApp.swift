//
//  MediStockApp.swift
//  MediStock
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

import SwiftUI

@main
struct MediStockApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var session: SessionViewModel

    private let dbRepo: DatabaseRepository = {
#if DEBUG
        if AppFlags.isUITests {
            return PreviewDatabaseRepo()
        }
#endif
        return FirestoreRepo()
    }()

    init() {
        let authRepo: AuthRepository = {
#if DEBUG
            if NSClassFromString("XCTest") != nil {
                return PreviewAuthRepo(isConnected: false)
            }
            if AppFlags.isUITests {
                return PreviewAuthRepo(isConnected: !AppFlags.isTestingAuth, error: AppFlags.isTestingAuthError)
            }
#endif
            return FirebaseAuthRepo()
        }()
        self._session = StateObject(wrappedValue: SessionViewModel(authRepo: authRepo))
    }

    var body: some Scene {
        WindowGroup {
            if session.firstLoading {
                ProgressView()
            } else if session.session != nil {
                MainTabView(dbRepo: dbRepo)
            } else {
                LoginView()
            }
        }
        .environmentObject(session)
    }
}
