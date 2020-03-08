//
//  NWParameters+Passcode.swift
//  ion-swift
//
//  Created by Ivan Manov on 06.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import CryptoKit
import Network

extension NWParameters {
    convenience init(passcode: String) {
        // Customize TCP options to enable keepalives.
//        let tcpOptions = NWProtocolTCP.Options()
//        tcpOptions.enableKeepalive = true
//        tcpOptions.keepaliveIdle = 2
//        tcpOptions.noDelay = true

        self.init(tls: NWParameters.tlsOptions(passcode: passcode))
        // Create parameters with custom TLS and TCP options.
//        self.init(tls: NWParameters.tlsOptions(passcode: passcode), tcp: tcpOptions)

        // Enable using a peer-to-peer link.
        self.includePeerToPeer = true

//        self.multipathServiceType = .interactive

        // Add ion protocol to support protocol messages.
        let protocolOptions = NWProtocolFramer.Options(definition: IONProtocol.definition)
        self.defaultProtocolStack.applicationProtocols.insert(protocolOptions, at: 0)
    }

    // Create TLS options using a passcode to derive a pre-shared key.
    private static func tlsOptions(passcode: String) -> NWProtocolTLS.Options {
        let tlsOptions = NWProtocolTLS.Options()

        let authenticationKey = SymmetricKey(data: passcode.data(using: .utf8)!)
        var authenticationCode = HMAC<SHA256>.authenticationCode(
            for: "ion-swift".data(using: .utf8)!,
            using: authenticationKey
        )

        let authenticationDispatchData =
            withUnsafeBytes(of: &authenticationCode) { (ptr: UnsafeRawBufferPointer) in
                DispatchData(bytes: ptr)
            }

        sec_protocol_options_add_pre_shared_key(
            tlsOptions.securityProtocolOptions,
            authenticationDispatchData as __DispatchData,
            self.stringToDispatchData("ion-swift")! as __DispatchData
        )
        sec_protocol_options_append_tls_ciphersuite(
            tlsOptions.securityProtocolOptions,
            tls_ciphersuite_t(rawValue: UInt16(TLS_PSK_WITH_AES_128_GCM_SHA256))!
        )

        return tlsOptions
    }

    // Create a utility function to encode strings as pre-shared key data.
    private static func stringToDispatchData(_ string: String) -> DispatchData? {
        guard let stringData = string.data(using: .unicode) else {
            return nil
        }
        let dispatchData = withUnsafeBytes(of: stringData) { (ptr: UnsafeRawBufferPointer) in
            DispatchData(bytes: UnsafeRawBufferPointer(start: ptr.baseAddress, count: stringData.count))
        }
        return dispatchData
    }
}
