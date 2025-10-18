//
//  AccountView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 17/10/2025.
//

import SwiftUI

struct AccountView: View {

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionViewModel

    @State private var showNameAlert = false
    @State private var showSignOutAlert = false

    var body: some View {
        ScrollView {
            VStack {
                accountDetails
                    .padding(.top)
                Button("Sign out", role: .destructive) {
                    showSignOutAlert.toggle()
                }
                .accessibilityIdentifier("SignOutButton")
                .buttonStyle(MediPlainButtonStyle())
                .padding(.all, 24)
            }
        }
        .scrollIndicators(.hidden)
        .mediBackground()
        .navigationTitle("My account")
        .alert("Sign out?", isPresented: $showSignOutAlert) {
            signOutButtonAlert
        }
        .alert(nameAlertDescription(), isPresented: $showNameAlert) {
            updateNameButtonAlert
            cancelNameButtonAlert
        }
    }

    private func nameAlertDescription() -> String {
        if viewModel.displayName.isEmpty {
            return "Are you sure you want to erase your name?"
        }
        return "'\(viewModel.displayName)'\nUpdate your new name?"
    }
}

// MARK: Account details

private extension AccountView {

    var accountDetails: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .padding(.top)
                .accessibilityHidden(true)

            if let email = viewModel.session?.email {
                Text(email)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .brightness(colorScheme == .dark ? 0 : -0.2) // for contrast
                    .accessibilityLabel("Your email: \(email)")
            }

            TextFieldWithTitleView(
                title: "Display name",
                text: $viewModel.displayName,
                error: $viewModel.updateNameError,
                loading: $viewModel.updatingUserName
            ) {
                if viewModel.displayName != viewModel.session?.displayName {
                    showNameAlert.toggle()
                }
            }
            .padding(.vertical, 10)
            
            Text("Your display name will be visible in your history entries.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .brightness(colorScheme == .dark ? 0 : -0.2) // for contrast
        }
        .roundedBackground()
    }
}

// MARK: Button alert

private extension AccountView {

    var signOutButtonAlert: some View {
        Button("Sign out", role: .destructive) {
            viewModel.signOut()
        }
        .accessibilityIdentifier("signOutButtonAlert")
    }

    var updateNameButtonAlert: some View {
        Button("Update", role: .destructive) {
            Task { await viewModel.updateName() }
        }
        .accessibilityIdentifier("updateNameButtonAlert")
    }

    var cancelNameButtonAlert: some View {
        Button("Cancel", role: .cancel) {
            viewModel.displayName = viewModel.session?.displayName ?? ""
        }
        .accessibilityIdentifier("cancelNameButtonAlert")
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    NavigationStack {
        AccountView()
    }
}
