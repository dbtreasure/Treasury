//
//  SignInView.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import Foundation
import SwiftUI
import Firebase

struct SignInView: View {
    @State var signUpProcessing = false
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var email = ""
    @State var password = ""
    
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
            SignInCredentialFields(email: $email, password: $password)
            Button(action: {
                
            }) {
                Text("Log In")
                    .bold()
                    .frame(width: 360, height: 50)
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .foregroundStyle(.black)
            }
            Spacer()
            HStack {
                Text("Don't have an account?")
                Button(action: {
                    viewRouter.currentPage = .signUpPage
                }) {
                    Text("Sign Up")
                        .bold()
                        .foregroundStyle(.black)
                }
            }
                .opacity(0.9)
        }
            .padding()
    }
}

struct LogoView: View {
    var body: some View {
        Image("Logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150, height: 150)
            .cornerRadius(20)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

struct SignInCredentialFields: View {
    
    @Binding var email: String
    @Binding var password: String
    
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
                .padding(.bottom, 30)
        }
    }
}
