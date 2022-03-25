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
                    ForEach(viewModel.activeFiscalMonth.subAccounts, id: \.id) { account in
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
                                    viewModel.getRemainingFundsForSubAccount(subAccountId: account.id, budget: account.budget) < 0 ?
                                    Text("$\(viewModel.getRemainingFundsForSubAccount(subAccountId: account.id, budget: account.budget))")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red) :
                                    Text("$\(viewModel.getRemainingFundsForSubAccount(subAccountId: account.id, budget: account.budget))")
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
                    Text("$\(viewModel.getBudgetForAllSubAccounts())")
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
                    (viewModel.getTransactionsSumForBudget() <= 0 ?
                     Text("$\(viewModel.getTransactionsSumForBudget())") :
                        Text("-$\(viewModel.getTransactionsSumForBudget())").foregroundColor(.red))
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
                        viewModel.getRemainingFundsForBudget(viewModel.getBudgetForAllSubAccounts()) < 0 ?
                        Text("$\(viewModel.getRemainingFundsForBudget(viewModel.getBudgetForAllSubAccounts()))")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red) :
                            Text("$\(viewModel.getRemainingFundsForBudget(viewModel.getBudgetForAllSubAccounts()))")
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
                if let subAccount = viewModel.activeFiscalMonth.subAccounts.first {
                    NavigationLink(destination: AddSubAccountView(viewModel: .init(budgetId: subAccount.budgetId))) {
                        Image(systemName: "folder.badge.plus")
                    }.foregroundColor(.black)
                }
                
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                if let year = currentMonth.year {
                    NavigationLink(destination: YearView(viewModel: .init())) {
                        
                        HStack(alignment: .center) {
                            Image(systemName: "arrowshape.turn.up.backward")
                                
                            Text(String(year))
                                .bold()
                        }
                    }
                }
            }
        }
    }
}


extension MonthView {
    class ViewModel: ObservableObject {
        @Published var activeFiscalMonth: FiscalMonth
        @Published var currentMonth: CurrentMonth?
    
        @EnvironmentObject var router: ViewRouter
        
        private var activeBudget: ActiveBudget
        
        private let currentDate = Date()
        private var currentMonthIndex: Int
        private let dateFormatter = DateFormatter()
        private let db = Firestore.firestore()
        
        init(currentMonth: CurrentMonth, activeBudget: ActiveBudget, activeFiscalMonth: FiscalMonth, router: ViewRouter) {
            self.activeFiscalMonth = activeFiscalMonth
            self.currentMonth = currentMonth
            self.activeBudget = activeBudget
            dateFormatter.dateFormat = "yyyy/mm/dd hh:mm:ss Z"
            dateFormatter.timeZone = .autoupdatingCurrent
            currentMonthIndex = Calendar.current.component(.month, from: currentDate)
            
            guard let _ = Auth.auth().currentUser else {
                withAnimation {
                    router.changePage(.signInPage)
                }
                return
            }
        }
        
        func getTransactionsForSubAccount(subAccountId: String) -> [Transaction] {
//            return self.transactions.filter({$0.subAccountId == subAccountId})
            return []
        }
        
        func getBudgetForAllSubAccounts() -> Int {
//            return self.subAccounts.reduce(0, {$0 + $1.budget})
            return 0
        }
        
        func getTransactionSumForSubAccount(subAccountId: String) -> Int {
//            let transactions = getTransactionsForSubAccount(subAccountId: subAccountId)
//            return transactions.reduce(0, {$0 + $1.total})
            return 0
        }
        
        func getRemainingFundsForSubAccount(subAccountId: String, budget: Int) -> Int {
//            return budget - getTransactionSumForSubAccount(subAccountId: subAccountId)
            return 0
        }
        
        func getTransactionsSumForBudget() -> Int {
//            return self.transactions.reduce(0, {$0 + $1.total})
            return 0
        }
        
        func getRemainingFundsForBudget(_ budgetForAllSubAccounts: Int) -> Int {
//            return budgetForAllSubAccounts - getTransactionsSumForBudget()
            return 0
        }
        
    }
}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(viewModel: .init(currentMonth: CurrentMonth(), activeBudget: ActiveBudget(), activeFiscalMonth: FiscalMonth(budgetId: "abc", monthName: "March", monthIndex: 3, totalExpenses: 200, transactions: [], totalBudget: 400, subAccounts: []), router: ViewRouter()))
    }
}
