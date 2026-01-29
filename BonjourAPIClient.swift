//
//  BonjourAPIClient.swift
//  Bonjourliquid
//
//  Created by Giuseppe Pizzini on 26/01/26.
//

import Foundation

// MARK: - Models

struct CheckRegistrationResponse: Decodable {
    let status: String
    let name: String?
    let picture: String?
    let message: String?
}

// risposta per request_registration (success/ko + message)
struct BasicStatusResponse: Decodable {
    let status: String
    let message: String?
}

// Modelli per export_today
struct ExportTodayEvent: Decodable, Identifiable {
    let id: Int
    let azione: String
    let data_inizio: String
    let data_fine: String
    let email: String
    let user_name: String
    let tipo_richiesta: String?
    let json_data: [String: AnyCodableJSON]
}

enum AnyCodableJSON: Decodable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode AnyCodableJSON")
        }
    }
}

struct ExportTodayResponse: Decodable {
    let status: String
    let events: [ExportTodayEvent]
}

enum BonjourAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case server(String)
    case decoding

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL non valido"
        case .invalidResponse: return "Risposta non valida"
        case .server(let msg): return msg
        case .decoding: return "Errore nel parsing della risposta"
        }
    }
}

final class BonjourAPIClient {

    // ✅ PROD - ZABBIX
    private let baseURL = URL(string: "https://zabbix7.stmitalia.com")!
    
    // 🔐 Shared TOTP Key (hardcoded)
    private let totpSharedKey = "PGYXQI2WQAS6CRHMCIMVEM55BX7X7V2R"
    
    // Riferimento alla sessione auth per TOTP
    private weak var authSession: AuthSession?
    
    init(authSession: AuthSession? = nil) {
        self.authSession = authSession
    }

    // MARK: - Helpers

    private func makeURL(_ path: String) -> URL {
        let clean = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return baseURL.appendingPathComponent(clean)
    }

    private func makeRequest(
        path: String,
        method: String = "POST",
        body: [String: Any]
    ) throws -> URLRequest {
        let url = makeURL(path)
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        return req
    }

    private func makeRequest<T: Encodable>(
        path: String,
        method: String = "POST",
        body: T
    ) throws -> URLRequest {
        let url = makeURL(path)
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 🔐 Aggiungi TOTP header per le richieste POST (assenze)
        if path == "/bonjour" {
            let totp = TOTP(secretBase32: totpSharedKey)
            if let code = totp.generate() {
                req.setValue(code, forHTTPHeaderField: "X-API-KEY")
                print("🔐 X-API-KEY Header:", code)
            }
        }
        
        req.httpBody = try JSONEncoder().encode(body)
        return req
    }

    private func run(_ req: URLRequest) async throws -> (Data, HTTPURLResponse) {

        // 🔎 logger utile: puoi lasciarlo finché non è stabile
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("➡️ REQUEST", req.httpMethod ?? "nil", req.url?.absoluteString ?? "nil")
        
        // Mostra gli header
        if let headers = req.allHTTPHeaderFields {
            print("➡️ HEADERS:")
            for (key, value) in headers {
                print("  \(key): \(value)")
            }
        }
        
        if let body = req.httpBody, let bodyStr = String(data: body, encoding: .utf8) {
            print("➡️ BODY:", bodyStr)
        } else {
            print("➡️ BODY: <empty>")
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw BonjourAPIError.invalidResponse
        }

        print("⬅️ STATUS:", http.statusCode)
        if let respStr = String(data: data, encoding: .utf8) {
            print("⬅️ RESPONSE:", respStr.prefix(500))
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━")

        return (data, http)
    }

    private func parseServerError(_ data: Data) -> String {
        if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let msg = obj["message"] as? String {
            return msg
        }
        return String(data: data, encoding: .utf8) ?? "Errore server"
    }

    // MARK: - Auth endpoints (DEV → PROD) - NO API KEY (per ora)

    func checkRegistration(email: String) async throws -> CheckRegistrationResponse {
        let cleanEmail = email.lowercased()
        let req = try makeRequest(
            path: "/api/bonjour/check_registration",
            body: [
                "email": cleanEmail,
                "device_id": DeviceManager.shared.deviceId(forEmail: cleanEmail)
            ]
        )

        let (data, http) = try await run(req)
        if !(200...299).contains(http.statusCode) {
            throw BonjourAPIError.server(parseServerError(data))
        }

        guard let decoded = try? JSONDecoder().decode(CheckRegistrationResponse.self, from: data) else {
            throw BonjourAPIError.decoding
        }
        return decoded
    }

    /// endpoint corretto
    func requestRegistration(email: String) async throws -> BasicStatusResponse {
        let cleanEmail = email.lowercased()
        let req = try makeRequest(
            path: "/api/bonjour/request_registration",
            body: [
                "email": cleanEmail,
                "device_id": DeviceManager.shared.deviceId(forEmail: cleanEmail)
            ]
        )

        let (data, http) = try await run(req)
        if !(200...299).contains(http.statusCode) {
            throw BonjourAPIError.server(parseServerError(data))
        }

        guard let decoded = try? JSONDecoder().decode(BasicStatusResponse.self, from: data) else {
            throw BonjourAPIError.decoding
        }
        return decoded
    }

    func verifyRegistration(email: String, code: String) async throws -> CheckRegistrationResponse {
        let cleanEmail = email.lowercased()
        let req = try makeRequest(
            path: "/api/bonjour/verify_registration",
            body: [
                "email": cleanEmail,
                "code": code,
                "device_id": DeviceManager.shared.deviceId(forEmail: cleanEmail)
            ]
        )

        let (data, http) = try await run(req)
        if !(200...299).contains(http.statusCode) {
            throw BonjourAPIError.server(parseServerError(data))
        }

        guard let decoded = try? JSONDecoder().decode(CheckRegistrationResponse.self, from: data) else {
            throw BonjourAPIError.decoding
        }

        return decoded
    }

    // MARK: - Main action endpoint (/bonjour)

    func postBonjour(payload: AbsencePayload) async throws {

        let req = try makeRequest(
            path: "/bonjour",
            body: payload
        )

        let (data, http) = try await run(req)
        if !(200...299).contains(http.statusCode) {
            throw BonjourAPIError.server(parseServerError(data))
        }
    }

    // MARK: - Report endpoint

    func exportToday(email: String, startDate: String, endDate: String) async throws -> ExportTodayResponse {
        // Construisci URL con query parameters
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = "/api/bonjour/export_today"
        components.queryItems = [
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "start_date", value: startDate),
            URLQueryItem(name: "end_date", value: endDate)
        ]
        
        guard let url = components.url else {
            throw BonjourAPIError.invalidURL
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 🔐 Aggiungi TOTP header
        let totp = TOTP(secretBase32: totpSharedKey)
        if let code = totp.generate() {
            req.setValue(code, forHTTPHeaderField: "X-API-KEY")
            print("🔐 X-API-KEY Header:", code)
        }

        let (data, http) = try await run(req)
        if !(200...299).contains(http.statusCode) {
            throw BonjourAPIError.server(parseServerError(data))
        }

        guard let decoded = try? JSONDecoder().decode(ExportTodayResponse.self, from: data) else {
            throw BonjourAPIError.decoding
        }
        return decoded
    }
}
