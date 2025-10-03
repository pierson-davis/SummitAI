import Foundation
import Combine
import SwiftUI

class ExpeditionManager: ObservableObject {
    @Published var currentExpedition: ExpeditionProgress?
    @Published var availableMountains: [Mountain] = []
    @Published var completedExpeditions: [ExpeditionProgress] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Realistic climbing integration
    // Environmental zone system - temporarily simplified
    // @Published var currentEnvironmentalZone: EnvironmentalZoneType = .rainforest
    // @Published var environmentalZoneTransitions: [EnvironmentalZoneTransition] = []
    // @Published var zoneSpecificChallenges: [ZoneChallenge] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let currentExpeditionKey = "current_expedition"
    private let completedExpeditionsKey = "completed_expeditions"
    
    // Realistic climbing manager
    // private let realisticClimbingManager = RealisticClimbingManager() // Temporarily removed
    
    init() {
        print("ExpeditionManager: Initializing ExpeditionManager")
        loadAvailableMountains()
        loadExpeditionData()
        // setupRealisticClimbingIntegration() // Temporarily disabled
        print("ExpeditionManager: Initialization complete - currentExpedition: \(currentExpedition != nil)")
    }
    
    // Temporarily disabled - realistic climbing integration
    /*
    private func setupRealisticClimbingIntegration() {
        // Subscribe to realistic climbing manager updates
        realisticClimbingManager.$currentWeather
            .assign(to: \.currentWeather, on: self)
            .store(in: &cancellables)
        
        realisticClimbingManager.$riskFactors
            .assign(to: \.riskFactors, on: self)
            .store(in: &cancellables)
        
        realisticClimbingManager.$climbingTips
            .assign(to: \.climbingTips, on: self)
            .store(in: &cancellables)
    }
    */
    
    // MARK: - Expedition Management
    
    func startExpedition(for mountain: Mountain) {
        print("ExpeditionManager: Starting expedition for \(mountain.name)")
        guard !isExpeditionInProgress() else {
            print("ExpeditionManager: Expedition already in progress")
            errorMessage = "You already have an expedition in progress"
            return
        }
        
        let expedition = ExpeditionProgress(mountainId: mountain.id)
        currentExpedition = expedition
        saveCurrentExpedition()
        print("ExpeditionManager: Expedition created and saved - currentExpedition: \(currentExpedition != nil)")
    }
    
    func updateExpeditionProgress(steps: Int, elevation: Double, workouts: [WorkoutData], heartRateData: [HeartRateData] = [], workoutIntensity: WorkoutIntensity = .low, sleepQuality: Double = 0.5) {
        guard var expedition = currentExpedition,
              let mountain = getMountain(by: expedition.mountainId) else { return }
        
        // Calculate realistic progress using the new system - temporarily disabled
        let currentCamp = getCurrentCamp()
        // let realisticProgress = realisticClimbingManager.calculateRealisticProgress(
        //     steps: steps,
        //     elevation: elevation,
        //     mountain: mountain,
        //     currentCamp: currentCamp
        // )
        
        // Update published realistic progress - temporarily disabled
        // self.realisticProgress = realisticProgress
        
        // Calculate enhanced progress with bonuses (legacy system for compatibility)
        let enhancedProgress = calculateEnhancedProgress(
            steps: steps,
            elevation: elevation,
            workouts: workouts,
            heartRateData: heartRateData,
            workoutIntensity: workoutIntensity,
            sleepQuality: sleepQuality
        )
        
        // Use simplified progress values (realistic progress temporarily disabled)
        expedition.totalSteps += steps
        expedition.totalElevation += elevation
        expedition.lastUpdateDate = Date()
        
        // Add today's progress
        let today = Calendar.current.startOfDay(for: Date())
        if let existingProgress = expedition.dailyProgress.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            // Update existing progress for today
            var updatedProgress = existingProgress
            updatedProgress.steps += steps
            updatedProgress.elevation += elevation
            updatedProgress.workouts.append(contentsOf: workouts)
            // updatedProgress.bonusMultiplier = realisticProgress.weatherImpact * realisticProgress.healthImpact * realisticProgress.equipmentImpact * realisticProgress.acclimatizationImpact // Temporarily disabled
            // updatedProgress.intensityBonus = enhancedProgress.intensityBonus // Temporarily disabled
            // updatedProgress.sleepBonus = enhancedProgress.sleepBonus // Temporarily disabled
            
            if let index = expedition.dailyProgress.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
                expedition.dailyProgress[index] = updatedProgress
            }
        } else {
            // Create new progress for today
            var newProgress = DailyProgress(date: today, steps: steps, elevation: elevation)
            newProgress.workouts = workouts
            // newProgress.bonusMultiplier = realisticProgress.weatherImpact * realisticProgress.healthImpact * realisticProgress.equipmentImpact * realisticProgress.acclimatizationImpact // Temporarily disabled
            // newProgress.intensityBonus = enhancedProgress.intensityBonus // Temporarily disabled
            // newProgress.sleepBonus = enhancedProgress.sleepBonus // Temporarily disabled
            expedition.dailyProgress.append(newProgress)
        }
        
        // Check if expedition is completed
        checkExpeditionCompletion(expedition: expedition)
        
        currentExpedition = expedition
        saveCurrentExpedition()
    }
    
    private func calculateEnhancedProgress(steps: Int, elevation: Double, workouts: [WorkoutData], heartRateData: [HeartRateData], workoutIntensity: WorkoutIntensity, sleepQuality: Double) -> EnhancedProgress {
        var bonusMultiplier = 1.0
        var intensityBonus = 0.0
        var sleepBonus = 0.0
        
        // Workout type multipliers
        let workoutMultiplier = calculateWorkoutMultiplier(workouts: workouts)
        bonusMultiplier *= workoutMultiplier
        
        // Heart rate intensity bonus
        if !heartRateData.isEmpty {
            let averageHeartRate = heartRateData.map { $0.value }.reduce(0, +) / Double(heartRateData.count)
            let estimatedMaxHR = 220 - 30 // Assuming 30-year-old user
            let intensityPercentage = averageHeartRate / Double(estimatedMaxHR)
            
            if intensityPercentage >= 0.85 {
                intensityBonus = 0.5 // 50% bonus for high intensity
            } else if intensityPercentage >= 0.65 {
                intensityBonus = 0.25 // 25% bonus for moderate intensity
            }
        }
        
        // Workout intensity bonus
        switch workoutIntensity {
        case .high:
            intensityBonus = max(intensityBonus, 0.4) // 40% bonus
        case .moderate:
            intensityBonus = max(intensityBonus, 0.2) // 20% bonus
        case .low:
            break // No additional bonus
        }
        
        // Sleep quality bonus/penalty
        if sleepQuality >= 0.8 {
            sleepBonus = 0.1 // 10% bonus for good sleep
        } else if sleepQuality < 0.4 {
            sleepBonus = -0.1 // 10% penalty for poor sleep
        }
        
        // Rest day penalty (if no workouts and low steps)
        if workouts.isEmpty && steps < 1000 {
            bonusMultiplier *= 0.8 // 20% penalty for rest days
        }
        
        // Weather and environmental factors (mock implementation)
        let weatherBonus = calculateWeatherBonus()
        bonusMultiplier *= weatherBonus
        
        // Calculate final enhanced progress
        let totalBonus = 1.0 + intensityBonus + sleepBonus
        let finalMultiplier = bonusMultiplier * totalBonus
        
        return EnhancedProgress(
            steps: Int(Double(steps) * finalMultiplier),
            elevation: elevation * finalMultiplier,
            bonusMultiplier: finalMultiplier,
            intensityBonus: intensityBonus,
            sleepBonus: sleepBonus
        )
    }
    
    private func calculateWorkoutMultiplier(workouts: [WorkoutData]) -> Double {
        guard !workouts.isEmpty else { return 1.0 }
        
        var totalMultiplier = 0.0
        for workout in workouts {
            let multiplier: Double
            switch workout.type {
            case .running:
                multiplier = 1.5
            case .cycling:
                multiplier = 1.2
            case .hiking:
                multiplier = 1.8
            case .climbing:
                multiplier = 2.0
            case .walking:
                multiplier = 1.0
            case .gym:
                multiplier = 1.3
            case .other:
                multiplier = 1.1
            }
            totalMultiplier += multiplier
        }
        
        return totalMultiplier / Double(workouts.count)
    }
    
    private func calculateWeatherBonus() -> Double {
        // Mock weather bonus - in real app, would integrate with weather API
        let randomWeather = Double.random(in: 0.8...1.2)
        return randomWeather
    }
    
    private func checkExpeditionCompletion(expedition: ExpeditionProgress) {
        guard let mountain = getMountain(by: expedition.mountainId) else { return }
        
        // Check if user has reached the summit
        let summitCamp = mountain.camps.first { $0.isSummit }
        guard let summit = summitCamp else { return }
        
        if expedition.totalSteps >= summit.stepsRequired {
            var completedExpedition = expedition
            completedExpedition.isCompleted = true
            completedExpedition.completionDate = Date()
            completedExpedition.currentCampId = summit.id
            
            // Move to completed expeditions
            completedExpeditions.append(completedExpedition)
            currentExpedition = nil
            
            saveCurrentExpedition()
            saveCompletedExpeditions()
        } else {
            // Check if user has reached a new camp
            updateCurrentCamp(expedition: expedition, mountain: mountain)
        }
    }
    
    private func updateCurrentCamp(expedition: ExpeditionProgress, mountain: Mountain) {
        // Find the highest camp the user has reached
        let reachableCamps = mountain.camps.filter { camp in
            expedition.totalSteps >= camp.stepsRequired
        }
        
        if let highestCamp = reachableCamps.max(by: { $0.altitude < $1.altitude }) {
            if expedition.currentCampId != highestCamp.id {
                var updatedExpedition = expedition
                updatedExpedition.currentCampId = highestCamp.id
                currentExpedition = updatedExpedition
                saveCurrentExpedition()
            }
        }
    }
    
    func getCurrentCamp() -> Camp? {
        guard let expedition = currentExpedition,
              let campId = expedition.currentCampId,
              let mountain = getMountain(by: expedition.mountainId) else {
            return nil
        }
        
        return mountain.camps.first { $0.id == campId }
    }
    
    func getMountain(by id: UUID) -> Mountain? {
        return availableMountains.first { $0.id == id }
    }
    
    func getExpeditionProgress() -> Double {
        guard let expedition = currentExpedition,
              let mountain = getMountain(by: expedition.mountainId) else {
            return 0.0
        }
        
        let summitCamp = mountain.camps.first { $0.isSummit }
        guard let summit = summitCamp else { return 0.0 }
        
        let stepsProgress = Double(expedition.totalSteps) / Double(summit.stepsRequired)
        
        return min(1.0, stepsProgress)
    }
    
    func getNextCamp() -> Camp? {
        guard let expedition = currentExpedition,
              let mountain = getMountain(by: expedition.mountainId) else {
            return nil
        }
        
        let unreachedCamps = mountain.camps.filter { camp in
            expedition.totalSteps < camp.stepsRequired
        }
        
        return unreachedCamps.min { $0.altitude < $1.altitude }
    }
    
    func getDistanceToNextCamp() -> (steps: Int, elevation: Double)? {
        guard let expedition = currentExpedition,
              let nextCamp = getNextCamp() else {
            return nil
        }
        
        let stepsNeeded = max(0, nextCamp.stepsRequired - expedition.totalSteps)
        let elevationNeeded = max(0, nextCamp.elevationRequired - expedition.totalElevation)
        
        return (steps: stepsNeeded, elevation: elevationNeeded)
    }
    
    func isExpeditionInProgress() -> Bool {
        return currentExpedition != nil && !(currentExpedition?.isCompleted ?? true)
    }
    
    func abandonExpedition() {
        currentExpedition = nil
        saveCurrentExpedition()
    }
    
    // MARK: - Realistic Climbing Actions
    
    func rest() {
        // realisticClimbingManager.rest() // Temporarily disabled
    }
    
    func hydrate() {
        // realisticClimbingManager.hydrate() // Temporarily disabled
    }
    
    func descend() {
        // realisticClimbingManager.descend() // Temporarily disabled
        
        // Update expedition progress if descending
        guard var expedition = currentExpedition else { return }
        
        // Reduce total steps and elevation to reflect descent
        expedition.totalSteps = max(0, expedition.totalSteps - 5000)
        expedition.totalElevation = max(0, expedition.totalElevation - 100)
        
        currentExpedition = expedition
        saveCurrentExpedition()
    }
    
    func getCurrentAltitude() -> Double {
        // return realisticClimbingManager.currentAltitude // Temporarily disabled
        return 0.0 // Temporary placeholder
    }
    
    // Realistic climbing status methods temporarily removed
    // func getAcclimatizationStatus() -> AcclimatizationStatus {
    //     return realisticClimbingManager.acclimatizationStatus
    // }
    // 
    // func getHealthStatus() -> HealthStatus {
    //     return realisticClimbingManager.healthStatus
    // }
    // 
    // func getEquipmentStatus() -> EquipmentStatus {
    //     return realisticClimbingManager.equipmentStatus
    // }
    
    // MARK: - Mountain Management
    
    private func loadAvailableMountains() {
        availableMountains = Mountain.allMountains
    }
    
    func getAvailableMountains(for user: User) -> [Mountain] {
        if user.hasAccess {
            return availableMountains
        } else {
            return availableMountains.filter { !$0.isPaywalled }
        }
    }
    
    func canAccessMountain(_ mountain: Mountain, user: User) -> Bool {
        return !mountain.isPaywalled || user.hasAccess
    }
    
    // MARK: - Statistics
    
    func getTotalExpeditionsCompleted() -> Int {
        return completedExpeditions.count
    }
    
    func getTotalStepsClimbed() -> Int {
        return completedExpeditions.reduce(0) { $0 + $1.totalSteps }
    }
    
    func getTotalElevationClimbed() -> Double {
        return completedExpeditions.reduce(0) { $0 + $1.totalElevation }
    }
    
    func getAverageExpeditionDuration() -> TimeInterval? {
        guard !completedExpeditions.isEmpty else { return nil }
        
        let totalDuration = completedExpeditions.reduce(0) { total, expedition in
            guard let completionDate = expedition.completionDate else { return total }
            return total + completionDate.timeIntervalSince(expedition.startDate)
        }
        
        return totalDuration / Double(completedExpeditions.count)
    }
    
    func getFavoriteMountain() -> Mountain? {
        let mountainCounts = Dictionary(grouping: completedExpeditions) { $0.mountainId }
            .mapValues { $0.count }
        
        guard let mostCompletedMountainId = mountainCounts.max(by: { $0.value < $1.value })?.key else {
            return nil
        }
        
        return getMountain(by: mostCompletedMountainId)
    }
    
    // MARK: - Daily Progress
    
    func getTodayProgress() -> DailyProgress? {
        guard let expedition = currentExpedition else { return nil }
        
        let today = Calendar.current.startOfDay(for: Date())
        return expedition.dailyProgress.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    func getWeeklyProgress() -> [DailyProgress] {
        guard let expedition = currentExpedition else { return [] }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        
        return expedition.dailyProgress.filter { $0.date >= weekAgo }
    }
    
    func getMonthlyProgress() -> [DailyProgress] {
        guard let expedition = currentExpedition else { return [] }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: today)!
        
        return expedition.dailyProgress.filter { $0.date >= monthAgo }
    }
    
    // MARK: - Storage Methods
    
    private func saveCurrentExpedition() {
        guard let expedition = currentExpedition else {
            userDefaults.removeObject(forKey: currentExpeditionKey)
            return
        }
        
        do {
            let data = try JSONEncoder().encode(expedition)
            userDefaults.set(data, forKey: currentExpeditionKey)
        } catch {
            print("Failed to save current expedition: \(error)")
        }
    }
    
    private func loadExpeditionData() {
        // Load current expedition
        if let data = userDefaults.data(forKey: currentExpeditionKey) {
            do {
                currentExpedition = try JSONDecoder().decode(ExpeditionProgress.self, from: data)
            } catch {
                print("Failed to load current expedition: \(error)")
            }
        }
        
        // Load completed expeditions
        if let data = userDefaults.data(forKey: completedExpeditionsKey) {
            do {
                completedExpeditions = try JSONDecoder().decode([ExpeditionProgress].self, from: data)
            } catch {
                print("Failed to load completed expeditions: \(error)")
            }
        }
    }
    
    private func saveCompletedExpeditions() {
        do {
            let data = try JSONEncoder().encode(completedExpeditions)
            userDefaults.set(data, forKey: completedExpeditionsKey)
        } catch {
            print("Failed to save completed expeditions: \(error)")
        }
    }
    
    // MARK: - Mock Data for Development
    
    func createMockExpedition() {
        let mountain = Mountain.kilimanjaro
        var expedition = ExpeditionProgress(mountainId: mountain.id)
        expedition.totalSteps = 25000
        expedition.totalElevation = 800
        expedition.currentCampId = mountain.camps[1].id // Camp 1
        
        currentExpedition = expedition
        saveCurrentExpedition()
    }
    
    // MARK: - Environmental Zone System - Temporarily Disabled
    // Complex environmental zone system removed to fix compilation issues
    
    // Environmental zone methods temporarily removed
    // private func generateZoneSpecificChallenges(for zone: EnvironmentalZoneType) {
    //     let challenges = getChallengesForZone(zone)
    //     zoneSpecificChallenges = challenges
    // }
    
    // All environmental zone methods temporarily removed to fix compilation issues
    /*
    private func getChallengesForZone(_ zone: EnvironmentalZoneType) -> [ZoneChallenge] {
        switch zone {
        case .rainforest:
            return [
                ZoneChallenge(
                    id: UUID(),
                    title: "Navigate Through Dense Vegetation",
                    description: "Find your way through the dense rainforest canopy",
                    zone: .rainforest,
                    difficulty: .easy,
                    reward: "Navigation skills improved",
                    isCompleted: false
                ),
                ZoneChallenge(
                    id: UUID(),
                    title: "Avoid Wildlife Encounters",
                    description: "Successfully navigate without disturbing local wildlife",
                    zone: .rainforest,
                    difficulty: .medium,
                    reward: "Stealth bonus for next zone",
                    isCompleted: false
                )
            ]
        case .moorland:
            return [
                ZoneChallenge(
                    id: UUID(),
                    title: "Endure Wind Exposure",
                    description: "Maintain progress despite strong winds",
                    zone: .moorland,
                    difficulty: .medium,
                    reward: "Wind resistance increased",
                    isCompleted: false
                ),
                ZoneChallenge(
                    id: UUID(),
                    title: "Find Shelter",
                    description: "Locate and use natural shelter during weather changes",
                    zone: .moorland,
                    difficulty: .easy,
                    reward: "Survival knowledge gained",
                    isCompleted: false
                )
            ]
        case .alpineDesert:
            return [
                ZoneChallenge(
                    id: UUID(),
                    title: "Manage Extreme Temperatures",
                    description: "Survive the extreme temperature swings",
                    zone: .alpineDesert,
                    difficulty: .hard,
                    reward: "Temperature resistance improved",
                    isCompleted: false
                ),
                ZoneChallenge(
                    id: UUID(),
                    title: "Conserve Water",
                    description: "Manage hydration in the arid environment",
                    zone: .alpineDesert,
                    difficulty: .medium,
                    reward: "Water conservation skills",
                    isCompleted: false
                )
            ]
        case .summit:
            return [
                ZoneChallenge(
                    id: UUID(),
                    title: "Survive the Death Zone",
                    description: "Reach the summit and return safely",
                    zone: .summit,
                    difficulty: .extreme,
                    reward: "Ultimate achievement unlocked",
                    isCompleted: false
                ),
                ZoneChallenge(
                    id: UUID(),
                    title: "Extreme Cold Endurance",
                    description: "Endure temperatures below -30°C",
                    zone: .summit,
                    difficulty: .extreme,
                    reward: "Cold resistance mastery",
                    isCompleted: false
                )
            ]
        }
    }
    
    private func showEnvironmentalZoneTransition(_ transition: EnvironmentalZoneTransition) {
        // This would typically show a notification or alert
        print("Environmental Zone Transition: \(transition.message)")
        
        // Add to notification system or show alert
        // For now, we'll just print it
    }
    
    func completeZoneChallenge(_ challengeId: UUID) {
        if let index = zoneSpecificChallenges.firstIndex(where: { $0.id == challengeId }) {
            zoneSpecificChallenges[index].isCompleted = true
            
            // Apply challenge reward
            applyChallengeReward(zoneSpecificChallenges[index])
        }
    }
    
    private func applyChallengeReward(_ challenge: ZoneChallenge) {
        // Apply the reward based on the challenge type
        switch challenge.zone {
        case .rainforest:
            // Navigation skills bonus
            break
        case .moorland:
            // Wind resistance bonus
            break
        case .alpineDesert:
            // Temperature resistance bonus
            break
        case .summit:
            // Ultimate achievement
            break
        }
    }
    */

// MARK: - Enhanced Progress Models

struct EnhancedProgress {
    let steps: Int
    let elevation: Double
    let bonusMultiplier: Double
    let intensityBonus: Double
    let sleepBonus: Double
}

// MARK: - Updated Daily Progress Model
// Note: DailyProgress is defined in Mountain.swift to avoid conflicts

// MARK: - Zone Challenge Model - Temporarily Removed
// Complex challenge system removed to fix compilation issues
}
