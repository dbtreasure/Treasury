//
//  _Budget.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Budget: Identifiable, Codable {
    @DocumentID var id: String?
    var ownerIds: [String]
    
    enum CodingKeys: CodingKey {
        case id
        case ownerIds
    }
}

extension Budget {
    func collectionId() -> String {
        return "budgets"
    }
}
