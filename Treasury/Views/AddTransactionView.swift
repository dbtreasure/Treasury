//
//  TransactionView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/21/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct AddTransactionView: View {
    @ObservedObject var viewModel: ViewModel
    
    @State private var description: String = ""
    @State private var date: Date = Date.now
    @State private var total: Int = 0
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 60) {
            HStack {
                Spacer()
                Text("Add Transaction")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                Spacer()
            }
            VStack(spacing: 20){
                HStack{
                    Text("$").font(.custom("something", size: 90))
                    TextField("", value: $total, format: .number)
                        .keyboardType(.decimalPad)
                        .font(.custom("something", size: 90))
                        .allowsTightening(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        
                }.padding([.leading, .trailing])
                
                TextField("Description", text: $description)
                    .padding([.leading, .trailing])
                    .foregroundColor(.black)
                    .font(.title)
                DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: [.date]
                    ).padding([.leading, .trailing])
                    .font(.title)
                Spacer()
            }
            HStack{
                Spacer()
                Button("Submit") {
                    submit()
                }
                .foregroundColor(.black)
                .font(Font.largeTitle.weight(.bold))
                .padding(.bottom)
                Spacer()
            }
            
        }.padding(.bottom)
    }
    
    func submit() {
        viewModel.addTransaction(description: description, total: total, date: date)
        self.description = ""
        self.total = 0
        presentationMode.wrappedValue.dismiss()
    }
}

extension AddTransactionView {
    class ViewModel: ObservableObject {
        private var budgetId: String
        private var subAccountId: String
        private let ref = Database.database().reference()
        private let dbPath = "transactions"
        
        init(budgetId: String, subAccountId: String) {
            self.budgetId = budgetId
            self.subAccountId = subAccountId
        }
        
        func addTransaction(description: String, total: Int, date: Date) {
            if let userID = Auth.auth().currentUser?.uid {
                guard let autoId = ref.child(dbPath).child(userID).childByAutoId().key else { return }
                let transaction = Transaction(id: autoId, updatedAt: Date.now, budgetId: budgetId, ownerId: userID, subAccountId: subAccountId, description: description, total: total, transactionDate: date)
                do {
//                    let transactionAsDictionary = try transaction.asDictionary()
//                    ref.child("\(dbPath)/\(userID)/\(transaction.id)").setValue(transactionAsDictionary)
                } catch {

                }
            }
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView(viewModel: .init(budgetId: "abc", subAccountId: "abc"))
    }
}
