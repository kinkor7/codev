//
// MODIChatMessageBridgedFlagTests.swift
// BitFoundationTests
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import Foundation
import Testing
@testable import BitFoundation

@Suite("MODIChatMessage bridged flag")
struct MODIChatMessageBridgedFlagTests {
    @Test func bridgedFlagSurvivesBinaryRoundTrip() throws {
        let message = MODIChatMessage(
            sender: "far-friend",
            content: "hello from across the hill",
            timestamp: Date(),
            isRelay: false,
            senderPeerID: PeerID(bridge: "deadbeefcafe0123deadbeefcafe0123"),
            isBridged: true
        )
        let binary = try #require(message.toBinaryPayload())
        let decoded = try #require(MODIChatMessage(binary))
        #expect(decoded.isBridged)
        #expect(decoded.senderPeerID?.isBridge == true)
    }

    @Test func plainMessageStaysUnbridgedThroughBinary() throws {
        let plain = MODIChatMessage(
            sender: "neighbor",
            content: "radio only",
            timestamp: Date(),
            isRelay: false
        )
        let binary = try #require(plain.toBinaryPayload())
        let decoded = try #require(MODIChatMessage(binary))
        #expect(!decoded.isBridged)
    }

    @Test func legacyBinaryWithoutBridgedBitDecodesUnbridged() throws {
        // A pre-bridge encoder never sets flag bit 0x40; decoding such a
        // payload must default to unbridged.
        let message = MODIChatMessage(
            sender: "old",
            content: "hi",
            timestamp: Date(),
            isRelay: false,
            isBridged: true
        )
        var binary = try #require(message.toBinaryPayload())
        binary[0] &= ~UInt8(0x40) // strip the bridged bit like an old client
        let decoded = try #require(MODIChatMessage(binary))
        #expect(!decoded.isBridged)
    }
}
