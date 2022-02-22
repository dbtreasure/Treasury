//
//  MonthView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/21/22.
//

import SwiftUI

struct MonthView: View {
    @State private var budget = APIBudgetLoader.load()
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
                NavigationLink(destination: MonthView()) {
                    Image(systemName: "plus")
                        .foregroundColor(Color.black)
                        .imageScale(.large)
                        .font(Font.title3.bold())
                }
            }
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    ForEach(budget.getAccounts(), id: \.id) { account in
                        NavigationLink(destination: SubAccountView(account: account)) {
                            HStack(alignment: .center, spacing: 10) {
                                Text(account.name)
                                    .font(.title3)
                                    .foregroundColor(.black)
                                Spacer()
                                (
                                    account.getRemainingFunds() < 0 ?
                                    Text("$\(account.getRemainingFunds())")
                                        .foregroundColor(.red) :
                                    Text("$\(account.getRemainingFunds())")
                                        .foregroundColor(.black)
                                )
                            }
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
            VStack(alignment: .center, spacing: 6) {
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
                    Text("Total expenses")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    (budget.getTotalTransactions() > 0 ? Text("-$\(budget.getTotalTransactions())") :
                        Text("$\(budget.getTotalTransactions())"))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Divider()
                    .background(.black)
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
        }
        
        .padding(.leading)
        .padding(.trailing)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }

}
