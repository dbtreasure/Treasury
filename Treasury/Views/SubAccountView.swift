//
//  SubAccountView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/21/22.
//

import SwiftUI

struct SubAccountView: View {
    @EnvironmentObject private var subAccountViewModel: SubAccountViewModel
    
    let account: _SubAccount
    
    init(account: _SubAccount) {
        self.account = account
    }
    
    var body: some View {
        VStack {
            Spacer()
            ScrollView {
//                VStack(alignment: .center, spacing: 10) {
//                    ForEach([account.transactions], id: \.id) { transaction in
//                        HStack(alignment: .center, spacing: 10) {
//                            Text(transaction.description)
//                                .font(.title3)
//                            Spacer()
//                            Text("$\(transaction.total)")
//                        }
//                    }
//                }
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
                    (subAccountViewModel.sumOfTransactions(id: account.id) > 0 ? Text("-$\(subAccountViewModel.sumOfTransactions(id: account.id))") :
                        Text("$\(subAccountViewModel.sumOfTransactions(id: account.id))"))
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
                        subAccountViewModel.getRemainingFunds(id: account.id) < 0 ?
                        Text("$\(subAccountViewModel.getRemainingFunds(id: account.id))")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red) :
                        Text("$\(subAccountViewModel.getRemainingFunds(id: account.id))")
                            .font(.title2)
                            .fontWeight(.semibold)
                    )
                }
            }
        }
        .padding([.leading, .trailing])
        .navigationBarTitle(account.title)
        .navigationBarItems(trailing:
                                NavigationLink(destination: AddTransactionView(account: _SubAccount(id: "1234", budgetId: "456", ownerId: "abc", title: "Groceries", budget: 100))) {
                Image(systemName: "doc.badge.plus")
            }
            
        ).foregroundColor(.black)
    }
}

struct SubAccountView_Previews: PreviewProvider {
    static var previews: some View {
        SubAccountView(account: _SubAccount(id: "1234", budgetId: "456", ownerId: "abc", title: "Groceries", budget: 100))
    }
}
