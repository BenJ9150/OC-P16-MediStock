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
    @StateObject private var session = SessionViewModel()
    
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
