//
//  SubAccount.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/20/22.
//
import Foundation

class SubAccount: Identifiable, Codable {
    var name: String
    var budget: Int
    var id: UUID
    var transactions: [Transaction]
    
    init(name: String, budget: Int) {
        self.id = UUID()
        self.name = name
        self.budget = budget
        self.transactions = []
    }
    
    func sumOfTransactions() -> Int {
        var sum = 0
        for transaction in self.transactions {
            sum += transaction.total
        }
        return sum
    }
    
    func getRemainingFunds() -> Int {
        return self.budget - self.sumOfTransactions()
    }
    
    func addTransaction(transaction: Transaction) {
        self.transactions.append(transaction)
    }
}
