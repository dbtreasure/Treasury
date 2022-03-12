//
//  SignUpView.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import SwiftUI
import Firebase

struct SignUpView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var email = ""
    @State var password = ""
    @State var passwordConfirmation = ""
    
    @State var signUpProcessing = false
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            HStack {
                Text("Treasury")
                    .bold()
                    .font(.largeTitle)
            }
            Spacer()
            SignUpCredentialFields(email: $email, password: $password, passwordConfirmation: $passwordConfirmation)
            Button(action: {
                signUpUser(userEmail: email, userPassword: password)
            }) {
                Text("Sign Up")
                    .bold()
                    .frame(width: 360, height: 50)
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .foregroundStyle(.black)
            }.disabled(!signUpProcessing && !email.isEmpty && !password.isEmpty && !passwordConfirmation.isEmpty && password == passwordConfirmation ? false : true)
            Spacer()
            HStack {
                Text("Already have an account?")
                Button(action: {
                    viewRouter.currentPage = .signInPage
                }) {
                    Text("Log In")
                        .bold()
                        .foregroundStyle(.black)
                }
            }
                .opacity(0.9)
        }
            .padding()
    }
    
    
    func signUpUser(userEmail: String, userPassword: String) {
            
        signUpProcessing = true
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
            guard error == nil else {
                signUpProcessing = false
                return
            }
            switch authResult {
            case .none:
                print("Could not create account.")
                signUpProcessing = false
            case .some(_):
                print("User created")
                signUpProcessing = false
                viewRouter.currentPage = .homePage
            }
        }
    }

}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

struct SignUpCredentialFields: View {
    
    @Binding var email: String
    @Binding var password: String
    @Binding var passwordConfirmation: String
    
    var body: some View {
        Group {
            TextField("Email", text: $email)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(10)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(10)
            SecureField("Confirm Password", text: $passwordConfirmation)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(10)
                .border(Color.red, width: passwordConfirmation != password ? 1 : 0)
                .padding(.bottom, 30)
        }
    }
}

