//
//  IndexView.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import SwiftUI

struct IndexView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        switch viewRouter.currentPage {
        case .signUpPage:
            SignUpView(viewModel: .init()).padding([.leading, .trailing])
        case .signInPage:
            SignInView().padding([.leading, .trailing])
        case .homePage:
            HomeView()
        }
    }
}

struct IndexView_Previews: PreviewProvider {
    static var previews: some View {
        IndexView()
            .environmentObject(ViewRouter())
    }
}
