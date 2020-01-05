//
//  SceneDelegate.swift
//  ion-swift-example
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options _: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}
