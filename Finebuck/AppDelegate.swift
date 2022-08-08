//
//  AppDelegate.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 04/05/2022.
//

import Foundation
import UIKit
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        #if DEBUG
            let settings = Firestore.firestore().settings
            settings.host = "localhost:8080"
            Auth.auth().useEmulator(withHost:"localhost", port:9099)
            settings.isPersistenceEnabled = false
            settings.isSSLEnabled = false
            Firestore.firestore().settings = settings
        #endif
        
        // Handle testing
        let env = ProcessInfo.processInfo.environment
        if let uiTests = env["UITESTS"], uiTests == "1" {
            // do anything you want
            try? Auth.auth().signOut()
        }
        
        return true
    }
}
