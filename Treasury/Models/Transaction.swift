//
//  _Transaction.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Transaction: Identifiable, Codable {
    @DocumentID var id: String?
    var budgetId: String
    var fiscalMonthId: String
    var subAccountId: String
    var description: String
    var total: Int
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case budgetId
        case fiscalMonthId
        case subAccountId
        case description
        case total
        case createdAt
    }
}
