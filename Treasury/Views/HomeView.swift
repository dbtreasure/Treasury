//
//  ContentView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/19/22.
//

import SwiftUI
import Firebase

struct HomeView: View {
    @StateObject var currentMonth = CurrentMonth()
    
    var body: some View {
        NavigationView {
            YearView(viewModel: .init())
        }
        .environmentObject(currentMonth)
        .accentColor(.black)
        .navigationViewStyle(.stack)
    }
    
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .colorScheme(.light)
            .preferredColorScheme(.light)
    }
}
