import SwiftUI

struct LoginView: View {

    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @EnvironmentObject var session: SessionViewModel

    @FocusState private var pwdIsFocused: Bool
    @AccessibilityFocusState private var isLoginFocused: Bool

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
                                    colors: [.accent, .accent.opacity(reduceTransparency ? 1 : 0.2)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .frame(width: 100)
                    .padding(.top, 80)
                    .accessibilityHidden(true)
                
                Text("MediStock")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(.accent)
                    .accessibilityFocusOnAppear()
                
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
                        .onSubmit {
                            pwdIsFocused = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isLoginFocused = true
                            }
                        }
                    
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
            .accessibilityFocused($isLoginFocused)

            ErrorView(message: session.signUpError)
            Button {
                Task { await session.signUp(email: email, password: password) }
            } label: {
                Text("Sign Up")
                    .underline()
                    .baselineOffset(6)
                    .frame(minHeight: 44)
            }
            .accessibilityIdentifier("SignUpButton")
            .padding(.vertical, 4)
        }
        .buttonLoader(isLoading: $session.isLoading)
        .padding(.top)
    }
}

// MARK: - Preview

#Preview(traits: .previewEnvironment()) {
    LoginView()
}
