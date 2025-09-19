import SwiftUI

struct LoginView: View {

    @EnvironmentObject var session: SessionViewModel

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            VStack(spacing: 16) {
                Button {
                    Task { await session.signIn(email: email, password: password) }
                } label: {
                    Text("Login")
                }
                Button {
                    Task { await session.signUp(email: email, password: password) }
                } label: {
                    Text("Sign Up")
                }
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

// MARK: - Preview

@available(iOS 18.0, *)
#Preview(traits: .previewEnvironment()) {
    LoginView()
}
