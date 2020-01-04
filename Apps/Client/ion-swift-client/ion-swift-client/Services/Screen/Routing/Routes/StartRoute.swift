//
//  StartRoute.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 25.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import Foundation

protocol StartRoute {
    func openStart()
}

extension StartRoute where Self: RouterProtocol {
    func openStart() {
        if let startVC = ScreenFactory.shared.prepareStart() {
            let window = AppRouter.shared.window
            window?.rootViewController = startVC
            window?.makeKeyAndVisible()
        }
    }
}
