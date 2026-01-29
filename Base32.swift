//
//  Base32.swift
//  Liquid
//
//  Created by Giuseppe Pizzini on 15/12/25.
//


import Foundation

enum Base32 {
    // Decodifica Base32 RFC 4648 (A-Z2-7), tollera "=" e spazi
    static func decode(_ string: String) -> Data? {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        let cleaned = string
            .uppercased()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: " ", with: "")

        var bits = 0
        var value = 0
        var output = Data()

        for ch in cleaned {
            guard let idx = alphabet.firstIndex(of: ch) else { return nil }
            let v = alphabet.distance(from: alphabet.startIndex, to: idx)
            value = (value << 5) | v
            bits += 5

            if bits >= 8 {
                let byte = UInt8((value >> (bits - 8)) & 0xFF)
                output.append(byte)
                bits -= 8
            }
        }
        return output
    }
}