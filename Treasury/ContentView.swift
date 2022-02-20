//
//  ContentView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/19/22.
//

import SwiftUI

private var budget = Budget()

struct ContentView: View {
    var body: some View {
        VStack {
            HStack(
                alignment: .center, spacing: 10
            ) {
                Text("February")
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .font(.largeTitle)
                Spacer()
            }
            ScrollView {
                VStack(alignment: .center, spacing: 10) {

                    ForEach(budget.getAccounts(), id: \.id) { account in
                        HStack(alignment: .center, spacing: 10) {
                            Text(account.name)
                                .font(.title3)
                            
                            Spacer()
                            (
                                account.remaining < 0 ?
                                Text("$\(account.remaining)")
                                    .foregroundColor(.red) :
                                Text("$\(account.remaining)")
                            )
                            
                        }
                    }
                }
            }
            .frame(
                  minWidth: 0,
                  maxWidth: .infinity,
                  minHeight: 0,
                  maxHeight: .infinity,
                  alignment: .topLeading
                )
            HStack(
                alignment: .center, spacing: 10
            ) {
                Text("Total budget")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Text("$\(budget.getTotalBudget())")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            HStack(
                alignment: .center, spacing: 10
            ) {
                Text("Total exepenses")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Text("$\(budget.getTotalTransactions())")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            HStack(
                alignment: .center, spacing: 10
            ) {
                Text("Remaining")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                (
                    budget.getRemainingFunds() < 0 ?
                    Text("$\(budget.getRemainingFunds())")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.red) :
                    Text("$\(budget.getRemainingFunds())")
                        .font(.title2)
                        .fontWeight(.semibold)
                )
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
            
    }
}
