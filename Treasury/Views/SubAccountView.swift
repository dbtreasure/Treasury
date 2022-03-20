//
//  SubAccountView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/21/22.
//

import SwiftUI
import Firebase

struct SubAccountView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Spacer()
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    ForEach(viewModel.getTransactionsForSubAccount(subAccountId: viewModel.account.id), id: \.id) { transaction in
                        HStack(alignment: .center, spacing: 10) {
                            Text(transaction.description)
                                .font(.title3)
                            Spacer()
                            Text("$\(transaction.total)")
                                .fontWeight(.semibold)
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
                    Text("$\(viewModel.account.budget)")
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
                    (viewModel.getTransactionSumForSubAccount(subAccountId: viewModel.account.id) <= 0 ?
                     Text("$\(viewModel.getTransactionSumForSubAccount(subAccountId: viewModel.account.id))") :
                        Text("-$\(viewModel.getTransactionSumForSubAccount(subAccountId: viewModel.account.id))").foregroundColor(.red))
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
                        viewModel.getRemainingFundsForSubAccount(subAccountId: viewModel.account.id, budget: viewModel.account.budget) < 0 ?
                        Text("$\(viewModel.getRemainingFundsForSubAccount(subAccountId: viewModel.account.id, budget: viewModel.account.budget))")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red) :
                            Text("$\(viewModel.getRemainingFundsForSubAccount(subAccountId: viewModel.account.id, budget: viewModel.account.budget))")
                            .font(.title2)
                            .fontWeight(.semibold)
                    )
                }
            }
        }
        .padding([.leading, .trailing, .bottom])
        .navigationBarTitle(viewModel.account.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let budgetId = viewModel.account.budgetId, let subAccountId = viewModel.account.id {
                    NavigationLink(destination: AddTransactionView(viewModel: .init(budgetId: budgetId, subAccountId: subAccountId))) {
                        Image(systemName: "doc.badge.plus")
                    }.foregroundColor(.black)
                }
            }
        }
        
    }
}

extension SubAccountView {
    class ViewModel: ObservableObject {
        @Published private(set) public var account: SubAccount
        @Published var transactions = [Transaction]()
        
        private let ref = Database.database().reference()
        
        private let transactionsDbPath = "transactions"
        private let currentDate = Date()
        private var currentMonthIndex: Int
        private let dateFormatter = DateFormatter()
        
        init(subAccount: SubAccount) {
            self.account = subAccount
            dateFormatter.dateFormat = "yyyy/mm/dd hh:mm:ss Z"
            dateFormatter.timeZone = .autoupdatingCurrent
            currentMonthIndex = Calendar.current.component(.month, from: currentDate)
            fetchTransactions()
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
        
        func getTransactionSumForSubAccount(subAccountId: String) -> Int {
            let transactions = getTransactionsForSubAccount(subAccountId: subAccountId)
            return transactions.reduce(0, {$0 + $1.total})
        }
        
        func getRemainingFundsForSubAccount(subAccountId: String, budget: Int) -> Int {
            return budget - getTransactionSumForSubAccount(subAccountId: subAccountId)
        }
    }
}

struct SubAccountView_Previews: PreviewProvider {
    
    static var previews: some View {
        SubAccountView(viewModel: .init(subAccount: SubAccount(id: "abc", budgetId: "123", ownerId: "acd", title: "Donus", budget: 400)))
    }
}
