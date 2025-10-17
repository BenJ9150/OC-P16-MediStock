//
//  AccountView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 17/10/2025.
//

import SwiftUI

struct AccountView: View {

    @EnvironmentObject var session: SessionViewModel
    @State private var showSignOutAlert = false

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .accessibilityHidden(true)
            }
            .roundedBackground()

            Spacer()

            Button("Sign out", role: .destructive) {
                showSignOutAlert.toggle()
            }
            .accessibilityIdentifier("SignOutButton")
            .buttonStyle(MediPlainButtonStyle())
            .padding(.all, 24)
        }
        .mediBackground()
        .navigationTitle("My account")
        .alert("Sign out?", isPresented: $showSignOutAlert) {
            signOutButtonAlert
        }
    }

    private var signOutButtonAlert: some View {
        Button("Sign out", role: .destructive) {
            session.signOut()
        }
        .accessibilityIdentifier("signOutButtonAlert")
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    NavigationStack {
        AccountView()
    }
}
