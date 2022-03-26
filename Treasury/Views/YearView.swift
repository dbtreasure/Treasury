//
//  YearView.swift
//  Treasury
//
//  Created by Daniel Treasure on 3/20/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
                    ForEach(viewModel.fiscalMonths, id: \.id) { month in
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
                    Text("$\(viewModel.getBudgetForAllSubAccounts()*viewModel.fiscalMonths.count)")
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
        @Published var fiscalMonths = [FiscalMonth]()
        private var activeBudget: ActiveBudget
        private var currentMonth: CurrentMonth
        
        let db = Firestore.firestore()
        
        init(activeBudget: ActiveBudget, currentMonth: CurrentMonth) {
            self.activeBudget = activeBudget
            self.currentMonth = currentMonth
            fetchFiscalMonths()
        }
        
        private func fetchFiscalMonths() {
            do {
                db.collection("fiscalMonths").whereField("budgetId", isEqualTo: activeBudget.documentId).order(by: "createdAt", descending: false).addSnapshotListener {
                    (snap, err) in
                    
                    guard let docs = snap else { return }
                    
                    docs.documentChanges.forEach { (doc) in
                        let fiscalMonth = try? doc.document.data(as: FiscalMonth.self)
                        if let month = fiscalMonth {
                            let yearOfFiscalMonth = Calendar.current.component(.year, from: Date(timeIntervalSince1970: month.createdAt))
                            if yearOfFiscalMonth == self.currentMonth.year {
                                self.fiscalMonths.append(month)
                            }
                        }   
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        func getBudgetForAllSubAccounts() -> Int {
            return 0
        }
        
        func getTransactionsSumForBudget() -> Int {
            return 0
        }
        
        func getRemainingFundsForBudget(_ budgetForAllSubAccounts: Int) -> Int {
            return 0
        }
    }
}

struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView(viewModel: .init(activeBudget: ActiveBudget(), currentMonth: CurrentMonth()))
    }
}

