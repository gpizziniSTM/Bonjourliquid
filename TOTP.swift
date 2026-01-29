//
//  TOTP.swift
//  Bonjourliquid
//
//  Created by Giuseppe Pizzini on 15/12/25.
//


import Foundation
import CommonCrypto

struct TOTP {
    let secretBase32: String
    let digits: Int
    let period: TimeInterval

    init(secretBase32: String, digits: Int = 6, period: TimeInterval = 30) {
        self.secretBase32 = secretBase32
        self.digits = digits
        self.period = period
    }

    func generate(at date: Date = Date()) -> String? {
        guard let key = Base32.decode(secretBase32) else { return nil }

        let counter = UInt64(floor(date.timeIntervalSince1970 / period))
        var bigEndianCounter = counter.bigEndian
        let counterData = Data(bytes: &bigEndianCounter, count: MemoryLayout.size(ofValue: bigEndianCounter))

        // HMAC-SHA1(counter, key)
        var hmac = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        key.withUnsafeBytes { keyBytes in
            counterData.withUnsafeBytes { msgBytes in
                CCHmac(
                    CCHmacAlgorithm(kCCHmacAlgSHA1),
                    keyBytes.baseAddress,
                    key.count,
                    msgBytes.baseAddress,
                    counterData.count,
                    &hmac
                )
            }
        }

        // Dynamic truncation
        let offset = Int(hmac.last! & 0x0F)
        let part = (UInt32(hmac[offset]) & 0x7F) << 24
                 | (UInt32(hmac[offset + 1]) & 0xFF) << 16
                 | (UInt32(hmac[offset + 2]) & 0xFF) << 8
                 | (UInt32(hmac[offset + 3]) & 0xFF)

        let mod = UInt32(pow(10.0, Double(digits)))
        let otp = part % mod
        return String(format: "%0*u", digits, otp)
    }
}