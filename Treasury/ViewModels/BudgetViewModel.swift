//
//  BudgetViewModel.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import Combine
import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseDatabaseSwift

class BudgetViewModel: ObservableObject {
    @Published var budgets = [Budget]()
    private let ref = Database.database().reference()
    private let dbPath = "budgets"
    
    
    init() {
        initListener()
    }
    
    func initListener() {
        if let userID = Auth.auth().currentUser?.uid {
            
            ref.child(dbPath).child(userID).observeSingleEvent(of: .value) { snapshot in
                guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                    return
                }
                
                self.budgets = children.compactMap { snapshot in
                    return try? snapshot.data(as: Budget.self)
                }
            }
        }
    }
    
    func addBudget() {
        if let userID = Auth.auth().currentUser?.uid {
            guard let autoId = ref.child(dbPath).child(userID).childByAutoId().key else {
                return
            }
            let budget = Budget(id: autoId, updatedAt: Date.now, ownerId: userID)
            
            do {
                let budgetAsDictionary = try budget.asDictionary()
                ref.child("\(dbPath)/\(userID)/\(budget.id)").setValue(budgetAsDictionary)
                initListener()
            } catch  {
                return
            }
            
        }
    }
    
}
