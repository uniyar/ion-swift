//
//  UIWindow+Helper.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 25.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import UIKit

extension UIWindow {
    static var visibleViewController: UIViewController? {
        var currentVc = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
        while let presentedVc = currentVc?.presentedViewController {
            if let navVc = (presentedVc as? UINavigationController)?.viewControllers.last {
                currentVc = navVc
            } else if let tabVc = (presentedVc as? UITabBarController)?.selectedViewController {
                currentVc = tabVc
                if let navVc = (currentVc as? UINavigationController)?.viewControllers.last {
                    currentVc = navVc
                }
            } else {
                currentVc = presentedVc
            }
        }
        return currentVc
    }
}
