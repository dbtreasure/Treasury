//
//  ActiveBudget.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/21/22.
//

import Foundation

class ActiveBudget: ObservableObject {
    @Published private(set) public var documentId: String?
    
    func setActiveBudgetDocumentId(id: String) {
        self.documentId = id
    }
}
