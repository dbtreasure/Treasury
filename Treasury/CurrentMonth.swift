//
//  CurrentMonth.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import Foundation

class CurrentMonth: ObservableObject {
    let currentDate = Date()
    @Published var name: String
    @Published var index: Int
    
    init() {
        let nameFormatter = DateFormatter()
        nameFormatter.timeZone = TimeZone(abbreviation: "UTC")
        nameFormatter.dateFormat = "MMMM" // format January, February, March, ...
        let monthName = nameFormatter.string(from: currentDate)
        let monthIndex = Calendar.current.component(.month, from: currentDate)
        name = monthName
        index = monthIndex
    }
}
