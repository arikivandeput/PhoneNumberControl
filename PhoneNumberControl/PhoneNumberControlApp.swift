//
//  PhoneNumberControlApp.swift
//  PhoneNumberControl
//
//  Created by Peter Put on 19/02/2024.
////  https://seald-apps.com 

import SwiftUI

@main
struct PhoneNumberControlApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


class AppDelegate: UIResponder, UIApplicationDelegate {
    static private(set) var instance: AppDelegate! = nil
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.instance = self
        if UserDefaults.standard.string(forKey: "kCountyCode") == nil {
            IPService.shared.getCountryCodeFromIP { countryCode in
                if let countryCode = countryCode {
                    UserDefaults.standard.set(countryCode, forKey: "kCountyCode")
                }
            }
        }
        return true
    }
}
