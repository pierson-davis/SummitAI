import Foundation
import SwiftUI

// MARK: - Character Model

struct Character: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatar: CharacterAvatar
    var level: Int
    var experience: Int
    var experienceToNextLevel: Int
    var skillPoints: Int
    var skills: CharacterSkills
    var gear: [GearItem]
    var equippedGear: EquippedGear
    var personalityTraits: PersonalityTraits
    var climbingStyle: ClimbingStyle
    var achievements: [Achievement]
    var stats: CharacterStats
    var createdAt: Date
    var lastUpdated: Date
    
    init(name: String, avatar: CharacterAvatar) {
        self.id = UUID()
        self.name = name
        self.avatar = avatar
        self.level = 1
        self.experience = 0
        self.experienceToNextLevel = 100
        self.skillPoints = 5 // Starting skill points
        self.skills = CharacterSkills()
        self.gear = []
        self.equippedGear = EquippedGear()
        self.personalityTraits = PersonalityTraits()
        self.climbingStyle = .balanced
        self.achievements = []
        self.stats = CharacterStats()
        self.createdAt = Date()
        self.lastUpdated = Date()
    }
    
    // MARK: - Leveling System
    
    var totalExperienceRequired: Int {
        return level * 100 + (level - 1) * 50 // Exponential growth
    }
    
    var canLevelUp: Bool {
        return experience >= experienceToNextLevel
    }
    
    mutating func addExperience(_ amount: Int) {
        experience += amount
        
        while canLevelUp {
            levelUp()
        }
    }
    
    private mutating func levelUp() {
        level += 1
        skillPoints += 3 // 3 skill points per level
        experience -= experienceToNextLevel
        experienceToNextLevel = totalExperienceRequired
        
        // Apply level-up bonuses
        stats.maxHealth += 10
        stats.currentHealth = stats.maxHealth
        stats.maxStamina += 5
        stats.currentStamina = stats.maxStamina
    }
}

// MARK: - Character Avatar

struct CharacterAvatar: Codable {
    let skinTone: SkinTone
    let hairColor: HairColor
    let eyeColor: EyeColor
    let facialFeatures: FacialFeatures
    let clothing: ClothingStyle
    
    enum SkinTone: String, CaseIterable, Codable {
        case light = "Light"
        case medium = "Medium"
        case dark = "Dark"
        case veryDark = "Very Dark"
        
        var color: Color {
            switch self {
            case .light: return Color(red: 0.96, green: 0.87, blue: 0.70)
            case .medium: return Color(red: 0.85, green: 0.65, blue: 0.45)
            case .dark: return Color(red: 0.55, green: 0.35, blue: 0.25)
            case .veryDark: return Color(red: 0.35, green: 0.25, blue: 0.15)
            }
        }
    }
    
    enum HairColor: String, CaseIterable, Codable {
        case black = "Black"
        case brown = "Brown"
        case blonde = "Blonde"
        case red = "Red"
        case gray = "Gray"
        case white = "White"
        
        var color: Color {
            switch self {
            case .black: return .black
            case .brown: return Color.brown
            case .blonde: return Color.yellow.opacity(0.8)
            case .red: return Color.red.opacity(0.8)
            case .gray: return Color.gray
            case .white: return .white
            }
        }
    }
    
    enum EyeColor: String, CaseIterable, Codable {
        case brown = "Brown"
        case blue = "Blue"
        case green = "Green"
        case hazel = "Hazel"
        case gray = "Gray"
        
        var color: Color {
            switch self {
            case .brown: return Color.brown
            case .blue: return .blue
            case .green: return .green
            case .hazel: return Color.orange.opacity(0.8)
            case .gray: return .gray
            }
        }
    }
    
    enum FacialFeatures: String, CaseIterable, Codable {
        case clean = "Clean Shaven"
        case mustache = "Mustache"
        case beard = "Beard"
        case goatee = "Goatee"
        case fullBeard = "Full Beard"
    }
    
    enum ClothingStyle: String, CaseIterable, Codable {
        case casual = "Casual"
        case athletic = "Athletic"
        case rugged = "Rugged"
        case professional = "Professional"
        case adventurous = "Adventurous"
    }
}

// MARK: - Character Skills

struct CharacterSkills: Codable {
    var survival: SkillTree
    var climbing: SkillTree
    var leadership: SkillTree
    var endurance: SkillTree
    
    init() {
        self.survival = SkillTree(type: .survival)
        self.climbing = SkillTree(type: .climbing)
        self.leadership = SkillTree(type: .leadership)
        self.endurance = SkillTree(type: .endurance)
    }
    
    enum SkillType: String, CaseIterable, Codable {
        case survival = "Survival"
        case climbing = "Climbing"
        case leadership = "Leadership"
        case endurance = "Endurance"
        
        var description: String {
            switch self {
            case .survival:
                return "Skills for surviving in harsh environments"
            case .climbing:
                return "Technical climbing and mountaineering skills"
            case .leadership:
                return "Leading teams and making strategic decisions"
            case .endurance:
                return "Physical stamina and mental resilience"
            }
        }
        
        var icon: String {
            switch self {
            case .survival: return "leaf.fill"
            case .climbing: return "figure.climbing"
            case .leadership: return "person.3.fill"
            case .endurance: return "heart.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .survival: return .green
            case .climbing: return .blue
            case .leadership: return .purple
            case .endurance: return .red
            }
        }
    }
}

// MARK: - Skill Tree

struct SkillTree: Codable {
    let type: CharacterSkills.SkillType
    var skills: [Skill]
    var totalPointsInvested: Int
    
    init(type: CharacterSkills.SkillType) {
        self.type = type
        self.skills = Self.getDefaultSkills(for: type)
        self.totalPointsInvested = 0
    }
    
    private static func getDefaultSkills(for type: CharacterSkills.SkillType) -> [Skill] {
        switch type {
        case .survival:
            return [
                Skill(id: UUID(), name: "Weather Reading", description: "Predict weather changes", level: 0, maxLevel: 5, cost: 1, prerequisites: []),
                Skill(id: UUID(), name: "Shelter Building", description: "Build effective shelters", level: 0, maxLevel: 5, cost: 1, prerequisites: []),
                Skill(id: UUID(), name: "Water Purification", description: "Find and purify water sources", level: 0, maxLevel: 3, cost: 2, prerequisites: ["Weather Reading"]),
                Skill(id: UUID(), name: "Fire Making", description: "Start fires in difficult conditions", level: 0, maxLevel: 5, cost: 1, prerequisites: []),
                Skill(id: UUID(), name: "First Aid", description: "Treat injuries and illnesses", level: 0, maxLevel: 5, cost: 2, prerequisites: ["Shelter Building"]),
                Skill(id: UUID(), name: "Wilderness Navigation", description: "Navigate without modern tools", level: 0, maxLevel: 5, cost: 3, prerequisites: ["Weather Reading", "Fire Making"])
            ]
        case .climbing:
            return [
                Skill(id: UUID(), name: "Rope Work", description: "Advanced rope techniques", level: 0, maxLevel: 5, cost: 1, prerequisites: []),
                Skill(id: UUID(), name: "Ice Climbing", description: "Climb on ice and snow", level: 0, maxLevel: 5, cost: 2, prerequisites: ["Rope Work"]),
                Skill(id: UUID(), name: "Rock Climbing", description: "Technical rock climbing", level: 0, maxLevel: 5, cost: 1, prerequisites: []),
                Skill(id: UUID(), name: "Crevass Rescue", description: "Rescue from crevasses", level: 0, maxLevel: 3, cost: 3, prerequisites: ["Ice Climbing", "Rope Work"]),
                Skill(id: UUID(), name: "Avalanche Safety", description: "Avoid and survive avalanches", level: 0, maxLevel: 4, cost: 2, prerequisites: ["Ice Climbing"]),
                Skill(id: UUID(), name: "High Altitude Climbing", description: "Climb above 6000m", level: 0, maxLevel: 5, cost: 4, prerequisites: ["Rock Climbing", "Ice Climbing"])
            ]
        case .leadership:
            return [
                Skill(id: UUID(), name: "Team Coordination", description: "Lead climbing teams", level: 0, maxLevel: 5, cost: 1, prerequisites: []),
                Skill(id: UUID(), name: "Decision Making", description: "Make critical decisions under pressure", level: 0, maxLevel: 5, cost: 2, prerequisites: []),
                Skill(id: UUID(), name: "Risk Assessment", description: "Evaluate climbing risks", level: 0, maxLevel: 5, cost: 2, prerequisites: ["Team Coordination"]),
                Skill(id: UUID(), name: "Emergency Response", description: "Handle emergency situations", level: 0, maxLevel: 4, cost: 3, prerequisites: ["Decision Making", "Risk Assessment"]),
                Skill(id: UUID(), name: "Mentoring", description: "Teach others climbing skills", level: 0, maxLevel: 3, cost: 2, prerequisites: ["Team Coordination"]),
                Skill(id: UUID(), name: "Expedition Planning", description: "Plan complex expeditions", level: 0, maxLevel: 5, cost: 4, prerequisites: ["Risk Assessment", "Emergency Response"])
            ]
        case .endurance:
            return [
                Skill(id: UUID(), name: "Cardio Fitness", description: "Improve cardiovascular endurance", level: 0, maxLevel: 5, cost: 1, prerequisites: []),
                Skill(id: UUID(), name: "Strength Training", description: "Build physical strength", level: 0, maxLevel: 5, cost: 1, prerequisites: []),
                Skill(id: UUID(), name: "Altitude Adaptation", description: "Adapt to high altitude", level: 0, maxLevel: 5, cost: 2, prerequisites: ["Cardio Fitness"]),
                Skill(id: UUID(), name: "Mental Toughness", description: "Overcome mental challenges", level: 0, maxLevel: 5, cost: 2, prerequisites: []),
                Skill(id: UUID(), name: "Recovery", description: "Faster recovery from exertion", level: 0, maxLevel: 4, cost: 2, prerequisites: ["Strength Training", "Cardio Fitness"]),
                Skill(id: UUID(), name: "Peak Performance", description: "Achieve optimal performance", level: 0, maxLevel: 5, cost: 4, prerequisites: ["Altitude Adaptation", "Mental Toughness", "Recovery"])
            ]
        }
    }
}

// MARK: - Skill

struct Skill: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    var level: Int
    let maxLevel: Int
    let cost: Int // Skill points required per level
    let prerequisites: [String] // Names of prerequisite skills
    
    var isMaxed: Bool {
        return level >= maxLevel
    }
    
    var canUpgrade: Bool {
        return level < maxLevel
    }
    
    var totalCost: Int {
        return (level + 1) * cost
    }
    
    var effectiveness: Double {
        return Double(level) / Double(maxLevel)
    }
}

// MARK: - Personality Traits

struct PersonalityTraits: Codable {
    var riskTolerance: RiskTolerance
    var socialPreference: SocialPreference
    var decisionStyle: DecisionStyle
    var motivationType: MotivationType
    
    init() {
        self.riskTolerance = .moderate
        self.socialPreference = .balanced
        self.decisionStyle = .analytical
        self.motivationType = .achievement
    }
    
    enum RiskTolerance: String, CaseIterable, Codable {
        case conservative = "Conservative"
        case moderate = "Moderate"
        case aggressive = "Aggressive"
        case extreme = "Extreme"
        
        var description: String {
            switch self {
            case .conservative: return "Prefers safe, well-planned routes"
            case .moderate: return "Takes calculated risks"
            case .aggressive: return "Willing to take significant risks"
            case .extreme: return "Thrives on extreme challenges"
            }
        }
    }
    
    enum SocialPreference: String, CaseIterable, Codable {
        case solo = "Solo"
        case smallGroup = "Small Group"
        case balanced = "Balanced"
        case largeGroup = "Large Group"
        
        var description: String {
            switch self {
            case .solo: return "Prefers climbing alone"
            case .smallGroup: return "Prefers 2-4 person teams"
            case .balanced: return "Comfortable in any group size"
            case .largeGroup: return "Enjoys large expedition teams"
            }
        }
    }
    
    enum DecisionStyle: String, CaseIterable, Codable {
        case analytical = "Analytical"
        case intuitive = "Intuitive"
        case collaborative = "Collaborative"
        case decisive = "Decisive"
        
        var description: String {
            switch self {
            case .analytical: return "Makes decisions based on data"
            case .intuitive: return "Relies on gut feelings"
            case .collaborative: return "Seeks team input"
            case .decisive: return "Makes quick decisions"
            }
        }
    }
    
    enum MotivationType: String, CaseIterable, Codable {
        case achievement = "Achievement"
        case exploration = "Exploration"
        case competition = "Competition"
        case personalGrowth = "Personal Growth"
        
        var description: String {
            switch self {
            case .achievement: return "Driven by reaching goals"
            case .exploration: return "Motivated by discovery"
            case .competition: return "Thrives on competition"
            case .personalGrowth: return "Seeks self-improvement"
            }
        }
    }
}

// MARK: - Climbing Style

enum ClimbingStyle: String, CaseIterable, Codable {
    case speed = "Speed"
    case endurance = "Endurance"
    case technical = "Technical"
    case balanced = "Balanced"
    case social = "Social"
    
    var description: String {
        switch self {
        case .speed: return "Fast, efficient climbing"
        case .endurance: return "Long-distance, steady climbing"
        case .technical: return "Skill-focused climbing"
        case .balanced: return "Well-rounded approach"
        case .social: return "Team-oriented climbing"
        }
    }
    
    var icon: String {
        switch self {
        case .speed: return "bolt.fill"
        case .endurance: return "timer"
        case .technical: return "wrench.fill"
        case .balanced: return "scale.3d"
        case .social: return "person.3.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .speed: return .yellow
        case .endurance: return .green
        case .technical: return .blue
        case .balanced: return .purple
        case .social: return .orange
        }
    }
}

// MARK: - Character Stats

struct CharacterStats: Codable {
    var maxHealth: Int
    var currentHealth: Int
    var maxStamina: Int
    var currentStamina: Int
    var strength: Int
    var agility: Int
    var intelligence: Int
    var charisma: Int
    
    init() {
        self.maxHealth = 100
        self.currentHealth = 100
        self.maxStamina = 100
        self.currentStamina = 100
        self.strength = 10
        self.agility = 10
        self.intelligence = 10
        self.charisma = 10
    }
    
    var healthPercentage: Double {
        return Double(currentHealth) / Double(maxHealth)
    }
    
    var staminaPercentage: Double {
        return Double(currentStamina) / Double(maxStamina)
    }
}

// MARK: - Achievement

struct Achievement: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let category: AchievementCategory
    let rarity: AchievementRarity
    let reward: AchievementReward
    let unlockedAt: Date?
    let progress: Int
    let maxProgress: Int
    
    var isUnlocked: Bool {
        return unlockedAt != nil
    }
    
    var progressPercentage: Double {
        return Double(progress) / Double(maxProgress)
    }
    
    enum AchievementCategory: String, CaseIterable, Codable {
        case climbing = "Climbing"
        case survival = "Survival"
        case exploration = "Exploration"
        case social = "Social"
        case endurance = "Endurance"
        
        var icon: String {
            switch self {
            case .climbing: return "figure.climbing"
            case .survival: return "leaf.fill"
            case .exploration: return "map.fill"
            case .social: return "person.3.fill"
            case .endurance: return "heart.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .climbing: return .blue
            case .survival: return .green
            case .exploration: return .purple
            case .social: return .orange
            case .endurance: return .red
            }
        }
    }
    
    enum AchievementRarity: String, CaseIterable, Codable {
        case common = "Common"
        case uncommon = "Uncommon"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
        
        var color: Color {
            switch self {
            case .common: return .gray
            case .uncommon: return .green
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .common: return "circle.fill"
            case .uncommon: return "star.fill"
            case .rare: return "diamond.fill"
            case .epic: return "crown.fill"
            case .legendary: return "flame.fill"
            }
        }
    }
    
    struct AchievementReward: Codable {
        let experience: Int
        let skillPoints: Int
        let gear: GearItem?
        let title: String?
        
        init(experience: Int = 0, skillPoints: Int = 0, gear: GearItem? = nil, title: String? = nil) {
            self.experience = experience
            self.skillPoints = skillPoints
            self.gear = gear
            self.title = title
        }
    }
}
