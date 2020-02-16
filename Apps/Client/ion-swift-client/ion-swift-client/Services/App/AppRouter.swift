//
//  AppRouter.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 25.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import UIKit

final class AppRouter: Router<UIViewController>, AppRouter.Routes {
    static let shared = AppRouter()

    /// Key app window
    var window: UIWindow?

    typealias Routes =
        StartRoute &
        MainRoute &
        ChatRoute

    /// Present viewController in current visible context as Modal
    /// - Parameter viewController: controller to present to
    /// - Parameter parentViewController: controller to present from
    /// - Parameter completion: completion block on modal dismiss and etc.
    func present(viewController: UIViewController?,
                 parentViewController: UIViewController? = UIWindow.visibleViewController,
                 completion: (() -> Void)? = nil) {
        if parentViewController != nil, viewController != nil {
            viewController!.modalPresentationStyle = .overFullScreen
            parentViewController!.present(viewController!, animated: true, completion: completion)
        }
    }
}
