//
//  MainRoute.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 25.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import Foundation

protocol MainRoute {
    func openMain()
}

extension MainRoute where Self: RouterProtocol {
    func openMain() {
        if let mainVC = ScreenFactory.shared.prepareMain() {
            open(mainVC, transition: ModalTransition())
        }
    }
}
