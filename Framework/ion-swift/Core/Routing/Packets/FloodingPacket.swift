//
//  FloodingPacket.swift
//  ion-swift
//
//  Created by Ivan Manov on 09.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

/**
 * A FloodingPacket is a packet that floods any other packet through the network.
 * The pair of sequenceNumber and originIdentifier are required to ensure that packets are not flooded indefinitely. See the FloodingPacketManager for more information.
 */
struct FloodingPacket: Packet {
    let sequenceNumber: Int32
    let originIdentifier: UUID
    let payload: Data

    static func getType() -> PacketType { return PacketType.floodPacket }
    static func getLength() -> Int { return MemoryLayout<PacketType>.size + MemoryLayout<Int32>.size + MemoryLayout<UUID>.size }

    static func deserialize(_ data: DataReader) -> FloodingPacket? {
        if !Packets.check(data: data, expectedType: self.getType(), minimumLength: self.getLength()) { return nil }
        return FloodingPacket(sequenceNumber: data.getInteger(), originIdentifier: data.getUUID(), payload: data.getData() as Data)
    }

    func serialize() -> Data {
        let data = DataWriter(length: type(of: self).getLength() + payload.count)
        data.add(type(of: self).getType().rawValue)
        data.add(self.sequenceNumber)
        data.add(self.originIdentifier)
        data.add(self.payload)
        return data.getData() as Data
    }
}
