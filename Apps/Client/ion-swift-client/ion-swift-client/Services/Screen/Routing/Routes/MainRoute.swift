//
//  MainRoute.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 25.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import Foundation

protocol MainRoute {
    var mainTransition: Transition { get }
    func openMain()
}

extension MainRoute where Self: RouterProtocol {
    var mainTransition: Transition {
        return ModalTransition()
    }

    func openMain() {
        let transition = self.mainTransition
        if let mainVC = ScreenFactory.shared.prepareMain() {
            open(mainVC, transition: transition)
        }
    }
}
