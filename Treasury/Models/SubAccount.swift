//
//  _SubAccount.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import Foundation
import FirebaseFirestoreSwift

struct SubAccount: Identifiable, Codable {
    @DocumentID var id: String?
    var fiscalMonthId: String
    var budgetId: String
    var title: String
    var budget: Int
    var expenses: Int
    
    func bottomLine() -> Int {
        return self.budget - expenses
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case fiscalMonthId
        case expenses
        case budgetId
        case title
        case budget
    }
}
