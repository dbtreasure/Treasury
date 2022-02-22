//
//  ContentView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/19/22.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            NavigationView {
                MonthView()
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
            }.accentColor(.black)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
