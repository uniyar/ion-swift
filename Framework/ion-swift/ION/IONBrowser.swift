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
    var browserDelegate: BrowserDelegate?

    let browser: NWBrowser
    let queue: DispatchQueue

    init(type prefix: String, queue: DispatchQueue) {
        self.browser = NWBrowser(
            for: .bonjour(type: prefix + "._tcp", domain: nil),
            using: NWParameters()
        )
        self.queue = queue
        self.handleChanges()
    }
    
    private func handleChanges() {
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
    }

    // MARK: Browser protocol methods

    func startBrowsing() {
        self.browser.start(queue: self.queue)
        self.browserDelegate?.didStartBrowsing(self)
    }

    func stopBrowsing() {
        self.browser.cancel()
        self.browserDelegate?.didStopBrowsing(self)
    }
}
