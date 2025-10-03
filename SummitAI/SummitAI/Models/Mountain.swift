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
    let isPremium: Bool
    let camps: [Camp]
    let baseSteps: Int // Base number of steps to complete
    let baseElevation: Double // Base elevation gain
    
    init(name: String, height: Double, location: String, difficulty: MountainDifficulty, description: String, imageName: String, isPremium: Bool, camps: [Camp], baseSteps: Int, baseElevation: Double) {
        self.id = UUID()
        self.name = name
        self.height = height
        self.location = location
        self.difficulty = difficulty
        self.description = description
        self.imageName = imageName
        self.isPremium = isPremium
        self.camps = camps
        self.baseSteps = baseSteps
        self.baseElevation = baseElevation
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

// MARK: - Predefined Mountains
extension Mountain {
    static let kilimanjaro = Mountain(
        name: "Mount Kilimanjaro",
        height: 5895,
        location: "Tanzania, Africa",
        difficulty: .intermediate,
        description: "The highest peak in Africa and the highest free-standing mountain in the world.",
        imageName: "kilimanjaro",
        isPremium: false,
        camps: [
            Camp(name: "Base Camp", altitude: 1828, stepsRequired: 0, elevationRequired: 0, description: "Starting point of your Kilimanjaro expedition", unlockedMessage: "Welcome to Mount Kilimanjaro!", isBaseCamp: true, isSummit: false),
            Camp(name: "Camp 1 - Mandara", altitude: 2700, stepsRequired: 15000, elevationRequired: 500, description: "First camp through the rainforest", unlockedMessage: "You've reached the rainforest zone!", isBaseCamp: false, isSummit: false),
            Camp(name: "Camp 2 - Horombo", altitude: 3720, stepsRequired: 35000, elevationRequired: 1200, description: "High altitude moorland camp", unlockedMessage: "Entering the moorland zone!", isBaseCamp: false, isSummit: false),
            Camp(name: "Camp 3 - Kibo", altitude: 4700, stepsRequired: 60000, elevationRequired: 2000, description: "Base camp for summit attempt", unlockedMessage: "Final camp before the summit!", isBaseCamp: false, isSummit: false),
            Camp(name: "Uhuru Peak", altitude: 5895, stepsRequired: 100000, elevationRequired: 3000, description: "The summit of Mount Kilimanjaro", unlockedMessage: "Congratulations! You've conquered Kilimanjaro!", isBaseCamp: false, isSummit: true)
        ],
        baseSteps: 100000,
        baseElevation: 3000
    )
    
    static let everest = Mountain(
        name: "Mount Everest",
        height: 8848,
        location: "Nepal/Tibet, Asia",
        difficulty: .expert,
        description: "The world's highest peak and ultimate mountaineering challenge.",
        imageName: "everest",
        isPremium: true,
        camps: [
            Camp(name: "Base Camp", altitude: 5364, stepsRequired: 0, elevationRequired: 0, description: "Everest Base Camp - the starting point", unlockedMessage: "Welcome to the roof of the world!", isBaseCamp: true, isSummit: false),
            Camp(name: "Camp 1", altitude: 6065, stepsRequired: 25000, elevationRequired: 800, description: "First high camp on the mountain", unlockedMessage: "You've reached Camp 1!", isBaseCamp: false, isSummit: false),
            Camp(name: "Camp 2", altitude: 6400, stepsRequired: 50000, elevationRequired: 1500, description: "Advanced base camp", unlockedMessage: "Camp 2 achieved!", isBaseCamp: false, isSummit: false),
            Camp(name: "Camp 3", altitude: 7200, stepsRequired: 75000, elevationRequired: 2500, description: "High altitude camp", unlockedMessage: "Camp 3 reached!", isBaseCamp: false, isSummit: false),
            Camp(name: "Camp 4", altitude: 8000, stepsRequired: 100000, elevationRequired: 3500, description: "South Col - final camp", unlockedMessage: "The death zone awaits!", isBaseCamp: false, isSummit: false),
            Camp(name: "Summit", altitude: 8848, stepsRequired: 150000, elevationRequired: 4500, description: "The summit of Mount Everest", unlockedMessage: "You've conquered the world's highest peak!", isBaseCamp: false, isSummit: true)
        ],
        baseSteps: 150000,
        baseElevation: 4500
    )
    
    static let elCapitan = Mountain(
        name: "El Capitan",
        height: 914,
        location: "Yosemite, USA",
        difficulty: .expert,
        description: "The legendary granite monolith in Yosemite Valley.",
        imageName: "elcapitan",
        isPremium: true,
        camps: [
            Camp(name: "Base", altitude: 1207, stepsRequired: 0, elevationRequired: 0, description: "Base of El Capitan", unlockedMessage: "Welcome to El Capitan!", isBaseCamp: true, isSummit: false),
            Camp(name: "Pitch 10", altitude: 1400, stepsRequired: 20000, elevationRequired: 200, description: "First major pitch", unlockedMessage: "You're on the wall!", isBaseCamp: false, isSummit: false),
            Camp(name: "Pitch 20", altitude: 1600, stepsRequired: 40000, elevationRequired: 400, description: "Halfway up the wall", unlockedMessage: "Halfway there!", isBaseCamp: false, isSummit: false),
            Camp(name: "Pitch 30", altitude: 1800, stepsRequired: 60000, elevationRequired: 600, description: "Near the top", unlockedMessage: "Almost at the summit!", isBaseCamp: false, isSummit: false),
            Camp(name: "Summit", altitude: 2121, stepsRequired: 80000, elevationRequired: 914, description: "Top of El Capitan", unlockedMessage: "You've conquered El Capitan!", isBaseCamp: false, isSummit: true)
        ],
        baseSteps: 80000,
        baseElevation: 914
    )
    
    static let allMountains: [Mountain] = [.kilimanjaro, .everest, .elCapitan]
}
