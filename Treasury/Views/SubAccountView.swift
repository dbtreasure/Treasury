//
//  SubAccountView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/21/22.
//

import SwiftUI

struct SubAccountView: View {
    @EnvironmentObject private var subAccountViewModel: SubAccountViewModel
    @EnvironmentObject private var transactionViewModel: TransactionViewModel
    
    let account: SubAccount
    
    init(account: SubAccount) {
        self.account = account
    }
    
    var body: some View {
        VStack {
            Spacer()
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    ForEach(transactionViewModel.getTransactionsForSubAccount(subAccountId: account.id), id: \.id) { transaction in
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
                    Text("-$\(transactionViewModel.getTransactionSumForSubAccount(subAccountId: account.id))")
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
                        transactionViewModel.getRemainingFundsForSubAccount(subAccountId: account.id, budget: account.budget) < 0 ?
                        Text("$\(transactionViewModel.getRemainingFundsForSubAccount(subAccountId: account.id, budget: account.budget))")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red) :
                        Text("$\(transactionViewModel.getRemainingFundsForSubAccount(subAccountId: account.id, budget: account.budget))")
                            .font(.title2)
                            .fontWeight(.semibold)
                    )
                }
            }
        }
        .padding([.leading, .trailing])
        .navigationBarTitle(account.title)
        .navigationBarItems(trailing:
                                NavigationLink(destination: AddTransactionView(account: account)) {
                Image(systemName: "doc.badge.plus")
            }
            
        ).foregroundColor(.black)
    }
}

struct SubAccountView_Previews: PreviewProvider {
    static var previews: some View {
        SubAccountView(account: SubAccount(id: "1234", budgetId: "456", ownerId: "abc", title: "Groceries", budget: 100))
    }
}
