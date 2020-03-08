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

    var connection: Connection?
    var peer: IONRemotePeer? {
        didSet {
            self.handlePeer()
        }
    }

    private var cameraCaptureHelper: CameraCaptureHelper?

    init(with peerId: String) {
        self.peerId = peerId

        IONManager.shared.peersSubject
            .subscribe(onNext: { _ in
                self.updatePeer()
            }).disposed(by: self.disposeBag)

        self.updatePeer()
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

    private func updatePeer() {
        self.peer = IONManager.shared.peers.first(where: { $0.stringIdentifier == self.peerId })
    }

    private func handleNewOutput(frame: UIImage) {
        DispatchQueue.main.async {
            self.outputFrameSubject.onNext(frame)
        }

        if let data = frame.jpegData(compressionQuality: 0.4) {
            _ = self.connection?.send(data: data)
        }
    }

    private func handleNewInput(data: Data) {
        if let inputFrame = UIImage(data: data) {
            DispatchQueue.main.async {
                self.inputFrameSubject.onNext(inputFrame)
            }
        }
    }

    private func handlePeer() {
        guard let peer = self.peer else { return }
        self.connection = IONManager.shared.connect(to: peer)

        DispatchQueue.global(qos: .default).async {
            self.connection?.onData = { [unowned self] in self.handleNewInput(data: $0) }
        }
    }
}

extension ChatViewModel: CameraCaptureHelperDelegate {
    func newCameraImage(_: CameraCaptureHelper, image: UIImage) {
        DispatchQueue.global(qos: .default).async {
            self.handleNewOutput(frame: image)
        }
    }
}
