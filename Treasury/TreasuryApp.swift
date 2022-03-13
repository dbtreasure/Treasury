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
    @StateObject var viewRouter = ViewRouter()
    
    init() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
    }
    
    var body: some Scene {
        WindowGroup {
            IndexView()
                .environmentObject(viewRouter)
                .environmentObject(BudgetViewModel())
                .environmentObject(SubAccountViewModel())
                .environmentObject(TransactionViewModel())
            
        }
    }
}
