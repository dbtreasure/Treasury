//
//  SignUpView.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var viewModel: ViewModel
    
    @State var email = ""
    @State var password = ""
    @State var passwordConfirmation = ""
    
    @State var signUpProcessing = false
    @State var signUpErrorMessage = ""
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            LogoView()
            HStack {
                Text("Treasury")
                    .bold()
                    .font(.largeTitle)
            }
            Spacer()
            SignUpCredentialFields(email: $email, password: $password, passwordConfirmation: $passwordConfirmation)
            Button(action: {
                Task {
                    await signUpUser(userEmail: email, userPassword: password)
                }
            }) {
                Text("Sign Up")
                    .bold()
                    .frame(width: 360, height: 50)
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .foregroundStyle(.black)
            }.disabled(!signUpProcessing && !email.isEmpty && !password.isEmpty && !passwordConfirmation.isEmpty && password == passwordConfirmation ? false : true)
            if signUpProcessing {
                ProgressView()
            }
            if !signUpErrorMessage.isEmpty {
                Text("Failed creating account: \(signUpErrorMessage)")
                    .foregroundColor(.red)
            }
            Spacer()
            HStack {
                Text("Already have an account?")
                Button(action: {
                    viewRouter.changePage(.signInPage)
                }) {
                    Text("Log In")
                        .bold()
                        .foregroundStyle(.black)
                }
            }
                .opacity(0.9)
        }
        .padding(.bottom)
    }
    
    @MainActor
    func signUpUser(userEmail: String, userPassword: String) async {
        signUpProcessing = true
        do {
           let signupResult = try await Auth.auth().createUser(withEmail: userEmail, password: userPassword)
            let user = signupResult.user
            
            print("User created")
            Task {
                await viewModel.addBudget(user: user)
                signUpProcessing = false
                viewRouter.changePage(.homePage)
            }
            
        }
        catch {
            signUpErrorMessage = error.localizedDescription
            signUpProcessing = false
        }
        
    }

}

extension SignUpView {
    class ViewModel: ObservableObject {
        let db = Firestore.firestore()
        
        @MainActor
        func addBudget(user: User) async {
            do {
                let budget = Budget(ownerIds: [user.uid])
                try await db.collection(budget.collectionId()).addDocument(from: budget)
            } catch {
                return
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(viewModel: .init())
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

