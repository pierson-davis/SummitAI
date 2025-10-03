# SummitAI Gamification Implementation Plan

## Phase 1: Survival Mechanics & Environmental Hazards

### 1.1 Frostbite System Implementation

#### Core Models
```swift
// MARK: - Survival System Models
struct SurvivalState: Codable {
    var bodyTemperature: Double // 0.0 - 1.0 (1.0 = optimal)
    var windChill: Double // 0.0 - 1.0 (1.0 = extreme)
    var altitude: Double // meters
    var gearQuality: Double // 0.0 - 1.0 (1.0 = best gear)
    var activityLevel: Double // 0.0 - 1.0 (1.0 = high activity)
    var hydration: Double // 0.0 - 1.0 (1.0 = fully hydrated)
    var nutrition: Double // 0.0 - 1.0 (1.0 = well fed)
    var lastUpdate: Date
    var frostbiteRisk: Double { calculateFrostbiteRisk() }
    
    private func calculateFrostbiteRisk() -> Double {
        let baseRisk = (1.0 - bodyTemperature) * 0.4
        let windFactor = windChill * 0.3
        let altitudeFactor = min(1.0, altitude / 8000.0) * 0.2
        let gearProtection = gearQuality * 0.4
        let hydrationFactor = (1.0 - hydration) * 0.1
        
        return max(0.0, min(1.0, baseRisk + windFactor + altitudeFactor - gearProtection + hydrationFactor))
    }
}

struct WeatherCondition: Codable {
    var temperature: Double // Celsius
    var windSpeed: Double // km/h
    var windDirection: Double // degrees
    var humidity: Double // 0.0 - 1.0
    var precipitation: Double // 0.0 - 1.0
    var visibility: Double // 0.0 - 1.0
    var pressure: Double // hPa
    var timestamp: Date
    var severity: WeatherSeverity { calculateSeverity() }
    
    private func calculateSeverity() -> WeatherSeverity {
        let windChill = temperature - (windSpeed * 0.7)
        let combinedRisk = (windChill < -20 ? 0.8 : 0.0) + (precipitation > 0.7 ? 0.6 : 0.0) + (visibility < 0.3 ? 0.4 : 0.0)
        
        switch combinedRisk {
        case 0.8...: return .extreme
        case 0.6..<0.8: return .severe
        case 0.4..<0.6: return .moderate
        default: return .mild
        }
    }
}

enum WeatherSeverity: String, CaseIterable, Codable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
    case extreme = "Extreme"
    
    var color: Color {
        switch self {
        case .mild: return .green
        case .moderate: return .yellow
        case .severe: return .orange
        case .extreme: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .mild: return "sun.max.fill"
        case .moderate: return "cloud.sun.fill"
        case .severe: return "cloud.rain.fill"
        case .extreme: return "cloud.bolt.fill"
        }
    }
}
```

#### Survival Manager
```swift
// MARK: - Survival Manager
class SurvivalManager: ObservableObject {
    @Published var survivalState = SurvivalState(
        bodyTemperature: 1.0,
        windChill: 0.0,
        altitude: 0.0,
        gearQuality: 0.5,
        activityLevel: 0.5,
        hydration: 1.0,
        nutrition: 1.0,
        lastUpdate: Date()
    )
    
    @Published var weatherCondition = WeatherCondition(
        temperature: 20.0,
        windSpeed: 0.0,
        windDirection: 0.0,
        humidity: 0.5,
        precipitation: 0.0,
        visibility: 1.0,
        pressure: 1013.25,
        timestamp: Date()
    )
    
    @Published var warnings: [SurvivalWarning] = []
    
    private var timer: Timer?
    
    init() {
        startSurvivalMonitoring()
    }
    
    func startSurvivalMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            self.updateSurvivalState()
        }
    }
    
    func updateSurvivalState() {
        // Update based on current activity and environmental conditions
        let currentActivity = getCurrentActivityLevel()
        let environmentalImpact = calculateEnvironmentalImpact()
        
        // Update body temperature based on activity and environment
        let temperatureChange = (currentActivity * 0.1) - (environmentalImpact * 0.05)
        survivalState.bodyTemperature = max(0.0, min(1.0, survivalState.bodyTemperature + temperatureChange))
        
        // Update other survival metrics
        survivalState.activityLevel = currentActivity
        survivalState.lastUpdate = Date()
        
        // Check for warnings
        checkSurvivalWarnings()
    }
    
    private func getCurrentActivityLevel() -> Double {
        // This would integrate with HealthKit to get current activity level
        // For now, return a mock value
        return 0.7
    }
    
    private func calculateEnvironmentalImpact() -> Double {
        let windChill = weatherCondition.temperature - (weatherCondition.windSpeed * 0.7)
        let altitudeFactor = survivalState.altitude / 8000.0
        let weatherFactor = weatherCondition.severity.rawValue == "Extreme" ? 0.8 : 0.3
        
        return max(0.0, min(1.0, (windChill < 0 ? abs(windChill) / 50.0 : 0.0) + altitudeFactor + weatherFactor))
    }
    
    private func checkSurvivalWarnings() {
        warnings.removeAll()
        
        if survivalState.frostbiteRisk > 0.7 {
            warnings.append(SurvivalWarning(
                type: .frostbite,
                severity: .critical,
                message: "⚠️ EXTREME FROSTBITE RISK! Seek shelter immediately!",
                timestamp: Date()
            ))
        } else if survivalState.frostbiteRisk > 0.5 {
            warnings.append(SurvivalWarning(
                type: .frostbite,
                severity: .high,
                message: "❄️ High frostbite risk. Keep moving and stay warm!",
                timestamp: Date()
            ))
        }
        
        if survivalState.hydration < 0.3 {
            warnings.append(SurvivalWarning(
                type: .hydration,
                severity: .high,
                message: "💧 Dehydration risk! Drink water immediately!",
                timestamp: Date()
            ))
        }
        
        if survivalState.nutrition < 0.3 {
            warnings.append(SurvivalWarning(
                type: .nutrition,
                severity: .medium,
                message: "🍎 Low energy! Eat something to maintain strength!",
                timestamp: Date()
            ))
        }
    }
}

struct SurvivalWarning: Identifiable, Codable {
    let id = UUID()
    let type: WarningType
    let severity: WarningSeverity
    let message: String
    let timestamp: Date
    
    enum WarningType: String, Codable {
        case frostbite = "frostbite"
        case hydration = "hydration"
        case nutrition = "nutrition"
        case weather = "weather"
        case gear = "gear"
    }
    
    enum WarningSeverity: String, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case critical = "critical"
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }
    }
}
```

### 1.2 Enhanced Mountain Model with Environmental Zones

```swift
// MARK: - Enhanced Mountain Model
extension Mountain {
    struct EnvironmentalZone: Codable {
        let name: String
        let altitudeRange: ClosedRange<Double>
        let temperatureRange: ClosedRange<Double>
        let windFactor: Double
        let oxygenLevel: Double
        let frostbiteRisk: Double
        let weatherPatterns: [WeatherPattern]
        let requiredGear: [GearRequirement]
        let survivalTips: [String]
    }
    
    struct WeatherPattern: Codable {
        let name: String
        let probability: Double
        let severity: WeatherSeverity
        let duration: TimeInterval
        let effects: [WeatherEffect]
    }
    
    struct WeatherEffect: Codable {
        let type: EffectType
        let intensity: Double
        let duration: TimeInterval
        
        enum EffectType: String, Codable {
            case temperature = "temperature"
            case wind = "wind"
            case visibility = "visibility"
            case precipitation = "precipitation"
        }
    }
    
    struct GearRequirement: Codable {
        let gearType: GearType
        let minimumQuality: Double
        let critical: Bool
        let description: String
        
        enum GearType: String, Codable {
            case clothing = "clothing"
            case footwear = "footwear"
            case headgear = "headgear"
            case gloves = "gloves"
            case equipment = "equipment"
        }
    }
}

// MARK: - Enhanced Kilimanjaro with Environmental Zones
extension Mountain {
    static let kilimanjaroEnhanced = Mountain(
        name: "Mount Kilimanjaro",
        height: 5895,
        location: "Tanzania, Africa",
        difficulty: .intermediate,
        description: "The highest peak in Africa with diverse climate zones from tropical to arctic.",
        imageName: "kilimanjaro",
        isPremium: false,
        camps: [
            Camp(name: "Base Camp", altitude: 1828, stepsRequired: 0, elevationRequired: 0, 
                 description: "Starting point through tropical rainforest", 
                 unlockedMessage: "Welcome to Mount Kilimanjaro! The journey begins in the rainforest.", 
                 isBaseCamp: true, isSummit: false),
            Camp(name: "Camp 1 - Mandara", altitude: 2700, stepsRequired: 1500, elevationRequired: 500, 
                 description: "First camp through the rainforest zone", 
                 unlockedMessage: "You've reached the rainforest zone! Watch for wildlife and stay hydrated.", 
                 isBaseCamp: false, isSummit: false),
            Camp(name: "Camp 2 - Horombo", altitude: 3720, stepsRequired: 3500, elevationRequired: 1200, 
                 description: "High altitude moorland camp", 
                 unlockedMessage: "Entering the moorland zone! The air is getting thinner.", 
                 isBaseCamp: false, isSummit: false),
            Camp(name: "Camp 3 - Kibo", altitude: 4700, stepsRequired: 6000, elevationRequired: 2000, 
                 description: "Base camp for summit attempt", 
                 unlockedMessage: "Final camp before the summit! Prepare for extreme conditions.", 
                 isBaseCamp: false, isSummit: false),
            Camp(name: "Uhuru Peak", altitude: 5895, stepsRequired: 5895, elevationRequired: 3000, 
                 description: "The summit of Mount Kilimanjaro", 
                 unlockedMessage: "Congratulations! You've conquered Kilimanjaro and reached the roof of Africa!", 
                 isBaseCamp: false, isSummit: true)
        ],
        baseSteps: 5895,
        baseElevation: 3000
    )
    
    var environmentalZones: [EnvironmentalZone] {
        switch self.name {
        case "Mount Kilimanjaro":
            return [
                EnvironmentalZone(
                    name: "Rainforest Zone",
                    altitudeRange: 1800...2700,
                    temperatureRange: 20...30,
                    windFactor: 0.1,
                    oxygenLevel: 1.0,
                    frostbiteRisk: 0.0,
                    weatherPatterns: [
                        WeatherPattern(name: "Tropical Rain", probability: 0.3, severity: .moderate, 
                                     duration: 3600, effects: [WeatherEffect(type: .precipitation, intensity: 0.7, duration: 3600)])
                    ],
                    requiredGear: [
                        GearRequirement(gearType: .clothing, minimumQuality: 0.3, critical: false, 
                                      description: "Light, breathable clothing")
                    ],
                    survivalTips: ["Stay hydrated in the heat", "Watch for wildlife", "Use insect repellent"]
                ),
                EnvironmentalZone(
                    name: "Moorland Zone",
                    altitudeRange: 2700...4000,
                    temperatureRange: 10...20,
                    windFactor: 0.3,
                    oxygenLevel: 0.8,
                    frostbiteRisk: 0.1,
                    weatherPatterns: [
                        WeatherPattern(name: "High Winds", probability: 0.4, severity: .moderate, 
                                     duration: 7200, effects: [WeatherEffect(type: .wind, intensity: 0.6, duration: 7200)])
                    ],
                    requiredGear: [
                        GearRequirement(gearType: .clothing, minimumQuality: 0.5, critical: true, 
                                      description: "Warm, windproof clothing")
                    ],
                    survivalTips: ["Layer your clothing", "Watch for altitude sickness", "Stay warm"]
                ),
                EnvironmentalZone(
                    name: "Alpine Desert Zone",
                    altitudeRange: 4000...5000,
                    temperatureRange: -5...10,
                    windFactor: 0.6,
                    oxygenLevel: 0.6,
                    frostbiteRisk: 0.4,
                    weatherPatterns: [
                        WeatherPattern(name: "Blizzard", probability: 0.2, severity: .severe, 
                                     duration: 10800, effects: [
                                        WeatherEffect(type: .temperature, intensity: 0.8, duration: 10800),
                                        WeatherEffect(type: .wind, intensity: 0.9, duration: 10800),
                                        WeatherEffect(type: .visibility, intensity: 0.3, duration: 10800)
                                     ])
                    ],
                    requiredGear: [
                        GearRequirement(gearType: .clothing, minimumQuality: 0.8, critical: true, 
                                      description: "Extreme cold weather gear"),
                        GearRequirement(gearType: .headgear, minimumQuality: 0.7, critical: true, 
                                      description: "Warm hat and face protection")
                    ],
                    survivalTips: ["Extreme cold conditions", "High frostbite risk", "Oxygen levels dropping"]
                ),
                EnvironmentalZone(
                    name: "Summit Zone",
                    altitudeRange: 5000...5895,
                    temperatureRange: -20...0,
                    windFactor: 0.9,
                    oxygenLevel: 0.4,
                    frostbiteRisk: 0.8,
                    weatherPatterns: [
                        WeatherPattern(name: "Extreme Storm", probability: 0.3, severity: .extreme, 
                                     duration: 14400, effects: [
                                        WeatherEffect(type: .temperature, intensity: 1.0, duration: 14400),
                                        WeatherEffect(type: .wind, intensity: 1.0, duration: 14400),
                                        WeatherEffect(type: .visibility, intensity: 0.1, duration: 14400)
                                     ])
                    ],
                    requiredGear: [
                        GearRequirement(gearType: .clothing, minimumQuality: 1.0, critical: true, 
                                      description: "Extreme altitude gear"),
                        GearRequirement(gearType: .headgear, minimumQuality: 1.0, critical: true, 
                                      description: "Full face protection"),
                        GearRequirement(gearType: .gloves, minimumQuality: 1.0, critical: true, 
                                      description: "Extreme cold gloves")
                    ],
                    survivalTips: ["EXTREME CONDITIONS", "Maximum frostbite risk", "Very low oxygen", "Summit attempt only in good weather"]
                )
            ]
        default:
            return []
        }
    }
}
```

### 1.3 Enhanced HomeView with Survival Mechanics

```swift
// MARK: - Enhanced HomeView with Survival Mechanics
extension HomeView {
    private var survivalStatusView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Survival Status")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Weather indicator
                HStack(spacing: 4) {
                    Image(systemName: weatherCondition.icon)
                        .foregroundColor(weatherCondition.severity.color)
                    Text(weatherCondition.severity.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Survival metrics
            HStack(spacing: 20) {
                // Body Temperature
                VStack(spacing: 8) {
                    Image(systemName: "thermometer")
                        .font(.title2)
                        .foregroundColor(bodyTemperatureColor)
                    
                    Text("\(Int(survivalState.bodyTemperature * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Body Temp")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                
                // Frostbite Risk
                VStack(spacing: 8) {
                    Image(systemName: "snowflake")
                        .font(.title2)
                        .foregroundColor(frostbiteRiskColor)
                    
                    Text("\(Int(survivalState.frostbiteRisk * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Frostbite Risk")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                
                // Hydration
                VStack(spacing: 8) {
                    Image(systemName: "drop.fill")
                        .font(.title2)
                        .foregroundColor(hydrationColor)
                    
                    Text("\(Int(survivalState.hydration * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Hydration")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Survival warnings
            if !warnings.isEmpty {
                VStack(spacing: 8) {
                    ForEach(warnings) { warning in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(warning.severity.color)
                            
                            Text(warning.message)
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding()
                        .background(warning.severity.color.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var bodyTemperatureColor: Color {
        switch survivalState.bodyTemperature {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .yellow
        case 0.4..<0.6: return .orange
        default: return .red
        }
    }
    
    private var frostbiteRiskColor: Color {
        switch survivalState.frostbiteRisk {
        case 0.0..<0.3: return .green
        case 0.3..<0.5: return .yellow
        case 0.5..<0.7: return .orange
        default: return .red
        }
    }
    
    private var hydrationColor: Color {
        switch survivalState.hydration {
        case 0.7...1.0: return .green
        case 0.4..<0.7: return .yellow
        case 0.2..<0.4: return .orange
        default: return .red
        }
    }
}
```

## Phase 2: Multiplayer & Social Features

### 2.1 Multiplayer Models

```swift
// MARK: - Multiplayer Models
struct ClimbingSession: Identifiable, Codable {
    let id: UUID
    let mountainId: UUID
    let hostId: UUID
    var participants: [ClimbingParticipant]
    let startTime: Date
    var endTime: Date?
    var status: SessionStatus
    var sharedResources: [SharedResource]
    var teamChallenges: [TeamChallenge]
    var chatMessages: [ChatMessage]
    
    init(mountainId: UUID, hostId: UUID) {
        self.id = UUID()
        self.mountainId = mountainId
        self.hostId = hostId
        self.participants = []
        self.startTime = Date()
        self.status = .waiting
        self.sharedResources = []
        self.teamChallenges = []
        self.chatMessages = []
    }
}

struct ClimbingParticipant: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let displayName: String
    let avatar: String
    var currentAltitude: Double
    var currentCampId: UUID?
    var isOnline: Bool
    var lastSeen: Date
    var progress: Double
    var survivalState: SurvivalState
    var gear: [GearItem]
    
    init(userId: UUID, displayName: String, avatar: String) {
        self.id = UUID()
        self.userId = userId
        self.displayName = displayName
        self.avatar = avatar
        self.currentAltitude = 0.0
        self.isOnline = true
        self.lastSeen = Date()
        self.progress = 0.0
        self.survivalState = SurvivalState(
            bodyTemperature: 1.0,
            windChill: 0.0,
            altitude: 0.0,
            gearQuality: 0.5,
            activityLevel: 0.5,
            hydration: 1.0,
            nutrition: 1.0,
            lastUpdate: Date()
        )
        self.gear = []
    }
}

enum SessionStatus: String, Codable {
    case waiting = "waiting"
    case active = "active"
    case paused = "paused"
    case completed = "completed"
    case cancelled = "cancelled"
}

struct SharedResource: Identifiable, Codable {
    let id: UUID
    let type: ResourceType
    let quantity: Int
    let location: String
    let addedBy: UUID
    let timestamp: Date
    
    enum ResourceType: String, Codable {
        case food = "food"
        case water = "water"
        case medical = "medical"
        case gear = "gear"
        case fuel = "fuel"
    }
}

struct TeamChallenge: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let type: ChallengeType
    let target: Int
    var currentProgress: Int
    let reward: ChallengeReward
    let timeLimit: TimeInterval?
    let startTime: Date
    var isCompleted: Bool
    
    enum ChallengeType: String, Codable {
        case steps = "steps"
        case altitude = "altitude"
        case survival = "survival"
        case teamwork = "teamwork"
    }
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let senderId: UUID
    let senderName: String
    let message: String
    let timestamp: Date
    let type: MessageType
    
    enum MessageType: String, Codable {
        case text = "text"
        case system = "system"
        case achievement = "achievement"
        case warning = "warning"
    }
}
```

### 2.2 Multiplayer Manager

```swift
// MARK: - Multiplayer Manager
class MultiplayerManager: ObservableObject {
    @Published var currentSession: ClimbingSession?
    @Published var availableSessions: [ClimbingSession] = []
    @Published var participants: [ClimbingParticipant] = []
    @Published var chatMessages: [ChatMessage] = []
    @Published var isConnected = false
    
    private var firestoreManager: FirebaseManager
    private var listener: ListenerRegistration?
    
    init(firestoreManager: FirebaseManager) {
        self.firestoreManager = firestoreManager
    }
    
    func createClimbingSession(mountainId: UUID, hostId: UUID) {
        let session = ClimbingSession(mountainId: mountainId, hostId: hostId)
        currentSession = session
        
        // Save to Firestore
        firestoreManager.createClimbingSession(session) { [weak self] result in
            switch result {
            case .success:
                self?.isConnected = true
                self?.startSessionUpdates()
            case .failure(let error):
                print("Failed to create session: \(error)")
            }
        }
    }
    
    func joinClimbingSession(sessionId: UUID, userId: UUID, displayName: String) {
        firestoreManager.joinClimbingSession(sessionId: sessionId, userId: userId, displayName: displayName) { [weak self] result in
            switch result {
            case .success(let session):
                self?.currentSession = session
                self?.isConnected = true
                self?.startSessionUpdates()
            case .failure(let error):
                print("Failed to join session: \(error)")
            }
        }
    }
    
    func leaveClimbingSession() {
        guard let session = currentSession else { return }
        
        firestoreManager.leaveClimbingSession(sessionId: session.id) { [weak self] result in
            switch result {
            case .success:
                self?.currentSession = nil
                self?.isConnected = false
                self?.stopSessionUpdates()
            case .failure(let error):
                print("Failed to leave session: \(error)")
            }
        }
    }
    
    func sendChatMessage(message: String, senderId: UUID, senderName: String) {
        let chatMessage = ChatMessage(
            id: UUID(),
            senderId: senderId,
            senderName: senderName,
            message: message,
            timestamp: Date(),
            type: .text
        )
        
        chatMessages.append(chatMessage)
        
        // Send to Firestore
        firestoreManager.sendChatMessage(sessionId: currentSession?.id, message: chatMessage) { result in
            if case .failure(let error) = result {
                print("Failed to send message: \(error)")
            }
        }
    }
    
    func updateClimbingProgress(altitude: Double, campId: UUID?, progress: Double) {
        guard let session = currentSession else { return }
        
        // Update local state
        if let index = participants.firstIndex(where: { $0.userId == getCurrentUserId() }) {
            participants[index].currentAltitude = altitude
            participants[index].currentCampId = campId
            participants[index].progress = progress
            participants[index].lastSeen = Date()
        }
        
        // Update in Firestore
        firestoreManager.updateClimbingProgress(
            sessionId: session.id,
            userId: getCurrentUserId(),
            altitude: altitude,
            campId: campId,
            progress: progress
        ) { result in
            if case .failure(let error) = result {
                print("Failed to update progress: \(error)")
            }
        }
    }
    
    private func startSessionUpdates() {
        guard let session = currentSession else { return }
        
        listener = firestoreManager.listenToClimbingSession(sessionId: session.id) { [weak self] result in
            switch result {
            case .success(let updatedSession):
                self?.currentSession = updatedSession
                self?.participants = updatedSession.participants
                self?.chatMessages = updatedSession.chatMessages
            case .failure(let error):
                print("Failed to update session: \(error)")
            }
        }
    }
    
    private func stopSessionUpdates() {
        listener?.remove()
        listener = nil
    }
    
    private func getCurrentUserId() -> UUID {
        // This would get the current user ID from UserManager
        return UUID() // Placeholder
    }
}
```

## Phase 3: Character Customization & Progression

### 3.1 Character System

```swift
// MARK: - Character System
struct Character: Codable {
    let id: UUID
    let userId: UUID
    var name: String
    var avatar: String
    var level: Int
    var experience: Int
    var skillPoints: Int
    var skills: SkillTree
    var gear: [GearItem]
    var achievements: [Achievement]
    var climbingStyle: ClimbingStyle
    var personality: PersonalityTraits
    
    init(userId: UUID, name: String) {
        self.id = UUID()
        self.userId = userId
        self.name = name
        self.avatar = "default_avatar"
        self.level = 1
        self.experience = 0
        self.skillPoints = 0
        self.skills = SkillTree()
        self.gear = []
        self.achievements = []
        self.climbingStyle = .balanced
        self.personality = PersonalityTraits()
    }
}

struct SkillTree: Codable {
    var survival: SurvivalSkills
    var climbing: ClimbingSkills
    var leadership: LeadershipSkills
    var endurance: EnduranceSkills
    
    init() {
        self.survival = SurvivalSkills()
        self.climbing = ClimbingSkills()
        self.leadership = LeadershipSkills()
        self.endurance = EnduranceSkills()
    }
}

struct SurvivalSkills: Codable {
    var frostbiteResistance: Int = 0
    var weatherPrediction: Int = 0
    var resourceManagement: Int = 0
    var firstAid: Int = 0
    var navigation: Int = 0
    
    var totalPoints: Int {
        frostbiteResistance + weatherPrediction + resourceManagement + firstAid + navigation
    }
}

struct ClimbingSkills: Codable {
    var technique: Int = 0
    var strength: Int = 0
    var balance: Int = 0
    var ropeWork: Int = 0
    var routeFinding: Int = 0
    
    var totalPoints: Int {
        technique + strength + balance + ropeWork + routeFinding
    }
}

struct LeadershipSkills: Codable {
    var teamCoordination: Int = 0
    var motivation: Int = 0
    var decisionMaking: Int = 0
    var communication: Int = 0
    var crisisManagement: Int = 0
    
    var totalPoints: Int {
        teamCoordination + motivation + decisionMaking + communication + crisisManagement
    }
}

struct EnduranceSkills: Codable {
    var stamina: Int = 0
    var recovery: Int = 0
    var altitudeAdaptation: Int = 0
    var mentalToughness: Int = 0
    var focus: Int = 0
    
    var totalPoints: Int {
        stamina + recovery + altitudeAdaptation + mentalToughness + focus
    }
}

enum ClimbingStyle: String, CaseIterable, Codable {
    case speed = "speed"
    case endurance = "endurance"
    case technical = "technical"
    case balanced = "balanced"
    case social = "social"
    
    var description: String {
        switch self {
        case .speed: return "Fast and aggressive climbing"
        case .endurance: return "Steady, long-distance climbing"
        case .technical: return "Precise, skill-based climbing"
        case .balanced: return "Well-rounded climbing approach"
        case .social: return "Team-focused climbing"
        }
    }
    
    var bonuses: [SkillBonus] {
        switch self {
        case .speed:
            return [SkillBonus(skill: "strength", multiplier: 1.2), SkillBonus(skill: "stamina", multiplier: 1.1)]
        case .endurance:
            return [SkillBonus(skill: "stamina", multiplier: 1.3), SkillBonus(skill: "recovery", multiplier: 1.2)]
        case .technical:
            return [SkillBonus(skill: "technique", multiplier: 1.3), SkillBonus(skill: "balance", multiplier: 1.2)]
        case .balanced:
            return [SkillBonus(skill: "all", multiplier: 1.05)]
        case .social:
            return [SkillBonus(skill: "teamCoordination", multiplier: 1.3), SkillBonus(skill: "motivation", multiplier: 1.2)]
        }
    }
}

struct SkillBonus: Codable {
    let skill: String
    let multiplier: Double
}

struct PersonalityTraits: Codable {
    var riskTolerance: Double = 0.5 // 0.0 = very cautious, 1.0 = very risky
    var socialPreference: Double = 0.5 // 0.0 = solo, 1.0 = team
    var goalOrientation: Double = 0.5 // 0.0 = process-focused, 1.0 = result-focused
    var adaptability: Double = 0.5 // 0.0 = routine, 1.0 = flexible
    var competitiveness: Double = 0.5 // 0.0 = cooperative, 1.0 = competitive
}
```

### 3.2 Gear System

```swift
// MARK: - Gear System
struct GearItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: GearType
    let quality: Double // 0.0 - 1.0
    let rarity: GearRarity
    let stats: GearStats
    let description: String
    let imageName: String
    let isEquipped: Bool
    let unlockLevel: Int
    let mountainRestrictions: [UUID] // Mountains where this gear can be used
    
    init(name: String, type: GearType, quality: Double, rarity: GearRarity, stats: GearStats, description: String, imageName: String, unlockLevel: Int) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.quality = quality
        self.rarity = rarity
        self.stats = stats
        self.description = description
        self.imageName = imageName
        self.isEquipped = false
        self.unlockLevel = unlockLevel
        self.mountainRestrictions = []
    }
}

enum GearType: String, CaseIterable, Codable {
    case clothing = "clothing"
    case footwear = "footwear"
    case headgear = "headgear"
    case gloves = "gloves"
    case equipment = "equipment"
    case accessories = "accessories"
    
    var icon: String {
        switch self {
        case .clothing: return "tshirt.fill"
        case .footwear: return "shoe.2.fill"
        case .headgear: return "hat.fill"
        case .gloves: return "hand.raised.fill"
        case .equipment: return "backpack.fill"
        case .accessories: return "star.fill"
        }
    }
}

enum GearRarity: String, CaseIterable, Codable {
    case common = "common"
    case uncommon = "uncommon"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    var dropRate: Double {
        switch self {
        case .common: return 0.5
        case .uncommon: return 0.3
        case .rare: return 0.15
        case .epic: return 0.04
        case .legendary: return 0.01
        }
    }
}

struct GearStats: Codable {
    var frostbiteResistance: Double = 0.0
    var windResistance: Double = 0.0
    var durability: Double = 1.0
    var weight: Double = 0.0
    var mobility: Double = 1.0
    var warmth: Double = 0.0
    var breathability: Double = 1.0
    var waterproof: Double = 0.0
    var grip: Double = 1.0
    var visibility: Double = 1.0
}

// MARK: - Predefined Gear Items
extension GearItem {
    static let basicClothing = GearItem(
        name: "Basic Hiking Clothes",
        type: .clothing,
        quality: 0.3,
        rarity: .common,
        stats: GearStats(frostbiteResistance: 0.2, windResistance: 0.1, warmth: 0.3),
        description: "Standard hiking clothing for mild conditions",
        imageName: "basic_clothing",
        unlockLevel: 1
    )
    
    static let extremeWeatherGear = GearItem(
        name: "Extreme Weather Suit",
        type: .clothing,
        quality: 0.9,
        rarity: .epic,
        stats: GearStats(frostbiteResistance: 0.8, windResistance: 0.9, warmth: 0.9, waterproof: 0.8),
        description: "Professional-grade gear for extreme mountain conditions",
        imageName: "extreme_gear",
        unlockLevel: 15
    )
    
    static let legendarySummitGear = GearItem(
        name: "Summit Master's Armor",
        type: .clothing,
        quality: 1.0,
        rarity: .legendary,
        stats: GearStats(frostbiteResistance: 1.0, windResistance: 1.0, warmth: 1.0, waterproof: 1.0, mobility: 0.8),
        description: "Legendary gear worn by the greatest climbers",
        imageName: "legendary_gear",
        unlockLevel: 25
    )
}
```

This implementation plan provides a comprehensive foundation for transforming SummitAI into a highly gamified experience that appeals to Gen Z users. The phased approach ensures manageable development while delivering immediate value through survival mechanics, multiplayer features, and character progression systems.
