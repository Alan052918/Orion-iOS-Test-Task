//
//  SceneDelegate.swift
//  OrionTestTask
//
//  Created by Junda Ai on 10/16/22.
//

import UIKit
import Logging

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let logger = Logger(label: "com.jundaai.OrionTestTask.SceneDelegate")

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)

        let viewController = ViewController(nibName: nil, bundle: nil)
        viewController.restorationIdentifier = "ViewController"
        viewController.restorationClass = ViewController.self
        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            logger.info("scene(_:willConnectTo:options:) continue from activity")
            viewController.restore(from: userActivity)
            scene.userActivity = userActivity
        }

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.restorationIdentifier = "RootNavigationController"
        navigationController.isNavigationBarHidden = true
        navigationController.isToolbarHidden = false

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let userActivity = window?.windowScene?.userActivity {
            userActivity.becomeCurrent()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        BrowserStateManager.sharedInstance.saveBrowserState()

        if let userActivity = window?.windowScene?.userActivity {
            userActivity.resignCurrent()
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        BrowserStateManager.sharedInstance.saveBrowserState()
    }

}
