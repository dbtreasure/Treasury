//
//  TreasuryApp.swift
//  Treasury
//
//  Created by Daniel Treasure on 2/19/22.
//

import SwiftUI
import Firebase

@main
struct TreasuryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var viewRouter = ViewRouter()
    
    
    var body: some Scene {
        WindowGroup {
            IndexView()
                .environmentObject(viewRouter)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      FirebaseApp.configure()
      Database.database().isPersistenceEnabled = true
      return true
  }
}
