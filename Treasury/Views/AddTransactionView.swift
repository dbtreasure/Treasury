//
//  TransactionView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/21/22.
//

import SwiftUI
import FirebaseFirestore

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
        Task {
            await viewModel.addTransaction(description: description, total: total, date: date)
            self.description = ""
            self.total = 0
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

extension AddTransactionView {
    class ViewModel: ObservableObject {
        @Published private(set) public var account: SubAccount
        let db = Firestore.firestore()
        
        init(subAccount: SubAccount) {
            self.account = subAccount
            
        }
        
        @MainActor
        func addTransaction(description: String, total: Int, date: Date) async {
            do {
                let transactionsRef = db.collection("transactions")
                let transaction = Transaction(budgetId: account.budgetId, fiscalMonthId: account.fiscalMonthId, subAccountId: account.id!, description: description, total: total, createdAt: date)
                try await transactionsRef.addDocument(from: transaction)
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView(viewModel: .init(subAccount: SubAccount(fiscalMonthId: "abc", budgetId: "123", title: "Donus", budget: 400, expenses: 0)))
    }
}
