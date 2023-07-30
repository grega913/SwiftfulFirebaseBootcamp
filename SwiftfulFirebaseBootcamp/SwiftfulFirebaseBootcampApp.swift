//
//  SwiftfulFirebaseBootcampApp.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 26/07/2023.
//

import SwiftUI
import Firebase



@main
struct SwiftfulFirebaseBootcampApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Configured Firebase through App Delegate!")
        
        return true
    }
}
