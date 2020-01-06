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
//        let parameters = NWParameters()
//        parameters.includePeerToPeer = true

        self.browser = NWBrowser(
            for: .bonjour(type: "_\(prefix)._tcp", domain: nil),
            using: IONLocalPeer.dafaultParemeters
        )
        self.dispatchQueue = dispatchQueue
        self.handleUpdates()
    }

    private func handleUpdates() {
        self.browser.browseResultsChangedHandler = { _, changes in
            if self.isBrowsing == false { return }

            changes.forEach { change in
                switch change {
                case let .added(result):
                    print("Added \(result.endpoint)")
                    self.addEndpoint(result.endpoint)
                case let .removed(result):
                    print("Removed \(result.endpoint)")
                    self.removeEndpoint(result.endpoint)

//                case let .changed(oldResult, newResult, flags):
//                    if flags.contains(.interfaceAdded) {
//                        print("\(newResult.endpoint) added interfaces")
//
//                        var newInterfaces = newResult.interfaces
//                        newInterfaces.removeAll(where: {
//                            let new = $0
//                            return oldResult.interfaces.contains(where: {
//                                $0.hashValue == new.hashValue
//                            })
//                        })
//                    }
//                    if flags.contains(.interfaceRemoved) {
//                        print("\(newResult.endpoint) removed interfaces")
//
//                        var removedInterfaces = newResult.interfaces
//                        removedInterfaces.removeAll(where: {
//                            let new = $0
//                            return !oldResult.interfaces.contains(where: {
//                                $0.hashValue == new.hashValue
//                            })
//                        })
//                    }
                default:
                    break
                }
            }

//            let endpoints = results.map { $0.endpoint }
//            print(endpoints)
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

    private func addEndpoint(_ endpoint: NWEndpoint) {
        switch endpoint {
        case let .service(name, _, _, _):
            let address = IONAddress(
                hostName: name,
                endpoint: endpoint,
                dispatchQueue: self.dispatchQueue
            )

            self.browserDelegate?.didDiscoverAddress(
                self,
                address: address,
                identifier: UUIDfromString(name) ?? randomUUID()
            )
        default:
            break
        }
    }

    private func removeEndpoint(_ endpoint: NWEndpoint) {
        switch endpoint {
        case let .service(name, _, _, _):
            let address = IONAddress(
                hostName: name,
                endpoint: endpoint,
                dispatchQueue: self.dispatchQueue
            )

            self.browserDelegate?.didRemoveAddress(
                self,
                address: address,
                identifier: UUIDfromString(name) ?? randomUUID()
            )
        default:
            break
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
