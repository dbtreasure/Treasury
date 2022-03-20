//
//  FiscalMonth.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/20/22.
//

import Foundation


struct FiscalMonth {
    var monthName: String
    var monthIndex: Int
    var totalExpenses: Int
    var transactions: [Transaction]
    var totalBudget: Int
    var subAccounts: [SubAccount]
    
    func bottomLine() -> Int {
        return self.totalBudget - totalExpenses
    }
}
