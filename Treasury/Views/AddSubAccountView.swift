//
//  AddSubAccountView.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/12/22.
//

import SwiftUI

struct AddSubAccountView: View {
    @State private var title: String = ""
    @State private var total: Int = 0
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var budgetViewModel: BudgetViewModel
    @EnvironmentObject private var subAccountViewModel: SubAccountViewModel
    
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
        }
    }
    
    func submitSubAccount() {
        subAccountViewModel.addSubAccount(title: title, budgetId: budgetViewModel.budgets.first!.id, budget: total)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddSubAccountView_Previews: PreviewProvider {
    static var previews: some View {
        AddSubAccountView()
    }
}
