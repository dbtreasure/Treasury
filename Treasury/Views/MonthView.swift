//
//  MonthView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/21/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MonthView: View {
    @ObservedObject var viewModel: ViewModel
    @EnvironmentObject var currentMonth: CurrentMonth
    @EnvironmentObject var activeBudget: ActiveBudget
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    ForEach(viewModel.subAccounts, id: \.id) { account in
                        NavigationLink(
                            destination: SubAccountView(
                                viewModel: .init(subAccount: account)
                            )) {
                            HStack(alignment: .center, spacing: 10) {
                                Text(account.title)
                                    .font(.title3)
                                    .foregroundStyle(.black)
                                Spacer()
                                (
                                    account.bottomLine() < 0 ?
                                    Text("$\(account.bottomLine())")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red) :
                                    Text("$\(account.bottomLine())")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                )
                            }
                        }
                        
                    }
                }
            }
            .frame(
                  minWidth: 0,
                  maxWidth: .infinity,
                  minHeight: 0,
                  maxHeight: .infinity,
                  alignment: .topLeading
                )
            VStack(alignment: .center, spacing: 6) {
                HStack(
                    alignment: .center, spacing: 10
                ) {
                    Text("Total budget")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("$\(viewModel.activeFiscalMonth.totalBudget)")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                HStack(
                    alignment: .center, spacing: 10
                ) {
                    Text("Total expenses")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    (viewModel.activeFiscalMonth.totalExpenses <= 0 ?
                     Text("$\(viewModel.activeFiscalMonth.totalExpenses)") :
                        Text("-$\(viewModel.activeFiscalMonth.totalExpenses)").foregroundColor(.red))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Divider()
                    .background(.black)
                HStack(
                    alignment: .center, spacing: 10
                ) {
                    Text("Remaining")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    (
                        viewModel.activeFiscalMonth.bottomLine() < 0 ?
                        Text("$\(viewModel.activeFiscalMonth.bottomLine())")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red) :
                            Text("$\(viewModel.activeFiscalMonth.bottomLine())")
                            .font(.title2)
                            .fontWeight(.semibold)
                    )
                }
            }
        }
        .navigationBarTitle(viewModel.activeFiscalMonth.monthName)
        .padding([.leading, .trailing, .bottom])
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddSubAccountView(viewModel: .init(budgetId: activeBudget.documentId!, activeFiscalMonth: viewModel.activeFiscalMonth))) {
                    Image(systemName: "folder.badge.plus")
                }.foregroundColor(.black)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                if let year = currentMonth.year {
                    NavigationLink(destination: YearView(viewModel: .init(activeBudget: activeBudget, currentMonth: currentMonth))) {
                        
                        HStack(alignment: .center) {
                            Image(systemName: "arrowshape.turn.up.backward")
                                
                            Text(String(year))
                                .bold()
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.listenForSubAccounts()
        }
        .onDisappear {
            viewModel.removeSubAccountsListener()
        }
    }
}


extension MonthView {
    class ViewModel: ObservableObject {
        @Published var activeFiscalMonth: FiscalMonth
        @Published var currentMonth: CurrentMonth?
        @Published var subAccounts = [SubAccount]()
    
        @EnvironmentObject var router: ViewRouter
        
        private var activeBudget: ActiveBudget
        private let db = Firestore.firestore()
        private var subAccountsListener: ListenerRegistration?
        
        init(currentMonth: CurrentMonth, activeBudget: ActiveBudget, activeFiscalMonth: FiscalMonth, router: ViewRouter) {
            self.activeFiscalMonth = activeFiscalMonth
            self.currentMonth = currentMonth
            self.activeBudget = activeBudget
        }
        
        func listenForSubAccounts() {
            attachSubAccountsListener()
        }
        
        func removeSubAccountsListener() {
            if let listener = self.subAccountsListener {
                listener.remove()
            }
        }
        
        private func attachSubAccountsListener() {
            do {
                let listener = db.collection("subAccounts").whereField("fiscalMonthId", isEqualTo: activeFiscalMonth.id).addSnapshotListener {
                    (snap, err) in
                    
                    guard let docs = snap?.documents else { return }
                    
                    let subAccounts = docs.map { return try! $0.data(as: SubAccount.self) }
                    self.subAccounts = subAccounts
                }
                self.subAccountsListener = listener
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(viewModel: .init(currentMonth: CurrentMonth(), activeBudget: ActiveBudget(), activeFiscalMonth: FiscalMonth(budgetId: "abc", monthName: "March", monthIndex: 3, totalExpenses: 200, totalBudget: 400), router: ViewRouter()))
    }
}
