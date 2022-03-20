//
//  ContentView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/19/22.
//

import SwiftUI
import Firebase

struct HomeView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @State var signOutProcessing = false
    
    var body: some View {
        NavigationView {
            MonthView(viewModel: .init())
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if signOutProcessing {
                            ProgressView()
                        } else {
                            Button() {
                                signOutUser()
                            }label: {
                                Image(systemName: "arrowshape.turn.up.backward")
                            }
                        }
                    }
                }
        }
        .accentColor(.black)
        .navigationViewStyle(.stack)
    }
    
    func signOutUser() {
        signOutProcessing = true
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            withAnimation {
                viewRouter.changePage(.signInPage)
            }
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
            signOutProcessing = false
        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .colorScheme(.light)
            .preferredColorScheme(.light)
    }
}
