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
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(SessionViewModel())
    }
}
