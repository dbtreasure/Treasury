//
//  FiscalMonth.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/20/22.
//

import Foundation
import FirebaseFirestoreSwift


struct FiscalMonth: Identifiable, Codable {
    @DocumentID var id: String?
    var budgetId: String
    var monthName: String
    var monthIndex: Int
    var totalExpenses: Int
    var totalBudget: Int
    var createdAt = Date().timeIntervalSince1970
    
    func bottomLine() -> Int {
        return self.totalBudget - totalExpenses
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case budgetId
        case monthName
        case monthIndex
        case totalExpenses
        case totalBudget
        case createdAt
    }

}
