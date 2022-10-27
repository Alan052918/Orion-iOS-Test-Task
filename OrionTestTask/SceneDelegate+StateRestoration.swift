//
//  SceneDelegate+StateRestoration.swift
//  OrionTestTask
//
//  Created by Junda Ai on 10/24/22.
//

import UIKit

extension SceneDelegate {

    static let MainSceneActivityType = { () -> String in
        guard let activityTypes = Bundle.main.infoDictionary?["NSUserActivityTypes"] as? [String],
              activityTypes.count > 0 else {
            fatalError("Missing information property for key 'NSUserActivityTypes'")
        }
        return activityTypes[0]
    }

    static let webViewInteractionStateKey = "webViewInteractionState"
    static let fullWebViewVisibleStateKey = "fullWebViewVisibleState"

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        if let rootViewController = window?.rootViewController as? UINavigationController,
           let viewController = rootViewController.topViewController as? ViewController {
            viewController.updateUserActivity()
        }
        logger.info("restore activity: \(String(describing: scene.userActivity)) for scene: \(scene)")

        return scene.userActivity
    }

    func scene(_ scene: UIScene, restoreInteractionStateWith stateRestorationActivity: NSUserActivity) {
        guard let navigationController = window?.rootViewController as? UINavigationController,
              let viewController = navigationController.topViewController as? ViewController,
              stateRestorationActivity.activityType == SceneDelegate.MainSceneActivityType(),
              let userInfo = stateRestorationActivity.userInfo else { return }

        if let webViewInteractionState = userInfo[SceneDelegate.webViewInteractionStateKey] {
            viewController.restoredWebViewInteractionState = webViewInteractionState
        }
        if let fullWebViewVisibleState = userInfo[SceneDelegate.fullWebViewVisibleStateKey] as? Bool {
            viewController.restoredFullWebViewVisibleState = fullWebViewVisibleState
        }
    }

}
