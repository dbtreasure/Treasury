//
//  BudgetLoader.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/21/22.
//

import Foundation

class APIBudgetLoader {
  static private var plistURL: URL {
    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documents.appendingPathComponent("budget.plist")
  }

  static func load() -> Budget {
    let decoder = PropertyListDecoder()

    guard let data = try? Data.init(contentsOf: plistURL),
      let budget = try? decoder.decode(Budget.self, from: data)
      else { return Budget() }

    return budget
  }
}

extension APIBudgetLoader {
  static func copyPreferencesFromBundle() {
    if let path = Bundle.main.path(forResource: "budget", ofType: "plist"),
      let data = FileManager.default.contents(atPath: path),
      FileManager.default.fileExists(atPath: plistURL.path) == false {

      FileManager.default.createFile(atPath: plistURL.path, contents: data, attributes: nil)
    }
  }
}

extension APIBudgetLoader {
  static func write(budget: Budget) {
    let encoder = PropertyListEncoder()

    if let data = try? encoder.encode(budget) {
      if FileManager.default.fileExists(atPath: plistURL.path) {
        // Update an existing plist
        try? data.write(to: plistURL)
      } else {
        // Create a new plist
        FileManager.default.createFile(atPath: plistURL.path, contents: data, attributes: nil)
      }
    }
  }
}
