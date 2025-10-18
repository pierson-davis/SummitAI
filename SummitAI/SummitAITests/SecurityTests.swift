import XCTest
@testable import SummitAI

class SecurityTests: XCTestCase {
    var securityManager: SecurityManager!
    var encryptionManager: DataEncryptionManager!
    var inputValidator: InputValidationManager!
    var rateLimiter: RateLimiter!
    
    override func setUp() {
        super.setUp()
        securityManager = SecurityManager.shared
        encryptionManager = DataEncryptionManager()
        inputValidator = InputValidationManager()
        rateLimiter = RateLimiter()
    }
    
    override func tearDown() {
        securityManager = nil
        encryptionManager = nil
        inputValidator = nil
        rateLimiter = nil
        super.tearDown()
    }
    
    // MARK: - Input Validation Tests
    
    func testEmailValidation() {
        // Valid emails
        XCTAssertEqual(inputValidator.validate("test@example.com", type: .email), .valid)
        XCTAssertEqual(inputValidator.validate("user.name+tag@domain.co.uk", type: .email), .valid)
        XCTAssertEqual(inputValidator.validate("test123@test-domain.com", type: .email), .valid)
        
        // Invalid emails
        if case .invalid(let message) = inputValidator.validate("invalid-email", type: .email) {
            XCTAssertTrue(message.contains("Invalid email format"))
        } else {
            XCTFail("Should return invalid for malformed email")
        }
        
        if case .invalid(let message) = inputValidator.validate("", type: .email) {
            XCTAssertTrue(message.contains("Email is required"))
        } else {
            XCTFail("Should return invalid for empty email")
        }
    }
    
    func testUsernameValidation() {
        // Valid usernames
        XCTAssertEqual(inputValidator.validate("valid_user123", type: .username), .valid)
        XCTAssertEqual(inputValidator.validate("user", type: .username), .valid)
        XCTAssertEqual(inputValidator.validate("user_name", type: .username), .valid)
        
        // Invalid usernames
        if case .invalid(let message) = inputValidator.validate("ab", type: .username) {
            XCTAssertTrue(message.contains("at least 3 characters"))
        } else {
            XCTFail("Should return invalid for short username")
        }
        
        if case .invalid(let message) = inputValidator.validate("user@name", type: .username) {
            XCTAssertTrue(message.contains("letters, numbers, and underscores"))
        } else {
            XCTFail("Should return invalid for username with special characters")
        }
    }
    
    func testPasswordValidation() {
        // Valid passwords
        XCTAssertEqual(inputValidator.validate("Password123!", type: .password), .valid)
        XCTAssertEqual(inputValidator.validate("MySecurePass1@", type: .password), .valid)
        
        // Invalid passwords
        if case .invalid(let message) = inputValidator.validate("short", type: .password) {
            XCTAssertTrue(message.contains("at least 8 characters"))
        } else {
            XCTFail("Should return invalid for short password")
        }
        
        if case .invalid(let message) = inputValidator.validate("nouppercase123!", type: .password) {
            XCTAssertTrue(message.contains("uppercase letter"))
        } else {
            XCTFail("Should return invalid for password without uppercase")
        }
        
        if case .invalid(let message) = inputValidator.validate("NOLOWERCASE123!", type: .password) {
            XCTAssertTrue(message.contains("lowercase letter"))
        } else {
            XCTFail("Should return invalid for password without lowercase")
        }
        
        if case .invalid(let message) = inputValidator.validate("NoNumbers!", type: .password) {
            XCTAssertTrue(message.contains("number"))
        } else {
            XCTFail("Should return invalid for password without numbers")
        }
        
        if case .invalid(let message) = inputValidator.validate("NoSpecial123", type: .password) {
            XCTAssertTrue(message.contains("special character"))
        } else {
            XCTFail("Should return invalid for password without special characters")
        }
    }
    
    func testInputSanitization() {
        let testCases = [
            ("<script>alert('xss')</script>", "&lt;script&gt;alert('xss')&lt;/script&gt;"),
            ("<img src=x onerror=alert('xss')>", "&lt;img src=x onerror=alert('xss')&gt;"),
            ("'; DROP TABLE users; --", "&#x27;; DROP TABLE users; --"),
            ("<iframe src='javascript:alert(\"xss\")'></iframe>", "&lt;iframe src=&#x27;javascript:alert(&quot;xss&quot;)&#x27;&gt;&lt;/iframe&gt;"),
            ("Normal text", "Normal text")
        ]
        
        for (input, expected) in testCases {
            let result = inputValidator.sanitize(input)
            XCTAssertEqual(result, expected, "Failed to sanitize: \(input)")
        }
    }
    
    // MARK: - Encryption Tests
    
    func testDataEncryption() {
        let testData = "Sensitive health data".data(using: .utf8)!
        
        // Test encryption
        let encryptedData = encryptionManager.encryptData(testData)
        XCTAssertNotNil(encryptedData, "Encryption should succeed")
        XCTAssertNotEqual(testData, encryptedData, "Encrypted data should be different")
        
        // Test decryption
        let decryptedData = encryptionManager.decryptData(encryptedData!)
        XCTAssertNotNil(decryptedData, "Decryption should succeed")
        XCTAssertEqual(testData, decryptedData, "Decrypted data should match original")
    }
    
    func testEncryptionWithDifferentData() {
        let testCases = [
            "Short data",
            "This is a longer string with more content to test encryption",
            "Data with special characters: !@#$%^&*()",
            "Unicode data: 🏔️⛰️🏕️",
            ""
        ]
        
        for testString in testCases {
            let testData = testString.data(using: .utf8)!
            let encryptedData = encryptionManager.encryptData(testData)
            let decryptedData = encryptionManager.decryptData(encryptedData!)
            
            XCTAssertEqual(testData, decryptedData, "Failed for: \(testString)")
        }
    }
    
    func testEncryptionKeyRotation() {
        let testData = "Test data".data(using: .utf8)!
        
        // Encrypt with first key
        let encryptedData1 = encryptionManager.encryptData(testData)
        XCTAssertNotNil(encryptedData1)
        
        // Simulate key rotation
        encryptionManager.rotateEncryptionKey()
        
        // Encrypt with new key
        let encryptedData2 = encryptionManager.encryptData(testData)
        XCTAssertNotNil(encryptedData2)
        
        // Should be different due to different keys
        XCTAssertNotEqual(encryptedData1, encryptedData2)
    }
    
    // MARK: - Rate Limiting Tests
    
    func testRateLimiting() {
        // Test normal rate limiting
        for _ in 0..<10 {
            XCTAssertTrue(rateLimiter.canMakeRequest(), "Should allow requests within limit")
        }
        
        // Test rate limit exceeded
        for _ in 0..<100 {
            rateLimiter.canMakeRequest()
        }
        
        XCTAssertFalse(rateLimiter.canMakeRequest(), "Should block requests after limit")
    }
    
    func testRateLimitingReset() {
        // Fill up rate limit
        for _ in 0..<100 {
            rateLimiter.canMakeRequest()
        }
        
        XCTAssertFalse(rateLimiter.canMakeRequest(), "Should be rate limited")
        
        // Reset rate limit
        rateLimiter.reset()
        
        XCTAssertTrue(rateLimiter.canMakeRequest(), "Should allow requests after reset")
    }
    
    // MARK: - Security Manager Tests
    
    func testSecurityEventLogging() {
        let initialEventCount = securityManager.securityEvents.count
        
        securityManager.logSecurityEvent(.authenticationAttempt, details: "Test event")
        
        // Wait for async processing
        let expectation = XCTestExpectation(description: "Security event logged")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(securityManager.securityEvents.count, initialEventCount + 1)
    }
    
    func testSecureDataStorage() {
        let testObject = TestCodableObject(name: "Test", value: 123)
        
        let success = securityManager.secureStore(testObject, key: "test_key")
        XCTAssertTrue(success, "Secure storage should succeed")
        
        let retrievedObject = securityManager.secureRetrieve(TestCodableObject.self, key: "test_key")
        XCTAssertNotNil(retrievedObject, "Retrieved object should not be nil")
        XCTAssertEqual(retrievedObject?.name, "Test")
        XCTAssertEqual(retrievedObject?.value, 123)
    }
    
    func testInputValidationIntegration() {
        let validEmail = "test@example.com"
        let invalidEmail = "invalid-email"
        
        let validResult = securityManager.validateInput(validEmail, type: .email)
        let invalidResult = securityManager.validateInput(invalidEmail, type: .email)
        
        if case .valid = validResult {
            // Valid email should pass
        } else {
            XCTFail("Valid email should pass validation")
        }
        
        if case .invalid = invalidResult {
            // Invalid email should fail
        } else {
            XCTFail("Invalid email should fail validation")
        }
    }
    
    func testThreatDetection() {
        // Simulate multiple authentication failures
        for _ in 0..<6 {
            securityManager.logSecurityEvent(.authenticationFailure, details: "Failed login attempt", severity: .medium)
        }
        
        // Wait for async processing
        let expectation = XCTestExpectation(description: "Threat detection")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Check if threat level increased
        XCTAssertTrue(securityManager.threatLevel == .high || securityManager.threatLevel == .critical)
    }
    
    // MARK: - Performance Tests
    
    func testEncryptionPerformance() {
        let testData = "Performance test data".data(using: .utf8)!
        
        measure {
            for _ in 0..<100 {
                let encryptedData = encryptionManager.encryptData(testData)
                let _ = encryptionManager.decryptData(encryptedData!)
            }
        }
    }
    
    func testInputValidationPerformance() {
        let testInputs = [
            "test@example.com",
            "invalid-email",
            "valid_user123",
            "ab",
            "Password123!",
            "weak"
        ]
        
        measure {
            for input in testInputs {
                let _ = inputValidator.validate(input, type: .email)
                let _ = inputValidator.validate(input, type: .username)
                let _ = inputValidator.validate(input, type: .password)
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyInputValidation() {
        let emptyInput = ""
        
        if case .invalid(let message) = inputValidator.validate(emptyInput, type: .email) {
            XCTAssertTrue(message.contains("required"))
        } else {
            XCTFail("Empty input should be invalid")
        }
    }
    
    func testVeryLongInput() {
        let longInput = String(repeating: "a", count: 2000)
        
        if case .invalid(let message) = inputValidator.validate(longInput, type: .general) {
            XCTAssertTrue(message.contains("too long"))
        } else {
            XCTFail("Very long input should be invalid")
        }
    }
    
    func testUnicodeInput() {
        let unicodeInput = "测试用户123"
        let result = inputValidator.validate(unicodeInput, type: .username)
        
        // Unicode should be handled gracefully
        XCTAssertNotNil(result)
    }
    
    // MARK: - Security Event Tests
    
    func testSecurityEventTypes() {
        let eventTypes: [SecurityEventType] = [
            .authenticationAttempt,
            .authenticationSuccess,
            .authenticationFailure,
            .dataAccess,
            .permissionDenied,
            .suspiciousActivity,
            .securityViolation
        ]
        
        for eventType in eventTypes {
            securityManager.logSecurityEvent(eventType, details: "Test event")
        }
        
        // Wait for async processing
        let expectation = XCTestExpectation(description: "Security events logged")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(securityManager.securityEvents.count, eventTypes.count)
    }
    
    func testSecurityEventSeverity() {
        let severities: [SecuritySeverity] = [.low, .medium, .high, .critical]
        
        for severity in severities {
            securityManager.logSecurityEvent(.suspiciousActivity, details: "Test event", severity: severity)
        }
        
        // Wait for async processing
        let expectation = XCTestExpectation(description: "Security events logged")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(securityManager.securityEvents.count, severities.count)
    }
}

// MARK: - Test Helper Types

struct TestCodableObject: Codable, Equatable {
    let name: String
    let value: Int
}
