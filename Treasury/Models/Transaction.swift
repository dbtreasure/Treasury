//
//  Transaction.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/20/22.
//

import Foundation

class Transaction: Identifiable, Codable {
    var date: Date
    var subAccount: SubAccount
    var total: Int
    var description: String
    var id: UUID
    
    init(date: Date, subAccount: SubAccount, total: Int, description: String) {
        self.date = date
        self.subAccount = subAccount
        self.total = total
        self.description = description
        self.id = UUID()
    }
}
