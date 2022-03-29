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
    var totalExpenses: Int
    var totalBudget: Int
    var createdAt = Date()
    
    func bottomLine() -> Int {
        return self.totalBudget - totalExpenses
    }
    
    func getMonthName() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self.createdAt) 
    }
    
    func getMonthIndex() -> Int {
        return Calendar.current.component(.month, from: self.createdAt)
    }
    
    func getYear() -> Int {
        return Calendar.current.component(.year, from: self.createdAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case budgetId
        case totalExpenses
        case totalBudget
        case createdAt
    }

}
