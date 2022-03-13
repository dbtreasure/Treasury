//
//  TransactionView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/21/22.
//

import SwiftUI

struct AddTransactionView: View {
    @State private var description: String = ""
    @State private var date: Date = Date.now
    @State private var total: Int = 0
    @State private var budget = APIBudgetLoader.load()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let account: _SubAccount
    init(account: _SubAccount) {
        self.account = account
    }
    func submit() {
//        self.account.addTransaction(
//            transaction: Transaction(date: date, subAccount: account, total: total, description: description)
//        )
        self.description = ""
        self.total = 0
    }
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
//                    let transaction = Transaction(date: date, subAccount: account, total: total, description: description)
//                    account.addTransaction(transaction: transaction)
//                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.black)
                .font(Font.largeTitle.weight(.bold))
                .padding(.bottom)
                Spacer()
            }
            
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView(account: _SubAccount(id: "1234", budgetId: "456", ownerId: "abc", title: "Groceries", budget: 100))
    }
}
