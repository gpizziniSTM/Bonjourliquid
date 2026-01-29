//
//  DeviceManager.swift
//  Liquid
//
//  Created by Giuseppe Pizzini on 26/01/26.
//


import UIKit

/// Gestisce l'identificativo univoco del device (IosIdForVendorAsync)
/// Valido finché almeno un'app del vendor resta installata sul device.
final class DeviceManager {

    static let shared = DeviceManager()

    // 🎭 Demo user configuration
    private let demoUserEmail = "demo_user@stmitalia.com"
    private let demoDeviceId = "741942DD-17D7-46D3-AB8E-4FB2EB8D8EDD"

    /// Device ID da usare come `device_id` verso il backend
    let deviceId: String

    private init() {
        if let id = UIDevice.current.identifierForVendor?.uuidString {
            self.deviceId = id
        } else {
            // Fallback estremamente raro, ma evita crash
            self.deviceId = UUID().uuidString
        }

        #if DEBUG
        print("📱 Device ID (identifierForVendor): \(deviceId)")
        #endif
    }
    
    /// Restituisce il device ID appropriato per l'email specificata
    /// Se è demo user, restituisce l'ID hardcoded, altrimenti l'ID reale del device
    func deviceId(forEmail email: String) -> String {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if cleanEmail == demoUserEmail {
            #if DEBUG
            print("🎭 Demo user detected - using hardcoded device ID")
            #endif
            return demoDeviceId
        }
        return deviceId
    }
    
    /// Verifica se l'email corrisponde al demo user
    func isDemoUser(email: String) -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return cleanEmail == demoUserEmail
    }
}