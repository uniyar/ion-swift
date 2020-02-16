//
//  ScreenFactory.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 25.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import UIKit

class ScreenFactory {
    static let shared = ScreenFactory()

    // MARK: active view controllers

    private(set) var startVC: StartViewController?
    private(set) var mainVC: MainViewController?

    func reset() {
        self.startVC = nil
        self.mainVC = nil
    }

    // MARK: Initialization methods

    func prepareStart() -> UIViewController? {
        self.startVC = UIStoryboard(name: "Start", bundle: nil)
            .instantiateViewController(withIdentifier: "start") as? StartViewController

        return self.startVC
    }

    func prepareMain() -> UIViewController? {
        self.mainVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "main") as? MainViewController

        return UINavigationController(rootViewController: self.mainVC ?? UIViewController())
    }

    func prepareChat(with peerId: String) -> UIViewController {
        let chatCV = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "chat") as? ChatViewController
        chatCV?.viewModel = ChatViewModel(with: peerId)

        return chatCV ?? UIViewController()
    }
}
