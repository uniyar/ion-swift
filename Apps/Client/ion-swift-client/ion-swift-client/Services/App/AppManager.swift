//
//  AppManager.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 25.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import UIKit

class AppManager {
    static let shared = AppManager()
}

// MARK: App life circle

extension AppManager {
    /// Start application from start screen / App entry point
    func startApp() {
        AppRouter.shared.openStart()
    }

    /// Restart app on logout. Clear all active UI and user data (todo)
    func restartApp() {
        self.resetApp()
        self.startApp()
    }

    /// Reset all data (ex. after logout)
    func resetApp() {
        ScreenFactory.shared.reset()
    }

    // MARK: Reusable app routes

    /// Enter main app circle from main tabs screen if authenticated
    func openMain() {
        ScreenFactory.shared.reset()
        AppRouter.shared.viewController = UIWindow.visibleViewController
        AppRouter.shared.openMain()
    }
}
