//
//  IONConnection.swift
//  ion-swift
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation
import Network

class IONConnection: UnderlyingConnection {
    var delegate: UnderlyingConnectionDelegate?
    var isConnected: Bool = false
    var recommendedPacketSize: Int = 0

    let endpoint: NWEndpoint
    let dispatchQueue: DispatchQueue

    var connection: NWConnection?
    var description: String {
        return "Connection: {endpoint: \(self.endpoint), isConnected: \(self.isConnected))}"
    }

    init(endpoint: NWEndpoint,
         dispatchQueue: DispatchQueue) {
        self.endpoint = endpoint
        self.dispatchQueue = dispatchQueue

        self.connection = NWConnection(to: endpoint, using: IONLocalPeer.dafaultParemeters)
        self.handleUpdates()
    }

    private func handleUpdates() {
        guard let connection = connection else { return }

        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                self.isConnected = true
                print("\(connection) established")

                // When the connection is ready, start receiving messages.
                self.receiveNextMessage()

                // Notify your delegate that the connection is ready.
                self.delegate?.didConnect(self)
            case let .failed(error):
                self.isConnected = false
                print("\(connection) failed with \(error)")

                // Close the connection upon a failure.
                self.close(error as AnyObject)
            default:
                break
            }
        }
    }

    private func receiveNextMessage() {
        guard let connection = connection else { return }

        connection.receiveMessage { data, _, isComplete, error in
            if isComplete, let data = data, error != nil {
                self.delegate?.didReceiveData(self, data: data)
            } else if error == nil {
                // Continue to receive more messages until you receive and error.
                self.receiveNextMessage()
            }
        }
    }

    // MARK: UnderlyingConnection protocol implementation methods

    func connect() {
        guard let connection = connection else { return }

        // Start the connection establishment.
        connection.start(queue: self.dispatchQueue)
    }

    func close() {
        self.close(nil)
    }

    func close(_ error: AnyObject? = nil) {
        guard let connection = connection else { return }

        connection.cancel()
        self.connection = nil

        self.delegate?.didClose(self, error: error)
    }

    func writeData(_ data: Data) {
        if self.isConnected == false { return }

        guard let connection = connection else { return }

//      TODO: Context based routing
//      let context = NWConnection.ContentContext(identifier: "route",
//                                                  metadata: nil)

        connection.send(content: data,
                        completion: .contentProcessed { _ in
                            self.delegate?.didSendData(self)
        })
    }
}
