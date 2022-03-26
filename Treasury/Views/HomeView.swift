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
                MonthView(viewModel: .init(currentMonth: currentMonth, activeBudget: activeBudget, activeFiscalMonth: activeFiscalMonth,  router: router))
            }
            .environmentObject(currentMonth)
            .environmentObject(activeBudget)
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
                    self.activeFiscalMonth = month
                    print("DANLOG activeFiscalMonth", fiscalMonth.documentID as Any)
                } else {
                    print("DANLOG creating new activeFiscalMonth")
                    let newFiscalMonth = FiscalMonth(budgetId: activeBudget.documentId!, monthName: currentMonth.name, monthIndex: currentMonth.index, totalExpenses: 0, totalBudget: 0)
                    let savedFiscalMonthRef = try db.collection("fiscalMonths").addDocument(from: newFiscalMonth)
                    let savedFiscalMonth = try await savedFiscalMonthRef.getDocument().data(as: FiscalMonth.self)
                    self.activeFiscalMonth = savedFiscalMonth
                    print("DANLOG new activeFiscalMonth", savedFiscalMonthRef.documentID as Any)
                }
            } catch {
                print(error.localizedDescription)
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
