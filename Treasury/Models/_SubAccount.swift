//
//  _SubAccount.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import Foundation
import FirebaseDatabaseSwift

struct _SubAccount: Identifiable, Codable {
    var id: String
    @ServerTimestamp var updatedAt = Date()
    var budgetId: String
    var ownerId: String
    var title: String
    var budget: Int
}
