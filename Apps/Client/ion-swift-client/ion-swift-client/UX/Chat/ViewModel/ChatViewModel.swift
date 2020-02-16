//
//  ChatViewModel.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 16.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import IONSwift
import RxSwift
import UIKit

class ChatViewModel {
    let peerId: String
    let outputFrameSubject = PublishSubject<UIImage>()
    let inputFrameSubject = PublishSubject<UIImage>()
    private let disposeBag = DisposeBag()

    var peer: IONRemotePeer?

    private var cameraCaptureHelper: CameraCaptureHelper?

    init(with peerId: String) {
        self.peerId = peerId

        IONManager.shared.peersSubject
            .subscribe(onNext: { peers in
                self.peer = peers.first(where: { $0.stringIdentifier == self.peerId })
            }).disposed(by: self.disposeBag)
    }

    // MARK: Public methods

    func startCamera() {
        self.cameraCaptureHelper = CameraCaptureHelper(cameraPosition: .front)
        self.cameraCaptureHelper?.delegate = self
    }

    func stopCamera() {
        self.cameraCaptureHelper?.delegate = nil
        self.cameraCaptureHelper = nil
    }

    // MARK: Private methods

    private func handleNewOutput(frame: UIImage) {
        self.outputFrameSubject.onNext(frame)
    }
}

extension ChatViewModel: CameraCaptureHelperDelegate {
    func newCameraImage(_: CameraCaptureHelper, image: UIImage) {
        self.handleNewOutput(frame: image)
    }
}
