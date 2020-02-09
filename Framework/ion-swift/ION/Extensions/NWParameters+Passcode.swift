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
    static func defaultParams() -> NWParameters {
        // First, create the TLS options.
        let tlsOptions = NWProtocolTLS.Options()

        // Always disable resumption for the probes to measure the
        // full handshake time. You should not disable resumption
        // for general use in your app.
        let securityOptions = tlsOptions.securityProtocolOptions
        sec_protocol_options_set_tls_resumption_enabled(securityOptions, true)

        // Create the parameters based on the probe type.
        let parameters: NWParameters
        sec_protocol_options_set_min_tls_protocol_version(securityOptions, .TLSv13)
        sec_protocol_options_set_max_tls_protocol_version(securityOptions, .TLSv13)
        parameters = NWParameters(tls: tlsOptions)

        return parameters
    }

    convenience init(passcode: String) {
        // Customize TCP options to enable keepalives.
        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.enableKeepalive = true
        tcpOptions.keepaliveIdle = 2

        // Create parameters with custom TLS and TCP options.
        self.init(tls: NWParameters.tlsOptions(passcode: passcode), tcp: tcpOptions)

        // Enable using a peer-to-peer link.
        self.includePeerToPeer = true
    }

    // Create TLS options using a passcode to derive a pre-shared key.
    private static func tlsOptions(passcode: String) -> NWProtocolTLS.Options {
        let tlsOptions = NWProtocolTLS.Options()

        let authenticationKey = SymmetricKey(data: passcode.data(using: .utf8)!)
        var authenticationCode = HMAC<SHA256>.authenticationCode(for: "ion-swift".data(using: .utf8)!, using: authenticationKey)

        let authenticationDispatchData = withUnsafeBytes(of: &authenticationCode) { (ptr: UnsafeRawBufferPointer) in
            DispatchData(bytes: ptr)
        }

        sec_protocol_options_add_pre_shared_key(tlsOptions.securityProtocolOptions,
                                                authenticationDispatchData as __DispatchData,
                                                stringToDispatchData("ion-swift")! as __DispatchData)
        sec_protocol_options_append_tls_ciphersuite(tlsOptions.securityProtocolOptions,
                                                    tls_ciphersuite_t(rawValue: TLS_PSK_WITH_AES_128_GCM_SHA256)!)

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
