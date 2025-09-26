import SwiftUI

struct LoginView: View {

    @EnvironmentObject var session: SessionViewModel

    @FocusState private var pwdIsFocused: Bool
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 16) {
            TextFieldView("Email", text: $email, error: $session.emailError)
                .textInputAutocapitalization(.never)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .submitLabel(.next)
                .onSubmit { pwdIsFocused = true }

            TextFieldView("Password", text: $password, error: $session.pwdError, isSecure: true)
                .textInputAutocapitalization(.never)
                .textContentType(.password)
                .submitLabel(.done)
                .focused($pwdIsFocused)
                .onSubmit { pwdIsFocused = false }

            VStack(spacing: 16) {
                button("Login", error: session.signInError) {
                    await session.signIn(email: email, password: password)
                }
                .accessibilityIdentifier("SignInButton")
                button("Sign Up", error: session.signUpError) {
                    await session.signUp(email: email, password: password)
                }
                .accessibilityIdentifier("SignUpButton")
            }
            .opacity(session.isLoading ? 0 : 1)
            .overlay {
                ProgressView()
                    .opacity(session.isLoading ? 1 : 0)
            }
            .padding(.top)
        }
        .padding()
    }
}

// MARK: Buttons

private extension LoginView {

    func button(_ title: String, error: String?, action: @escaping () async -> Void) -> some View {
        VStack {
            ErrorView(message: error)
            Button {
                Task { await action() }
            } label: {
                Text(title)
            }
        }
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    LoginView()
}
