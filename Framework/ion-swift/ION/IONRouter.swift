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
    let advertiser: CompositeAdvertiser
    let browser: CompositeBrowser
    var modules: [ManagedModule]

    /// <#Description#>
    /// - Parameters:
    ///   - localIdentifier: <#localIdentifier description#>
    ///   - localName: <#localName description#>
    ///   - dispatchQueue: <#dispatchQueue description#>
    ///   - modules: <#modules description#>
    init(localIdentifier: UUID, localName: String, dispatchQueue: DispatchQueue, modules: [Module]) {
        self.modules = modules.map { ManagedModule(module: $0, dispatchQueue: dispatchQueue) }

        self.advertiser = CompositeAdvertiser(advertisers: self.modules.map { $0.advertiser })
        self.browser = CompositeBrowser(browsers: self.modules.map { $0.browser })

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

    /// <#Description#>
    /// - Parameter module: <#module description#>
    func addModule(_ module: Module) {
        let newModule = ManagedModule(module: module, dispatchQueue: self.dispatchQueue)

        self.advertiser.addAdvertiser(newModule.advertiser)
        self.browser.addBrowser(newModule.browser)
        self.modules.append(newModule)
    }

    /// <#Description#>
    /// - Parameter module: <#module description#>
    func removeModule(_ module: Module) {
        let removedModules = self.modules.filter { $0.module === module }

        for removedModule in removedModules {
            self.advertiser.removeAdvertiser(removedModule.advertiser)
            self.browser.removeBrowser(removedModule.browser)
        }

        self.modules = self.modules.filter { $0.module !== module }
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
