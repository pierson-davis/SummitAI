import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine
import SwiftUI
import AuthenticationServices

class FirebaseManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()
    
    init() {
        print("FirebaseManager: Initializing Firebase Manager")
        setupAuthStateListener()
    }
    
    // MARK: - Authentication State Management
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.isAuthenticated = true
                    self?.loadUserFromFirestore(uid: user.uid)
                } else {
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                }
            }
        }
    }
    
    // MARK: - Apple Sign-In Integration
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) {
        isLoading = true
        errorMessage = nil
        
        guard let nonce = currentNonce else {
            errorMessage = "Invalid state: A login callback was received, but no login request was sent."
            isLoading = false
            return
        }
        
        guard let appleIDToken = credential.identityToken else {
            errorMessage = "Invalid state: A login callback was received, but no login request was sent."
            isLoading = false
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            errorMessage = "Unable to serialize token string from data: \(appleIDToken.debugDescription)"
            isLoading = false
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if let result = result {
                    // User signed in successfully
                    self?.createOrUpdateUserInFirestore(user: result.user, credential: credential)
                }
            }
        }
    }
    
    // MARK: - User Management
    
    private func loadUserFromFirestore(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error loading user from Firestore: \(error)")
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                if let document = document, document.exists {
                    do {
                        let user = try document.data(as: User.self)
                        self?.currentUser = user
                    } catch {
                        print("Error decoding user: \(error)")
                        self?.errorMessage = "Failed to load user data"
                    }
                } else {
                    // User document doesn't exist, create it
                    self?.createNewUserDocument(uid: uid)
                }
            }
        }
    }
    
    private func createOrUpdateUserInFirestore(user: FirebaseAuth.User, credential: ASAuthorizationAppleIDCredential) {
        let userRef = db.collection("users").document(user.uid)
        
        let userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "displayName": credential.fullName?.formatted() ?? user.displayName ?? "Apple User",
            "photoURL": user.photoURL?.absoluteString ?? "",
            "createdAt": FieldValue.serverTimestamp(),
            "lastLoginAt": FieldValue.serverTimestamp(),
            "hasAccess": false,
            "totalSteps": 0,
            "totalElevation": 0.0,
            "streakCount": 0,
            "completedExpeditions": [],
            "currentExpeditionId": NSNull(),
            "badges": [],
            "stats": [
                "totalWorkouts": 0,
                "totalDistance": 0.0,
                "totalCaloriesBurned": 0.0,
                "totalTimeSpent": 0.0,
                "longestStreak": 0,
                "totalExpeditionsCompleted": 0
            ]
        ]
        
        userRef.setData(userData, merge: true) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error saving user to Firestore: \(error)")
                    self?.errorMessage = error.localizedDescription
                } else {
                    // Load the updated user data
                    self?.loadUserFromFirestore(uid: user.uid)
                }
            }
        }
    }
    
    private func createNewUserDocument(uid: String) {
        let userRef = db.collection("users").document(uid)
        
        let userData: [String: Any] = [
            "uid": uid,
            "email": "",
            "displayName": "New User",
            "photoURL": "",
            "createdAt": FieldValue.serverTimestamp(),
            "lastLoginAt": FieldValue.serverTimestamp(),
            "hasAccess": false,
            "totalSteps": 0,
            "totalElevation": 0.0,
            "streakCount": 0,
            "completedExpeditions": [],
            "currentExpeditionId": NSNull(),
            "badges": [],
            "stats": [
                "totalWorkouts": 0,
                "totalDistance": 0.0,
                "totalCaloriesBurned": 0.0,
                "totalTimeSpent": 0.0,
                "longestStreak": 0,
                "totalExpeditionsCompleted": 0
            ]
        ]
        
        userRef.setData(userData) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error creating user document: \(error)")
                    self?.errorMessage = error.localizedDescription
                } else {
                    // Load the new user data
                    self?.loadUserFromFirestore(uid: uid)
                }
            }
        }
    }
    
    // MARK: - User Data Updates
    
    func updateUserStats(steps: Int, elevation: Double, workout: WorkoutData? = nil) {
        guard let currentUser = currentUser else { return }
        
        let userRef = db.collection("users").document(currentUser.id)
        
        var updateData: [String: Any] = [
            "totalSteps": FieldValue.increment(Int64(steps)),
            "totalElevation": FieldValue.increment(elevation),
            "lastActivityDate": FieldValue.serverTimestamp()
        ]
        
        if let workout = workout {
            updateData["stats.totalWorkouts"] = FieldValue.increment(1)
            updateData["stats.totalDistance"] = FieldValue.increment((workout.distance ?? 0) / 1000.0)
            updateData["stats.totalCaloriesBurned"] = FieldValue.increment(workout.calories ?? 0)
            updateData["stats.totalTimeSpent"] = FieldValue.increment(workout.duration)
        }
        
        userRef.updateData(updateData) { [weak self] error in
            if let error = error {
                print("Error updating user stats: \(error)")
            } else {
                // Reload user data to get updated values
                self?.loadUserFromFirestore(uid: currentUser.id)
            }
        }
    }
    
    func updateExpeditionProgress(expeditionId: UUID, progress: Double) {
        guard let currentUser = currentUser else { return }
        
        let userRef = db.collection("users").document(currentUser.id)
        let expeditionRef = userRef.collection("expeditions").document(expeditionId.uuidString)
        
        expeditionRef.setData([
            "expeditionId": expeditionId.uuidString,
            "progress": progress,
            "lastUpdated": FieldValue.serverTimestamp()
        ], merge: true) { error in
            if let error = error {
                print("Error updating expedition progress: \(error)")
            }
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Nonce Generation for Apple Sign-In
    
    private var currentNonce: String?
    
    func generateNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return nonce
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
}

// MARK: - Extensions for Apple Sign-In

extension ASAuthorizationAppleIDCredential {
    var fullName: PersonNameComponents? {
        return self.fullName
    }
}

extension PersonNameComponents {
    func formatted() -> String {
        let formatter = PersonNameComponentsFormatter()
        return formatter.string(from: self)
    }
}
