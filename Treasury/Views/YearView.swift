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
                                viewModel: .init(activeBudget: activeBudget, activeFiscalMonth: month, router: router)
                            )) {
                            HStack(alignment: .center, spacing: 10) {
                                Text(month.getMonthName())
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
            if let totalBudget = viewModel.yearlyBudget, let totalExpenses = viewModel.yearlyExpenses, let bottomLine = viewModel.yearlyBottomLine {
                VStack(alignment: .center, spacing: 6) {
                    HStack(
                        alignment: .center, spacing: 10
                    ) {
                        Text("Total budget")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("$\(totalBudget)")
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
                        (totalExpenses <= 0 ?
                         Text("$\(totalExpenses)") :
                            Text("-$\(totalExpenses)").foregroundColor(.red))
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
                            bottomLine < 0 ?
                            Text("$\(bottomLine)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.red) :
                                Text("$\(bottomLine)")
                                .font(.title2)
                                .fontWeight(.semibold)
                        )
                    }
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
        .navigationBarTitle(String(Calendar.current.component(.year, from: Date())))
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
        @Published private(set) public var yearlyExpenses: Int?
        @Published private(set) public var yearlyBudget: Int?
        @Published private(set) public var yearlyBottomLine: Int?
        
        private var activeBudget: ActiveBudget
        
        private let db = Firestore.firestore()
        
        init(activeBudget: ActiveBudget) {
            self.activeBudget = activeBudget
            fetchFiscalMonths()
        }
        
        private func fetchFiscalMonths() {
            do {
                db.collection("fiscalMonths").whereField("budgetId", isEqualTo: activeBudget.documentId).order(by: "createdAt", descending: false).addSnapshotListener {
                    (snap, err) in
                    
                    guard let docs = snap?.documents else { return }
                    
                    self.fiscalMonths = docs.map { return try! $0.data(as: FiscalMonth.self) }
                        .filter { $0.getYear() == Calendar.current.component(.year, from: Date()) }
                    self.calculateYearlyTotal()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        private func calculateYearlyTotal() {
            let yearlyBudget = self.fiscalMonths.reduce(0) {$0 + $1.totalBudget}
            self.yearlyBudget = yearlyBudget
            let yearlyExpenses = self.fiscalMonths.reduce(0) {$0 + $1.totalExpenses}
            self.yearlyExpenses = yearlyExpenses
            self.yearlyBottomLine = yearlyBudget - yearlyExpenses
        }
    }
}

struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView(viewModel: .init(activeBudget: ActiveBudget()))
    }
}

