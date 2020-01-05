//
//  IONBrowser.swift
//  ion-swift
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation
import Network

class IONBrowser: Browser {
    var isBrowsing: Bool = false
    weak var browserDelegate: BrowserDelegate?

    let browser: NWBrowser
    let dispatchQueue: DispatchQueue

    init(type prefix: String, dispatchQueue: DispatchQueue) {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        self.browser = NWBrowser(
            for: .bonjour(type: "_\(prefix)._tcp", domain: nil),
            using: parameters
        )
        self.dispatchQueue = dispatchQueue
        self.handleUpdates()
    }

    private func handleUpdates() {
        self.browser.browseResultsChangedHandler = { results, changes in
            changes.forEach { change in
                switch change {
                case let .added(result):
                    print("Added \(result.endpoint)")
                case let .removed(result):
                    print("Removed \(result.endpoint)")
                case let .changed(_, result, flags):
                    if flags.contains(.interfaceAdded) {
                        print("\(result.endpoint) added interfaces")
                    }
                    if flags.contains(.interfaceRemoved) {
                        print("\(result.endpoint) removed interfaces")
                    }
                default:
                    break
                }
            }

            let endpoints = results.map { $0.endpoint }
            print(endpoints)
        }

        self.browser.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                self.isBrowsing = true
            case let .failed(error):
                print("Browser failed with \(error), restarting...")
                self.isBrowsing = false
                self.restartBrowsing()
            default:
                self.isBrowsing = false
            }
        }
    }

    func restartBrowsing() {
        self.stopBrowsing()
        self.startBrowsing()
    }

    // MARK: Browser protocol methods

    func startBrowsing() {
        self.browser.start(queue: self.dispatchQueue)
        self.browserDelegate?.didStartBrowsing(self)
    }

    func stopBrowsing() {
        self.browser.cancel()
        self.browserDelegate?.didStopBrowsing(self)
    }
}
