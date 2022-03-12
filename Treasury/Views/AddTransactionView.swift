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
    
    let account: SubAccount
    init(account: SubAccount) {
        self.account = account
    }
    func submit() {
        self.account.addTransaction(
            transaction: Transaction(date: date, subAccount: account, total: total, description: description)
        )
        self.description = ""
        self.total = 0
        APIBudgetLoader.write(budget: budget)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Text("Add Transaction")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                Spacer()
            }
            Form {
                TextField("Total", value: $total, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Pizza", text: $description)
                DatePicker(
                        "Transaction Date",
                        selection: $date,
                        displayedComponents: [.date]
                    ).font(.title2)
                Button("Submit") {
                    
                }
                .foregroundColor(.black)
                .font(.title2)
            }
            Spacer()
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView(account: SubAccount(name: "Groceries", budget: 300))
    }
}
