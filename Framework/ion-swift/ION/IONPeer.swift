//
//  IONPeer.swift
//  ion-swift
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

public class IONPeer: LocalPeer {
    let appId: String

    /// Constructs a new IONPeer object.
    /// - Parameters:
    ///   - appId: application identifier. Using to browse peers with the same appId
    ///   - peerName: The name user for the peer
    ///   - dispatchQueue:  The dispatchQueue used to run all networking code with. The dispatchQueue can be used to specifiy the thread that should be used.
    public init(appId: String = "default_ion_app",
                peerName: String = vendorUUID().UUIDString,
                dispatchQueue: DispatchQueue) {
        self.appId = appId

        super.init(
            name: peerName,
            identifier: vendorUUID(),
            modules: [IONModule()],
            dispatchQueue: dispatchQueue
        )
    }
}
