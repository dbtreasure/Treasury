//
//  TransactionViewModel.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import Combine
import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseDatabaseSwift

class TransactionViewModel: ObservableObject {
    @Published var transactions = [_Transaction]()
    private let ref = Database.database().reference()
    private let dbPath = "transactions"
    
    init() {
        initListener()
    }
    
    func initListener() {
        if let userID = Auth.auth().currentUser?.uid {
            ref.child(dbPath).child(userID).observeSingleEvent(of: .value) { snapshot in
                guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                self.transactions = children.compactMap { snapshot in
                    return try? snapshot.data(as: _Transaction.self)
                }
            }
        }
    }
    
    func addTransaction(description: String, budgetId: String, total: Int, subAccountId: String, date: Date) {
        if let userID = Auth.auth().currentUser?.uid {
            guard let autoId = ref.child(dbPath).child(userID).childByAutoId().key else { return }
            let transaction = _Transaction(id: autoId, updatedAt: Date.now, budgetId: budgetId, ownerId: userID, subAccountId: subAccountId, description: description, total: total, transactionDate: date)
            do {
                let transactionAsDictionary = try transaction.asDictionary()
                ref.child("\(dbPath)/\(userID)/\(transaction.id)").setValue(transactionAsDictionary)
                initListener()
            } catch {
                
            }
        }
    }
    
    func getTransactionsForSubAccount(subAccountId: String) -> [_Transaction] {
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
