//
//  ChatViewModel.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 16.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import AVFoundation
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

        let frame = self.resizeImage(image: frame, targetSize: CGSize(width: 320, height: 640))
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

    fileprivate func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
