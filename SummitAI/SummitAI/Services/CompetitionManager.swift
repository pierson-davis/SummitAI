import Foundation
import Combine
import SwiftUI

// MARK: - Competition Manager

class CompetitionManager: ObservableObject {
    @Published var dailyChallenges: [DailyChallenge] = []
    @Published var weeklyChallenges: [WeeklyChallenge] = []
    @Published var globalLeaderboard: [LeaderboardEntry] = []
    @Published var teamCompetitions: [TeamCompetition] = []
    @Published var userRankings: UserRankings?
    @Published var achievements: [Achievement] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    
    init() {
        print("CompetitionManager: Initializing CompetitionManager")
        loadCompetitionData()
        generateDailyChallenges()
        generateWeeklyChallenges()
        loadLeaderboard()
        print("CompetitionManager: Initialization complete")
    }
    
    // MARK: - Daily Challenges
    
    func generateDailyChallenges() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if we already have challenges for today
        if let lastGenerated = userDefaults.object(forKey: "last_daily_challenges") as? Date,
           Calendar.current.isDate(lastGenerated, inSameDayAs: today) {
            return
        }
        
        dailyChallenges = [
            DailyChallenge(
                id: UUID(),
                title: "Step Master",
                description: "Take 10,000 steps today",
                type: .steps,
                targetValue: 10000,
                reward: ChallengeReward(experience: 200, coins: 50, gear: nil),
                difficulty: .medium,
                category: .fitness,
                expiresAt: Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
            ),
            DailyChallenge(
                id: UUID(),
                title: "Elevation Climber",
                description: "Gain 500m of elevation today",
                type: .elevation,
                targetValue: 500,
                reward: ChallengeReward(experience: 300, coins: 75, gear: GearItem.basicBoots),
                difficulty: .hard,
                category: .climbing,
                expiresAt: Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
            ),
            DailyChallenge(
                id: UUID(),
                title: "Survival Expert",
                description: "Complete a mountain zone without taking damage",
                type: .survival,
                targetValue: 1,
                reward: ChallengeReward(experience: 250, coins: 60, gear: nil),
                difficulty: .expert,
                category: .survival,
                expiresAt: Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
            )
        ]
        
        userDefaults.set(today, forKey: "last_daily_challenges")
        saveDailyChallenges()
    }
    
    func completeDailyChallenge(_ challengeId: UUID) {
        guard let index = dailyChallenges.firstIndex(where: { $0.id == challengeId }) else { return }
        
        dailyChallenges[index].isCompleted = true
        dailyChallenges[index].completedAt = Date()
        
        saveDailyChallenges()
        
        // Award reward
        let challenge = dailyChallenges[index]
        awardChallengeReward(challenge.reward)
        
        // Check for completion achievements
        checkDailyChallengeAchievements()
    }
    
    // MARK: - Weekly Challenges
    
    func generateWeeklyChallenges() {
        let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        // Check if we already have challenges for this week
        if let lastGenerated = userDefaults.object(forKey: "last_weekly_challenges") as? Date,
           Calendar.current.isDate(lastGenerated, inSameDayAs: startOfWeek) {
            return
        }
        
        weeklyChallenges = [
            WeeklyChallenge(
                id: UUID(),
                title: "Mountain Conqueror",
                description: "Complete 3 different mountains this week",
                type: .mountains,
                targetValue: 3,
                reward: ChallengeReward(experience: 1000, coins: 200, gear: GearItem.expeditionJacket),
                difficulty: .expert,
                category: .climbing,
                expiresAt: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startOfWeek) ?? Date()
            ),
            WeeklyChallenge(
                id: UUID(),
                title: "Endurance Master",
                description: "Take 50,000 steps this week",
                type: .steps,
                targetValue: 50000,
                reward: ChallengeReward(experience: 800, coins: 150, gear: nil),
                difficulty: .hard,
                category: .fitness,
                expiresAt: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startOfWeek) ?? Date()
            ),
            WeeklyChallenge(
                id: UUID(),
                title: "Social Climber",
                description: "Complete 5 team challenges this week",
                type: .teamwork,
                targetValue: 5,
                reward: ChallengeReward(experience: 600, coins: 100, gear: nil),
                difficulty: .medium,
                category: .social,
                expiresAt: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startOfWeek) ?? Date()
            )
        ]
        
        userDefaults.set(startOfWeek, forKey: "last_weekly_challenges")
        saveWeeklyChallenges()
    }
    
    func completeWeeklyChallenge(_ challengeId: UUID) {
        guard let index = weeklyChallenges.firstIndex(where: { $0.id == challengeId }) else { return }
        
        weeklyChallenges[index].isCompleted = true
        weeklyChallenges[index].completedAt = Date()
        
        saveWeeklyChallenges()
        
        // Award reward
        let challenge = weeklyChallenges[index]
        awardChallengeReward(challenge.reward)
        
        // Check for completion achievements
        checkWeeklyChallengeAchievements()
    }
    
    // MARK: - Leaderboard System
    
    func loadLeaderboard() {
        // Mock leaderboard data
        globalLeaderboard = [
            LeaderboardEntry(
                id: UUID(),
                userId: "user1",
                displayName: "MountainMaster",
                avatar: CharacterAvatar(skinTone: .medium, hairColor: .brown, eyeColor: .blue, facialFeatures: .clean, clothing: .athletic),
                score: 15420,
                rank: 1,
                level: 25,
                achievements: 45,
                mountainsCompleted: 12,
                totalSteps: 1250000,
                totalElevation: 45000
            ),
            LeaderboardEntry(
                id: UUID(),
                userId: "user2",
                displayName: "SummitSeeker",
                avatar: CharacterAvatar(skinTone: .light, hairColor: .blonde, eyeColor: .green, facialFeatures: .mustache, clothing: .rugged),
                score: 14890,
                rank: 2,
                level: 24,
                achievements: 42,
                mountainsCompleted: 11,
                totalSteps: 1180000,
                totalElevation: 42000
            ),
            LeaderboardEntry(
                id: UUID(),
                userId: "user3",
                displayName: "PeakPro",
                avatar: CharacterAvatar(skinTone: .dark, hairColor: .black, eyeColor: .brown, facialFeatures: .beard, clothing: .professional),
                score: 14250,
                rank: 3,
                level: 23,
                achievements: 38,
                mountainsCompleted: 10,
                totalSteps: 1100000,
                totalElevation: 40000
            )
        ]
        
        // Calculate user rankings
        calculateUserRankings()
    }
    
    func updateUserScore(_ score: Int) {
        // This would typically update the user's score in Firebase
        // For now, we'll just update local rankings
        calculateUserRankings()
    }
    
    private func calculateUserRankings() {
        // Mock user rankings
        userRankings = UserRankings(
            globalRank: 156,
            weeklyRank: 23,
            dailyRank: 8,
            totalUsers: 15420,
            percentile: 98.9
        )
    }
    
    // MARK: - Team Competitions
    
    func createTeamCompetition(mountainId: UUID, maxTeams: Int = 8) {
        let competition = TeamCompetition(
            id: UUID(),
            title: "\(getMountainName(for: mountainId)) Championship",
            description: "Compete for the ultimate climbing title",
            mountainId: mountainId,
            maxTeams: maxTeams,
            status: .registration,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            prize: CompetitionPrize(
                firstPlace: ChallengeReward(experience: 5000, coins: 1000, gear: GearItem.legendaryJacket),
                secondPlace: ChallengeReward(experience: 3000, coins: 600, gear: GearItem.expeditionJacket),
                thirdPlace: ChallengeReward(experience: 2000, coins: 400, gear: GearItem.technicalBoots)
            )
        )
        
        teamCompetitions.append(competition)
        saveTeamCompetitions()
    }
    
    func joinTeamCompetition(_ competitionId: UUID, teamId: String) {
        guard let index = teamCompetitions.firstIndex(where: { $0.id == competitionId }) else { return }
        
        if teamCompetitions[index].participatingTeams.count < teamCompetitions[index].maxTeams {
            teamCompetitions[index].participatingTeams.append(teamId)
            saveTeamCompetitions()
        }
    }
    
    // MARK: - Achievement System
    
    func checkAchievements() {
        // Check for various achievement conditions
        checkStepsAchievements()
        checkElevationAchievements()
        checkMountainAchievements()
        checkSocialAchievements()
    }
    
    private func checkStepsAchievements() {
        // Mock step achievements
        if !hasAchievement("first_10k_steps") {
            unlockAchievement("First 10K", "Take your first 10,000 steps", .common, 100)
        }
        
        if !hasAchievement("step_master") {
            unlockAchievement("Step Master", "Take 100,000 steps", .rare, 500)
        }
    }
    
    private func checkElevationAchievements() {
        // Mock elevation achievements
        if !hasAchievement("first_1k_elevation") {
            unlockAchievement("First 1K", "Gain your first 1,000m of elevation", .common, 150)
        }
        
        if !hasAchievement("altitude_master") {
            unlockAchievement("Altitude Master", "Gain 10,000m of elevation", .epic, 1000)
        }
    }
    
    private func checkMountainAchievements() {
        // Mock mountain achievements
        if !hasAchievement("first_mountain") {
            unlockAchievement("First Summit", "Complete your first mountain", .common, 200)
        }
        
        if !hasAchievement("mountain_master") {
            unlockAchievement("Mountain Master", "Complete 10 mountains", .legendary, 2000)
        }
    }
    
    private func checkSocialAchievements() {
        // Mock social achievements
        if !hasAchievement("team_player") {
            unlockAchievement("Team Player", "Complete your first team challenge", .uncommon, 300)
        }
        
        if !hasAchievement("social_butterfly") {
            unlockAchievement("Social Butterfly", "Complete 20 team challenges", .rare, 750)
        }
    }
    
    func unlockAchievement(_ name: String, _ description: String, _ rarity: Achievement.AchievementRarity, _ experience: Int) {
        let achievement = Achievement(
            id: UUID(),
            name: name,
            description: description,
            category: .climbing,
            rarity: rarity,
            reward: Achievement.AchievementReward(experience: experience),
            unlockedAt: Date(),
            progress: 1,
            maxProgress: 1
        )
        
        achievements.append(achievement)
        saveAchievements()
        
        // Award experience
        // This would typically be handled by the CharacterManager
    }
    
    private func hasAchievement(_ identifier: String) -> Bool {
        return achievements.contains { achievement in
            achievement.name.lowercased().replacingOccurrences(of: " ", with: "_") == identifier
        }
    }
    
    // MARK: - Reward System
    
    private func awardChallengeReward(_ reward: ChallengeReward) {
        // This would typically be handled by the CharacterManager
        // For now, we'll just log the reward
        print("Awarded reward: \(reward.experience) XP, \(reward.coins) coins")
        
        if let gear = reward.gear {
            print("Awarded gear: \(gear.name)")
        }
    }
    
    private func checkDailyChallengeAchievements() {
        let completedCount = dailyChallenges.filter { $0.isCompleted }.count
        
        if completedCount >= 7 && !hasAchievement("daily_master") {
            unlockAchievement("Daily Master", "Complete 7 daily challenges", .rare, 500)
        }
        
        if completedCount >= 30 && !hasAchievement("daily_legend") {
            unlockAchievement("Daily Legend", "Complete 30 daily challenges", .epic, 1500)
        }
    }
    
    private func checkWeeklyChallengeAchievements() {
        let completedCount = weeklyChallenges.filter { $0.isCompleted }.count
        
        if completedCount >= 4 && !hasAchievement("weekly_master") {
            unlockAchievement("Weekly Master", "Complete 4 weekly challenges", .rare, 750)
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveDailyChallenges() {
        do {
            let data = try JSONEncoder().encode(dailyChallenges)
            userDefaults.set(data, forKey: "daily_challenges")
        } catch {
            print("Failed to save daily challenges: \(error)")
        }
    }
    
    private func loadDailyChallenges() {
        if let data = userDefaults.data(forKey: "daily_challenges") {
            do {
                dailyChallenges = try JSONDecoder().decode([DailyChallenge].self, from: data)
            } catch {
                print("Failed to load daily challenges: \(error)")
            }
        }
    }
    
    private func saveWeeklyChallenges() {
        do {
            let data = try JSONEncoder().encode(weeklyChallenges)
            userDefaults.set(data, forKey: "weekly_challenges")
        } catch {
            print("Failed to save weekly challenges: \(error)")
        }
    }
    
    private func loadWeeklyChallenges() {
        if let data = userDefaults.data(forKey: "weekly_challenges") {
            do {
                weeklyChallenges = try JSONDecoder().decode([WeeklyChallenge].self, from: data)
            } catch {
                print("Failed to load weekly challenges: \(error)")
            }
        }
    }
    
    private func saveTeamCompetitions() {
        do {
            let data = try JSONEncoder().encode(teamCompetitions)
            userDefaults.set(data, forKey: "team_competitions")
        } catch {
            print("Failed to save team competitions: \(error)")
        }
    }
    
    private func loadTeamCompetitions() {
        if let data = userDefaults.data(forKey: "team_competitions") {
            do {
                teamCompetitions = try JSONDecoder().decode([TeamCompetition].self, from: data)
            } catch {
                print("Failed to load team competitions: \(error)")
            }
        }
    }
    
    private func saveAchievements() {
        do {
            let data = try JSONEncoder().encode(achievements)
            userDefaults.set(data, forKey: "achievements")
        } catch {
            print("Failed to save achievements: \(error)")
        }
    }
    
    private func loadAchievements() {
        if let data = userDefaults.data(forKey: "achievements") {
            do {
                achievements = try JSONDecoder().decode([Achievement].self, from: data)
            } catch {
                print("Failed to load achievements: \(error)")
            }
        }
    }
    
    private func loadCompetitionData() {
        loadDailyChallenges()
        loadWeeklyChallenges()
        loadTeamCompetitions()
        loadAchievements()
    }
    
    // MARK: - Helper Methods
    
    private func getMountainName(for mountainId: UUID) -> String {
        if let mountain = Mountain.allMountains.first(where: { $0.id == mountainId }) {
            return mountain.name
        }
        return "Unknown Mountain"
    }
    
    // MARK: - Mock Data for Development
    
    func createMockCompetitionData() {
        // Create mock team competition
        createTeamCompetition(mountainId: Mountain.kilimanjaro.id)
        
        // Add mock achievements
        unlockAchievement("Test Achievement", "This is a test achievement", .common, 100)
    }
}

// MARK: - Supporting Models

struct DailyChallenge: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let type: ChallengeType
    let targetValue: Int
    let reward: ChallengeReward
    let difficulty: ChallengeDifficulty
    let category: ChallengeCategory
    let expiresAt: Date
    var isCompleted: Bool = false
    var completedAt: Date?
    var progress: Int = 0
    
    enum ChallengeType: String, CaseIterable, Codable {
        case steps = "Steps"
        case elevation = "Elevation"
        case survival = "Survival"
        case teamwork = "Teamwork"
        case gear = "Gear"
        
        var icon: String {
            switch self {
            case .steps: return "figure.walk"
            case .elevation: return "arrow.up"
            case .survival: return "leaf.fill"
            case .teamwork: return "person.3.fill"
            case .gear: return "tshirt.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .steps: return .green
            case .elevation: return .blue
            case .survival: return .orange
            case .teamwork: return .purple
            case .gear: return .yellow
            }
        }
    }
    
    enum ChallengeDifficulty: String, CaseIterable, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        case expert = "Expert"
        
        var color: Color {
            switch self {
            case .easy: return .green
            case .medium: return .yellow
            case .hard: return .orange
            case .expert: return .red
            }
        }
    }
    
    enum ChallengeCategory: String, CaseIterable, Codable {
        case fitness = "Fitness"
        case climbing = "Climbing"
        case survival = "Survival"
        case social = "Social"
        case exploration = "Exploration"
        
        var icon: String {
            switch self {
            case .fitness: return "figure.run"
            case .climbing: return "figure.climbing"
            case .survival: return "leaf.fill"
            case .social: return "person.3.fill"
            case .exploration: return "map.fill"
            }
        }
    }
}

struct WeeklyChallenge: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let type: WeeklyChallengeType
    let targetValue: Int
    let reward: ChallengeReward
    let difficulty: DailyChallenge.ChallengeDifficulty
    let category: DailyChallenge.ChallengeCategory
    let expiresAt: Date
    var isCompleted: Bool = false
    var completedAt: Date?
    var progress: Int = 0
    
    enum WeeklyChallengeType: String, CaseIterable, Codable {
        case steps = "Steps"
        case elevation = "Elevation"
        case mountains = "Mountains"
        case teamwork = "Teamwork"
        case survival = "Survival"
        
        var icon: String {
            switch self {
            case .steps: return "figure.walk"
            case .elevation: return "arrow.up"
            case .mountains: return "mountain.2.fill"
            case .teamwork: return "person.3.fill"
            case .survival: return "leaf.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .steps: return .green
            case .elevation: return .blue
            case .mountains: return .orange
            case .teamwork: return .purple
            case .survival: return .red
            }
        }
    }
}

struct ChallengeReward: Codable {
    let experience: Int
    let coins: Int
    let gear: GearItem?
    
    init(experience: Int = 0, coins: Int = 0, gear: GearItem? = nil) {
        self.experience = experience
        self.coins = coins
        self.gear = gear
    }
}

struct LeaderboardEntry: Identifiable, Codable {
    let id: UUID
    let userId: String
    let displayName: String
    let avatar: CharacterAvatar
    let score: Int
    let rank: Int
    let level: Int
    let achievements: Int
    let mountainsCompleted: Int
    let totalSteps: Int
    let totalElevation: Double
    let lastActive: Date
    
    init(id: UUID = UUID(), userId: String, displayName: String, avatar: CharacterAvatar, score: Int, rank: Int, level: Int, achievements: Int, mountainsCompleted: Int, totalSteps: Int, totalElevation: Double, lastActive: Date = Date()) {
        self.id = id
        self.userId = userId
        self.displayName = displayName
        self.avatar = avatar
        self.score = score
        self.rank = rank
        self.level = level
        self.achievements = achievements
        self.mountainsCompleted = mountainsCompleted
        self.totalSteps = totalSteps
        self.totalElevation = totalElevation
        self.lastActive = lastActive
    }
}

struct UserRankings: Codable {
    let globalRank: Int
    let weeklyRank: Int
    let dailyRank: Int
    let totalUsers: Int
    let percentile: Double
    
    var globalPercentile: Double {
        return (Double(totalUsers - globalRank) / Double(totalUsers)) * 100
    }
}

struct TeamCompetition: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let mountainId: UUID
    let maxTeams: Int
    var status: CompetitionStatus
    let startDate: Date
    let endDate: Date
    let prize: CompetitionPrize
    var participatingTeams: [String] = []
    var teamScores: [String: Int] = [:]
    
    enum CompetitionStatus: String, CaseIterable, Codable {
        case registration = "Registration"
        case active = "Active"
        case completed = "Completed"
        case cancelled = "Cancelled"
        
        var color: Color {
            switch self {
            case .registration: return .blue
            case .active: return .green
            case .completed: return .orange
            case .cancelled: return .red
            }
        }
    }
}

struct CompetitionPrize: Codable {
    let firstPlace: ChallengeReward
    let secondPlace: ChallengeReward
    let thirdPlace: ChallengeReward
}
