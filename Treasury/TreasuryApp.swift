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
    @StateObject var currentMonth = CurrentMonth()
    @StateObject var budgetViewModel = BudgetViewModel()
    @StateObject var subAccountViewModel = SubAccountViewModel()
    @StateObject var transactionViewModel = TransactionViewModel()
    
    init() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
    }
    
    var body: some Scene {
        WindowGroup {
            IndexView()
                .environmentObject(viewRouter)
                .environmentObject(currentMonth)
                .environmentObject(budgetViewModel)
                .environmentObject(subAccountViewModel)
                .environmentObject(transactionViewModel)
            
        }
    }
}
