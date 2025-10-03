import Foundation
import SwiftUI

// MARK: - Mountain Model
struct Mountain: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let height: Double // in meters
    let location: String
    let difficulty: MountainDifficulty
    let description: String
    let imageName: String
    let isPaywalled: Bool
    let camps: [Camp]
    let baseSteps: Int // Base number of steps to complete
    let baseElevation: Double // Base elevation gain
    
    // Realistic climbing data
    let baseElevationStart: Double // Starting elevation (base camp)
    let totalElevationGain: Double // Actual elevation gain to climb
    let difficultyMultiplier: Double // Difficulty factor for step calculations
    let estimatedDays: Int // Realistic days to complete
    let climbingSeason: ClimbingSeason
    let weatherPatterns: [WeatherPattern]
    let hazards: [ClimbingHazard]
    let equipmentRequirements: [Equipment]
    let historicalData: HistoricalClimbingData
    
    init(name: String, height: Double, location: String, difficulty: MountainDifficulty, description: String, imageName: String, isPaywalled: Bool, camps: [Camp], baseSteps: Int, baseElevation: Double, baseElevationStart: Double, totalElevationGain: Double, difficultyMultiplier: Double, estimatedDays: Int, climbingSeason: ClimbingSeason, weatherPatterns: [WeatherPattern], hazards: [ClimbingHazard], equipmentRequirements: [Equipment], historicalData: HistoricalClimbingData) {
        self.id = UUID()
        self.name = name
        self.height = height
        self.location = location
        self.difficulty = difficulty
        self.description = description
        self.imageName = imageName
        self.isPaywalled = isPaywalled
        self.camps = camps
        self.baseSteps = baseSteps
        self.baseElevation = baseElevation
        self.baseElevationStart = baseElevationStart
        self.totalElevationGain = totalElevationGain
        self.difficultyMultiplier = difficultyMultiplier
        self.estimatedDays = estimatedDays
        self.climbingSeason = climbingSeason
        self.weatherPatterns = weatherPatterns
        self.hazards = hazards
        self.equipmentRequirements = equipmentRequirements
        self.historicalData = historicalData
    }
    
    enum MountainDifficulty: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
        
        var color: Color {
            switch self {
            case .beginner:
                return .green
            case .intermediate:
                return .yellow
            case .advanced:
                return .orange
            case .expert:
                return .red
            }
        }
        
        var icon: String {
            switch self {
            case .beginner:
                return "leaf.fill"
            case .intermediate:
                return "mountain.2.fill"
            case .advanced:
                return "mountain.2.circle.fill"
            case .expert:
                return "crown.fill"
            }
        }
    }
}

// MARK: - Camp Model
struct Camp: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let altitude: Double // in meters
    let stepsRequired: Int
    let elevationRequired: Double // in meters
    let description: String
    let unlockedMessage: String
    let isBaseCamp: Bool
    let isSummit: Bool
    
    init(name: String, altitude: Double, stepsRequired: Int, elevationRequired: Double, description: String, unlockedMessage: String, isBaseCamp: Bool, isSummit: Bool) {
        self.id = UUID()
        self.name = name
        self.altitude = altitude
        self.stepsRequired = stepsRequired
        self.elevationRequired = elevationRequired
        self.description = description
        self.unlockedMessage = unlockedMessage
        self.isBaseCamp = isBaseCamp
        self.isSummit = isSummit
    }
    
    var progressPercentage: Double {
        return Double(stepsRequired) / 100000.0 // Assuming 100k steps for full mountain
    }
}

// MARK: - Expedition Progress Model
struct ExpeditionProgress: Identifiable, Codable, Equatable {
    let id: UUID
    var mountainId: UUID
    var currentCampId: UUID?
    var totalSteps: Int
    var totalElevation: Double
    var startDate: Date
    var lastUpdateDate: Date
    var isCompleted: Bool
    var completionDate: Date?
    var dailyProgress: [DailyProgress]
    
    init(mountainId: UUID) {
        self.id = UUID()
        self.mountainId = mountainId
        self.currentCampId = nil
        self.totalSteps = 0
        self.totalElevation = 0
        self.startDate = Date()
        self.lastUpdateDate = Date()
        self.isCompleted = false
        self.completionDate = nil
        self.dailyProgress = []
    }
}

// MARK: - Daily Progress Model
struct DailyProgress: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var steps: Int
    var elevation: Double
    var workouts: [WorkoutData]
    
    init(date: Date, steps: Int = 0, elevation: Double = 0) {
        self.id = UUID()
        self.date = date
        self.steps = steps
        self.elevation = elevation
        self.workouts = []
    }
}

// MARK: - Workout Data Model
struct WorkoutData: Identifiable, Codable, Equatable {
    let id: UUID
    let type: WorkoutType
    let duration: TimeInterval
    let distance: Double?
    let elevation: Double?
    let calories: Double?
    let timestamp: Date
    
    init(type: WorkoutType, duration: TimeInterval, distance: Double? = nil, elevation: Double? = nil, calories: Double? = nil, timestamp: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.duration = duration
        self.distance = distance
        self.elevation = elevation
        self.calories = calories
        self.timestamp = timestamp
    }
    
    enum WorkoutType: String, CaseIterable, Codable {
        case walking = "Walking"
        case running = "Running"
        case cycling = "Cycling"
        case hiking = "Hiking"
        case climbing = "Climbing"
        case gym = "Gym"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .walking:
                return "figure.walk"
            case .running:
                return "figure.run"
            case .cycling:
                return "bicycle"
            case .hiking:
                return "mountain.2.fill"
            case .climbing:
                return "figure.climbing"
            case .gym:
                return "dumbbell.fill"
            case .other:
                return "figure.mixed.cardio"
            }
        }
        
        var multiplier: Double {
            switch self {
            case .walking:
                return 1.0
            case .running:
                return 1.5
            case .cycling:
                return 1.2
            case .hiking:
                return 2.0
            case .climbing:
                return 3.0
            case .gym:
                return 1.3
            case .other:
                return 1.0
            }
        }
    }
}

// MARK: - Supporting Models for Realistic Climbing

struct ClimbingSeason: Codable, Hashable {
    let name: String
    let startMonth: Int
    let endMonth: Int
    let description: String
    
    static let spring = ClimbingSeason(name: "Spring", startMonth: 3, endMonth: 5, description: "Best climbing conditions with stable weather")
    static let summer = ClimbingSeason(name: "Summer", startMonth: 6, endMonth: 8, description: "Warm weather but potential storms")
    static let autumn = ClimbingSeason(name: "Autumn", startMonth: 9, endMonth: 11, description: "Clear skies and good visibility")
    static let winter = ClimbingSeason(name: "Winter", startMonth: 12, endMonth: 2, description: "Extreme conditions, experts only")
}

struct WeatherPattern: Codable, Hashable {
    let name: String
    let description: String
    let progressModifier: Double // 0.0 to 1.0
    let safetyRisk: SafetyRisk
    
    enum SafetyRisk: String, Codable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case extreme = "Extreme"
    }
    
    static let clear = WeatherPattern(name: "Clear", description: "Perfect climbing conditions", progressModifier: 1.0, safetyRisk: .low)
    static let cloudy = WeatherPattern(name: "Cloudy", description: "Reduced visibility but safe", progressModifier: 0.9, safetyRisk: .low)
    static let windy = WeatherPattern(name: "Windy", description: "Strong winds, increased difficulty", progressModifier: 0.7, safetyRisk: .moderate)
    static let storm = WeatherPattern(name: "Storm", description: "Dangerous conditions, rest required", progressModifier: 0.3, safetyRisk: .high)
    static let blizzard = WeatherPattern(name: "Blizzard", description: "Extreme conditions, no progress possible", progressModifier: 0.0, safetyRisk: .extreme)
}

struct ClimbingHazard: Codable, Hashable {
    let name: String
    let description: String
    let altitudeRange: ClosedRange<Double>
    let riskLevel: SafetyRisk
    let mitigationStrategy: String
    
    enum SafetyRisk: String, Codable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case extreme = "Extreme"
    }
    
    static let altitudeSickness = ClimbingHazard(
        name: "Altitude Sickness",
        description: "Caused by rapid ascent to high altitude",
        altitudeRange: 2500...8848,
        riskLevel: .high,
        mitigationStrategy: "Gradual ascent, acclimatization, descent if symptoms worsen"
    )
    
    static let avalanches = ClimbingHazard(
        name: "Avalanches",
        description: "Snow and ice slides on steep slopes",
        altitudeRange: 3000...8848,
        riskLevel: .extreme,
        mitigationStrategy: "Avoid steep slopes, check conditions, use safety equipment"
    )
    
    static let crevasses = ClimbingHazard(
        name: "Crevasses",
        description: "Deep cracks in glaciers",
        altitudeRange: 4000...8848,
        riskLevel: .high,
        mitigationStrategy: "Rope up, use crampons, test snow bridges"
    )
    
    static let rockfall = ClimbingHazard(
        name: "Rockfall",
        description: "Loose rocks falling from above",
        altitudeRange: 2000...8848,
        riskLevel: .moderate,
        mitigationStrategy: "Wear helmets, avoid loose rock areas, climb early morning"
    )
    
    static let frostbite = ClimbingHazard(
        name: "Frostbite",
        description: "Freezing of body tissues",
        altitudeRange: 4000...8848,
        riskLevel: .high,
        mitigationStrategy: "Keep extremities warm, dry clothing, monitor skin color"
    )
}

struct Equipment: Codable, Hashable {
    let name: String
    let category: EquipmentCategory
    let isEssential: Bool
    let durability: Int // 0-100
    let weight: Double // in kg
    let description: String
    
    enum EquipmentCategory: String, Codable {
        case clothing = "Clothing"
        case climbing = "Climbing"
        case safety = "Safety"
        case navigation = "Navigation"
        case camping = "Camping"
        case medical = "Medical"
    }
    
    static let iceAxe = Equipment(name: "Ice Axe", category: .climbing, isEssential: true, durability: 100, weight: 0.8, description: "Essential tool for ice climbing and self-arrest")
    static let crampons = Equipment(name: "Crampons", category: .climbing, isEssential: true, durability: 100, weight: 1.2, description: "Metal spikes for walking on ice and snow")
    static let helmet = Equipment(name: "Climbing Helmet", category: .safety, isEssential: true, durability: 100, weight: 0.4, description: "Protection against falling rocks and ice")
    static let oxygenBottle = Equipment(name: "Oxygen Bottle", category: .safety, isEssential: false, durability: 100, weight: 2.5, description: "Supplemental oxygen for high altitude")
    static let rope = Equipment(name: "Climbing Rope", category: .safety, isEssential: true, durability: 100, weight: 3.0, description: "Safety rope for technical sections")
    static let gps = Equipment(name: "GPS Device", category: .navigation, isEssential: false, durability: 100, weight: 0.3, description: "Navigation and emergency communication")
}

struct HistoricalClimbingData: Codable, Hashable {
    let firstAscent: Date
    let firstAscentTeam: String
    let successRate: Double // 0.0 to 1.0
    let averageDays: Int
    let totalAttempts: Int
    let totalSuccessful: Int
    let fatalities: Int
    let difficultyRating: String
    
    static let everest = HistoricalClimbingData(
        firstAscent: Date(timeIntervalSince1970: -515376000), // May 29, 1953
        firstAscentTeam: "Edmund Hillary and Tenzing Norgay",
        successRate: 0.33,
        averageDays: 40,
        totalAttempts: 10000,
        totalSuccessful: 3300,
        fatalities: 300,
        difficultyRating: "Extreme - World's highest peak"
    )
    
    static let kilimanjaro = HistoricalClimbingData(
        firstAscent: Date(timeIntervalSince1970: -2209248000), // October 6, 1889
        firstAscentTeam: "Hans Meyer and Ludwig Purtscheller",
        successRate: 0.85,
        averageDays: 7,
        totalAttempts: 50000,
        totalSuccessful: 42500,
        fatalities: 10,
        difficultyRating: "Intermediate - High altitude but non-technical"
    )
    
    static let fuji = HistoricalClimbingData(
        firstAscent: Date(timeIntervalSince1970: -2209248000), // Ancient times
        firstAscentTeam: "Unknown - Climbed for centuries",
        successRate: 0.95,
        averageDays: 1,
        totalAttempts: 300000,
        totalSuccessful: 285000,
        fatalities: 5,
        difficultyRating: "Beginner - Well-maintained trails"
    )
}

// MARK: - Predefined Mountains
extension Mountain {
    static let kilimanjaro = Mountain(
        name: "Mount Kilimanjaro",
        height: 5895,
        location: "Tanzania, Africa",
        difficulty: .intermediate,
        description: "The highest peak in Africa and the highest free-standing mountain in the world. A non-technical climb but requires excellent fitness and acclimatization.",
        imageName: "kilimanjaro",
        isPaywalled: false,
        camps: [
            Camp(name: "Base Camp", altitude: 1828, stepsRequired: 0, elevationRequired: 0, description: "Starting point of your Kilimanjaro expedition", unlockedMessage: "Welcome to Mount Kilimanjaro!", isBaseCamp: true, isSummit: false),
            Camp(name: "Camp 1 - Mandara", altitude: 2700, stepsRequired: 25000, elevationRequired: 500, description: "First camp through the rainforest", unlockedMessage: "You've reached the rainforest zone!", isBaseCamp: false, isSummit: false),
            Camp(name: "Camp 2 - Horombo", altitude: 3720, stepsRequired: 75000, elevationRequired: 1200, description: "High altitude moorland camp", unlockedMessage: "Entering the moorland zone!", isBaseCamp: false, isSummit: false),
            Camp(name: "Camp 3 - Kibo", altitude: 4700, stepsRequired: 150000, elevationRequired: 2000, description: "Base camp for summit attempt", unlockedMessage: "Final camp before the summit!", isBaseCamp: false, isSummit: false),
            Camp(name: "Uhuru Peak", altitude: 5895, stepsRequired: 283752, elevationRequired: 4067, description: "The summit of Mount Kilimanjaro", unlockedMessage: "Congratulations! You've conquered Kilimanjaro!", isBaseCamp: false, isSummit: true)
        ],
        baseSteps: 283752,
        baseElevation: 4067,
        baseElevationStart: 1828,
        totalElevationGain: 4067,
        difficultyMultiplier: 8.0,
        estimatedDays: 7,
        climbingSeason: .spring,
        weatherPatterns: [.clear, .cloudy, .windy],
        hazards: [.altitudeSickness, .frostbite],
        equipmentRequirements: [.helmet, .rope],
        historicalData: .kilimanjaro
    )
    
    static let everest = Mountain(
        name: "Mount Everest",
        height: 8848,
        location: "Nepal/Tibet, Asia",
        difficulty: .expert,
        description: "The world's highest peak and ultimate mountaineering challenge. Requires extreme fitness, technical skills, and months of preparation.",
        imageName: "everest",
        isPaywalled: true,
        camps: [
            Camp(name: "Base Camp", altitude: 5364, stepsRequired: 0, elevationRequired: 0, description: "Everest Base Camp - the starting point", unlockedMessage: "Welcome to the roof of the world!", isBaseCamp: true, isSummit: false),
            Camp(name: "Camp 1", altitude: 6065, stepsRequired: 500000, elevationRequired: 800, description: "First high camp on the mountain", unlockedMessage: "You've reached Camp 1!", isBaseCamp: false, isSummit: false),
            Camp(name: "Camp 2", altitude: 6400, stepsRequired: 1000000, elevationRequired: 1500, description: "Advanced base camp", unlockedMessage: "Camp 2 achieved!", isBaseCamp: false, isSummit: false),
            Camp(name: "Camp 3", altitude: 7200, stepsRequired: 1800000, elevationRequired: 2500, description: "High altitude camp", unlockedMessage: "Camp 3 reached!", isBaseCamp: false, isSummit: false),
            Camp(name: "Camp 4", altitude: 8000, stepsRequired: 2800000, elevationRequired: 3500, description: "South Col - final camp", unlockedMessage: "The death zone awaits!", isBaseCamp: false, isSummit: false),
            Camp(name: "Summit", altitude: 8848, stepsRequired: 3399000, elevationRequired: 3484, description: "The summit of Mount Everest", unlockedMessage: "You've conquered the world's highest peak!", isBaseCamp: false, isSummit: true)
        ],
        baseSteps: 3399000,
        baseElevation: 3484,
        baseElevationStart: 5364,
        totalElevationGain: 3484,
        difficultyMultiplier: 25.0,
        estimatedDays: 35,
        climbingSeason: .spring,
        weatherPatterns: [.clear, .cloudy, .windy, .storm, .blizzard],
        hazards: [.altitudeSickness, .avalanches, .crevasses, .frostbite],
        equipmentRequirements: [.iceAxe, .crampons, .helmet, .oxygenBottle, .rope, .gps],
        historicalData: .everest
    )
    
    static let elCapitan = Mountain(
        name: "El Capitan",
        height: 2121,
        location: "Yosemite, USA",
        difficulty: .expert,
        description: "The legendary granite monolith in Yosemite Valley. Requires advanced rock climbing skills and multi-day commitment.",
        imageName: "elcapitan",
        isPaywalled: true,
        camps: [
            Camp(name: "Base", altitude: 1207, stepsRequired: 0, elevationRequired: 0, description: "Base of El Capitan", unlockedMessage: "Welcome to El Capitan!", isBaseCamp: true, isSummit: false),
            Camp(name: "Pitch 10", altitude: 1400, stepsRequired: 15000, elevationRequired: 200, description: "First major pitch", unlockedMessage: "You're on the wall!", isBaseCamp: false, isSummit: false),
            Camp(name: "Pitch 20", altitude: 1600, stepsRequired: 30000, elevationRequired: 400, description: "Halfway up the wall", unlockedMessage: "Halfway there!", isBaseCamp: false, isSummit: false),
            Camp(name: "Pitch 30", altitude: 1800, stepsRequired: 50000, elevationRequired: 600, description: "Near the top", unlockedMessage: "Almost at the summit!", isBaseCamp: false, isSummit: false),
            Camp(name: "Summit", altitude: 2121, stepsRequired: 66840, elevationRequired: 914, description: "Top of El Capitan", unlockedMessage: "You've conquered El Capitan!", isBaseCamp: false, isSummit: true)
        ],
        baseSteps: 66840,
        baseElevation: 914,
        baseElevationStart: 1207,
        totalElevationGain: 914,
        difficultyMultiplier: 15.0,
        estimatedDays: 4,
        climbingSeason: .summer,
        weatherPatterns: [.clear, .cloudy, .windy],
        hazards: [.rockfall],
        equipmentRequirements: [.rope, .helmet],
        historicalData: HistoricalClimbingData(
            firstAscent: Date(timeIntervalSince1970: -946684800), // November 12, 1958
            firstAscentTeam: "Warren Harding, Wayne Merry, and George Whitmore",
            successRate: 0.60,
            averageDays: 4,
            totalAttempts: 5000,
            totalSuccessful: 3000,
            fatalities: 20,
            difficultyRating: "Expert - Technical rock climbing"
        )
    )
    
    static let fuji = Mountain(
        name: "Mount Fuji",
        height: 3776,
        location: "Japan, Asia",
        difficulty: .beginner,
        description: "Japan's most iconic mountain and a sacred symbol. A popular day hike with well-maintained trails.",
        imageName: "fuji",
        isPaywalled: false,
        camps: [
            Camp(name: "Base Camp", altitude: 2305, stepsRequired: 0, elevationRequired: 0, description: "Starting point of your Fuji expedition", unlockedMessage: "Welcome to Mount Fuji!", isBaseCamp: true, isSummit: false),
            Camp(name: "Station 5", altitude: 2390, stepsRequired: 2000, elevationRequired: 200, description: "First station on the mountain", unlockedMessage: "You've reached Station 5!", isBaseCamp: false, isSummit: false),
            Camp(name: "Station 8", altitude: 3100, stepsRequired: 6000, elevationRequired: 500, description: "High altitude station", unlockedMessage: "Station 8 reached!", isBaseCamp: false, isSummit: false),
            Camp(name: "Summit", altitude: 3776, stepsRequired: 9413, elevationRequired: 1471, description: "The summit of Mount Fuji", unlockedMessage: "You've conquered Mount Fuji!", isBaseCamp: false, isSummit: true)
        ],
        baseSteps: 9413,
        baseElevation: 1471,
        baseElevationStart: 2305,
        totalElevationGain: 1471,
        difficultyMultiplier: 3.0,
        estimatedDays: 1,
        climbingSeason: .summer,
        weatherPatterns: [.clear, .cloudy],
        hazards: [],
        equipmentRequirements: [],
        historicalData: .fuji
    )
    
    static let rainier = Mountain(
        name: "Mount Rainier",
        height: 4392,
        location: "Washington, USA",
        difficulty: .intermediate,
        description: "The most glaciated peak in the contiguous United States. Requires glacier travel skills and crevasse rescue knowledge.",
        imageName: "rainier",
        isPaywalled: false,
        camps: [
            Camp(name: "Base Camp", altitude: 1500, stepsRequired: 0, elevationRequired: 0, description: "Starting point of your Rainier expedition", unlockedMessage: "Welcome to Mount Rainier!", isBaseCamp: true, isSummit: false),
            Camp(name: "Camp Muir", altitude: 3000, stepsRequired: 40000, elevationRequired: 400, description: "High camp on the mountain", unlockedMessage: "You've reached Camp Muir!", isBaseCamp: false, isSummit: false),
            Camp(name: "Summit", altitude: 4392, stepsRequired: 125112, elevationRequired: 2892, description: "The summit of Mount Rainier", unlockedMessage: "You've conquered Mount Rainier!", isBaseCamp: false, isSummit: true)
        ],
        baseSteps: 125112,
        baseElevation: 2892,
        baseElevationStart: 1500,
        totalElevationGain: 2892,
        difficultyMultiplier: 12.0,
        estimatedDays: 3,
        climbingSeason: .summer,
        weatherPatterns: [.clear, .cloudy, .windy, .storm],
        hazards: [.crevasses, .avalanches, .altitudeSickness],
        equipmentRequirements: [.iceAxe, .crampons, .helmet, .rope],
        historicalData: HistoricalClimbingData(
            firstAscent: Date(timeIntervalSince1970: -2209248000), // August 17, 1870
            firstAscentTeam: "Hazard Stevens and P. B. Van Trump",
            successRate: 0.50,
            averageDays: 3,
            totalAttempts: 10000,
            totalSuccessful: 5000,
            fatalities: 50,
            difficultyRating: "Intermediate - Glacier travel required"
        )
    )
    
    static let blanc = Mountain(
        name: "Mont Blanc",
        height: 4808,
        location: "France/Italy, Europe",
        difficulty: .advanced,
        description: "The highest peak in the Alps and Western Europe. Requires alpine climbing skills and experience with high altitude.",
        imageName: "blanc",
        isPaywalled: true,
        camps: [
            Camp(name: "Base Camp", altitude: 1000, stepsRequired: 0, elevationRequired: 0, description: "Starting point of your Mont Blanc expedition", unlockedMessage: "Welcome to Mont Blanc!", isBaseCamp: true, isSummit: false),
            Camp(name: "Refuge du Goûter", altitude: 3000, stepsRequired: 80000, elevationRequired: 500, description: "High altitude refuge", unlockedMessage: "You've reached Refuge du Goûter!", isBaseCamp: false, isSummit: false),
            Camp(name: "Summit", altitude: 4808, stepsRequired: 200000, elevationRequired: 3808, description: "The summit of Mont Blanc", unlockedMessage: "You've conquered Mont Blanc!", isBaseCamp: false, isSummit: true)
        ],
        baseSteps: 200000,
        baseElevation: 3808,
        baseElevationStart: 1000,
        totalElevationGain: 3808,
        difficultyMultiplier: 15.0,
        estimatedDays: 5,
        climbingSeason: .summer,
        weatherPatterns: [.clear, .cloudy, .windy, .storm],
        hazards: [.altitudeSickness, .avalanches, .rockfall],
        equipmentRequirements: [.iceAxe, .crampons, .helmet, .rope],
        historicalData: HistoricalClimbingData(
            firstAscent: Date(timeIntervalSince1970: -2209248000), // August 8, 1786
            firstAscentTeam: "Jacques Balmat and Michel Paccard",
            successRate: 0.70,
            averageDays: 5,
            totalAttempts: 20000,
            totalSuccessful: 14000,
            fatalities: 100,
            difficultyRating: "Advanced - Alpine climbing required"
        )
    )
    
    static let allMountains: [Mountain] = [.kilimanjaro, .fuji, .rainier, .everest, .blanc, .elCapitan]
}
