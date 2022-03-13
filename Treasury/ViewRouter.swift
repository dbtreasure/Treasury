//
//  ViewRouter.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import SwiftUI

class ViewRouter: ObservableObject {
    @Published var currentPage: Page = .homePage
}

enum Page {
    case signUpPage
    case signInPage
    case homePage
}
