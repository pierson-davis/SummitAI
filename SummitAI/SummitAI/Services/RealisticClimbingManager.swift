import Foundation
import Combine
import SwiftUI

// MARK: - Realistic Climbing Manager
class RealisticClimbingManager: ObservableObject {
    @Published var currentWeather: WeatherPattern = .clear
    @Published var currentAltitude: Double = 0
    @Published var acclimatizationStatus: AcclimatizationStatus = AcclimatizationStatus()
    @Published var healthStatus: HealthStatus = HealthStatus()
    @Published var equipmentStatus: EquipmentStatus = EquipmentStatus()
    @Published var dailyProgress: RealisticDailyProgress?
    @Published var riskFactors: [RiskFactor] = []
    @Published var climbingTips: [ClimbingTip] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadPersistedData()
        generateDailyWeather()
        generateClimbingTips()
    }
    
    // MARK: - Progress Calculation
    
    func calculateRealisticProgress(
        steps: Int,
        elevation: Double,
        mountain: Mountain,
        currentCamp: Camp?
    ) -> RealisticProgress {
        
        let baseProgress = calculateBaseProgress(steps: steps, elevation: elevation)
        let altitudeModifier = calculateAltitudeModifier(currentAltitude: currentAltitude, mountain: mountain)
        let weatherModifier = currentWeather.progressModifier
        let healthModifier = calculateHealthModifier(health: healthStatus)
        let equipmentModifier = calculateEquipmentModifier(equipment: equipmentStatus)
        let acclimatizationModifier = calculateAcclimatizationModifier(acclimatization: acclimatizationStatus)
        
        // Calculate altitude gain based on realistic climbing factors
        let altitudeGain = calculateAltitudeGain(
            steps: steps,
            elevation: elevation,
            mountain: mountain,
            currentAltitude: currentAltitude
        )
        
        // Apply all modifiers
        let finalSteps = Int(Double(baseProgress.steps) * weatherModifier * healthModifier * equipmentModifier * acclimatizationModifier)
        let finalElevation = baseProgress.elevation * weatherModifier * healthModifier * equipmentModifier * acclimatizationModifier
        
        // Update altitude
        currentAltitude = min(currentAltitude + altitudeGain, mountain.height)
        
        // Update acclimatization
        updateAcclimatizationStatus(altitudeGain: altitudeGain, mountain: mountain)
        
        // Update health status
        updateHealthStatus(altitudeGain: altitudeGain, weather: currentWeather)
        
        // Generate risk factors
        generateRiskFactors(mountain: mountain, currentAltitude: currentAltitude)
        
        return RealisticProgress(
            steps: finalSteps,
            elevation: finalElevation,
            altitudeGain: altitudeGain,
            weatherImpact: weatherModifier,
            healthImpact: healthModifier,
            equipmentImpact: equipmentModifier,
            acclimatizationImpact: acclimatizationModifier,
            riskFactors: riskFactors
        )
    }
    
    private func calculateBaseProgress(steps: Int, elevation: Double) -> BaseProgress {
        // Base calculation: 1 step = 0.8 meters (average stride length)
        let baseSteps = steps
        let baseElevation = elevation
        
        return BaseProgress(steps: baseSteps, elevation: baseElevation)
    }
    
    private func calculateAltitudeModifier(currentAltitude: Double, mountain: Mountain) -> Double {
        // Altitude affects progress - higher altitude = slower progress
        let altitudePercentage = currentAltitude / mountain.height
        
        if altitudePercentage < 0.3 {
            return 1.0 // No penalty at low altitude
        } else if altitudePercentage < 0.6 {
            return 0.9 // 10% penalty at moderate altitude
        } else if altitudePercentage < 0.8 {
            return 0.8 // 20% penalty at high altitude
        } else {
            return 0.6 // 40% penalty in death zone
        }
    }
    
    private func calculateHealthModifier(health: HealthStatus) -> Double {
        var modifier = 1.0
        
        // Altitude sickness penalty
        if health.altitudeSicknessSeverity > 0 {
            modifier *= (1.0 - Double(health.altitudeSicknessSeverity) * 0.3)
        }
        
        // Fatigue penalty
        if health.fatigueLevel > 0.7 {
            modifier *= 0.8
        } else if health.fatigueLevel > 0.5 {
            modifier *= 0.9
        }
        
        // Hydration penalty
        if health.hydrationLevel < 0.6 {
            modifier *= 0.9
        }
        
        return modifier
    }
    
    private func calculateEquipmentModifier(equipment: EquipmentStatus) -> Double {
        var modifier = 1.0
        
        // Equipment failure penalty
        for item in equipment.equipment {
            if item.durability < 50 {
                modifier *= 0.95 // 5% penalty for damaged equipment
            }
        }
        
        return modifier
    }
    
    private func calculateAcclimatizationModifier(acclimatization: AcclimatizationStatus) -> Double {
        let altitudePercentage = currentAltitude / 8848.0 // Everest as reference
        
        if acclimatization.daysAtCurrentAltitude < 2 {
            // Rapid ascent penalty
            return 0.7
        } else if acclimatization.daysAtCurrentAltitude < 4 {
            // Moderate acclimatization
            return 0.85
        } else {
            // Well acclimatized
            return 1.0
        }
    }
    
    private func calculateAltitudeGain(
        steps: Int,
        elevation: Double,
        mountain: Mountain,
        currentAltitude: Double
    ) -> Double {
        // Realistic altitude gain based on mountain difficulty and current altitude
        let baseAltitudeGain = elevation * 0.1 // 10% of elevation gain becomes altitude gain
        
        // Apply mountain difficulty modifier
        let difficultyModifier = mountain.difficultyMultiplier / 10.0 // Scale down the multiplier
        
        // Apply altitude penalty (higher altitude = less gain per step)
        let altitudePenalty = max(0.1, 1.0 - (currentAltitude / mountain.height) * 0.8)
        
        return baseAltitudeGain * difficultyModifier * altitudePenalty
    }
    
    // MARK: - Status Updates
    
    private func updateAcclimatizationStatus(altitudeGain: Double, mountain: Mountain) {
        if altitudeGain > 300 {
            // Rapid ascent - reset acclimatization
            acclimatizationStatus.daysAtCurrentAltitude = 0
            acclimatizationStatus.altitudeSicknessRisk = min(1.0, acclimatizationStatus.altitudeSicknessRisk + 0.3)
        } else if altitudeGain > 100 {
            // Moderate ascent
            acclimatizationStatus.daysAtCurrentAltitude = 0
            acclimatizationStatus.altitudeSicknessRisk = min(1.0, acclimatizationStatus.altitudeSicknessRisk + 0.1)
        } else {
            // Gradual ascent - good acclimatization
            acclimatizationStatus.daysAtCurrentAltitude += 1
            acclimatizationStatus.altitudeSicknessRisk = max(0.0, acclimatizationStatus.altitudeSicknessRisk - 0.05)
        }
        
        // Update maximum altitude reached
        acclimatizationStatus.maxAltitudeReached = max(acclimatizationStatus.maxAltitudeReached, currentAltitude)
    }
    
    private func updateHealthStatus(altitudeGain: Double, weather: WeatherPattern) {
        // Update fatigue based on activity
        if altitudeGain > 200 {
            healthStatus.fatigueLevel = min(1.0, healthStatus.fatigueLevel + 0.2)
        } else if altitudeGain > 100 {
            healthStatus.fatigueLevel = min(1.0, healthStatus.fatigueLevel + 0.1)
        }
        
        // Update hydration based on weather
        if weather.name == "Clear" || weather.name == "Windy" {
            healthStatus.hydrationLevel = max(0.0, healthStatus.hydrationLevel - 0.1)
        }
        
        // Update altitude sickness based on risk
        if acclimatizationStatus.altitudeSicknessRisk > 0.7 {
            healthStatus.altitudeSicknessSeverity = min(3, healthStatus.altitudeSicknessSeverity + 1)
        } else if acclimatizationStatus.altitudeSicknessRisk < 0.3 {
            healthStatus.altitudeSicknessSeverity = max(0, healthStatus.altitudeSicknessSeverity - 1)
        }
    }
    
    // MARK: - Weather System
    
    private func generateDailyWeather() {
        let weatherTypes: [WeatherPattern] = [.clear, .cloudy, .windy, .storm]
        let weights = [0.4, 0.3, 0.2, 0.1] // Clear weather is more common
        
        let random = Double.random(in: 0...1)
        var cumulative = 0.0
        
        for (index, weight) in weights.enumerated() {
            cumulative += weight
            if random <= cumulative {
                currentWeather = weatherTypes[index]
                break
            }
        }
    }
    
    // MARK: - Risk Assessment
    
    private func generateRiskFactors(mountain: Mountain, currentAltitude: Double) {
        var factors: [RiskFactor] = []
        
        // Check altitude sickness risk
        if acclimatizationStatus.altitudeSicknessRisk > 0.6 {
            factors.append(RiskFactor(
                type: .altitudeSickness,
                severity: .high,
                description: "High risk of altitude sickness. Consider descending or resting.",
                mitigation: "Rest at current altitude, hydrate, consider descent"
            ))
        }
        
        // Check weather risks
        if currentWeather.safetyRisk == .high || currentWeather.safetyRisk == .extreme {
            factors.append(RiskFactor(
                type: .weather,
                severity: currentWeather.safetyRisk == .extreme ? .extreme : .high,
                description: "Dangerous weather conditions. Avoid climbing.",
                mitigation: "Wait for better weather, seek shelter"
            ))
        }
        
        // Check equipment risks
        let damagedEquipment = equipmentStatus.equipment.filter { $0.durability < 50 }
        if !damagedEquipment.isEmpty {
            factors.append(RiskFactor(
                type: .equipment,
                severity: .moderate,
                description: "Equipment damage detected. Safety compromised.",
                mitigation: "Repair or replace damaged equipment before continuing"
            ))
        }
        
        // Check fatigue risks
        if healthStatus.fatigueLevel > 0.8 {
            factors.append(RiskFactor(
                type: .fatigue,
                severity: .high,
                description: "Extreme fatigue detected. Risk of poor decision making.",
                mitigation: "Rest and recover before continuing"
            ))
        }
        
        riskFactors = factors
    }
    
    // MARK: - Climbing Tips
    
    private func generateClimbingTips() {
        var tips: [ClimbingTip] = []
        
        // Environmental zone tips
        let currentZone = getCurrentEnvironmentalZone()
        tips.append(contentsOf: getZoneSpecificTips(for: currentZone))
        
        // Altitude tips
        if currentAltitude > 3000 {
            tips.append(ClimbingTip(
                title: "High Altitude Climbing",
                description: "Above 3000m, climb high, sleep low. Take rest days every 3-4 days.",
                category: .altitude
            ))
        }
        
        // Weather tips
        if currentWeather.name == "Storm" || currentWeather.name == "Blizzard" {
            tips.append(ClimbingTip(
                title: "Storm Safety",
                description: "Stay in shelter during storms. Wind and cold can be deadly.",
                category: .weather
            ))
        }
        
        // Equipment tips
        let damagedEquipment = equipmentStatus.equipment.filter { $0.durability < 70 }
        if !damagedEquipment.isEmpty {
            tips.append(ClimbingTip(
                title: "Equipment Maintenance",
                description: "Check your equipment regularly. Damaged gear can fail when you need it most.",
                category: .equipment
            ))
        }
        
        // Health tips
        if healthStatus.hydrationLevel < 0.7 {
            tips.append(ClimbingTip(
                title: "Stay Hydrated",
                description: "Dehydration at altitude is dangerous. Drink 3-4 liters per day.",
                category: .health
            ))
        }
        
        climbingTips = tips
    }
    
    // MARK: - Environmental Zone System
    
    private func getCurrentEnvironmentalZone() -> EnvironmentalZoneType {
        if currentAltitude < 2000 {
            return .rainforest
        } else if currentAltitude < 3000 {
            return .moorland
        } else if currentAltitude < 5000 {
            return .alpineDesert
        } else {
            return .summit
        }
    }
    
    private func getZoneSpecificTips(for zone: EnvironmentalZoneType) -> [ClimbingTip] {
        switch zone {
        case .rainforest:
            return [
                ClimbingTip(
                    title: "Rainforest Navigation",
                    description: "Watch for wildlife and use insect repellent. The dense vegetation can make navigation challenging.",
                    category: .technique
                ),
                ClimbingTip(
                    title: "High Humidity",
                    description: "Stay hydrated in the humid rainforest environment. The high humidity can cause rapid dehydration.",
                    category: .health
                )
            ]
        case .moorland:
            return [
                ClimbingTip(
                    title: "Moorland Weather",
                    description: "Weather changes rapidly in moorland. Always be prepared for sudden temperature drops and wind.",
                    category: .weather
                ),
                ClimbingTip(
                    title: "Wind Exposure",
                    description: "Moorland offers little shelter from wind. Layer your clothing and protect exposed skin.",
                    category: .safety
                )
            ]
        case .alpineDesert:
            return [
                ClimbingTip(
                    title: "Alpine Desert Conditions",
                    description: "Extreme temperature swings between day and night. Protect yourself from intense UV radiation.",
                    category: .safety
                ),
                ClimbingTip(
                    title: "Altitude Management",
                    description: "You're entering high altitude territory. Monitor for altitude sickness symptoms carefully.",
                    category: .altitude
                )
            ]
        case .summit:
            return [
                ClimbingTip(
                    title: "Death Zone",
                    description: "Above 5000m is the death zone. Limit time here and consider using supplemental oxygen.",
                    category: .safety
                ),
                ClimbingTip(
                    title: "Extreme Cold",
                    description: "Temperatures can drop to -40°C. Ensure all equipment is rated for extreme cold.",
                    category: .equipment
                )
            ]
        }
    }
    
    // MARK: - Environmental Zone Transitions
    
    func checkForZoneTransition() -> EnvironmentalZoneTransition? {
        let currentZone = getCurrentEnvironmentalZone()
        let previousZone = getPreviousEnvironmentalZone()
        
        if currentZone != previousZone {
            return EnvironmentalZoneTransition(
                from: previousZone,
                to: currentZone,
                altitude: currentAltitude,
                timestamp: Date()
            )
        }
        
        return nil
    }
    
    private func getPreviousEnvironmentalZone() -> EnvironmentalZoneType {
        // This would be stored from previous altitude
        // For now, we'll calculate based on a slightly lower altitude
        let previousAltitude = max(0, currentAltitude - 100)
        
        if previousAltitude < 2000 {
            return .rainforest
        } else if previousAltitude < 3000 {
            return .moorland
        } else if previousAltitude < 5000 {
            return .alpineDesert
        } else {
            return .summit
        }
    }
    
    // MARK: - Data Persistence
    
    private func loadPersistedData() {
        // Load persisted data from UserDefaults
        if let data = userDefaults.data(forKey: "realistic_climbing_data"),
           let decoded = try? JSONDecoder().decode(RealisticClimbingData.self, from: data) {
            currentAltitude = decoded.currentAltitude
            acclimatizationStatus = decoded.acclimatizationStatus
            healthStatus = decoded.healthStatus
            equipmentStatus = decoded.equipmentStatus
        }
    }
    
    func savePersistedData() {
        let data = RealisticClimbingData(
            currentAltitude: currentAltitude,
            acclimatizationStatus: acclimatizationStatus,
            healthStatus: healthStatus,
            equipmentStatus: equipmentStatus
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: "realistic_climbing_data")
        }
    }
    
    // MARK: - Recovery Actions
    
    func rest() {
        // Rest reduces fatigue and improves acclimatization
        healthStatus.fatigueLevel = max(0.0, healthStatus.fatigueLevel - 0.3)
        acclimatizationStatus.daysAtCurrentAltitude += 1
        acclimatizationStatus.altitudeSicknessRisk = max(0.0, acclimatizationStatus.altitudeSicknessRisk - 0.1)
        
        savePersistedData()
    }
    
    func hydrate() {
        // Hydration improves health
        healthStatus.hydrationLevel = min(1.0, healthStatus.hydrationLevel + 0.3)
        
        savePersistedData()
    }
    
    func descend() {
        // Descent improves altitude sickness
        currentAltitude = max(0, currentAltitude - 500)
        healthStatus.altitudeSicknessSeverity = max(0, healthStatus.altitudeSicknessSeverity - 1)
        acclimatizationStatus.altitudeSicknessRisk = max(0.0, acclimatizationStatus.altitudeSicknessRisk - 0.2)
        
        savePersistedData()
    }
}

// MARK: - Supporting Models

struct RealisticProgress {
    let steps: Int
    let elevation: Double
    let altitudeGain: Double
    let weatherImpact: Double
    let healthImpact: Double
    let equipmentImpact: Double
    let acclimatizationImpact: Double
    let riskFactors: [RiskFactor]
}

struct BaseProgress {
    let steps: Int
    let elevation: Double
}

struct AcclimatizationStatus: Codable {
    var daysAtCurrentAltitude: Int = 0
    var altitudeSicknessRisk: Double = 0.0
    var maxAltitudeReached: Double = 0.0
    var lastAscentRate: Double = 0.0
}

struct HealthStatus: Codable {
    var altitudeSicknessSeverity: Int = 0 // 0-3 scale
    var fatigueLevel: Double = 0.0 // 0.0-1.0
    var hydrationLevel: Double = 0.8 // 0.0-1.0
    var nutritionLevel: Double = 0.8 // 0.0-1.0
    var sleepQuality: Double = 0.8 // 0.0-1.0
}

struct EquipmentStatus: Codable {
    var equipment: [EquipmentItem] = [
        EquipmentItem(name: "Ice Axe", durability: 100),
        EquipmentItem(name: "Crampons", durability: 100),
        EquipmentItem(name: "Helmet", durability: 100),
        EquipmentItem(name: "Rope", durability: 100)
    ]
}

struct EquipmentItem: Codable {
    let name: String
    var durability: Int // 0-100
}

struct RiskFactor {
    let type: RiskType
    let severity: RiskSeverity
    let description: String
    let mitigation: String
    
    enum RiskType {
        case altitudeSickness
        case weather
        case equipment
        case fatigue
        case dehydration
        case hypothermia
    }
    
    enum RiskSeverity {
        case low
        case moderate
        case high
        case extreme
    }
}

struct ClimbingTip {
    let title: String
    let description: String
    let category: TipCategory
    
    enum TipCategory {
        case altitude
        case weather
        case equipment
        case health
        case technique
        case safety
    }
}

struct RealisticDailyProgress {
    let date: Date
    let steps: Int
    let elevation: Double
    let altitudeGain: Double
    let weather: WeatherPattern
    let health: HealthStatus
    let risks: [RiskFactor]
    let tips: [ClimbingTip]
}

struct RealisticClimbingData: Codable {
    let currentAltitude: Double
    let acclimatizationStatus: AcclimatizationStatus
    let healthStatus: HealthStatus
    let equipmentStatus: EquipmentStatus
}

// MARK: - Environmental Zone System Models

enum EnvironmentalZoneType: String, CaseIterable, Codable {
    case rainforest = "Rainforest"
    case moorland = "Moorland"
    case alpineDesert = "Alpine Desert"
    case summit = "Summit"
    
    var description: String {
        switch self {
        case .rainforest:
            return "Lush vegetation, high humidity, moderate temperatures"
        case .moorland:
            return "Open grasslands, cooler temperatures, variable weather"
        case .alpineDesert:
            return "Rocky terrain, extreme temperatures, high altitude"
        case .summit:
            return "Extreme conditions, death zone, ultimate challenge"
        }
    }
    
    var altitudeRange: ClosedRange<Double> {
        switch self {
        case .rainforest:
            return 0...2000
        case .moorland:
            return 2000...3000
        case .alpineDesert:
            return 3000...5000
        case .summit:
            return 5000...8848
        }
    }
    
    var challenges: [String] {
        switch self {
        case .rainforest:
            return ["High humidity", "Dense vegetation", "Wildlife encounters"]
        case .moorland:
            return ["Temperature changes", "Wind exposure", "Limited shelter"]
        case .alpineDesert:
            return ["Extreme temperatures", "High altitude", "Rocky terrain"]
        case .summit:
            return ["Death zone", "Extreme cold", "Oxygen deprivation"]
        }
    }
    
    var tips: [String] {
        switch self {
        case .rainforest:
            return ["Stay hydrated", "Watch for wildlife", "Use insect repellent"]
        case .moorland:
            return ["Layer clothing", "Watch weather changes", "Find shelter"]
        case .alpineDesert:
            return ["Protect from sun", "Manage altitude", "Use proper gear"]
        case .summit:
            return ["Use oxygen", "Limit time", "Descend quickly"]
        }
    }
}

struct EnvironmentalZoneTransition {
    let from: EnvironmentalZoneType
    let to: EnvironmentalZoneType
    let altitude: Double
    let timestamp: Date
    
    var message: String {
        switch (from, to) {
        case (.rainforest, .moorland):
            return "Leaving the rainforest behind. Welcome to the moorland zone!"
        case (.moorland, .alpineDesert):
            return "Entering the alpine desert. Conditions are becoming extreme."
        case (.alpineDesert, .summit):
            return "You've reached the death zone. Every step counts now."
        default:
            return "Environmental zone transition detected."
        }
    }
    
    var warningLevel: RiskFactor.RiskSeverity {
        switch (from, to) {
        case (.alpineDesert, .summit):
            return .extreme
        case (.moorland, .alpineDesert):
            return .high
        case (.rainforest, .moorland):
            return .moderate
        default:
            return .low
        }
    }
}
