//
//  Transaction.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/20/22.
//

import Foundation


class Transaction: Identifiable {
    let date: Date
    let subAccount: SubAccount
    let total: Int
    let description: String
    let id = UUID()
    
    init(date: Date, subAccount: SubAccount, total: Int, description: String) {
        self.date = date
        self.subAccount = subAccount
        self.total = total
        self.description = description
    }
}
