//
//  IONManager.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 23.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import IONSwift
import RxSwift

class IONManager: LocalPeer {
    static let shared = IONManager()

    private let disposeBag = DisposeBag()

    let discoveredPeerSubject = PublishSubject<RemotePeer>()
    let removedPeerSubject = PublishSubject<RemotePeer>()
    let connectedPeerSubject = PublishSubject<(RemotePeer, Connection)>()
//    let nodesSubject = PublishSubject<[IONSwift.UUID: Node]>()

    init() {
        super.init(
            name: LocalPeer.deviceName,
            identifier: IONSwift.fromUUID(Foundation.UUID()),
            modules: [
//                IONProvider.shared.sioModule,
            ],
            dispatchQueue: DispatchQueue.main
        )

//        self.start { _ in
//            self.nodesSubject.onNext(self.nodes)
//        }
    }
}
