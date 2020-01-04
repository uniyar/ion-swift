//
//  AppDelegate.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 23.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()

        AppRouter.shared.window = self.window
        AppManager.shared.startApp()

        return true
    }
}
