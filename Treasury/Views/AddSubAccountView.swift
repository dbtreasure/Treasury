//
//  AddSubAccountView.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct AddSubAccountView: View {
    @State private var title: String = ""
    @State private var total: Int = 0
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Text("Add Category")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                Spacer()
            }
            Spacer()
            HStack {
                Text("Title")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                Spacer()
            }.padding([.leading, .trailing])
            TextField("Groceries", text: $title)
                .padding([.leading, .trailing])
                .foregroundColor(.black)
                .font(.custom("something", size: 60))
            Spacer()
            HStack {
                Text("Total Budget")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                Spacer()
            }.padding([.leading, .trailing])
            
            HStack{
                Spacer()
                Text("$").font(.custom("something", size: 90))
                TextField("", value: $total, format: .number)
                    .keyboardType(.decimalPad)
                    .font(.custom("something", size: 90))
                    .allowsTightening(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                Spacer()
            }.padding([.leading, .trailing])
            Spacer()
            HStack{
                Spacer()
                Button("Submit") {
                    submitSubAccount()
                }
                .foregroundColor(.black)
                .font(Font.largeTitle.weight(.bold))
                .padding(.bottom)
                Spacer()
            }
        }.padding(.bottom)
    }
    
    func submitSubAccount() {
        viewModel.addSubAccount(title: title, budget: total)
        presentationMode.wrappedValue.dismiss()
    }
}

extension AddSubAccountView {
    class ViewModel: ObservableObject {
        private var budgetId: String
        
        init(budgetId: String) {
            self.budgetId = budgetId
        }
        
        private let ref = Database.database().reference()
        private let dbPath = "subAccounts"
        
        func addSubAccount(title: String, budget: Int) {
            if let userID = Auth.auth().currentUser?.uid {
                guard let autoId = ref.child(dbPath).child(userID).childByAutoId().key else { return }
                let subAccount = SubAccount(id: autoId, updatedAt: Date.now, budgetId: budgetId, ownerId: userID, title: title, budget: budget)
                do {
                    let subAccountAsDictionary = try subAccount.asDictionary()
                    ref.child("\(dbPath)/\(userID)/\(subAccount.id)").setValue(subAccountAsDictionary)
                } catch {
                    
                }
            }
        }
    }
}

struct AddSubAccountView_Previews: PreviewProvider {
    static var previews: some View {
        AddSubAccountView(viewModel: .init(budgetId: "abc"))
    }
}
