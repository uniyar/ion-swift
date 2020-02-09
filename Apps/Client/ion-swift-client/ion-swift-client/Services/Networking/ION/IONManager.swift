//
//  IONManager.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 23.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import IONSwift
import RxSwift

class IONManager {
    static let shared = IONManager()

    private let disposeBag = DisposeBag()

    let discoveredPeerSubject = PublishSubject<IONRemotePeer>()
    let removedPeerSubject = PublishSubject<IONRemotePeer>()

    init() {
        self.setupION()
    }

    private func setupION() {
        let localPeer = IONLocalPeer(
            appId: AppRepository.shared.appIdentifier,
            dispatchQueue: DispatchQueue.main
        )

        localPeer.start(onPeerDiscovered: { remotePeer in
            self.discoveredPeerSubject.onNext(remotePeer)
        }, onPeerRemoved: { remotePeer in
            self.removedPeerSubject.onNext(remotePeer)
        })
    }
}
