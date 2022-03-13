//
//  TreasuryApp.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/19/22.
//

import SwiftUI
import Firebase

@main
struct TreasuryApp: App {
    
    init() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
    }
    
    var body: some Scene {
        WindowGroup {
            IndexView()
                .environmentObject(ViewRouter())
                .environmentObject(BudgetViewModel())
                .environmentObject(SubAccountViewModel())
            
        }
    }
}
