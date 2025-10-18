import Foundation
import Combine
import SwiftUI

// MARK: - Streak Manager
class StreakManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var dailyStepTarget: Int = 5000
    @Published var todaySteps: Int = 0
    @Published var streakHistory: [StreakDay] = []
    @Published var isStreakActive: Bool = false
    @Published var streakMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let streakKey = "streak_data"
    private let targetKey = "daily_step_target"
    
    // MARK: - Initialization
    
    init() {
        loadStreakData()
        loadStepTarget()
        updateStreakMessage()
    }
    
    // MARK: - Public Methods
    
    func updateStreak(with steps: Int) {
        todaySteps = steps
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if we already processed today
        if let lastUpdate = userDefaults.object(forKey: "last_streak_update") as? Date,
           calendar.isDate(lastUpdate, inSameDayAs: today) {
            return
        }
        
        // Update streak based on today's steps
        if steps >= dailyStepTarget {
            if isStreakActive {
                // Continue existing streak
                currentStreak += 1
            } else {
                // Start new streak
                currentStreak = 1
                isStreakActive = true
            }
            
            // Add to streak history
            let streakDay = StreakDay(
                date: today,
                steps: steps,
                target: dailyStepTarget,
                isStreakDay: true,
                fireLevel: getStreakFireLevel()
            )
            streakHistory.append(streakDay)
            
        } else {
            // Streak broken
            if isStreakActive {
                currentStreak = 0
                isStreakActive = false
            }
            
            // Add to streak history
            let streakDay = StreakDay(
                date: today,
                steps: steps,
                target: dailyStepTarget,
                isStreakDay: false,
                fireLevel: 0
            )
            streakHistory.append(streakDay)
        }
        
        // Save data
        saveStreakData()
        userDefaults.set(today, forKey: "last_streak_update")
        updateStreakMessage()
    }
    
    func setDailyStepTarget(_ target: Int) {
        dailyStepTarget = max(1000, min(50000, target)) // Reasonable bounds
        userDefaults.set(dailyStepTarget, forKey: targetKey)
        updateStreakMessage()
    }
    
    func getStreakFireLevel() -> Int {
        return min(currentStreak, 10) // Cap at 10 for UI purposes
    }
    
    func getStreakFireEmoji() -> String {
        let level = getStreakFireLevel()
        return StreakFireLevel(rawValue: level)?.fireEmoji ?? ""
    }
    
    func getStreakProgress() -> Double {
        guard dailyStepTarget > 0 else { return 0.0 }
        return min(1.0, Double(todaySteps) / Double(dailyStepTarget))
    }
    
    func getStepsRemaining() -> Int {
        return max(0, dailyStepTarget - todaySteps)
    }
    
    func getStreakMotivationMessage() -> String {
        if isStreakActive {
            switch currentStreak {
            case 1:
                return "Great start! Keep it up! 🔥"
            case 2:
                return "Two days strong! You're on fire! 🔥🔥"
            case 3:
                return "Three days in a row! Amazing! 🔥🔥🔥"
            case 4...6:
                return "\(currentStreak) days streak! You're unstoppable! \(getStreakFireEmoji())"
            case 7...13:
                return "\(currentStreak) days streak! You're a streak master! \(getStreakFireEmoji())"
            case 14...29:
                return "\(currentStreak) days streak! Incredible dedication! \(getStreakFireEmoji())"
            case 30...99:
                return "\(currentStreak) days streak! You're a legend! \(getStreakFireEmoji())"
            default:
                return "\(currentStreak) days streak! You're absolutely incredible! \(getStreakFireEmoji())"
            }
        } else {
            let progress = getStreakProgress()
            if progress >= 0.8 {
                return "So close! Just \(getStepsRemaining()) more steps to start your streak!"
            } else if progress >= 0.5 {
                return "You're halfway there! Keep going!"
            } else if progress >= 0.2 {
                return "Every step counts! You've got this!"
            } else {
                return "Ready to start your streak? Let's get moving!"
            }
        }
    }
    
    func resetStreak() {
        currentStreak = 0
        isStreakActive = false
        saveStreakData()
        updateStreakMessage()
    }
    
    func getStreakStatistics() -> StreakStatistics {
        let totalDays = streakHistory.count
        let streakDays = streakHistory.filter { $0.isStreakDay }.count
        let longestStreak = streakHistory.reduce(0) { max($0, $1.fireLevel) }
        let averageSteps = streakHistory.isEmpty ? 0 : streakHistory.map { $0.steps }.reduce(0, +) / streakHistory.count
        
        return StreakStatistics(
            totalDays: totalDays,
            streakDays: streakDays,
            longestStreak: longestStreak,
            averageSteps: averageSteps,
            currentStreak: currentStreak
        )
    }
    
    // MARK: - Private Methods
    
    private func updateStreakMessage() {
        streakMessage = getStreakMotivationMessage()
    }
    
    private func saveStreakData() {
        let data = StreakData(
            currentStreak: currentStreak,
            isStreakActive: isStreakActive,
            streakHistory: streakHistory
        )
        
        do {
            let encoded = try JSONEncoder().encode(data)
            userDefaults.set(encoded, forKey: streakKey)
        } catch {
            print("Failed to save streak data: \(error)")
        }
    }
    
    private func loadStreakData() {
        guard let data = userDefaults.data(forKey: streakKey) else { return }
        
        do {
            let streakData = try JSONDecoder().decode(StreakData.self, from: data)
            currentStreak = streakData.currentStreak
            isStreakActive = streakData.isStreakActive
            streakHistory = streakData.streakHistory
        } catch {
            print("Failed to load streak data: \(error)")
        }
    }
    
    private func loadStepTarget() {
        dailyStepTarget = userDefaults.integer(forKey: targetKey)
        if dailyStepTarget == 0 {
            dailyStepTarget = 5000 // Default value
        }
    }
}

// MARK: - Streak Data Models

struct StreakDay: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let steps: Int
    let target: Int
    let isStreakDay: Bool
    let fireLevel: Int
    
    var progress: Double {
        guard target > 0 else { return 0.0 }
        return min(1.0, Double(steps) / Double(target))
    }
    
    var isTargetMet: Bool {
        return steps >= target
    }
}

struct StreakData: Codable {
    let currentStreak: Int
    let isStreakActive: Bool
    let streakHistory: [StreakDay]
}

struct StreakStatistics {
    let totalDays: Int
    let streakDays: Int
    let longestStreak: Int
    let averageSteps: Int
    let currentStreak: Int
    
    var streakPercentage: Double {
        guard totalDays > 0 else { return 0.0 }
        return Double(streakDays) / Double(totalDays)
    }
}

// MARK: - Streak Fire Level

enum StreakFireLevel: Int, CaseIterable {
    case none = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    
    var fireEmoji: String {
        switch self {
        case .none: return ""
        case .one: return "🔥"
        case .two: return "🔥🔥"
        case .three: return "🔥🔥🔥"
        case .four: return "🔥🔥🔥🔥"
        case .five: return "🔥🔥🔥🔥🔥"
        case .six: return "🔥🔥🔥🔥🔥🔥"
        case .seven: return "🔥🔥🔥🔥🔥🔥🔥"
        case .eight: return "🔥🔥🔥🔥🔥🔥🔥🔥"
        case .nine: return "🔥🔥🔥🔥🔥🔥🔥🔥🔥"
        case .ten: return "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
        }
    }
    
    var color: Color {
        switch self {
        case .none: return .gray
        case .one: return .orange
        case .two: return .red
        case .three: return .red
        case .four: return .red
        case .five: return .red
        case .six: return .red
        case .seven: return .red
        case .eight: return .red
        case .nine: return .red
        case .ten: return .red
        }
    }
    
    var description: String {
        switch self {
        case .none: return "No streak"
        case .one: return "1 day streak"
        case .two: return "2 day streak"
        case .three: return "3 day streak"
        case .four: return "4 day streak"
        case .five: return "5 day streak"
        case .six: return "6 day streak"
        case .seven: return "7 day streak"
        case .eight: return "8 day streak"
        case .nine: return "9 day streak"
        case .ten: return "10+ day streak"
        }
    }
}
