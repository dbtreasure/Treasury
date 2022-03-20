//
//  MonthView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/21/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct MonthView: View {
    @EnvironmentObject private var currentMonth: CurrentMonth
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    ForEach(viewModel.subAccounts, id: \.id) { account in
                        NavigationLink(
                            destination: SubAccountView(
                                viewModel: .init(subAccount: account)
                            )) {
                            HStack(alignment: .center, spacing: 10) {
                                Text(account.title)
                                    .font(.title3)
                                    .foregroundStyle(.black)
                                Spacer()
                                (
                                    viewModel.getRemainingFundsForSubAccount(subAccountId: account.id, budget: account.budget) < 0 ?
                                    Text("$\(viewModel.getRemainingFundsForSubAccount(subAccountId: account.id, budget: account.budget))")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red) :
                                    Text("$\(viewModel.getRemainingFundsForSubAccount(subAccountId: account.id, budget: account.budget))")
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
                    Text("$\(viewModel.getBudgetForAllSubAccounts())")
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
                    (viewModel.getTransactionsSumForBudget() <= 0 ?
                     Text("$\(viewModel.getTransactionsSumForBudget())") :
                        Text("-$\(viewModel.getTransactionsSumForBudget())").foregroundColor(.red))
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
                        viewModel.getRemainingFundsForBudget(viewModel.getBudgetForAllSubAccounts()) < 0 ?
                        Text("$\(viewModel.getRemainingFundsForBudget(viewModel.getBudgetForAllSubAccounts()))")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red) :
                            Text("$\(viewModel.getRemainingFundsForBudget(viewModel.getBudgetForAllSubAccounts()))")
                            .font(.title2)
                            .fontWeight(.semibold)
                    )
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let subAccount = viewModel.subAccounts.first {
                    NavigationLink(destination: AddSubAccountView(viewModel: .init(budgetId: subAccount.budgetId))) {
                        Image(systemName: "folder.badge.plus")
                    }.foregroundColor(.black)
                }
                
            }
        }
        .navigationBarTitle(currentMonth.name)
        .padding([.leading, .trailing, .bottom])
        
    }
}

extension MonthView {
    class ViewModel: ObservableObject {
        @Published var subAccounts = [SubAccount]()
        @Published var transactions = [Transaction]()
        
        private let ref = Database.database().reference()
        
        private let subAccountDbPath = "subAccounts"
        private let transactionsDbPath = "transactions"
        private let currentDate = Date()
        private var currentMonthIndex: Int
        private let dateFormatter = DateFormatter()
        
        init() {
            dateFormatter.dateFormat = "yyyy/mm/dd hh:mm:ss Z"
            dateFormatter.timeZone = .autoupdatingCurrent
            currentMonthIndex = Calendar.current.component(.month, from: currentDate)
            fetchSubAccounts()
            fetchTransactions()
        }
        
        private func fetchSubAccounts() {
            if let userID = Auth.auth().currentUser?.uid {
                ref.child(subAccountDbPath).child(userID).observe(.value) { snapshot in
                    guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    self.subAccounts = children.compactMap { snapshot in
                        return try? snapshot.data(as: SubAccount.self)
                    }
                }
            }
        }
        
        private func fetchTransactions() {
            if let userID = Auth.auth().currentUser?.uid {
                ref.child(transactionsDbPath).child(userID).observe(.value) { snapshot in
                    guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }

                    self.transactions = children.compactMap { snapshot in
                        return try? snapshot.data(as: Transaction.self)
                    }.filter({
                        if let date = $0.transactionDate, Calendar.current.component(.month, from: date) == self.currentMonthIndex {
                            return true
                        } else {
                            return false
                        }
                    })
                }
            }
        }
        
        func getTransactionsForSubAccount(subAccountId: String) -> [Transaction] {
            return self.transactions.filter({$0.subAccountId == subAccountId})
        }
        
        func getBudgetForAllSubAccounts() -> Int {
            return self.subAccounts.reduce(0, {$0 + $1.budget})
        }
        
        func getTransactionSumForSubAccount(subAccountId: String) -> Int {
            let transactions = getTransactionsForSubAccount(subAccountId: subAccountId)
            return transactions.reduce(0, {$0 + $1.total})
        }
        
        func getRemainingFundsForSubAccount(subAccountId: String, budget: Int) -> Int {
            return budget - getTransactionSumForSubAccount(subAccountId: subAccountId)
        }
        
        func getTransactionsSumForBudget() -> Int {
            return self.transactions.reduce(0, {$0 + $1.total})
        }
        
        func getRemainingFundsForBudget(_ budgetForAllSubAccounts: Int) -> Int {
            return budgetForAllSubAccounts - getTransactionsSumForBudget()
        }
        
    }
}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(viewModel: .init())
    }
}
