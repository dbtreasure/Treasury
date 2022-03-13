//
//  _Transaction.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import Foundation
import FirebaseDatabaseSwift

struct Transaction: Identifiable, Codable {
    var id: String
    @ServerTimestamp var updatedAt = Date()
    var budgetId: String
    var ownerId: String
    var subAccountId: String
    var description: String
    var total: Int
    @ServerTimestamp var transactionDate = Date()
}
