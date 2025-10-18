import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var todaySteps: Int = 0
    @Published var todayElevation: Double = 0
    @Published var todayWorkouts: [HKWorkout] = []
    @Published var errorMessage: String?
    
    // Advanced HealthKit data
    @Published var heartRateData: [HeartRateData] = []
    @Published var sleepData: SleepData?
    @Published var workoutIntensity: WorkoutIntensity = .low
    @Published var fitnessScore: Double = 0.0
    @Published var weeklyTrends: WeeklyTrends = WeeklyTrends()
    @Published var healthInsights: [HealthInsight] = []
    
    // Streak integration
    @Published var streakManager: StreakManager?
    
    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?
    
    // HealthKit types we want to read - all available health data
    private let typesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .height)!,
        HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
        HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
        HKObjectType.quantityType(forIdentifier: .bloodGlucose)!,
        HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
        HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
        HKObjectType.quantityType(forIdentifier: .dietaryWater)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.categoryType(forIdentifier: .mindfulSession)!,
        HKObjectType.workoutType()
    ]
    
    init() {
        checkHealthKitAvailability()
        setupStreakManager()
    }
    
    private func setupStreakManager() {
        streakManager = StreakManager()
        
        // Update streak when steps change
        $todaySteps
            .sink { [weak self] steps in
                self?.streakManager?.updateStreak(with: steps)
            }
            .store(in: &cancellables)
    }
    
    private func checkHealthKitAvailability() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit is not available on this device"
            return
        }
    }
    
    func requestHealthKitPermissions() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit is not available on this device"
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "HealthKit authorization failed: \(error.localizedDescription)"
                    self?.isAuthorized = false
                    return
                }
                
                self?.isAuthorized = success
                if success {
                    self?.fetchTodayData()
                    self?.startObservingHealthData()
                    self?.startRealTimeUpdates()
                }
            }
        }
    }
    
    private func startObservingHealthData() {
        guard isAuthorized else { return }
        
        // Observe step count changes
        if let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) {
            let stepQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Step count observation error: \(error.localizedDescription)"
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self?.fetchTodayData()
                }
            }
            
            healthStore.execute(stepQuery)
        }
        
        // Observe workout changes
        let workoutQuery = HKObserverQuery(sampleType: HKObjectType.workoutType(), predicate: nil) { [weak self] _, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Workout observation error: \(error.localizedDescription)"
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.fetchTodayData()
            }
        }
        
        healthStore.execute(workoutQuery)
    }
    
    func fetchTodayData() {
        guard isAuthorized else { return }
        
        fetchTodaySteps()
        fetchTodayElevation()
        fetchTodayWorkouts()
        fetchHeartRateData()
        fetchSleepData()
        calculateFitnessScore()
    }
    
    private func fetchTodaySteps() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch steps: \(error.localizedDescription)"
                    return
                }
                
                if let result = result, let sum = result.sumQuantity() {
                    self?.todaySteps = Int(sum.doubleValue(for: HKUnit.count()))
                } else {
                    self?.todaySteps = 0
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchTodayElevation() {
        guard let elevationType = HKObjectType.quantityType(forIdentifier: .flightsClimbed) else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: elevationType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch elevation: \(error.localizedDescription)"
                    return
                }
                
                if let result = result, let sum = result.sumQuantity() {
                    // Convert flights to meters (assuming 10 feet per flight, 1 foot = 0.3048 meters)
                    let flights = sum.doubleValue(for: HKUnit.count())
                    self?.todayElevation = flights * 10 * 0.3048
                } else {
                    self?.todayElevation = 0
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchTodayWorkouts() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch workouts: \(error.localizedDescription)"
                    return
                }
                
                if let workouts = samples as? [HKWorkout] {
                    self?.todayWorkouts = workouts
                } else {
                    self?.todayWorkouts = []
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchStepsForDateRange(startDate: Date, endDate: Date, completion: @escaping (Int) -> Void) {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to fetch steps for date range: \(error.localizedDescription)"
                    completion(0)
                    return
                }
                
                if let result = result, let sum = result.sumQuantity() {
                    completion(Int(sum.doubleValue(for: HKUnit.count())))
                } else {
                    completion(0)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchElevationForDateRange(startDate: Date, endDate: Date, completion: @escaping (Double) -> Void) {
        guard let elevationType = HKObjectType.quantityType(forIdentifier: .flightsClimbed) else {
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: elevationType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to fetch elevation for date range: \(error.localizedDescription)"
                    completion(0)
                    return
                }
                
                if let result = result, let sum = result.sumQuantity() {
                    let flights = sum.doubleValue(for: HKUnit.count())
                    completion(flights * 10 * 0.3048) // Convert to meters
                } else {
                    completion(0)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchWorkoutsForDateRange(startDate: Date, endDate: Date, completion: @escaping ([HKWorkout]) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to fetch workouts for date range: \(error.localizedDescription)"
                    completion([])
                    return
                }
                
                if let workouts = samples as? [HKWorkout] {
                    completion(workouts)
                } else {
                    completion([])
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // Convert HKWorkout to our WorkoutData model
    func convertHKWorkoutToWorkoutData(_ hkWorkout: HKWorkout) -> WorkoutData {
        let workoutType: WorkoutData.WorkoutType
        
        switch hkWorkout.workoutActivityType {
        case .walking:
            workoutType = .walking
        case .running:
            workoutType = .running
        case .cycling:
            workoutType = .cycling
        case .hiking:
            workoutType = .hiking
        case .climbing:
            workoutType = .climbing
        default:
            workoutType = .other
        }
        
        return WorkoutData(
            type: workoutType,
            duration: hkWorkout.duration,
            distance: hkWorkout.totalDistance?.doubleValue(for: HKUnit.meter()) ?? nil,
            elevation: nil, // Would need to fetch separately
            calories: hkWorkout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? nil,
            timestamp: hkWorkout.startDate
        )
    }
    
    // MARK: - Real-time Updates
    
    private func startRealTimeUpdates() {
        // Update every second for real-time experience
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.fetchTodayData()
        }
    }
    
    private func stopRealTimeUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    deinit {
        stopRealTimeUpdates()
    }
    
    // MARK: - Advanced HealthKit Features
    
    func fetchHeartRateData() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { [weak self] _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch heart rate: \(error.localizedDescription)"
                    return
                }
                
                if let heartRateSamples = samples as? [HKQuantitySample] {
                    let heartRateData = heartRateSamples.map { sample in
                        HeartRateData(
                            value: sample.quantity.doubleValue(for: HKUnit(from: "count/min")),
                            timestamp: sample.startDate
                        )
                    }
                    self?.heartRateData = heartRateData
                    self?.analyzeWorkoutIntensity()
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchSleepData() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date().addingTimeInterval(-86400)) // Yesterday
        let endOfDay = calendar.startOfDay(for: Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { [weak self] _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch sleep data: \(error.localizedDescription)"
                    return
                }
                
                if let sleepSamples = samples as? [HKCategorySample] {
                    self?.processSleepData(sleepSamples)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func processSleepData(_ samples: [HKCategorySample]) {
        var totalSleepTime: TimeInterval = 0
        var deepSleepTime: TimeInterval = 0
        var lightSleepTime: TimeInterval = 0
        var remSleepTime: TimeInterval = 0
        
        for sample in samples {
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            totalSleepTime += duration
            
            switch sample.value {
            case HKCategoryValueSleepAnalysis.inBed.rawValue:
                break // Don't count in-bed time as sleep
            case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                lightSleepTime += duration
            case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                deepSleepTime += duration
            case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                remSleepTime += duration
            default:
                break
            }
        }
        
        let sleepQuality = calculateSleepQuality(totalSleep: totalSleepTime, deepSleep: deepSleepTime, remSleep: remSleepTime)
        
        sleepData = SleepData(
            totalSleepTime: totalSleepTime,
            deepSleepTime: deepSleepTime,
            lightSleepTime: lightSleepTime,
            remSleepTime: remSleepTime,
            quality: sleepQuality
        )
    }
    
    private func calculateSleepQuality(totalSleep: TimeInterval, deepSleep: TimeInterval, remSleep: TimeInterval) -> Double {
        let totalHours = totalSleep / 3600
        let deepSleepPercentage = deepSleep / totalSleep
        let remSleepPercentage = remSleep / totalSleep
        
        // Ideal sleep: 7-9 hours, 20-25% deep sleep, 20-25% REM sleep
        let durationScore = min(1.0, max(0.0, 1.0 - abs(totalHours - 8.0) / 2.0))
        let deepSleepScore = min(1.0, max(0.0, 1.0 - abs(deepSleepPercentage - 0.225) / 0.1))
        let remSleepScore = min(1.0, max(0.0, 1.0 - abs(remSleepPercentage - 0.225) / 0.1))
        
        return (durationScore + deepSleepScore + remSleepScore) / 3.0
    }
    
    private func analyzeWorkoutIntensity() {
        guard !heartRateData.isEmpty else {
            workoutIntensity = .low
            return
        }
        
        let recentHeartRates = heartRateData.suffix(10).map { $0.value }
        let averageHeartRate = recentHeartRates.reduce(0, +) / Double(recentHeartRates.count)
        
        // Basic intensity calculation (would need user's max heart rate for accuracy)
        let estimatedMaxHR = 220 - 30 // Assuming 30-year-old user
        let intensityPercentage = averageHeartRate / Double(estimatedMaxHR)
        
        if intensityPercentage >= 0.85 {
            workoutIntensity = .high
        } else if intensityPercentage >= 0.65 {
            workoutIntensity = .moderate
        } else {
            workoutIntensity = .low
        }
    }
    
    func calculateFitnessScore() {
        let stepScore = min(1.0, Double(todaySteps) / 10000.0) // 10k steps = 1.0
        let elevationScore = min(1.0, todayElevation / 100.0) // 100m elevation = 1.0
        let workoutScore = min(1.0, Double(todayWorkouts.count) / 3.0) // 3 workouts = 1.0
        let sleepScore = sleepData?.quality ?? 0.5
        
        fitnessScore = (stepScore + elevationScore + workoutScore + sleepScore) / 4.0
    }
    
    func fetchWeeklyTrends() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        
        var dailyData: [DailyHealthData] = []
        let group = DispatchGroup()
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: startDate)!
            let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
            
            group.enter()
            fetchStepsForDateRange(startDate: date, endDate: nextDate) { steps in
                group.enter()
                self.fetchElevationForDateRange(startDate: date, endDate: nextDate) { elevation in
                    group.enter()
                    self.fetchWorkoutsForDateRange(startDate: date, endDate: nextDate) { workouts in
                        let newData = DailyHealthData(
                            date: date,
                            steps: steps,
                            elevation: elevation,
                            workouts: workouts.count,
                            calories: workouts.reduce(0) { $0 + ($1.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0) }
                        )
                        
                        DispatchQueue.main.async {
                            dailyData.append(newData)
                        }
                        
                        group.leave()
                    }
                    group.leave()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.weeklyTrends = WeeklyTrends(dailyData: dailyData)
            self.generateHealthInsights()
        }
    }
    
    private func generateHealthInsights() {
        var insights: [HealthInsight] = []
        
        // Step trend insight
        if weeklyTrends.averageSteps > 8000 {
            insights.append(HealthInsight(
                type: .positive,
                title: "Great Activity Level!",
                message: "You're averaging \(Int(weeklyTrends.averageSteps)) steps per day. Keep it up!",
                icon: "figure.walk"
            ))
        } else if weeklyTrends.averageSteps < 5000 {
            insights.append(HealthInsight(
                type: .warning,
                title: "Low Activity Detected",
                message: "Try to increase your daily steps to improve your fitness level.",
                icon: "exclamationmark.triangle"
            ))
        }
        
        // Sleep insight
        if let sleepData = sleepData, sleepData.quality < 0.6 {
            insights.append(HealthInsight(
                type: .warning,
                title: "Poor Sleep Quality",
                message: "Your sleep quality is below average. Consider improving your sleep routine.",
                icon: "moon.zzz"
            ))
        }
        
        // Workout intensity insight
        if workoutIntensity == .high {
            insights.append(HealthInsight(
                type: .positive,
                title: "High Intensity Workout!",
                message: "You're pushing yourself hard today. Great job!",
                icon: "flame.fill"
            ))
        }
        
        healthInsights = insights
    }
}

// MARK: - Advanced Health Data Models

struct HeartRateData: Identifiable {
    let id = UUID()
    let value: Double // beats per minute
    let timestamp: Date
}

struct SleepData {
    let totalSleepTime: TimeInterval
    let deepSleepTime: TimeInterval
    let lightSleepTime: TimeInterval
    let remSleepTime: TimeInterval
    let quality: Double // 0.0 to 1.0
}

enum WorkoutIntensity: String, CaseIterable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .moderate: return "orange"
        case .high: return "red"
        }
    }
}

struct WeeklyTrends {
    let dailyData: [DailyHealthData]
    let averageSteps: Double
    let averageElevation: Double
    let totalWorkouts: Int
    let totalCalories: Double
    
    init(dailyData: [DailyHealthData] = []) {
        self.dailyData = dailyData
        self.averageSteps = dailyData.isEmpty ? 0 : dailyData.map { Double($0.steps) }.reduce(0, +) / Double(dailyData.count)
        self.averageElevation = dailyData.isEmpty ? 0 : dailyData.map { $0.elevation }.reduce(0, +) / Double(dailyData.count)
        self.totalWorkouts = dailyData.reduce(0) { $0 + $1.workouts }
        self.totalCalories = dailyData.reduce(0) { $0 + $1.calories }
    }
}

struct DailyHealthData {
    let date: Date
    let steps: Int
    let elevation: Double
    let workouts: Int
    let calories: Double
}

struct HealthInsight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let message: String
    let icon: String
    
    enum InsightType {
        case positive
        case warning
        case info
    }
}

