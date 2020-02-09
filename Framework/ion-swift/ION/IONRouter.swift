//
//  IONRouter.swift
//  ion-swift
//
//  Created by Ivan Manov on 06.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

/// IONRouter uses Modules to discover other peers.
class IONRouter: Router {
    let advertiser: Advertiser
    let browser: Browser
    let ionModule: IONModule

    /// <#Description#>
    /// - Parameters:
    ///   - localIdentifier: <#localIdentifier description#>
    ///   - localName: <#localName description#>
    ///   - dispatchQueue: <#dispatchQueue description#>
    ///   - modules: <#modules description#>
    init(localIdentifier: UUID, localName: String, dispatchQueue: DispatchQueue, module: IONModule) {
        self.ionModule = module

        self.advertiser = self.ionModule.advertiser
        self.browser = self.ionModule.browser

        super.init(identifier: localIdentifier, name: localName, dispatchQueue: dispatchQueue)

        self.advertiser.advertiserDelegate = self
        self.browser.browserDelegate = self
    }

    /// <#Description#>
    func start() {
        self.advertiser.startAdvertising(self.identifier)
        self.browser.startBrowsing()
    }

    /// <#Description#>
    func stop() {
        self.advertiser.stopAdvertising()
        self.browser.stopBrowsing()
    }
}

extension IONRouter: BrowserDelegate {
    func didStartBrowsing(_: Browser) {}

    func didStopBrowsing(_: Browser) {}

    func didDiscoverAddress(_: Browser, address: Address, identifier: UUID) {
        self.addAddress(identifier, nodeName: address.hostName, address: address)
    }

    func didRemoveAddress(_: Browser, address: Address, identifier: UUID) {
        self.removeAddress(identifier, nodeName: nil, address: address)
    }
}

extension IONRouter: AdvertiserDelegate {
    func didStartAdvertising(_: Advertiser) {}

    func didStopAdvertising(_: Advertiser) {}

    func handleConnection(_: Advertiser, connection underlyingConnection: UnderlyingConnection) {
        self.handleDirectConnection(underlyingConnection)
    }
}
