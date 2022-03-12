//
//  Budget.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/20/22.
//

import Foundation

class Budget: Codable {
    var id: UUID
    private var accounts: [SubAccount] = [
        SubAccount(name: "Groceries", budget: 300),
        SubAccount(name: "Hello Fresh", budget: 500),
        SubAccount(name: "Household", budget: 30),
        SubAccount(name: "Coffee", budget: 50),
        SubAccount(name: "Subscriptions", budget: 225),
        SubAccount(name: "Utilities", budget: 110),
        SubAccount(name: "Restaurant", budget: 300),
        SubAccount(name: "Insurance", budget: 170)
    ]
    
    func getAccounts() -> [SubAccount] {
        return self.accounts
    }
    
    func getSubAccountByName(name: String) -> SubAccount? {
        let instanceOfAccount = self.accounts.first(where: {$0.name == name})
        return instanceOfAccount
    }
    
    func getSubAccountById(id: SubAccount.ID) -> SubAccount? {
        let instanceOfAccount = self.accounts.first(where: {$0.id == id})
        return instanceOfAccount
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
        self.id = UUID()
        for account in self.accounts {
            for _ in 0...10 {
                let cost = Int.random(in: 0 ..< 100)
                let transaction = Transaction(date: Date.now, subAccount: account, total: cost, description: "Just one thing for $\(cost)")
                account.addTransaction(transaction: transaction)
            }
        }
        
    }
}
