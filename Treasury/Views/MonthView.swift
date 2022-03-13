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
                                    subAccountViewModel.getRemainingFunds(id: account.id) < 0 ?
                                    Text("$\(subAccountViewModel.getRemainingFunds(id: account.id))")
                                        .foregroundColor(.red) :
                                    Text("$\(subAccountViewModel.getRemainingFunds(id: account.id))")
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
//            VStack(alignment: .center, spacing: 6) {
//                HStack(
//                    alignment: .center, spacing: 10
//                ) {
//                    Text("Total budget")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                    Spacer()
//                    Text("$\(budget.getTotalBudget())")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                }
//                HStack(
//                    alignment: .center, spacing: 10
//                ) {
//                    Text("Total expenses")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                    Spacer()
//                    (budget.getTotalTransactions() > 0 ? Text("-$\(budget.getTotalTransactions())") :
//                        Text("$\(budget.getTotalTransactions())"))
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                }
//                Divider()
//                    .background(.black)
//                HStack(
//                    alignment: .center, spacing: 10
//                ) {
//                    Text("Remaining")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                    Spacer()
//                    (
//                        budget.getRemainingFunds() < 0 ?
//                        Text("$\(budget.getRemainingFunds())")
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                            .foregroundColor(.red) :
//                        Text("$\(budget.getRemainingFunds())")
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                    )
//                }
//            }
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
