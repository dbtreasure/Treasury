//
//  AddSubAccountView.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

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
        Task {
            await viewModel.addSubAccount(title: title, budget: total)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

extension AddSubAccountView {
    class ViewModel: ObservableObject {
        private var budgetId: String
        private var activeFiscalMonth: FiscalMonth
        let db = Firestore.firestore()
        
        init(budgetId: String, activeFiscalMonth: FiscalMonth) {
            self.activeFiscalMonth = activeFiscalMonth
            self.budgetId = budgetId
        }

        @MainActor
        func addSubAccount(title: String, budget: Int) async {
            do {
                if let documentId = self.activeFiscalMonth.id {
                    let subAccountsRef = db.collection("subAccounts")
                    let subAccount = SubAccount(fiscalMonthId: documentId, budgetId: self.budgetId, title: title, budget: budget, expenses: 0)
                    try await subAccountsRef.addDocument(from: subAccount)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct AddSubAccountView_Previews: PreviewProvider {
    static var previews: some View {
        AddSubAccountView(viewModel: .init(budgetId: "abc", activeFiscalMonth: FiscalMonth(budgetId: "abc", monthName: "March", monthIndex: 3, totalExpenses: 200, totalBudget: 400)))
    }
}
