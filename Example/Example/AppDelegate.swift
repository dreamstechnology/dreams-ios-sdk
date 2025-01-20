//
//  AppDelegate.swift
//  Example
//
//  Created by Doo on 2020-09-24.
//

import UIKit
import DreamsEnterpriseSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let configuration = DreamsConfiguration(clientId: "clientId", baseURL: URL(string: "https://acme.dreams.enterprises")!)
        Dreams.configure(configuration)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
