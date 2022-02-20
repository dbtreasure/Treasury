//
//  Budget.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/20/22.
//

import Foundation

class Budget {
    let id = UUID()
    private var accounts: [SubAccount] = [
        SubAccount(name: "Groceries", budget: 300),
        SubAccount(name: "Hello Fresh", budget: 500),
        SubAccount(name: "Household", budget: 30),
        SubAccount(name: "Coffee", budget: 50),
        SubAccount(name: "Subscriptions", budget: 225),
        SubAccount(name: "Utilities", budget: 110)
    ]
    
    func getAccounts() -> [SubAccount] {
        return self.accounts
    }
    
    func addAccount(account: SubAccount) {
        self.accounts.append(account)
    }
    
    func getRemainingFunds() -> Int {
        return getTotalBudget() - getTotalTransactions()
    }
    
    func getTotalTransactions() -> Int {
        var total = 0
        for account in self.accounts {
            total += account.sumOfTransactions()
        }
        return total
    }
    
    func getTotalBudget() -> Int {
        var total = 0
        for account in self.accounts {
            total = total +  account.budget
        }
        return total
    }
    
    init() {
        for _ in 0...10 {
            let cost = Int.random(in: 0 ..< 100)
            let subAccount =  self.accounts.randomElement()!
            let transaction = Transaction(date: Date.now, subAccount: subAccount, total: cost, description: "Just some things")
            subAccount.addTransaction(transaction: transaction)
        }
    }
}
