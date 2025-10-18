import Foundation
import CryptoKit
import Security
import os.log

// MARK: - Security Manager

class SecurityManager: ObservableObject {
    static let shared = SecurityManager()
    
    @Published var isSecure = true
    @Published var securityEvents: [SecurityEvent] = []
    @Published var threatLevel: ThreatLevel = .low
    
    private let encryptionManager = DataEncryptionManager()
    private let inputValidator = InputValidationManager()
    private let rateLimiter = RateLimiter()
    private let certificatePinner = CertificatePinningManager()
    private let securityLogger = SecurityEventLogger()
    
    private init() {
        setupSecurityMonitoring()
    }
    
    // MARK: - Security Monitoring
    
    private func setupSecurityMonitoring() {
        // Monitor for security events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSecurityEvent),
            name: .securityEvent,
            object: nil
        )
    }
    
    @objc private func handleSecurityEvent(_ notification: Notification) {
        guard let event = notification.object as? SecurityEvent else { return }
        
        DispatchQueue.main.async {
            self.securityEvents.append(event)
            self.updateThreatLevel()
            self.securityLogger.log(event)
        }
    }
    
    private func updateThreatLevel() {
        let recentEvents = securityEvents.suffix(100)
        let criticalEvents = recentEvents.filter { $0.severity == .critical }
        let highEvents = recentEvents.filter { $0.severity == .high }
        
        if criticalEvents.count > 0 {
            threatLevel = .critical
        } else if highEvents.count > 2 {
            threatLevel = .high
        } else if highEvents.count > 0 {
            threatLevel = .medium
        } else {
            threatLevel = .low
        }
    }
    
    // MARK: - Data Protection
    
    func encryptData(_ data: Data) -> Data? {
        return encryptionManager.encryptData(data)
    }
    
    func decryptData(_ encryptedData: Data) -> Data? {
        return encryptionManager.decryptData(encryptedData)
    }
    
    func secureStore<T: Codable>(_ object: T, key: String) -> Bool {
        do {
            let data = try JSONEncoder().encode(object)
            guard let encryptedData = encryptData(data) else { return false }
            
            let keychain = KeychainManager()
            return keychain.save(key: key, data: encryptedData)
        } catch {
            logSecurityEvent(.dataAccess, details: "Failed to store data: \(error.localizedDescription)")
            return false
        }
    }
    
    func secureRetrieve<T: Codable>(_ type: T.Type, key: String) -> T? {
        let keychain = KeychainManager()
        guard let encryptedData = keychain.load(key: key),
              let decryptedData = decryptData(encryptedData) else { return nil }
        
        do {
            return try JSONDecoder().decode(type, from: decryptedData)
        } catch {
            logSecurityEvent(.dataAccess, details: "Failed to retrieve data: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Input Validation
    
    func validateInput(_ input: String, type: InputType) -> ValidationResult {
        return inputValidator.validate(input, type: type)
    }
    
    func sanitizeInput(_ input: String) -> String {
        return inputValidator.sanitize(input)
    }
    
    // MARK: - Rate Limiting
    
    func canMakeRequest() -> Bool {
        return rateLimiter.canMakeRequest()
    }
    
    func resetRateLimit() {
        rateLimiter.reset()
    }
    
    // MARK: - Certificate Pinning
    
    func validateCertificate(_ serverTrust: SecTrust) -> Bool {
        return certificatePinner.validateCertificate(serverTrust)
    }
    
    // MARK: - Security Event Logging
    
    func logSecurityEvent(_ type: SecurityEventType, details: String, severity: SecuritySeverity = .medium) {
        let event = SecurityEvent(
            type: type,
            timestamp: Date(),
            details: details,
            severity: severity
        )
        
        NotificationCenter.default.post(name: .securityEvent, object: event)
    }
    
    // MARK: - Threat Detection
    
    func detectThreats() {
        // Analyze recent security events for threat patterns
        let recentEvents = securityEvents.suffix(50)
        
        // Check for brute force attacks
        if detectBruteForceAttack(recentEvents) {
            logSecurityEvent(.suspiciousActivity, details: "Brute force attack detected", severity: .high)
        }
        
        // Check for data exfiltration attempts
        if detectDataExfiltration(recentEvents) {
            logSecurityEvent(.suspiciousActivity, details: "Data exfiltration attempt detected", severity: .critical)
        }
        
        // Check for privilege escalation
        if detectPrivilegeEscalation(recentEvents) {
            logSecurityEvent(.suspiciousActivity, details: "Privilege escalation attempt detected", severity: .high)
        }
    }
    
    private func detectBruteForceAttack(_ events: ArraySlice<SecurityEvent>) -> Bool {
        let authFailures = events.filter { $0.type == .authenticationFailure }
        return authFailures.count > 5
    }
    
    private func detectDataExfiltration(_ events: ArraySlice<SecurityEvent>) -> Bool {
        let dataAccess = events.filter { $0.type == .dataAccess }
        return dataAccess.count > 20
    }
    
    private func detectPrivilegeEscalation(_ events: ArraySlice<SecurityEvent>) -> Bool {
        let permissionDenied = events.filter { $0.type == .permissionDenied }
        return permissionDenied.count > 10
    }
}

// MARK: - Data Encryption Manager

class DataEncryptionManager {
    private var encryptionKey: SymmetricKey?
    private let keychain = KeychainManager()
    
    init() {
        loadOrCreateEncryptionKey()
    }
    
    func encryptData(_ data: Data) -> Data? {
        guard let key = encryptionKey else { return nil }
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined
        } catch {
            print("Encryption failed: \(error)")
            return nil
        }
    }
    
    func decryptData(_ encryptedData: Data) -> Data? {
        guard let key = encryptionKey else { return nil }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            print("Decryption failed: \(error)")
            return nil
        }
    }
    
    private func loadOrCreateEncryptionKey() {
        if let keyData = keychain.load(key: "encryption_key") {
            encryptionKey = SymmetricKey(data: keyData)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            if let keyData = newKey.withUnsafeBytes({ Data($0) }) {
                keychain.save(key: "encryption_key", data: keyData)
                encryptionKey = newKey
            }
        }
    }
    
    func rotateEncryptionKey() {
        let newKey = SymmetricKey(size: .bits256)
        if let keyData = newKey.withUnsafeBytes({ Data($0) }) {
            keychain.save(key: "encryption_key", data: keyData)
            encryptionKey = newKey
        }
    }
}

// MARK: - Input Validation Manager

class InputValidationManager {
    func validate(_ input: String, type: InputType) -> ValidationResult {
        switch type {
        case .email:
            return validateEmail(input)
        case .username:
            return validateUsername(input)
        case .password:
            return validatePassword(input)
        case .general:
            return validateGeneral(input)
        }
    }
    
    func sanitize(_ input: String) -> String {
        return input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#x27;")
            .replacingOccurrences(of: "&", with: "&amp;")
    }
    
    private func validateEmail(_ email: String) -> ValidationResult {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if email.isEmpty {
            return .invalid("Email is required")
        } else if !emailPredicate.evaluate(with: email) {
            return .invalid("Invalid email format")
        } else {
            return .valid
        }
    }
    
    private func validateUsername(_ username: String) -> ValidationResult {
        let usernameRegex = "^[a-zA-Z0-9_]{3,20}$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        
        if username.isEmpty {
            return .invalid("Username is required")
        } else if username.count < 3 {
            return .invalid("Username must be at least 3 characters")
        } else if username.count > 20 {
            return .invalid("Username must be no more than 20 characters")
        } else if !usernamePredicate.evaluate(with: username) {
            return .invalid("Username can only contain letters, numbers, and underscores")
        } else {
            return .valid
        }
    }
    
    private func validatePassword(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return .invalid("Password is required")
        } else if password.count < 8 {
            return .invalid("Password must be at least 8 characters")
        } else if !password.contains(where: { $0.isUppercase }) {
            return .invalid("Password must contain at least one uppercase letter")
        } else if !password.contains(where: { $0.isLowercase }) {
            return .invalid("Password must contain at least one lowercase letter")
        } else if !password.contains(where: { $0.isNumber }) {
            return .invalid("Password must contain at least one number")
        } else if !password.contains(where: { "!@#$%^&*()_+-=[]{}|;:,.<>?".contains($0) }) {
            return .invalid("Password must contain at least one special character")
        } else {
            return .valid
        }
    }
    
    private func validateGeneral(_ input: String) -> ValidationResult {
        if input.isEmpty {
            return .invalid("Input is required")
        } else if input.count > 1000 {
            return .invalid("Input is too long")
        } else {
            return .valid
        }
    }
}

// MARK: - Rate Limiter

class RateLimiter {
    private var requestCounts: [String: [Date]] = [:]
    private let maxRequests = 100
    private let timeWindow: TimeInterval = 3600 // 1 hour
    
    func canMakeRequest() -> Bool {
        let now = Date()
        let key = "api_requests"
        
        // Clean old requests
        if var requests = requestCounts[key] {
            requests = requests.filter { now.timeIntervalSince($0) < timeWindow }
            requestCounts[key] = requests
        } else {
            requestCounts[key] = []
        }
        
        // Check if under limit
        let currentCount = requestCounts[key]?.count ?? 0
        if currentCount < maxRequests {
            requestCounts[key]?.append(now)
            return true
        }
        
        return false
    }
    
    func reset() {
        requestCounts.removeAll()
    }
}

// MARK: - Certificate Pinning Manager

class CertificatePinningManager {
    private let pinnedCertificates: [Data]
    
    init() {
        self.pinnedCertificates = loadPinnedCertificates()
    }
    
    func validateCertificate(_ serverTrust: SecTrust) -> Bool {
        guard pinnedCertificates.count > 0 else { return true }
        
        let serverCertificates = getServerCertificates(from: serverTrust)
        
        for serverCert in serverCertificates {
            if pinnedCertificates.contains(serverCert) {
                return true
            }
        }
        
        return false
    }
    
    private func loadPinnedCertificates() -> [Data] {
        // Load pinned certificates from bundle
        // This would typically load certificates for Firebase, APIs, etc.
        return []
    }
    
    private func getServerCertificates(from serverTrust: SecTrust) -> [Data] {
        var certificates: [Data] = []
        
        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        for i in 0..<certificateCount {
            if let certificate = SecTrustGetCertificateAtIndex(serverTrust, i) {
                let data = SecCertificateCopyData(certificate)
                certificates.append(data as Data)
            }
        }
        
        return certificates
    }
}

// MARK: - Keychain Manager

class KeychainManager {
    func save(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        return status == errSecSuccess ? result as? Data : nil
    }
    
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

// MARK: - Security Event Logger

class SecurityEventLogger {
    private let logger = OSLog(subsystem: "com.summitai.app", category: "Security")
    
    func log(_ event: SecurityEvent) {
        // Log to system log
        os_log("Security Event: %{public}@ - %{public}@", 
               log: logger, 
               type: .default, 
               event.type.rawValue, 
               event.details)
        
        // Send to monitoring system
        sendToMonitoringSystem(event)
        
        // Store locally for analysis
        storeEventLocally(event)
    }
    
    private func sendToMonitoringSystem(_ event: SecurityEvent) {
        // Send to security monitoring service
        // Implement based on monitoring solution
    }
    
    private func storeEventLocally(_ event: SecurityEvent) {
        // Store in local database for analysis
        // Implement based on storage solution
    }
}

// MARK: - Supporting Types

enum InputType {
    case email, username, password, general
}

enum ValidationResult {
    case valid
    case invalid(String)
}

enum ThreatLevel {
    case low, medium, high, critical
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

enum SecurityEventType: String {
    case authenticationAttempt = "Authentication Attempt"
    case authenticationSuccess = "Authentication Success"
    case authenticationFailure = "Authentication Failure"
    case dataAccess = "Data Access"
    case permissionDenied = "Permission Denied"
    case suspiciousActivity = "Suspicious Activity"
    case securityViolation = "Security Violation"
}

enum SecuritySeverity {
    case low, medium, high, critical
}

struct SecurityEvent {
    let id = UUID()
    let type: SecurityEventType
    let timestamp: Date
    let details: String
    let severity: SecuritySeverity
    let userID: String?
    
    init(type: SecurityEventType, timestamp: Date, details: String, severity: SecuritySeverity = .medium, userID: String? = nil) {
        self.type = type
        self.timestamp = timestamp
        self.details = details
        self.severity = severity
        self.userID = userID
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let securityEvent = Notification.Name("securityEvent")
}
