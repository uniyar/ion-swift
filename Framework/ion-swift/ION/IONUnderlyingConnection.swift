//
//  IONConnection.swift
//  ion-swift
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation
import Network

class IONUnderlyingConnection {
    let connection: NWConnection
    var connectionHandler: ConnectionHandler?
    let dispatchQueue: DispatchQueue

    // MARK: --- UnderlyingConnectionDelegate

    var delegate: UnderlyingConnectionDelegate?
    var isConnected: Bool {
        return self.connection.state == .ready
    }

    var recommendedPacketSize: Int = Int.max

    // ---

    let initiatedConnection: Bool

    // Create an outbound connection when the peer initiates a session.
    init(with endpoint: NWEndpoint,
         dispatchQueue: DispatchQueue) {
        self.initiatedConnection = true
        self.dispatchQueue = dispatchQueue

        let connection = NWConnection(to: endpoint, using: IONLocalPeer.dafaultParemeters)
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
                // When the connection is ready, start receiving data.
                self.receiveProtocolMessage()

                // Notify your delegate that the connection is ready.
                if let delegate = self.delegate {
                    delegate.didConnect(self)
                }

                self.connectionHandler?(true, nil)
            case let .failed(error):
                let message = "\(connection) failed with \(error)"

                // Cancel the connection upon a failure.
                connection.cancel()

                // Notify your delegate that the connection failed.
                if let delegate = self.delegate {
                    delegate.didClose(self, error: NSError(domain: message, code: 500, userInfo: nil))
                }

                self.connectionHandler?(false, message as AnyObject)
            default: break
            }
        }
    }
}

// MARK: UnderlyingConnectionDelegate

extension IONUnderlyingConnection: UnderlyingConnection {
    func connect() {
        if self.isConnected {
            self.connectionHandler?(true, nil)
            return
        }

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

        self.send(protocol: data, type: .core)
    }
}

// MARK: Framing protocol

extension IONUnderlyingConnection {
    func send(protocol data: Foundation.Data, type: IONMessageType) {
        self.dispatchQueue.async {
            let message = NWProtocolFramer.Message(ionMessageType: type)
            let context = NWConnection.ContentContext(
                identifier: type.identifier,
                metadata: [message]
            )

            // Send the application content along with the message.
            self.connection.send(
                content: data,
                contentContext: context,
                isComplete: true,
                completion: .idempotent
            )
            self.delegate?.didSendData(self)
        }
    }

    // Receive a message, deliver it to your delegate, and continue receiving more messages.
    func receiveProtocolMessage() {
        self.connection.receiveMessage { content, context, _, error in
            let message = context?.protocolMetadata(definition: IONProtocol.definition)
                as? NWProtocolFramer.Message

            // Extract your message type from the received context.
            if let ionMessage = message, let data = content {
                switch ionMessage.ionMessageType {
                case .metrics: break
                case .core:
                    self.delegate?.didReceiveData(self, data: data)
                default: break
                }
            }

            if error == nil {
                // Continue to receive more protocol messages until you receive and error.
                self.receiveProtocolMessage()
            }
        }
    }
}
