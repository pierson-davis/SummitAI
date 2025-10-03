import Foundation
import Combine
import SwiftUI

class AICoachManager: ObservableObject {
    @Published var trainingPlans: [TrainingPlan] = []
    @Published var currentPlan: TrainingPlan?
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTrainingPlans()
    }
    
    // MARK: - Training Plan Management
    
    func generatePersonalizedPlan(for user: User, goals: [FitnessGoal], duration: PlanDuration) {
        let plan = createPersonalizedPlan(for: user, goals: goals, duration: duration)
        trainingPlans.append(plan)
        currentPlan = plan
        saveTrainingPlans()
    }
    
    private func createPersonalizedPlan(for user: User, goals: [FitnessGoal], duration: PlanDuration) -> TrainingPlan {
        let weeks = duration.weeks
        var workouts: [Workout] = []
        
        for week in 1...weeks {
            let weekWorkouts = generateWeekWorkouts(for: week, totalWeeks: weeks, goals: goals, userLevel: getUserLevel(user))
            workouts.append(contentsOf: weekWorkouts)
        }
        
        return TrainingPlan(
            name: "Personalized \(duration.rawValue) Plan",
            description: "Custom training plan based on your goals and current fitness level",
            duration: duration,
            goals: goals,
            workouts: workouts,
            difficulty: getUserLevel(user)
        )
    }
    
    private func generateWeekWorkouts(for week: Int, totalWeeks: Int, goals: [FitnessGoal], userLevel: DifficultyLevel) -> [Workout] {
        var workouts: [Workout] = []
        
        // Base workouts per week
        let workoutsPerWeek = 4
        let progressMultiplier = Double(week) / Double(totalWeeks)
        
        for day in 1...workoutsPerWeek {
            let workout = createWorkout(
                day: day,
                week: week,
                progressMultiplier: progressMultiplier,
                goals: goals,
                difficulty: userLevel
            )
            workouts.append(workout)
        }
        
        return workouts
    }
    
    private func createWorkout(day: Int, week: Int, progressMultiplier: Double, goals: [FitnessGoal], difficulty: DifficultyLevel) -> Workout {
        let baseDuration = 30.0 + (progressMultiplier * 20.0) // 30-50 minutes
        let intensity = calculateIntensity(for: week, totalWeeks: 12, difficulty: difficulty)
        
        var exercises: [Exercise] = []
        
        // Generate exercises based on goals
        if goals.contains(.endurance) {
            exercises.append(contentsOf: generateEnduranceExercises(duration: baseDuration, intensity: intensity))
        }
        if goals.contains(.strength) {
            exercises.append(contentsOf: generateStrengthExercises(duration: baseDuration * 0.6, intensity: intensity))
        }
        if goals.contains(.climbing) {
            exercises.append(contentsOf: generateClimbingExercises(duration: baseDuration * 0.8, intensity: intensity))
        }
        
        return Workout(
            name: "Day \(day) - Week \(week)",
            description: "Progressive training session",
            duration: baseDuration,
            difficulty: difficulty,
            exercises: exercises,
            restDays: calculateRestDays(week: week),
            notes: generateWorkoutNotes(week: week, intensity: intensity)
        )
    }
    
    private func generateEnduranceExercises(duration: Double, intensity: WorkoutIntensity) -> [Exercise] {
        return [
            Exercise(
                name: "Cardio Base",
                description: "Steady-state cardiovascular exercise",
                duration: duration * 0.6,
                sets: 1,
                reps: nil,
                restTime: 0,
                intensity: intensity,
                type: .cardio
            ),
            Exercise(
                name: "Interval Training",
                description: "High-intensity interval training",
                duration: duration * 0.4,
                sets: 4,
                reps: nil,
                restTime: 60,
                intensity: .high,
                type: .interval
            )
        ]
    }
    
    private func generateStrengthExercises(duration: Double, intensity: WorkoutIntensity) -> [Exercise] {
        return [
            Exercise(
                name: "Push-ups",
                description: "Upper body strength exercise",
                duration: 0,
                sets: 3,
                reps: 10,
                restTime: 60,
                intensity: intensity,
                type: .strength
            ),
            Exercise(
                name: "Squats",
                description: "Lower body strength exercise",
                duration: 0,
                sets: 3,
                reps: 15,
                restTime: 60,
                intensity: intensity,
                type: .strength
            ),
            Exercise(
                name: "Plank",
                description: "Core strength exercise",
                duration: 60,
                sets: 3,
                reps: nil,
                restTime: 60,
                intensity: intensity,
                type: .strength
            )
        ]
    }
    
    private func generateClimbingExercises(duration: Double, intensity: WorkoutIntensity) -> [Exercise] {
        return [
            Exercise(
                name: "Hang Board Training",
                description: "Finger and grip strength",
                duration: duration * 0.3,
                sets: 5,
                reps: 10,
                restTime: 120,
                intensity: intensity,
                type: .climbing
            ),
            Exercise(
                name: "Core for Climbing",
                description: "Climbing-specific core exercises",
                duration: duration * 0.4,
                sets: 4,
                reps: 12,
                restTime: 90,
                intensity: intensity,
                type: .climbing
            ),
            Exercise(
                name: "Technique Practice",
                description: "Climbing technique and movement",
                duration: duration * 0.3,
                sets: 1,
                reps: nil,
                restTime: 0,
                intensity: .moderate,
                type: .climbing
            )
        ]
    }
    
    private func calculateIntensity(for week: Int, totalWeeks: Int, difficulty: DifficultyLevel) -> WorkoutIntensity {
        let baseIntensity: WorkoutIntensity
        
        switch difficulty {
        case .beginner:
            baseIntensity = .low
        case .intermediate:
            baseIntensity = .moderate
        case .advanced:
            baseIntensity = .high
        case .expert:
            baseIntensity = .high
        }
        
        // Progress intensity throughout the plan
        let progressFactor = Double(week) / Double(totalWeeks)
        
        if progressFactor < 0.3 {
            return baseIntensity
        } else if progressFactor < 0.7 {
            return baseIntensity == .low ? .moderate : .high
        } else {
            return .high
        }
    }
    
    private func calculateRestDays(week: Int) -> Int {
        // More rest in early weeks, less in later weeks
        return week <= 4 ? 2 : 1
    }
    
    private func generateWorkoutNotes(week: Int, intensity: WorkoutIntensity) -> [String] {
        var notes: [String] = []
        
        if week <= 2 {
            notes.append("Focus on proper form over intensity")
            notes.append("Listen to your body and rest when needed")
        } else if week <= 6 {
            notes.append("Gradually increase intensity")
            notes.append("Maintain consistent workout schedule")
        } else {
            notes.append("Push your limits while maintaining safety")
            notes.append("Consider adding extra challenges")
        }
        
        switch intensity {
        case .low:
            notes.append("Low intensity - focus on technique")
        case .moderate:
            notes.append("Moderate intensity - good balance of effort and recovery")
        case .high:
            notes.append("High intensity - ensure adequate recovery")
        }
        
        return notes
    }
    
    private func getUserLevel(_ user: User) -> DifficultyLevel {
        let totalSteps = user.totalSteps
        let completedExpeditions = user.completedExpeditions.count
        
        if totalSteps < 50000 && completedExpeditions == 0 {
            return .beginner
        } else if totalSteps < 200000 && completedExpeditions < 3 {
            return .intermediate
        } else if totalSteps < 500000 && completedExpeditions < 10 {
            return .advanced
        } else {
            return .expert
        }
    }
    
    // MARK: - Storage Methods
    
    private func saveTrainingPlans() {
        // In a real app, this would save to persistent storage
        // For now, we'll keep it in memory
    }
    
    private func loadTrainingPlans() {
        // Load any saved training plans
        // For now, we'll start with an empty array
    }
}

// MARK: - Supporting Models

struct TrainingPlan: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let duration: PlanDuration
    let goals: [FitnessGoal]
    let workouts: [Workout]
    let difficulty: DifficultyLevel
    let createdDate: Date
    var isCompleted: Bool = false
    var currentWeek: Int = 1
    
    init(name: String, description: String, duration: PlanDuration, goals: [FitnessGoal], workouts: [Workout], difficulty: DifficultyLevel) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.duration = duration
        self.goals = goals
        self.workouts = workouts
        self.difficulty = difficulty
        self.createdDate = Date()
        self.isCompleted = false
        self.currentWeek = 1
    }
}

struct Workout: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let duration: Double // in minutes
    let difficulty: DifficultyLevel
    let exercises: [Exercise]
    let restDays: Int
    let notes: [String]
    var isCompleted: Bool = false
    var completedDate: Date?
    
    init(name: String, description: String, duration: Double, difficulty: DifficultyLevel, exercises: [Exercise], restDays: Int, notes: [String] = []) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.duration = duration
        self.difficulty = difficulty
        self.exercises = exercises
        self.restDays = restDays
        self.notes = notes
        self.isCompleted = false
        self.completedDate = nil
    }
}

struct Exercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let duration: Double // in seconds
    let sets: Int
    let reps: Int?
    let restTime: Double // in seconds
    let intensity: WorkoutIntensity
    let type: ExerciseType
    var isCompleted: Bool = false
    
    init(name: String, description: String, duration: Double, sets: Int, reps: Int? = nil, restTime: Double, intensity: WorkoutIntensity, type: ExerciseType) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.duration = duration
        self.sets = sets
        self.reps = reps
        self.restTime = restTime
        self.intensity = intensity
        self.type = type
        self.isCompleted = false
    }
}

enum PlanDuration: String, CaseIterable, Codable {
    case fourWeeks = "4 Weeks"
    case eightWeeks = "8 Weeks"
    case twelveWeeks = "12 Weeks"
    case sixteenWeeks = "16 Weeks"
    
    var weeks: Int {
        switch self {
        case .fourWeeks:
            return 4
        case .eightWeeks:
            return 8
        case .twelveWeeks:
            return 12
        case .sixteenWeeks:
            return 16
        }
    }
}

enum FitnessGoal: String, CaseIterable, Codable {
    case endurance = "Endurance"
    case strength = "Strength"
    case climbing = "Climbing"
    case weightLoss = "Weight Loss"
    case generalFitness = "General Fitness"
}

enum DifficultyLevel: String, CaseIterable, Codable {
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
}

enum WorkoutIntensity: String, CaseIterable, Codable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .moderate:
            return .yellow
        case .high:
            return .red
        }
    }
}

enum ExerciseType: String, CaseIterable, Codable {
    case cardio = "Cardio"
    case strength = "Strength"
    case climbing = "Climbing"
    case interval = "Interval"
    case flexibility = "Flexibility"
    case balance = "Balance"
}
