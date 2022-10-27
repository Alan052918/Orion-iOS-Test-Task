//
//  AppDelegate.swift
//  OrionTestTask
//
//  Created by Junda Ai on 10/16/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }

}

// MARK: State Restoration
extension AppDelegate {

    func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func application(_ application: UIApplication,
                     viewControllerWithRestorationIdentifierPath identifierComponents: [String],
                     coder: NSCoder) -> UIViewController? {
        let viewController = ViewController(nibName: nil, bundle: nil)
        viewController.restorationIdentifier = identifierComponents.last
        viewController.restorationClass = ViewController.self
        return viewController
    }

}
