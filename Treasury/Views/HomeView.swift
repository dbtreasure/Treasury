//
//  ContentView.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/19/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct HomeView: View {
    @ObservedObject var viewModel: ViewModel
    @EnvironmentObject var router: ViewRouter
    @EnvironmentObject var currentMonth: CurrentMonth
    @EnvironmentObject var activeBudget: ActiveBudget
    
    var body: some View {
        if let activeFiscalMonth = viewModel.activeFiscalMonth {
            NavigationView {
                MonthView(viewModel: .init(activeBudget: activeBudget, activeFiscalMonth: activeFiscalMonth,  router: router))
            }
            .preferredColorScheme(.light)
            .accentColor(.black)
            .navigationViewStyle(.stack)
        } else {
            HStack {
                Spacer()
                Text("Loading")
                    .font(.largeTitle)
                Spacer()
            }
        }
        
    }
    
    
}

extension HomeView {
    class ViewModel: ObservableObject {
        @Published private(set) public var activeFiscalMonth: FiscalMonth?
        
        private var currentMonth: CurrentMonth
        private var activeBudget: ActiveBudget
        private var viewRouter: ViewRouter
        
        let db = Firestore.firestore()
        
        init(currentMonth: CurrentMonth, activeBudget: ActiveBudget, viewRouter: ViewRouter) {
            print("DANLOG init homeview>view model")
            self.currentMonth = currentMonth
            self.activeBudget = activeBudget
            self.viewRouter = viewRouter
            guard activeBudget.documentId != nil else {
                Task {
                    await fetchBudget()
                }
                return
            }
            Task {
                await fetchCurrentFiscalMonth()
            }
            
            let timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { timer in
                print("HomeView Timer fired!")
                Task {
                    print("DANLOG refreshCurrentFiscalMonth")
                    await self.refreshCurrentFiscalMonth()
                }
            }
        }
        
        @MainActor
        func refreshCurrentFiscalMonth() async {
            await fetchCurrentFiscalMonth()
        }
        
        @MainActor
        private func fetchBudget() async {
            print("DANLOG fetchBudget")
            do {
                if let userId = Auth.auth().currentUser?.uid {
                    let budgetResult = try await db.collection("budgets").whereField("ownerIds", arrayContains: userId).limit(to: 1).getDocuments()
                    if let budgetDocument = budgetResult.documents.first {
                        activeBudget.setActiveBudgetDocumentId(id: budgetDocument.documentID)
                        print("DANLOG budgetId", budgetDocument.documentID as Any)
                    }
                } else {
                    print("DANLOG bounced out with no auth")
                    withAnimation {
                        viewRouter.changePage(.signInPage)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        @MainActor
        private func fetchCurrentFiscalMonth() async {
            print("DANLOG fetchCurrentFiscalMonth")
            do {
                let fiscalMonthsResult = try await db.collection("fiscalMonths").whereField("budgetId", isEqualTo: activeBudget.documentId).order(by: "createdAt", descending: false).getDocuments()
                if let fiscalMonth = fiscalMonthsResult.documents.last {
                    let month = try fiscalMonth.data(as: FiscalMonth.self)
                    let monthOfFiscalMonth = Calendar.current.component(.month, from: Date(timeIntervalSince1970: month.createdAt))
                    if Calendar.current.component(.month, from: Date()) > monthOfFiscalMonth {
                        await rollOverFiscalMonth(fiscalMonthId: month.id!)
                    } else {
                        self.activeFiscalMonth = month
                        print("DANLOG activeFiscalMonth", fiscalMonth.documentID as Any)
                    }
                } else {
                    await self.setupNewFiscalMonth()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        @MainActor
        private func setupNewFiscalMonth() async {
            do {
                print("DANLOG creating new activeFiscalMonth")
                let newFiscalMonth = FiscalMonth(budgetId: activeBudget.documentId!, monthName: currentMonth.name, monthIndex: Calendar.current.component(.month, from: Date()), totalExpenses: 0, totalBudget: 0)
                let savedFiscalMonthRef = try db.collection("fiscalMonths").addDocument(from: newFiscalMonth)
                let savedFiscalMonth = try await savedFiscalMonthRef.getDocument().data(as: FiscalMonth.self)
                self.activeFiscalMonth = savedFiscalMonth
                print("DANLOG new activeFiscalMonth", savedFiscalMonthRef.documentID as Any)
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
        @MainActor
        private func rollOverFiscalMonth(fiscalMonthId: String) async {
            await setupNewFiscalMonth()
            do {
                let snap = try await db.collection("subAccounts").whereField("fiscalMonthId", isEqualTo:fiscalMonthId).getDocuments()
                let docs = snap.documents
                
                let subAccounts = docs.map { return try! $0.data(as: SubAccount.self) }
                for account in subAccounts {
                    let newSubAccount = SubAccount(fiscalMonthId: self.activeFiscalMonth!.id!, budgetId: account.budgetId, title: account.title, budget: account.budget, expenses: 0)
                    try self.db.collection("subAccounts").addDocument(from: newSubAccount)
                }
                
            } catch let error {
                print(error)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: .init(currentMonth: CurrentMonth(), activeBudget: ActiveBudget(), viewRouter: ViewRouter()))
            .colorScheme(.light)
            .preferredColorScheme(.light)
    }
}
