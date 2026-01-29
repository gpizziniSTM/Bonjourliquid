import Foundation
import Combine
import LocalAuthentication

@MainActor
final class AuthSession: ObservableObject {

    @Published var isAuthenticated = false
    @Published var isUnlocked = false

    @Published var email: String?
    @Published var displayName: String?
    @Published var pictureURL: String?
    @Published var totpSecret: String?

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var isAwaitingPIN = false
    @Published var enteredEmail: String = ""
    @Published var enteredPIN: String = ""

    private let api = BonjourAPIClient()

    private enum Keys {
        static let hasSession  = "auth.hasSession"
        static let email       = "auth.email"
        static let displayName = "auth.displayName"
        static let pictureURL  = "auth.pictureURL"
        static let totpSecret  = "auth.totpSecret"
    }

    init() {
        loadStoredSession()
    }

    // MARK: - Step 1

    func submitEmail() async {
        errorMessage = nil

        let mail = enteredEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard isValidEmail(mail) else {
            errorMessage = "Inserisci una mail @stmitalia.com valida"
            return
        }

        // 🎭 Demo user: bypass autenticazione
        if DeviceManager.shared.isDemoUser(email: mail) {
            completeLogin(email: mail, name: "Demo User", picture: nil)
            isAwaitingPIN = false
            enteredPIN = ""
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let check = try await api.checkRegistration(email: mail)

            if check.status == "registered" {
                completeLogin(email: mail, name: check.name, picture: check.picture)
                isAwaitingPIN = false
                enteredPIN = ""
                return
            }

            if check.status == "not_registered" {
                let res = try await api.requestRegistration(email: mail)
                // res.status = "success" e message = "Codice inviato"
                if res.status.lowercased() == "success" {
                    isAwaitingPIN = true
                    enteredPIN = ""
                    errorMessage = res.message // opzionale: mostra "Codice inviato"
                } else {
                    errorMessage = res.message ?? "Impossibile inviare il codice"
                }
                return
            }

            errorMessage = check.message ?? "Stato sconosciuto: \(check.status)"

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Step 2

    func submitPIN() async {
        errorMessage = nil

        let mail = enteredEmail
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let pin  = enteredPIN.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !mail.isEmpty else { errorMessage = "Email mancante"; return }
        guard pin.count >= 4 else { errorMessage = "Inserisci il PIN ricevuto via email"; return }

        isLoading = true
        defer { isLoading = false }

        do {
            let verify = try await api.verifyRegistration(email: mail, code: enteredPIN)

            if verify.status == "registered" || verify.status.lowercased() == "success" {
                completeLogin(email: mail, name: verify.name, picture: verify.picture)
                isAwaitingPIN = false
                enteredPIN = ""
            } else {
                errorMessage = verify.message ?? "PIN non valido"
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Lock/Unlock

    func lock() { isUnlocked = false }

    func unlockWithBiometrics() {
        errorMessage = nil
        let ctx = LAContext()
        var err: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &err) else {
            errorMessage = "Biometria non disponibile"
            return
        }

        Task {
            do {
                let ok = try await ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Sblocca Bonjour")
                if ok { self.isUnlocked = true }
            } catch {
                self.errorMessage = "Sblocco annullato"
            }
        }
    }

    func clearSessionAndGoToRegistration() {
        let d = UserDefaults.standard
        d.removeObject(forKey: Keys.hasSession)
        d.removeObject(forKey: Keys.email)
        d.removeObject(forKey: Keys.displayName)
        d.removeObject(forKey: Keys.pictureURL)
        d.removeObject(forKey: Keys.totpSecret)

        isAuthenticated = false
        isUnlocked = false

        email = nil
        displayName = nil
        pictureURL = nil
        totpSecret = nil

        enteredEmail = ""
        enteredPIN = ""
        isAwaitingPIN = false
        errorMessage = nil
    }

    func fallbackName() -> String {
        email?.components(separatedBy: "@").first ?? "Utente"
    }

    // MARK: - Private

    private func completeLogin(email: String, name: String?, picture: String?) {
        self.email = email
        self.displayName = (name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? name : fallbackName()
        self.pictureURL = picture
        
        // 🔎 TOTP: per ora non riceviamo il secret dal backend durante il login
        // Dovrà essere fornito in futuro dalla verifyRegistration

        isAuthenticated = true
        isUnlocked = true

        persistSession()
    }

    private func persistSession() {
        let d = UserDefaults.standard
        d.set(true, forKey: Keys.hasSession)
        d.set(email, forKey: Keys.email)
        d.set(displayName, forKey: Keys.displayName)
        d.set(pictureURL, forKey: Keys.pictureURL)
        d.set(totpSecret, forKey: Keys.totpSecret)
    }

    private func loadStoredSession() {
        let d = UserDefaults.standard
        guard d.bool(forKey: Keys.hasSession),
              let mail = d.string(forKey: Keys.email),
              !mail.isEmpty else { return }

        email = mail
        displayName = d.string(forKey: Keys.displayName)
        pictureURL = d.string(forKey: Keys.pictureURL)
        totpSecret = d.string(forKey: Keys.totpSecret)

        isAuthenticated = true
        isUnlocked = false
    }

    private func isValidEmail(_ mail: String) -> Bool {
        mail.contains("@") && mail.hasSuffix("@stmitalia.com")
    }
}
