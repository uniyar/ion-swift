//
//  PushTransition.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 25.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import UIKit

class PushTransition: NSObject {
    var animator: Animator?
    var isAnimated: Bool = true
    var completionHandler: (() -> Void)?

    weak var viewController: UIViewController?

    init(animator: Animator? = nil, isAnimated: Bool = true) {
        self.animator = animator
        self.isAnimated = isAnimated
    }
}

// MARK: - Transition

extension PushTransition: Transition {
    func open(_ viewController: UIViewController) {
        self.viewController?.navigationController?.delegate = self
        self.viewController?.navigationController?.pushViewController(viewController, animated: isAnimated)
    }

    func close(_: UIViewController) {
        self.viewController?.navigationController?.popViewController(animated: isAnimated)
    }
}

// MARK: - UINavigationControllerDelegate

extension PushTransition: UINavigationControllerDelegate {
    func navigationController(_: UINavigationController,
                              didShow _: UIViewController,
                              animated _: Bool) {
        completionHandler?()
    }

    func navigationController(_: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from _: UIViewController,
                              to _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let animator = animator else {
            return nil
        }
        if operation == .push {
            animator.isPresenting = true
            return animator
        } else {
            animator.isPresenting = false
            return animator
        }
    }
}
