import Foundation
import Combine
import SwiftUI

class AICoachManager: ObservableObject {
    @Published var trainingPlans: [TrainingPlan] = []
    @Published var currentPlan: TrainingPlan?
    @Published var errorMessage: String?
    
    // Advanced AI features
    @Published var personalizedRecommendations: [AIRecommendation] = []
    @Published var motivationalMessages: [MotivationalMessage] = []
    @Published var generatedContent: [GeneratedContent] = []
    @Published var fitnessInsights: [FitnessInsight] = []
    @Published var adaptiveGoals: [AdaptiveGoal] = []
    
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
    
    private func generateEnduranceExercises(duration: Double, intensity: AIWorkoutIntensity) -> [Exercise] {
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
    
    private func generateStrengthExercises(duration: Double, intensity: AIWorkoutIntensity) -> [Exercise] {
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
    
    private func generateClimbingExercises(duration: Double, intensity: AIWorkoutIntensity) -> [Exercise] {
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
    
    private func calculateIntensity(for week: Int, totalWeeks: Int, difficulty: DifficultyLevel) -> AIWorkoutIntensity {
        let baseIntensity: AIWorkoutIntensity
        
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
    
    private func generateWorkoutNotes(week: Int, intensity: AIWorkoutIntensity) -> [String] {
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
    
    // MARK: - Advanced AI Features
    
    func generatePersonalizedRecommendations(for user: User, healthData: HealthKitManager) {
        var recommendations: [AIRecommendation] = []
        
        // Analyze user's fitness level and generate recommendations
        let fitnessLevel = getUserLevel(user)
        let recentActivity = analyzeRecentActivity(healthData: healthData)
        
        // Step-based recommendations
        if healthData.todaySteps < 5000 {
            recommendations.append(AIRecommendation(
                type: .activity,
                title: "Increase Daily Steps",
                message: "Try to reach 8,000 steps today. Take a 10-minute walk every 2 hours.",
                priority: .high,
                actionType: .workout,
                estimatedTime: 30
            ))
        } else if healthData.todaySteps > 15000 {
            recommendations.append(AIRecommendation(
                type: .achievement,
                title: "Excellent Activity Level!",
                message: "You're crushing your step goals! Consider adding some strength training.",
                priority: .medium,
                actionType: .strength,
                estimatedTime: 20
            ))
        }
        
        // Sleep quality recommendations
        if let sleepData = healthData.sleepData, sleepData.quality < 0.6 {
            recommendations.append(AIRecommendation(
                type: .recovery,
                title: "Improve Sleep Quality",
                message: "Your sleep quality is below average. Try a bedtime routine with no screens 1 hour before bed.",
                priority: .high,
                actionType: .recovery,
                estimatedTime: 0
            ))
        }
        
        // Workout intensity recommendations
        switch healthData.workoutIntensity {
        case .low:
            recommendations.append(AIRecommendation(
                type: .challenge,
                title: "Increase Workout Intensity",
                message: "Try adding some high-intensity intervals to your next workout.",
                priority: .medium,
                actionType: .workout,
                estimatedTime: 15
            ))
        case .high:
            recommendations.append(AIRecommendation(
                type: .recovery,
                title: "Focus on Recovery",
                message: "You've been pushing hard! Consider a light recovery day or stretching session.",
                priority: .medium,
                actionType: .recovery,
                estimatedTime: 20
            ))
        case .moderate:
            break // Good balance
        }
        
        // Mountain-specific recommendations
        if let expedition = expeditionManager?.currentExpedition {
            let progress = expeditionManager?.getExpeditionProgress() ?? 0.0
            if progress < 0.3 {
                recommendations.append(AIRecommendation(
                    type: .motivation,
                    title: "Start Your Mountain Journey",
                    message: "Every step counts! Focus on building a consistent daily routine.",
                    priority: .high,
                    actionType: .motivation,
                    estimatedTime: 0
                ))
            } else if progress > 0.8 {
                recommendations.append(AIRecommendation(
                    type: .achievement,
                    title: "Summit Push!",
                    message: "You're so close to the summit! Maintain your current pace and you'll reach the top soon.",
                    priority: .high,
                    actionType: .motivation,
                    estimatedTime: 0
                ))
            }
        }
        
        personalizedRecommendations = recommendations
    }
    
    func generateMotivationalMessages(for user: User, healthData: HealthKitManager) {
        var messages: [MotivationalMessage] = []
        
        let timeOfDay = getTimeOfDay()
        let userProgress = calculateUserProgress(user: user, healthData: healthData)
        
        // Time-based messages
        switch timeOfDay {
        case .morning:
            messages.append(MotivationalMessage(
                text: "Good morning, \(user.displayName)! Today is a new opportunity to climb higher. Let's make it count!",
                type: .morning,
                emoji: "🌅"
            ))
        case .afternoon:
            messages.append(MotivationalMessage(
                text: "Keep pushing forward! Every step you take brings you closer to your mountain summit.",
                type: .afternoon,
                emoji: "💪"
            ))
        case .evening:
            messages.append(MotivationalMessage(
                text: "Great work today! Your dedication is building the strength you need for the summit.",
                type: .evening,
                emoji: "🏔️"
            ))
        }
        
        // Progress-based messages
        if userProgress.streakDays >= 7 {
            messages.append(MotivationalMessage(
                text: "Amazing! You've maintained your streak for \(userProgress.streakDays) days. Consistency is key to reaching the summit!",
                type: .achievement,
                emoji: "🔥"
            ))
        }
        
        if userProgress.weeklySteps > 50000 {
            messages.append(MotivationalMessage(
                text: "Incredible! You've walked over 50,000 steps this week. Your mountain legs are getting stronger!",
                type: .achievement,
                emoji: "🚶‍♂️"
            ))
        }
        
        // Challenge messages
        if userProgress.daysSinceLastWorkout > 2 {
            messages.append(MotivationalMessage(
                text: "Ready for a challenge? Your mountain is waiting for you to take the next step!",
                type: .challenge,
                emoji: "⛰️"
            ))
        }
        
        motivationalMessages = messages
    }
    
    func generateContent(for user: User, healthData: HealthKitManager) {
        var content: [GeneratedContent] = []
        
        // Achievement content
        if let expedition = expeditionManager?.currentExpedition,
           let mountain = expeditionManager?.getMountain(by: expedition.mountainId) {
            let progress = expeditionManager?.getExpeditionProgress() ?? 0.0
            
            if progress > 0.5 {
                content.append(GeneratedContent(
                    type: .achievement,
                    title: "Halfway to \(mountain.name) Summit!",
                    description: "You've reached the halfway point of your \(mountain.name) expedition. Keep climbing!",
                    imageTemplate: "mountain_halfway",
                    shareText: "Just reached the halfway point of my \(mountain.name) expedition! 🏔️ #SummitAI #MountainClimbing",
                    hashtags: ["#SummitAI", "#MountainClimbing", "#Fitness", "#Adventure"]
                ))
            }
            
            if progress >= 1.0 {
                content.append(GeneratedContent(
                    type: .summit,
                    title: "Summit Conquered!",
                    description: "Congratulations! You've successfully reached the summit of \(mountain.name)!",
                    imageTemplate: "summit_celebration",
                    shareText: "I just conquered \(mountain.name)! 🏔️✨ The view from the top is incredible! #SummitAI #SummitConquered",
                    hashtags: ["#SummitAI", "#SummitConquered", "#MountainClimbing", "#Achievement"]
                ))
            }
        }
        
        // Weekly progress content
        let weeklySteps = healthData.weeklyTrends.averageSteps
        if weeklySteps > 8000 {
            content.append(GeneratedContent(
                type: .progress,
                title: "Weekly Progress Report",
                description: "You averaged \(Int(weeklySteps)) steps per day this week. Amazing consistency!",
                imageTemplate: "weekly_progress",
                shareText: "Crushed my weekly step goal with an average of \(Int(weeklySteps)) steps per day! 📈 #SummitAI #FitnessGoals",
                hashtags: ["#SummitAI", "#FitnessGoals", "#Steps", "#Progress"]
            ))
        }
        
        // Workout intensity content
        if healthData.workoutIntensity == .high {
            content.append(GeneratedContent(
                type: .workout,
                title: "High Intensity Champion!",
                description: "You're pushing your limits with high-intensity workouts. Your mountain training is paying off!",
                imageTemplate: "high_intensity",
                shareText: "Just completed an intense workout session! My mountain training is getting stronger! 💪 #SummitAI #HighIntensity",
                hashtags: ["#SummitAI", "#HighIntensity", "#Workout", "#Fitness"]
            ))
        }
        
        generatedContent = content
    }
    
    func generateFitnessInsights(for user: User, healthData: HealthKitManager) {
        var insights: [FitnessInsight] = []
        
        // Step trend analysis
        let weeklyTrend = healthData.weeklyTrends
        if weeklyTrend.averageSteps > weeklyTrend.averageSteps * 1.1 {
            insights.append(FitnessInsight(
                type: .positive,
                title: "Step Count Trending Up!",
                description: "Your daily step count has increased by 10% this week. Great momentum!",
                icon: "arrow.up.circle.fill",
                color: .green
            ))
        } else if weeklyTrend.averageSteps < weeklyTrend.averageSteps * 0.9 {
            insights.append(FitnessInsight(
                type: .warning,
                title: "Step Count Declining",
                description: "Your daily step count has decreased this week. Try to maintain consistency.",
                icon: "arrow.down.circle.fill",
                color: .orange
            ))
        }
        
        // Sleep quality insights
        if let sleepData = healthData.sleepData {
            if sleepData.quality > 0.8 {
                insights.append(FitnessInsight(
                    type: .positive,
                    title: "Excellent Sleep Quality",
                    description: "Your sleep quality is excellent! This will help with your mountain training.",
                    icon: "moon.zzz.fill",
                    color: .blue
                ))
            } else if sleepData.quality < 0.5 {
                insights.append(FitnessInsight(
                    type: .warning,
                    title: "Sleep Quality Needs Attention",
                    description: "Poor sleep quality can affect your training performance. Consider improving your sleep routine.",
                    icon: "moon.zzz",
                    color: .red
                ))
            }
        }
        
        // Workout consistency insights
        let workoutCount = healthData.todayWorkouts.count
        if workoutCount >= 3 {
            insights.append(FitnessInsight(
                type: .positive,
                title: "Workout Consistency",
                description: "You've completed \(workoutCount) workouts today. Excellent dedication!",
                icon: "dumbbell.fill",
                color: .green
            ))
        }
        
        fitnessInsights = insights
    }
    
    func createAdaptiveGoals(for user: User, healthData: HealthKitManager) {
        var goals: [AdaptiveGoal] = []
        
        let currentLevel = getUserLevel(user)
        let recentPerformance = analyzeRecentActivity(healthData: healthData)
        
        // Adaptive step goal
        let currentStepGoal = 10000
        let adaptiveStepGoal = Int(Double(currentStepGoal) * recentPerformance.stepMultiplier)
        
        goals.append(AdaptiveGoal(
            type: .steps,
            title: "Daily Steps",
            target: adaptiveStepGoal,
            current: healthData.todaySteps,
            description: "Adaptive step goal based on your recent performance",
            difficulty: currentLevel
        ))
        
        // Adaptive workout goal
        let workoutGoal = currentLevel == .beginner ? 3 : (currentLevel == .intermediate ? 4 : 5)
        goals.append(AdaptiveGoal(
            type: .workouts,
            title: "Weekly Workouts",
            target: workoutGoal,
            current: healthData.weeklyTrends.totalWorkouts,
            description: "Weekly workout target adjusted for your fitness level",
            difficulty: currentLevel
        ))
        
        // Mountain progress goal
        if let expedition = expeditionManager?.currentExpedition {
            let progress = expeditionManager?.getExpeditionProgress() ?? 0.0
            let nextMilestone = Int(progress * 100) + 10
            goals.append(AdaptiveGoal(
                type: .mountain,
                title: "Mountain Progress",
                target: nextMilestone,
                current: Int(progress * 100),
                description: "Reach \(nextMilestone)% completion of your current expedition",
                difficulty: currentLevel
            ))
        }
        
        adaptiveGoals = goals
    }
    
    // MARK: - Helper Methods
    
    private func convertToAIWorkoutIntensity(_ intensity: WorkoutIntensity) -> AIWorkoutIntensity {
        switch intensity {
        case .low:
            return .low
        case .moderate:
            return .moderate
        case .high:
            return .high
        }
    }
    
    private func analyzeRecentActivity(healthData: HealthKitManager) -> ActivityAnalysis {
        let weeklyTrend = healthData.weeklyTrends
        let stepMultiplier = min(1.5, max(0.5, weeklyTrend.averageSteps / 8000.0))
        
        return ActivityAnalysis(
            stepMultiplier: stepMultiplier,
            consistencyScore: calculateConsistencyScore(healthData: healthData),
            intensityTrend: convertToAIWorkoutIntensity(healthData.workoutIntensity)
        )
    }
    
    private func calculateConsistencyScore(healthData: HealthKitManager) -> Double {
        let weeklyTrend = healthData.weeklyTrends
        let dailyData = weeklyTrend.dailyData
        
        guard dailyData.count >= 3 else { return 0.5 }
        
        let stepVariance = calculateVariance(values: dailyData.map { Double($0.steps) })
        let averageSteps = dailyData.map { Double($0.steps) }.reduce(0, +) / Double(dailyData.count)
        
        // Lower variance = higher consistency
        let consistencyScore = max(0.0, min(1.0, 1.0 - (stepVariance / averageSteps)))
        return consistencyScore
    }
    
    private func calculateVariance(values: [Double]) -> Double {
        guard values.count > 1 else { return 0.0 }
        
        let mean = values.reduce(0, +) / Double(values.count)
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        return squaredDifferences.reduce(0, +) / Double(values.count)
    }
    
    private func getTimeOfDay() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return .morning
        case 12..<17:
            return .afternoon
        default:
            return .evening
        }
    }
    
    private func calculateUserProgress(user: User, healthData: HealthKitManager) -> UserProgress {
        let weeklyTrend = healthData.weeklyTrends
        
        return UserProgress(
            streakDays: user.streakCount,
            weeklySteps: Int(weeklyTrend.averageSteps * 7),
            daysSinceLastWorkout: calculateDaysSinceLastWorkout(healthData: healthData),
            totalExpeditions: user.completedExpeditions.count
        )
    }
    
    private func calculateDaysSinceLastWorkout(healthData: HealthKitManager) -> Int {
        // This would be calculated based on actual workout history
        // For now, return a mock value
        return healthData.todayWorkouts.isEmpty ? 1 : 0
    }
    
    // MARK: - Dependencies
    private weak var expeditionManager: ExpeditionManager?
    
    func setExpeditionManager(_ manager: ExpeditionManager) {
        self.expeditionManager = manager
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
    let intensity: AIWorkoutIntensity
    let type: ExerciseType
    var isCompleted: Bool = false
    
    init(name: String, description: String, duration: Double, sets: Int, reps: Int? = nil, restTime: Double, intensity: AIWorkoutIntensity, type: ExerciseType) {
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

enum AIWorkoutIntensity: String, CaseIterable, Codable {
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

// MARK: - Advanced AI Models

struct AIRecommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let title: String
    let message: String
    let priority: Priority
    let actionType: ActionType
    let estimatedTime: Int // in minutes
    
    enum RecommendationType {
        case activity
        case recovery
        case challenge
        case achievement
        case motivation
    }
    
    enum Priority {
        case low
        case medium
        case high
    }
    
    enum ActionType {
        case workout
        case strength
        case recovery
        case motivation
    }
}

struct MotivationalMessage: Identifiable {
    let id = UUID()
    let text: String
    let type: MessageType
    let emoji: String
    
    enum MessageType {
        case morning
        case afternoon
        case evening
        case achievement
        case challenge
    }
}

struct GeneratedContent: Identifiable {
    let id = UUID()
    let type: ContentType
    let title: String
    let description: String
    let imageTemplate: String
    let shareText: String
    let hashtags: [String]
    
    enum ContentType {
        case achievement
        case summit
        case progress
        case workout
    }
}

struct FitnessInsight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    enum InsightType {
        case positive
        case warning
        case info
    }
}

struct AdaptiveGoal: Identifiable {
    let id = UUID()
    let type: GoalType
    let title: String
    let target: Int
    let current: Int
    let description: String
    let difficulty: DifficultyLevel
    
    enum GoalType {
        case steps
        case workouts
        case mountain
    }
    
    var progress: Double {
        return Double(current) / Double(target)
    }
}

// MARK: - Helper Models

struct ActivityAnalysis {
    let stepMultiplier: Double
    let consistencyScore: Double
    let intensityTrend: AIWorkoutIntensity
}

struct UserProgress {
    let streakDays: Int
    let weeklySteps: Int
    let daysSinceLastWorkout: Int
    let totalExpeditions: Int
}

enum TimeOfDay {
    case morning
    case afternoon
    case evening
}
