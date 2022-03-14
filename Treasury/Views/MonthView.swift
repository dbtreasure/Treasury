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
    @EnvironmentObject private var currentMonth: CurrentMonth
    
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
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red) :
                                    Text("$\(transactionViewModel.getRemainingFundsForSubAccount(subAccountId: account.id, budget: account.budget))")
                                        .fontWeight(.semibold)
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
                    (transactionViewModel.getTransactionsSumForBudget() <= 0 ?
                     Text("$\(transactionViewModel.getTransactionsSumForBudget())") :
                        Text("-$\(transactionViewModel.getTransactionsSumForBudget())").foregroundColor(.red))
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddSubAccountView()) {
                    Image(systemName: "folder.badge.plus")
                }.foregroundColor(.black)
            }
        }
        .navigationBarTitle(currentMonth.name)
        .padding([.leading, .trailing])
        
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
