import Foundation
import Combine
import SwiftUI

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let userKey = "current_user"
    
    init() {
        print("UserManager: Initializing UserManager")
        loadUserFromStorage()
        print("UserManager: Initialization complete - isAuthenticated: \(isAuthenticated), currentUser: \(currentUser != nil)")
    }
    
    // MARK: - Authentication Methods
    
    func signUp(username: String, email: String, displayName: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // In a real app, this would make an API call
            let newUser = User(username: username, email: email, displayName: displayName)
            self?.currentUser = newUser
            self?.isAuthenticated = true
            self?.saveUserToStorage()
            self?.isLoading = false
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // In a real app, this would make an API call
            // For demo purposes, create a user if none exists
            if self?.currentUser == nil {
                let user = User(username: "demo_user", email: email, displayName: "Demo User")
                self?.currentUser = user
            }
            self?.isAuthenticated = true
            self?.saveUserToStorage()
            self?.isLoading = false
        }
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        clearUserFromStorage()
    }
    
    func signInWithApple() {
        isLoading = true
        errorMessage = nil
        
        // Simulate Apple Sign In
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            let user = User(username: "apple_user", email: "user@icloud.com", displayName: "Apple User")
            self?.currentUser = user
            self?.isAuthenticated = true
            self?.saveUserToStorage()
            self?.isLoading = false
        }
    }
    
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        // Simulate Google Sign In
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            let user = User(username: "google_user", email: "user@gmail.com", displayName: "Google User")
            self?.currentUser = user
            self?.isAuthenticated = true
            self?.saveUserToStorage()
            self?.isLoading = false
        }
    }
    
    // MARK: - User Data Management
    
    func updateUser(_ user: User) {
        currentUser = user
        saveUserToStorage()
    }
    
    func updateUserStats(steps: Int, elevation: Double, workout: WorkoutData? = nil) {
        guard var user = currentUser else { return }
        
        user.totalSteps += steps
        user.totalElevation += elevation
        user.lastActivityDate = Date()
        
        if let workout = workout {
            user.stats.totalWorkouts += 1
            user.stats.totalDistance += (workout.distance ?? 0) / 1000.0 // Convert to km
            user.stats.totalCaloriesBurned += workout.calories ?? 0
            user.stats.totalTimeSpent += workout.duration
        }
        
        // Update streak
        updateStreak()
        
        // Update achievements
        checkAndUpdateAchievements(for: user)
        
        currentUser = user
        saveUserToStorage()
    }
    
    private func updateStreak() {
        guard var user = currentUser else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActivity = calendar.startOfDay(for: user.lastActivityDate)
        
        if calendar.dateInterval(of: .day, for: today)?.contains(lastActivity) == true {
            // User was active today, maintain streak
            user.streakCount = max(user.streakCount, 1)
        } else if calendar.dateComponents([.day], from: lastActivity, to: today).day == 1 {
            // User was active yesterday, continue streak
            user.streakCount += 1
        } else {
            // Streak broken
            user.streakCount = 1
        }
        
        user.stats.longestStreak = max(user.stats.longestStreak, user.streakCount)
        currentUser = user
    }
    
    func completeExpedition(_ mountainId: UUID) {
        guard var user = currentUser else { return }
        
        if !user.completedExpeditions.contains(mountainId) {
            user.completedExpeditions.append(mountainId)
            user.stats.totalExpeditionsCompleted += 1
            user.currentExpeditionId = nil
            
            // Award completion badge
            awardBadge(.expeditionLeader)
            
            currentUser = user
            saveUserToStorage()
        }
    }
    
    func startExpedition(_ mountainId: UUID) {
        guard var user = currentUser else { return }
        
        user.currentExpeditionId = mountainId
        currentUser = user
        saveUserToStorage()
    }
    
    // MARK: - Badge and Achievement Management
    
    func awardBadge(_ badge: Badge) {
        guard var user = currentUser else { return }
        
        let userBadge = Badge(
            name: badge.name,
            description: badge.description,
            iconName: badge.iconName,
            color: badge.color,
            rarity: badge.rarity,
            requirement: badge.requirement
        )
        
        if !user.badges.contains(where: { $0.name == badge.name }) {
            user.badges.append(userBadge)
            currentUser = user
            saveUserToStorage()
        }
    }
    
    private func checkAndUpdateAchievements(for user: User) {
        // Check for step achievements
        if user.totalSteps >= 1000 && !user.badges.contains(where: { $0.name == "First Steps" }) {
            awardBadge(.firstSteps)
        }
        
        // Check for elevation achievements
        if user.totalElevation >= 1000 && !user.badges.contains(where: { $0.name == "Mountain Goat" }) {
            awardBadge(.mountainGoat)
        }
        
        // Check for streak achievements
        if user.streakCount >= 30 && !user.badges.contains(where: { $0.name == "Streak Master" }) {
            awardBadge(.streakMaster)
        }
        
        // Check for expedition achievements
        if user.completedExpeditions.count >= 5 && !user.badges.contains(where: { $0.name == "Expedition Leader" }) {
            awardBadge(.expeditionLeader)
        }
    }
    
    // MARK: - Premium Features
    
    func purchasePremium(duration: PremiumDuration) {
        guard var user = currentUser else { return }
        
        user.isPremium = true
        
        let calendar = Calendar.current
        switch duration {
        case .monthly:
            user.subscriptionExpiryDate = calendar.date(byAdding: .month, value: 1, to: Date())
        case .yearly:
            user.subscriptionExpiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
        }
        
        currentUser = user
        saveUserToStorage()
    }
    
    func isPremiumActive() -> Bool {
        guard let user = currentUser,
              let expiryDate = user.subscriptionExpiryDate else {
            return false
        }
        
        return user.isPremium && expiryDate > Date()
    }
    
    enum PremiumDuration {
        case monthly
        case yearly
    }
    
    // MARK: - Storage Methods
    
    private func saveUserToStorage() {
        guard let user = currentUser else { return }
        
        do {
            let data = try JSONEncoder().encode(user)
            userDefaults.set(data, forKey: userKey)
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    private func loadUserFromStorage() {
        print("UserManager: Attempting to load user from storage")
        guard let data = userDefaults.data(forKey: userKey) else { 
            print("UserManager: No user data found in storage")
            return 
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            currentUser = user
            isAuthenticated = true
            print("UserManager: Successfully loaded user from storage")
        } catch {
            print("UserManager: Failed to load user: \(error)")
            clearUserFromStorage()
        }
    }
    
    private func clearUserFromStorage() {
        userDefaults.removeObject(forKey: userKey)
    }
    
    // MARK: - Mock Data for Development
    
    func createMockUser() {
        let mockUser = User(username: "mock_user", email: "mock@example.com", displayName: "Mock User")
        currentUser = mockUser
        isAuthenticated = true
        saveUserToStorage()
    }
}
