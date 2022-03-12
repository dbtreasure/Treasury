//
//  ContentView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/19/22.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        VStack {
            NavigationView {
                MonthView()
            }.accentColor(.black)
                
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .colorScheme(.light)
            .preferredColorScheme(.light)
    }
}
