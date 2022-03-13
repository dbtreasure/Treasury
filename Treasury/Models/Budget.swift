//
//  _Budget.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import Foundation
import FirebaseDatabaseSwift

struct Budget: Codable, Identifiable {
    var id: String
    @ServerTimestamp var updatedAt = Date()
    var ownerId: String
}
