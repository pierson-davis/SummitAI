import Foundation
import Combine
import SwiftUI

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Mountain Experiences integration
    @Published var mountainExperiencesPreferences: UserMountainExperiencesPreferences?
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let userKey = "current_user"
    
    init() {
        print("UserManager: Initializing UserManager")
        loadUserFromStorage()
        loadMountainExperiencesPreferences()
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
        
        // For now, use mock authentication until Firebase is fully configured
        // This will be replaced with real Apple Sign-In + Firebase integration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            let user = User(username: "apple_user", email: "user@icloud.com", displayName: "Apple User")
            self?.currentUser = user
            self?.isAuthenticated = true
            self?.saveUserToStorage()
            self?.isLoading = false
        }
    }
    
    func signInWithAppleFirebase(credential: Any) { // Temporarily simplified
        isLoading = true
        errorMessage = nil
        
        // For now, use mock authentication until Firebase is fully configured
        // This will be replaced with real Firebase integration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            let user = User(
                username: "apple_user_\(UUID().uuidString.prefix(8))",
                email: "user@icloud.com",
                displayName: "Apple User"
            )
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
        
        if !user.completedExpeditions.contains(mountainId.uuidString) {
            user.completedExpeditions.append(mountainId.uuidString)
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
        
        user.currentExpeditionId = mountainId.uuidString
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
    
    // MARK: - Access Features
    
    func purchaseAccess(duration: AccessDuration) {
        guard var user = currentUser else { return }
        
        user.hasAccess = true
        
        let calendar = Calendar.current
        switch duration {
        case .monthly:
            user.accessExpiryDate = calendar.date(byAdding: .month, value: 1, to: Date())
        case .yearly:
            user.accessExpiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
        }
        
        currentUser = user
        saveUserToStorage()
    }
    
    func hasAccessActive() -> Bool {
        guard let user = currentUser,
              let expiryDate = user.accessExpiryDate else {
            return false
        }
        
        return user.hasAccess && expiryDate > Date()
    }
    
    enum AccessDuration {
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
    
    // MARK: - Mountain Experiences Integration
    
    private func loadMountainExperiencesPreferences() {
        if let data = userDefaults.data(forKey: "mountain_experiences_preferences"),
           let preferences = try? JSONDecoder().decode(UserMountainExperiencesPreferences.self, from: data) {
            mountainExperiencesPreferences = preferences
        } else {
            mountainExperiencesPreferences = UserMountainExperiencesPreferences()
        }
    }
    
    func saveMountainExperiencesPreferences() {
        if let preferences = mountainExperiencesPreferences,
           let data = try? JSONEncoder().encode(preferences) {
            userDefaults.set(data, forKey: "mountain_experiences_preferences")
        }
    }
    
    func updateMountainExperiencesPreferences(_ preferences: UserMountainExperiencesPreferences) {
        mountainExperiencesPreferences = preferences
        saveMountainExperiencesPreferences()
    }
    
    func getRecommendedTrips() -> [Trip] {
        guard let preferences = mountainExperiencesPreferences else { return Trip.sampleTrips }
        
        var filteredTrips = Trip.sampleTrips
        
        if !preferences.favoriteCategories.isEmpty {
            filteredTrips = filteredTrips.filter { preferences.favoriteCategories.contains($0.category) }
        }
        
        if !preferences.favoriteDifficulties.isEmpty {
            filteredTrips = filteredTrips.filter { preferences.favoriteDifficulties.contains($0.difficulty) }
        }
        
        if let maxPrice = preferences.maxBudget {
            filteredTrips = filteredTrips.filter { ($0.price ?? 0) <= maxPrice }
        }
        
        return filteredTrips.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
    }
}

// MARK: - User Mountain Experiences Preferences Model

struct UserMountainExperiencesPreferences: Codable {
    var favoriteCategories: [TripCategory] = []
    var favoriteDifficulties: [TripDifficulty] = []
    var favoriteLocations: Set<String> = []
    var maxBudget: Double?
    var maxDuration: Int?
    var preferredSeason: String?
    var experienceLevel: ExperienceLevel = .beginner
    var interests: Set<TripInterest> = []
    var accessibilityNeeds: Set<AccessibilityNeed> = []
    var groupSizePreference: GroupSizePreference = .solo
    var accommodationPreference: AccommodationPreference = .camping
    
    init() {}
    
    enum ExperienceLevel: String, Codable, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
        
        var description: String {
            switch self {
            case .beginner: return "New to mountain adventures"
            case .intermediate: return "Some mountain experience"
            case .advanced: return "Experienced mountaineer"
            case .expert: return "Professional level climber"
            }
        }
    }
    
    enum TripInterest: String, Codable, CaseIterable {
        case photography = "Photography"
        case wildlife = "Wildlife Watching"
        case culture = "Cultural Experiences"
        case adventure = "Adventure Sports"
        case relaxation = "Relaxation"
        case education = "Educational Tours"
        case fitness = "Fitness Challenges"
        case social = "Social Experiences"
        
        var icon: String {
            switch self {
            case .photography: return "camera.fill"
            case .wildlife: return "bird.fill"
            case .culture: return "building.columns.fill"
            case .adventure: return "figure.climbing"
            case .relaxation: return "leaf.fill"
            case .education: return "book.fill"
            case .fitness: return "dumbbell.fill"
            case .social: return "person.3.fill"
            }
        }
    }
    
    enum AccessibilityNeed: String, Codable, CaseIterable {
        case wheelchair = "Wheelchair Accessible"
        case mobility = "Mobility Assistance"
        case hearing = "Hearing Assistance"
        case visual = "Visual Assistance"
        case dietary = "Dietary Restrictions"
        case medical = "Medical Support"
        
        var icon: String {
            switch self {
            case .wheelchair: return "figure.roll"
            case .mobility: return "figure.walk"
            case .hearing: return "ear.fill"
            case .visual: return "eye.fill"
            case .dietary: return "fork.knife"
            case .medical: return "cross.fill"
            }
        }
    }
    
    enum GroupSizePreference: String, Codable, CaseIterable {
        case solo = "Solo Travel"
        case small = "Small Group (2-4)"
        case medium = "Medium Group (5-8)"
        case large = "Large Group (9+)"
        case `private` = "Private Tour"
        
        var description: String {
            switch self {
            case .solo: return "Travel alone"
            case .small: return "2-4 people"
            case .medium: return "5-8 people"
            case .large: return "9+ people"
            case .`private`: return "Private guided tour"
            }
        }
    }
    
    enum AccommodationPreference: String, Codable, CaseIterable {
        case camping = "Camping"
        case lodges = "Mountain Lodges"
        case hotels = "Hotels"
        case hostels = "Hostels"
        case luxury = "Luxury Accommodation"
        case any = "Any"
        
        var icon: String {
            switch self {
            case .camping: return "tent.fill"
            case .lodges: return "house.fill"
            case .hotels: return "building.2.fill"
            case .hostels: return "bed.double.fill"
            case .luxury: return "crown.fill"
            case .any: return "checkmark.circle.fill"
            }
        }
    }
}
