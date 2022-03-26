//
//  SubAccountView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/21/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SubAccountView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Spacer()
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    ForEach(viewModel.transactions, id: \.id) { transaction in
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
                    (viewModel.account.expenses <= 0 ?
                     Text("$\(viewModel.account.expenses)") :
                        Text("-$\(viewModel.account.expenses)").foregroundColor(.red))
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
                        viewModel.account.bottomLine() < 0 ?
                        Text("$\(viewModel.account.bottomLine())")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red) :
                            Text("$\(viewModel.account.bottomLine())")
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
                if let subAccount = viewModel.account {
                    NavigationLink(destination: AddTransactionView(viewModel: .init(subAccount: subAccount))) {
                        Image(systemName: "doc.badge.plus")
                    }.foregroundColor(.black)
                }
            }
        }
        .onAppear {
            viewModel.listenForTransactions()
        }.onDisappear {
            viewModel.removeTransactionsListener()
        }
    }
}

extension SubAccountView {
    class ViewModel: ObservableObject {
        @Published private(set) public var account: SubAccount
        @Published var transactions = [Transaction]()
        
        private var transactionsListener: ListenerRegistration?
        private let db = Firestore.firestore()
        
        init(subAccount: SubAccount) {
            self.account = subAccount
        }
        
        func listenForTransactions() {
            attachTransactionListener()
        }
        
        func removeTransactionsListener() {
            if let listener = self.transactionsListener {
                listener.remove()
            }
        }
        
        private func attachTransactionListener() {
            do {
                let listener = db.collection("transactions").whereField("subAccountId", isEqualTo: account.id!).order(by: "createdAt", descending: false).addSnapshotListener {
                    (snap, err) in
                    guard let docs = snap?.documents else { return }
                    
                    let transactions = docs.map { return try! $0.data(as: Transaction.self) }
                    let sumOfTransactions = transactions.reduce(0) {$0 + $1.total}
                    self.transactions = transactions
                    if self.account.expenses != sumOfTransactions {
                        self.account.expenses = sumOfTransactions
                        print("DANLONG updating account expenses total")
                        Task.detached {
                           await self.updateSubAccount(account: self.account, expenses: sumOfTransactions)
                        }
                    }
                }
                self.transactionsListener = listener
            } catch {
                print(error.localizedDescription)
            }
        }
        
        @MainActor
        private func updateSubAccount(account: SubAccount, expenses: Int) async {
            do {
                let subAccountRef = db.collection("subAccounts").document(account.id!)
                try await subAccountRef.updateData(["expenses": expenses])
            } catch  {
                print(error.localizedDescription)
            }
        }
    }
}

struct SubAccountView_Previews: PreviewProvider {
    
    static var previews: some View {
        SubAccountView(viewModel: .init(subAccount: SubAccount(fiscalMonthId: "abc", budgetId: "123", title: "Donus", budget: 400, expenses: 0)))
    }
}
