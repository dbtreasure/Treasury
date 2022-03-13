//
//  DecodableExtensions.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import Foundation

extension Decodable {
  init(from: NSDictionary) throws {
    let data = try JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
    let decoder = JSONDecoder()
    self = try decoder.decode(Self.self, from: data)
  }
}
