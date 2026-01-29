import Foundation
import SwiftUI
import Combine
import UIKit
import CoreLocation

// MARK: - Models

struct AbsencePayload: Encodable {
    let email: String
    let data: String
    let ora: String
    let latitudine: Double
    let longitudine: Double
    let json_data: [String: AnyCodable]
}

// Helper per gestire valori di tipo diverso in Encodable
enum AnyCodable: Encodable {
    case string(String)
    case int(Int)
    case double(Double)
    case dict([String: AnyCodable])
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .dict(let value):
            try container.encode(value)
        }
    }
}

@MainActor
final class AbsenceViewModel: ObservableObject {

    private let api: BonjourAPIClient

    // ✅ Fonte unica di verità per utente/email
    private let auth: AuthSession

    init(auth: AuthSession) {
        self.auth = auth
        self.api = BonjourAPIClient(authSession: auth)
    }

    struct ResultAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
        let isSuccess: Bool
    }

    @Published var resultAlert: ResultAlert?

    func submitAction(
        actionName: String,
        actionId: Int,
        extraJSON: [String: Any] = [:],
        startDate: Date,
        endDate: Date,
        location: CLLocation?
    ) async {
        resultAlert = nil

        guard let email = auth.email?.lowercased(), !email.isEmpty else {
            resultAlert = .init(title: "KO", message: "Utente non autenticato. Riapri l’app e fai login.", isSuccess: false)
            return
        }

        // 🔎 DEBUG
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📧 EMAIL AUTH:", email)
        print("📋 DISPLAY NAME:", auth.displayName ?? "nil")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let userName = (auth.displayName?.trimmingCharacters(in: .whitespacesAndNewlines))
        let safeName = (userName?.isEmpty == false) ? userName! : auth.fallbackName()
        
        print("👤 SAFE NAME (final):", safeName)

        let now = Date()

        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryPct = max(0, Int(UIDevice.current.batteryLevel * 100))

        let lat = location?.coordinate.latitude ?? 0
        let lon = location?.coordinate.longitude ?? 0

        var jsonDataDict: [String: AnyCodable] = [
            "azione": .string(actionName),
            "id_azione": .int(actionId),
            "user_name": .string(safeName),
            "data_inizio": .string(Self.formatDate(startDate)),
            "data_fine": .string(Self.formatDate(endDate))
        ]

        // Aggiungere i campi extra (tipo_richiesta, ora_inizio_rol, etc.)
        for (key, value) in extraJSON {
            if let strValue = value as? String {
                jsonDataDict[key] = .string(strValue)
            } else if let intValue = value as? Int {
                jsonDataDict[key] = .int(intValue)
            } else if let doubleValue = value as? Double {
                jsonDataDict[key] = .double(doubleValue)
            }
        }

        let payload = AbsencePayload(
            email: email,
            data: Self.formatDate(now),
            ora: Self.formatTime(now),
            latitudine: lat,
            longitudine: lon,
            json_data: jsonDataDict
        )

        // 🔎 DEBUG: pretty print del payload
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(payload) {
            if let prettyData = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let prettyJson = try? JSONSerialization.data(withJSONObject: prettyData, options: .prettyPrinted),
               let prettyString = String(data: prettyJson, encoding: .utf8) {
                print("📤 PAYLOAD COMPLETO:")
                print(prettyString)
            }
        }

        do {
            try await api.postBonjour(payload: payload)   // ✅ DEV: no apiKey
            resultAlert = .init(title: "OK", message: "Dati salvati correttamente", isSuccess: true)
        } catch {
            resultAlert = .init(title: "KO", message: error.localizedDescription, isSuccess: false)
        }
    }

    private static func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private static func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: date)
    }

    static func formatHourMinute(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    // MARK: - Report

    func fetchTodayReport(startDate: String, endDate: String) async throws -> [ExportTodayEvent] {
        guard let email = auth.email else {
            throw BonjourAPIError.server("Email non disponibile")
        }
        let response = try await api.exportToday(email: email, startDate: startDate, endDate: endDate)
        return response.events
    }
}
