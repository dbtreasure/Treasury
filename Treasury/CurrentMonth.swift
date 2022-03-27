//
//  CurrentMonth.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/21/22.
//

import Foundation

class CurrentMonth: ObservableObject {
    var currentDate = Date()
    @Published var name: String
    @Published var index: Int
    @Published var year: Int
    let nameFormatter = DateFormatter()
    
    init() {
        nameFormatter.timeZone = TimeZone(abbreviation: "UTC")
        nameFormatter.dateFormat = "MMMM" // format January, February, March, ...
        name = nameFormatter.string(from: currentDate)
        index = Calendar.current.component(.month, from: currentDate)
        year = Calendar.current.component(.year, from: currentDate)   
    }
}
