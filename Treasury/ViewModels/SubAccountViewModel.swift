//
//  SubAccountViewModel.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import Combine
import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseDatabaseSwift

class SubAccountViewModel: ObservableObject {
    @Published var subAccounts = [_SubAccount]()
    private let ref = Database.database().reference()
    private let dbPath = "subAccounts"
    
    init() {
        initListener()
    }
    
    func initListener() {
        if let userID = Auth.auth().currentUser?.uid {
            ref.child(dbPath).child(userID).observeSingleEvent(of: .value) { snapshot in
                guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                self.subAccounts = children.compactMap { snapshot in
                    return try? snapshot.data(as: _SubAccount.self)
                }
            }
        }
    }
    
    func addSubAccount(title: String, budgetId: String, budget: Int) {
        if let userID = Auth.auth().currentUser?.uid {
            guard let autoId = ref.child(dbPath).child(userID).childByAutoId().key else { return }
            let subAccount = _SubAccount(id: autoId, updatedAt: Date.now, budgetId: budgetId, ownerId: userID, title: title, budget: budget)
            do {
                let subAccountAsDictionary = try subAccount.asDictionary()
                ref.child("\(dbPath)/\(userID)/\(subAccount.id)").setValue(subAccountAsDictionary)
                initListener()
            } catch {
                
            }
        }
    }
    
    func sumOfTransactions(id: String) -> Int {
        return 30
    }
    
    func getRemainingFunds(id: String) -> Int {
        if let acct = self.subAccounts.first(where: {$0.id == id}) {
            return acct.budget - sumOfTransactions(id: id)
        }
        return 0
    }
    
    func addTransaction(transaction: Transaction) {
        //
    }
    
    
}
