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

    init() {
#if DEBUG
        let authRepo: AuthRepository = {
            if NSClassFromString("XCTest") == nil {
                return FirebaseAuthRepo()
            }
            return PreviewAuthRepo(isConnected: false)
        }()
#else
        let authRepo: AuthRepository = FirebaseAuthRepo()
#endif
        self._session = StateObject(wrappedValue: SessionViewModel(authRepo: authRepo))
    }

    var body: some Scene {
        WindowGroup {
            if session.firstLoading {
                ProgressView()
            } else if session.session != nil {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .environmentObject(session)
    }
}
