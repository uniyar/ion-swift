//
//  IONConnection.swift
//  ion-swift
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation
import Network

class IONConnection {
    let connection: NWConnection
    var connectionHandler: ConnectionHandler?
    let dispatchQueue: DispatchQueue

    // MARK: --- UnderlyingConnectionDelegate

    var delegate: UnderlyingConnectionDelegate?
    var isConnected: Bool {
        return self.connection.state == .ready
    }

    var recommendedPacketSize: Int = 1024

    // ---

    let initiatedConnection: Bool

    // Create an outbound connection when the peer initiates a session.
    init(with endpoint: NWEndpoint,
         dispatchQueue: DispatchQueue) {
        self.initiatedConnection = true
        let connection = NWConnection(to: endpoint, using: IONLocalPeer.dafaultParemeters)
        self.dispatchQueue = dispatchQueue
        self.connection = connection

        self.handleConnectipnUpdates()
    }

    // Handle an inbound connection when the peer receives a session.
    init(with connection: NWConnection,
         dispatchQueue: DispatchQueue) {
        self.initiatedConnection = false
        self.dispatchQueue = dispatchQueue
        self.connection = connection

        self.handleConnectipnUpdates()
    }

    private func handleConnectipnUpdates() {
        let connection = self.connection

        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("\(connection) established")

                // When the connection is ready, start receiving messages.
                self.receiveNextMessage()

                // Notify your delegate that the connection is ready.
                if let delegate = self.delegate {
                    delegate.didConnect(self)
                }

                self.connectionHandler?(true, nil)
            case let .failed(error):
                let message = "\(connection) failed with \(error)"
                print(message)

                // Cancel the connection upon a failure.
                connection.cancel()

                // Notify your delegate that the connection failed.
                if let delegate = self.delegate {
                    delegate.didClose(self, error: NSError(domain: message, code: 500, userInfo: nil))
                }

                self.connectionHandler?(false, message as AnyObject)
            default:
                break
            }
        }
    }

    // Receive a message, deliver it to your delegate, and continue receiving more messages.
    private func receiveNextMessage() {
        let connection = self.connection

        connection.receive(
            minimumIncompleteLength: 0,
            maximumLength: self.recommendedPacketSize
        ) { data, _, _, error in
            if error == nil, let data = data {
                print("-- IONConnection: Did receive data")
                self.delegate?.didReceiveData(self, data: data)
            }

            if error == nil {
                // Continue to receive more messages until you receive and error.
                self.receiveNextMessage()
            }
        }
    }
}

// MARK: UnderlyingConnectionDelegate

extension IONConnection: UnderlyingConnection {
    func connect() {
        if self.isConnected { return }

        // Start the connection establishment.
        self.connection.start(queue: self.dispatchQueue)
    }

    func close() {
        self.connectionHandler = nil
        self.connection.cancel()

        if let delegate = self.delegate {
            delegate.didClose(self, error: NSError(domain: "Closed manually", code: 500, userInfo: nil))
        }
    }

    func writeData(_ data: Data) {
        if !self.isConnected { return }

        self.connection.send(
            content: data,
            completion: .contentProcessed { error in
                if error == nil {
                    print("-- IONConnection: Did send data")
                    self.delegate?.didSendData(self)
                }
            }
        )
    }
}
