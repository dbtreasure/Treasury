//
//  YearView.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/20/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct YearView: View {
    @EnvironmentObject private var currentMonth: CurrentMonth
    @EnvironmentObject private var activeBudget: ActiveBudget
    @EnvironmentObject var router: ViewRouter
    @ObservedObject var viewModel: ViewModel
    @State var signOutProcessing = false
    
    var body: some View {
        VStack{
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    ForEach(viewModel.months, id: \.monthIndex) { month in
                        NavigationLink(
                            destination: MonthView(
                                viewModel: .init(currentMonth: currentMonth, activeBudget: activeBudget, activeFiscalMonth: month, router: router)
                            )) {
                            HStack(alignment: .center, spacing: 10) {
                                Text(month.monthName)
                                    .font(.title3)
                                    .foregroundStyle(.black)
                                Spacer()
                                (
                                    month.bottomLine() < 0 ?
                                    Text("$\(month.bottomLine())")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red) :
                                    Text("$\(month.bottomLine())")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                )
                            }
                        }
                    }
                }
            }
            VStack(alignment: .center, spacing: 6) {
                HStack(
                    alignment: .center, spacing: 10
                ) {
                    Text("Total budget")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("$\(viewModel.getBudgetForAllSubAccounts()*viewModel.months.count)")
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if signOutProcessing {
                    ProgressView()
                } else {
                    Button() {
                        Task {
                            await signOutUser()
                        }
                        withAnimation {
                            router.changePage(.signInPage)
                        }
                        
                    }label: {
                        HStack {
                            Text("Logout")
                                .bold()
                        }
                        
                    }
                }
            }
        }
        .navigationBarTitle(String(currentMonth.year))
        .padding([.leading, .trailing, .bottom])
    }
    
    @MainActor
    func signOutUser() async {
        signOutProcessing = true
        do {
            try await Auth.auth().signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
            signOutProcessing = false
        }
        
    }
}

extension YearView {
    class ViewModel: ObservableObject {
        @Published var transactions = [Transaction]()
        @Published var subAccounts = [SubAccount]()
        @Published var months = [FiscalMonth]()
        
        private let ref = Database.database().reference()
        private let subAccountDbPath = "subAccounts"
        private let transactionsDbPath = "transactions"
        private let currentDate = Date()
        private var currentYearIndex: Int
        private let dateFormatter = DateFormatter()
        let nameFormatter = DateFormatter()
        
        
        init() {
            nameFormatter.timeZone = .autoupdatingCurrent
            nameFormatter.dateFormat = "MMMM" // format January, February, March, ...
            
            dateFormatter.dateFormat = "yyyy/mm/dd hh:mm:ss Z"
            dateFormatter.timeZone = .autoupdatingCurrent
            currentYearIndex = Calendar.current.component(.year, from: currentDate)
            fetchTransactions()
            fetchSubAccounts()
        }
        
        private func fetchSubAccounts() {
            if let userID = Auth.auth().currentUser?.uid {
                ref.child(subAccountDbPath).child(userID).observe(.value) { snapshot in
                    guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    self.subAccounts = children.compactMap { snapshot in
                        return try? snapshot.data(as: SubAccount.self)
                    }
                }
            }
        }
        
        private func fetchTransactions() {
            if let userID = Auth.auth().currentUser?.uid {
                ref.child(transactionsDbPath).child(userID).observe(.value) { snapshot in
                    guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    self.transactions = children.compactMap { snapshot in
                        return try? snapshot.data(as: Transaction.self)
                    }
                    .filter({
                        if let date = $0.transactionDate, Calendar.current.component(.year, from: date) == self.currentYearIndex {
                            return true
                        } else {
                            return false
                        }
                    })
                    .sorted(by: {
                        $0.transactionDate!.compare($1.transactionDate!) == .orderedAscending
                    })
                    self.months = self.transactions.reduce(into: [FiscalMonth]()) {
                        let monthIdx = Calendar.current.component(.month, from: $1.transactionDate!)
                        let monthName = self.nameFormatter.string(from: $1.transactionDate!)
                        if let matchIdx = $0.firstIndex(where: {$0.monthIndex == monthIdx}) {
                            $0[matchIdx].transactions.append($1)
                            $0[matchIdx].totalExpenses += $1.total
                        } else {
                            $0.append(
                                FiscalMonth(
                                    budgetId: "abc",
                                    monthName: monthName,
                                    monthIndex: monthIdx,
                                    totalExpenses: $1.total,
                                    transactions: [$1],
                                    totalBudget: self.getBudgetForAllSubAccounts(),
                                    subAccounts: []
                                )
                            )
                        }
                    }
                    
                }
            }
        }
        
        func getBudgetForAllSubAccounts() -> Int {
            return self.subAccounts.reduce(0, {$0 + $1.budget})
        }
        
        func getTransactionsSumForBudget() -> Int {
            return self.transactions.reduce(0, {$0 + $1.total})
        }
        
        func getRemainingFundsForBudget(_ budgetForAllSubAccounts: Int) -> Int {
            return (budgetForAllSubAccounts * self.months.count) - getTransactionsSumForBudget()
        }
    }
}

struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView(viewModel: .init())
    }
}

