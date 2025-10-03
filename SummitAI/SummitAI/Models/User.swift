import Foundation
import SwiftUI

// MARK: - User Model
struct User: Identifiable, Codable {
    let id: String // Changed to String for Firestore compatibility
    var username: String
    var email: String
    var displayName: String
    var avatarURL: String?
    var joinDate: Date
    var hasAccess: Bool
    var accessExpiryDate: Date?
    var totalSteps: Int
    var totalElevation: Double
    var completedExpeditions: [String] // Mountain IDs as strings for Firestore
    var currentExpeditionId: String?
    var streakCount: Int
    var lastActivityDate: Date
    var badges: [Badge]
    var achievements: [Achievement]
    var stats: UserStats
    
    init(username: String, email: String, displayName: String) {
        self.id = UUID().uuidString
        self.username = username
        self.email = email
        self.displayName = displayName
        self.avatarURL = nil
        self.joinDate = Date()
        self.hasAccess = false
        self.accessExpiryDate = nil
        self.totalSteps = 0
        self.totalElevation = 0
        self.completedExpeditions = []
        self.currentExpeditionId = nil
        self.streakCount = 0
        self.lastActivityDate = Date()
        self.badges = []
        self.achievements = []
        self.stats = UserStats()
    }
    
    // MARK: - Firestore Compatibility (will be implemented later)
    // init(from document: DocumentSnapshot) throws {
    //     // Implementation will be added when Firebase is properly configured
    // }
}

// MARK: - User Stats Model
struct UserStats: Codable {
    var totalWorkouts: Int
    var totalDistance: Double // in kilometers
    var totalCaloriesBurned: Double
    var longestStreak: Int
    var favoriteWorkoutType: WorkoutData.WorkoutType?
    var averageDailySteps: Int
    var totalExpeditionsCompleted: Int
    var totalTimeSpent: TimeInterval // in seconds
    
    init() {
        self.totalWorkouts = 0
        self.totalDistance = 0
        self.totalCaloriesBurned = 0
        self.longestStreak = 0
        self.favoriteWorkoutType = nil
        self.averageDailySteps = 0
        self.totalExpeditionsCompleted = 0
        self.totalTimeSpent = 0
    }
    
    init(totalWorkouts: Int, totalDistance: Double, totalCaloriesBurned: Double, longestStreak: Int, averageDailySteps: Int, totalExpeditionsCompleted: Int, totalTimeSpent: TimeInterval) {
        self.totalWorkouts = totalWorkouts
        self.totalDistance = totalDistance
        self.totalCaloriesBurned = totalCaloriesBurned
        self.longestStreak = longestStreak
        self.favoriteWorkoutType = nil
        self.averageDailySteps = averageDailySteps
        self.totalExpeditionsCompleted = totalExpeditionsCompleted
        self.totalTimeSpent = totalTimeSpent
    }
}

// MARK: - Badge Model
struct Badge: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let color: BadgeColor
    let rarity: BadgeRarity
    let requirement: BadgeRequirement
    let unlockedDate: Date?
    let isUnlocked: Bool
    
    init(name: String, description: String, iconName: String, color: BadgeColor, rarity: BadgeRarity, requirement: BadgeRequirement) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.iconName = iconName
        self.color = color
        self.rarity = rarity
        self.requirement = requirement
        self.unlockedDate = nil
        self.isUnlocked = false
    }
    
    enum BadgeColor: String, CaseIterable, Codable {
        case bronze = "Bronze"
        case silver = "Silver"
        case gold = "Gold"
        case platinum = "Platinum"
        case diamond = "Diamond"
        
        var color: Color {
            switch self {
            case .bronze:
                return .brown
            case .silver:
                return .gray
            case .gold:
                return .yellow
            case .platinum:
                return .purple
            case .diamond:
                return .blue
            }
        }
    }
    
    enum BadgeRarity: String, CaseIterable, Codable {
        case common = "Common"
        case uncommon = "Uncommon"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
    }
    
    enum BadgeRequirement: Codable, Hashable {
        case steps(Int)
        case elevation(Double)
        case expeditions(Int)
        case streak(Int)
        case workouts(Int)
        case distance(Double)
        case custom(String)
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let progress: Double // 0.0 to 1.0
    let isCompleted: Bool
    let completedDate: Date?
    let reward: AchievementReward?
    
    init(name: String, description: String, iconName: String, progress: Double = 0.0, isCompleted: Bool = false, completedDate: Date? = nil, reward: AchievementReward? = nil) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.iconName = iconName
        self.progress = progress
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.reward = reward
    }
    
    enum AchievementReward: Codable {
        case badge(Badge)
        case points(Int)
        case accessDays(Int)
        case custom(String)
    }
}

// MARK: - Squad Model
struct Squad: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let leaderId: UUID
    var memberIds: [UUID]
    let createdDate: Date
    var currentMountainId: UUID?
    var isActive: Bool
    var totalSteps: Int
    var totalElevation: Double
    var squadStats: SquadStats
    
    init(name: String, description: String, leaderId: UUID) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.leaderId = leaderId
        self.memberIds = [leaderId]
        self.createdDate = Date()
        self.currentMountainId = nil
        self.isActive = true
        self.totalSteps = 0
        self.totalElevation = 0
        self.squadStats = SquadStats()
    }
}

// MARK: - Squad Stats Model
struct SquadStats: Codable {
    var totalMembers: Int
    var expeditionsCompleted: Int
    var averageSteps: Int
    var totalDistance: Double
    var longestStreak: Int
    var createdDate: Date
    
    init() {
        self.totalMembers = 0
        self.expeditionsCompleted = 0
        self.averageSteps = 0
        self.totalDistance = 0
        self.longestStreak = 0
        self.createdDate = Date()
    }
}

// MARK: - Challenge Model
struct Challenge: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let type: ChallengeType
    let difficulty: Mountain.MountainDifficulty
    let startDate: Date
    let endDate: Date
    let requirements: ChallengeRequirements
    let rewards: [ChallengeReward]
    var participants: [UUID] // User IDs
    var isActive: Bool
    var isCompleted: Bool
    
    init(name: String, description: String, type: ChallengeType, difficulty: Mountain.MountainDifficulty, startDate: Date, endDate: Date, requirements: ChallengeRequirements, rewards: [ChallengeReward]) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.type = type
        self.difficulty = difficulty
        self.startDate = startDate
        self.endDate = endDate
        self.requirements = requirements
        self.rewards = rewards
        self.participants = []
        self.isActive = true
        self.isCompleted = false
    }
    
    enum ChallengeType: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case special = "Special Event"
        
        var icon: String {
            switch self {
            case .daily:
                return "sun.max.fill"
            case .weekly:
                return "calendar"
            case .monthly:
                return "calendar.badge.clock"
            case .special:
                return "star.fill"
            }
        }
    }
    
    struct ChallengeRequirements: Codable {
        var steps: Int?
        var elevation: Double?
        var workouts: Int?
        var distance: Double?
        var duration: TimeInterval?
    }
    
    enum ChallengeReward: Codable, Hashable {
        case points(Int)
        case badge(Badge)
        case accessDays(Int)
        case custom(String)
    }
}

// MARK: - Predefined Badges
extension Badge {
    static let firstSteps = Badge(
        name: "First Steps",
        description: "Take your first 1,000 steps",
        iconName: "figure.walk",
        color: .bronze,
        rarity: .common,
        requirement: .steps(1000)
    )
    
    static let mountainGoat = Badge(
        name: "Mountain Goat",
        description: "Climb 1,000 meters of elevation",
        iconName: "mountain.2.fill",
        color: .silver,
        rarity: .uncommon,
        requirement: .elevation(1000)
    )
    
    static let expeditionLeader = Badge(
        name: "Expedition Leader",
        description: "Complete 5 expeditions",
        iconName: "flag.fill",
        color: .gold,
        rarity: .rare,
        requirement: .expeditions(5)
    )
    
    static let streakMaster = Badge(
        name: "Streak Master",
        description: "Maintain a 30-day streak",
        iconName: "flame.fill",
        color: .platinum,
        rarity: .epic,
        requirement: .streak(30)
    )
    
    static let legend = Badge(
        name: "Legend",
        description: "Complete all available expeditions",
        iconName: "crown.fill",
        color: .diamond,
        rarity: .legendary,
        requirement: .custom("All expeditions completed")
    )
    
    static let allBadges: [Badge] = [.firstSteps, .mountainGoat, .expeditionLeader, .streakMaster, .legend]
}
