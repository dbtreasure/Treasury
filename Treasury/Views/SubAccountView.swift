//
//  SubAccountView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/21/22.
//

import SwiftUI

struct SubAccountView: View {
    @State private var budget = APIBudgetLoader.load()
    
    let account: SubAccount
    
    init(account: SubAccount) {
        self.account = account
    }
    
    var body: some View {
        VStack {
            Spacer()
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    ForEach(account.transactions, id: \.id) { transaction in
                        HStack(alignment: .center, spacing: 10) {
                            Text(transaction.description)
                                .font(.title3)
                            Spacer()
                            Text("$\(transaction.total)")
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
                    Text("$\(account.budget)")
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
                    (account.sumOfTransactions() > 0 ? Text("-$\(account.sumOfTransactions())") :
                        Text("$\(account.sumOfTransactions())"))
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
                        account.getRemainingFunds() < 0 ?
                        Text("$\(account.getRemainingFunds())")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red) :
                        Text("$\(account.getRemainingFunds())")
                            .font(.title2)
                            .fontWeight(.semibold)
                    )
                }
            }
        }
        .padding([.leading, .trailing])
        .navigationBarTitle(account.name)
        .navigationBarItems(trailing:
                                NavigationLink(destination: AddTransactionView(account: account)) {
                Image(systemName: "doc.badge.plus")
            }
            
        ).foregroundColor(.black)
            .onAppear(perform: {
                budget = APIBudgetLoader.load()
            })
    }
}

struct SubAccountView_Previews: PreviewProvider {
    static var previews: some View {
        SubAccountView(account: APIBudgetLoader.load().getAccounts().randomElement()!)
    }
}
