//
//  ChatRoute.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 16.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

protocol ChatRoute {
    func openChat(with peerId: String)
}

extension ChatRoute where Self: RouterProtocol {
    func openChat(with peerId: String) {
        let chatVC = ScreenFactory.shared.prepareChat(with: peerId)
        open(chatVC, transition: PushTransition())
    }
}
