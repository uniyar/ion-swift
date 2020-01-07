//
//  IONAdvertiser.swift
//  ion-swift
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation
import Network

class IONAdvertiser: Advertiser {
    var isAdvertising: Bool = false
    weak var advertiserDelegate: AdvertiserDelegate?

    let type: String
    var listener: NWListener?
    let dispatchQueue: DispatchQueue
    var connections: [NWConnection] = []

    init(type prefix: String, dispatchQueue: DispatchQueue) {
        self.type = "_\(prefix)._tcp"
        self.dispatchQueue = dispatchQueue

        self.prepareListener()
    }

    private func prepareListener() {
        // Create the listener object.
        guard let listener = try? NWListener(using: IONLocalPeer.dafaultParemeters) else {
            print("Failed to create listener")
            return
        }

        self.listener = listener
        self.handleUpdates()
    }

    private func handleUpdates() {
        guard let listener = self.listener else { return }

        listener.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Listener ready on \(String(describing: listener.port))")
                self.isAdvertising = true
            case let .failed(error):
                print("Listener failed with \(error), restarting...")
                self.isAdvertising = false
                self.restartAdvertising()
            default:
                self.isAdvertising = false
            }
        }

        listener.newConnectionHandler = { newConnection in
            if let connection = self.connections.first(where: {
                $0.endpoint.hashValue == newConnection.endpoint.hashValue
            }) {
//                newConnection.cancel()
            } else {
                newConnection.start(queue: self.dispatchQueue)
                self.connections.append(newConnection)
            }

//            connection.connect()
//            self.dispatchQueue.async {
//                print("New connection request: \(newConnection)")
//                let connection = IONConnection(endpoint: newConnection.endpoint, dispatchQueue: self.dispatchQueue)
//                self.advertiserDelegate?.handleConnection(self, connection: connection)
//            }
        }
    }

    func restartAdvertising() {
        guard let listener = self.listener else { return }

        listener.cancel()
        self.advertiserDelegate?.didStopAdvertising(self)

        listener.start(queue: self.dispatchQueue)

        self.dispatchQueue.async {
            self.advertiserDelegate?.didStartAdvertising(self)
        }
    }

    // MARK: Advertiser protocol methods

    func startAdvertising(_ identifier: UUID) {
        guard let listener = self.listener else { return }

        // Set the service to advertise.
        listener.service = NWListener.Service(name: identifier.UUIDString, type: self.type)

        // Start listening, and request updates on the dispatchQueue.
        listener.start(queue: self.dispatchQueue)
        self.dispatchQueue.async {
            self.advertiserDelegate?.didStartAdvertising(self)
        }
    }

    func stopAdvertising() {
        guard let listener = self.listener else { return }

        listener.cancel()
        self.dispatchQueue.async {
            self.advertiserDelegate?.didStopAdvertising(self)
        }
    }
}
