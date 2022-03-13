//
//  MonthView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/21/22.
//

import SwiftUI
import Firebase

struct MonthView: View {
    @EnvironmentObject private var budgetViewModel: BudgetViewModel
    @EnvironmentObject private var subAccountViewModel: SubAccountViewModel
    @EnvironmentObject private var transactionViewModel: TransactionViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    ForEach(subAccountViewModel.subAccounts, id: \.id) { account in
                        NavigationLink(destination: SubAccountView(account: account)) {
                            HStack(alignment: .center, spacing: 10) {
                                Text(account.title)
                                    .font(.title3)
                                    .foregroundStyle(.black)
                                Spacer()
                                (
                                    transactionViewModel.getRemainingFundsForSubAccount(subAccountId: account.id, budget: account.budget) < 0 ?
                                    Text("$\(transactionViewModel.getRemainingFundsForSubAccount(subAccountId: account.id, budget: account.budget))")
                                        .foregroundColor(.red) :
                                    Text("$\(transactionViewModel.getRemainingFundsForSubAccount(subAccountId: account.id, budget: account.budget))")
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
                    Text("$\(subAccountViewModel.getBudgetForAllSubAccounts())")
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
                    (transactionViewModel.getTransactionsSumForBudget() > 0 ? Text("-$\(transactionViewModel.getTransactionsSumForBudget())") :
                        Text("$\(transactionViewModel.getTransactionsSumForBudget())"))
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
                        transactionViewModel.getRemainingFundsForBudget(subAccountViewModel.getBudgetForAllSubAccounts()) < 0 ?
                        Text("$\(transactionViewModel.getRemainingFundsForBudget(subAccountViewModel.getBudgetForAllSubAccounts()))")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red) :
                            Text("$\(transactionViewModel.getRemainingFundsForBudget(subAccountViewModel.getBudgetForAllSubAccounts()))")
                            .font(.title2)
                            .fontWeight(.semibold)
                    )
                }
            }
        }
        .padding([.leading, .trailing])
        .navigationBarTitle("March")
        .navigationBarItems(trailing: NavigationLink(destination: AddSubAccountView()) {
            Image(systemName: "folder.badge.plus")
        }
                                
        ).foregroundColor(.black)
    }
}
struct MonthView_Previews: PreviewProvider {
    @EnvironmentObject private var budgetViewModel: BudgetViewModel
    @EnvironmentObject private var subAccountViewModel: SubAccountViewModel
    
    init() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        budgetViewModel.initListener()
        subAccountViewModel.initListener()
    }
    static var previews: some View {
        MonthView()
            .environmentObject(BudgetViewModel())
            .environmentObject(SubAccountViewModel())
            
    }
}
