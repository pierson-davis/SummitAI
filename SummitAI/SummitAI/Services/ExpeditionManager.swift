import Foundation
import Combine
import SwiftUI

class ExpeditionManager: ObservableObject {
    @Published var currentExpedition: ExpeditionProgress?
    @Published var availableMountains: [Mountain] = []
    @Published var completedExpeditions: [ExpeditionProgress] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let currentExpeditionKey = "current_expedition"
    private let completedExpeditionsKey = "completed_expeditions"
    
    init() {
        print("ExpeditionManager: Initializing ExpeditionManager")
        loadAvailableMountains()
        loadExpeditionData()
        print("ExpeditionManager: Initialization complete - currentExpedition: \(currentExpedition != nil)")
    }
    
    // MARK: - Expedition Management
    
    func startExpedition(for mountain: Mountain) {
        guard !isExpeditionInProgress() else {
            errorMessage = "You already have an expedition in progress"
            return
        }
        
        let expedition = ExpeditionProgress(mountainId: mountain.id)
        currentExpedition = expedition
        saveCurrentExpedition()
    }
    
    func updateExpeditionProgress(steps: Int, elevation: Double, workouts: [WorkoutData]) {
        guard var expedition = currentExpedition else { return }
        
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
            
            if let index = expedition.dailyProgress.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
                expedition.dailyProgress[index] = updatedProgress
            }
        } else {
            // Create new progress for today
            var newProgress = DailyProgress(date: today, steps: steps, elevation: elevation)
            newProgress.workouts = workouts
            expedition.dailyProgress.append(newProgress)
        }
        
        // Check if expedition is completed
        checkExpeditionCompletion(expedition: expedition)
        
        currentExpedition = expedition
        saveCurrentExpedition()
    }
    
    private func checkExpeditionCompletion(expedition: ExpeditionProgress) {
        guard let mountain = getMountain(by: expedition.mountainId) else { return }
        
        // Check if user has reached the summit
        let summitCamp = mountain.camps.first { $0.isSummit }
        guard let summit = summitCamp else { return }
        
        if expedition.totalSteps >= summit.stepsRequired && expedition.totalElevation >= summit.elevationRequired {
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
            expedition.totalSteps >= camp.stepsRequired && expedition.totalElevation >= camp.elevationRequired
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
        let elevationProgress = expedition.totalElevation / summit.elevationRequired
        
        return min(1.0, (stepsProgress + elevationProgress) / 2.0)
    }
    
    func getNextCamp() -> Camp? {
        guard let expedition = currentExpedition,
              let mountain = getMountain(by: expedition.mountainId) else {
            return nil
        }
        
        let unreachedCamps = mountain.camps.filter { camp in
            expedition.totalSteps < camp.stepsRequired || expedition.totalElevation < camp.elevationRequired
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
    
    // MARK: - Mountain Management
    
    private func loadAvailableMountains() {
        availableMountains = Mountain.allMountains
    }
    
    func getAvailableMountains(for user: User) -> [Mountain] {
        if user.isPremium {
            return availableMountains
        } else {
            return availableMountains.filter { !$0.isPremium }
        }
    }
    
    func canAccessMountain(_ mountain: Mountain, user: User) -> Bool {
        return !mountain.isPremium || user.isPremium
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
}
