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
    @Published var subAccounts = [SubAccount]()
    
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
                    return try? snapshot.data(as: SubAccount.self)
                }
            }
        }
    }
    
    func addSubAccount(title: String, budgetId: String, budget: Int) {
        if let userID = Auth.auth().currentUser?.uid {
            guard let autoId = ref.child(dbPath).child(userID).childByAutoId().key else { return }
            let subAccount = SubAccount(id: autoId, updatedAt: Date.now, budgetId: budgetId, ownerId: userID, title: title, budget: budget)
            do {
                let subAccountAsDictionary = try subAccount.asDictionary()
                ref.child("\(dbPath)/\(userID)/\(subAccount.id)").setValue(subAccountAsDictionary)
                initListener()
            } catch {
                
            }
        }
    }
    
    func getBudgetForAllSubAccounts() -> Int {
        return self.subAccounts.reduce(0, {$0 + $1.budget})
    }   
}
