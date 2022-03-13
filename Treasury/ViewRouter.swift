//
//  ViewRouter.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import SwiftUI
import FirebaseAuth

class ViewRouter: ObservableObject {
    @Published var currentPage: Page = Auth.auth().currentUser != nil ? .homePage : .signInPage
    
    func changePage(_ page: Page) -> Void {
        self.currentPage = page
    }
}

enum Page {
    case signUpPage
    case signInPage
    case homePage
}
