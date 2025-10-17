//
//  AccountView.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 17/10/2025.
//

import SwiftUI

struct AccountView: View {

    @EnvironmentObject var viewModel: SessionViewModel

    @State private var showNameAlert = false
    @State private var showSignOutAlert = false

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .padding(.vertical)
                    .accessibilityHidden(true)

                TextFieldWithTitleView(
                    title: "Name",
                    text: $viewModel.displayName,
                    error: $viewModel.updateNameError,
                    loading: $viewModel.updatingUserName
                ) {
                    if viewModel.displayName != viewModel.session?.displayName {
                        showNameAlert.toggle()
                    }
                }
                .padding(.bottom, 10)
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
