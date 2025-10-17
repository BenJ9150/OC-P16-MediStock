import SwiftUI

struct LoginView: View {

    @EnvironmentObject var session: SessionViewModel

    @FocusState private var pwdIsFocused: Bool
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image("AppMainIcon")
                    .resizable()
                    .scaledToFit()
                    .background(alignment: .center) {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [.accent, .accent.opacity(0.2)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .frame(width: 100)
                    .padding(.top, 80)
                
                Text("MediStock")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(.accent)
                
                VStack(spacing: 16) {
                    TextFieldView("Email", text: $email, error: $session.emailError, label: .next)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .padding(.top, 10)
                        .onSubmit { pwdIsFocused = true }

                    TextFieldView("Password", text: $password, error: $session.pwdError, label: .done, isSecure: true)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .autocorrectionDisabled()
                        .textContentType(.password)
                        .focused($pwdIsFocused)
                        .onSubmit { pwdIsFocused = false }
                    
                    loginButtons
                }
                .roundedBackground()
            }
        }
        .scrollIndicators(.hidden)
        .mediBackground()
        .onTapGesture {
            hideKeyboard()
        }
    }
}

// MARK: Buttons

private extension LoginView {

    var loginButtons: some View {
        VStack(spacing: 16) {
            ErrorView(message: session.signInError)
            Button("Login") {
                Task { await session.signIn(email: email, password: password) }
            }
            .buttonStyle(MediPlainButtonStyle())
            .accessibilityIdentifier("SignInButton")

            ErrorView(message: session.signUpError)
            Button("Sign Up") {
                Task { await session.signUp(email: email, password: password) }
            }
            .accessibilityIdentifier("SignUpButton")
            .padding(.vertical)
        }
        .buttonLoader(isLoading: $session.isLoading)
        .padding(.top)
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    LoginView()
}
