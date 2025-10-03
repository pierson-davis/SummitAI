import Foundation
import Combine
import SwiftUI
import FirebaseDatabase

// MARK: - Multiplayer Manager

class MultiplayerManager: ObservableObject {
    @Published var activeSessions: [ClimbingSession] = []
    @Published var currentSession: ClimbingSession?
    @Published var teamMembers: [TeamMember] = []
    @Published var ghostClimbers: [GhostClimber] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isConnected = false
    
    private var cancellables = Set<AnyCancellable>()
    private let database = Database.database()
    private let sessionsRef = Database.database().reference().child("climbing_sessions")
    private let usersRef = Database.database().reference().child("users")
    private var sessionListener: DatabaseHandle?
    private var teamListener: DatabaseHandle?
    
    init() {
        print("MultiplayerManager: Initializing MultiplayerManager")
        setupFirebaseListeners()
        print("MultiplayerManager: Initialization complete")
    }
    
    deinit {
        removeFirebaseListeners()
    }
    
    // MARK: - Session Management
    
    func createSession(mountainId: UUID, maxParticipants: Int = 4, isPublic: Bool = true) {
        isLoading = true
        
        let session = ClimbingSession(
            id: UUID(),
            mountainId: mountainId,
            hostUserId: getCurrentUserId(),
            maxParticipants: maxParticipants,
            isPublic: isPublic,
            status: .waiting,
            createdAt: Date()
        )
        
        // Save to Firebase
        let sessionData: [String: Any] = [
            "id": session.id.uuidString,
            "mountainId": session.mountainId.uuidString,
            "hostUserId": session.hostUserId,
            "maxParticipants": session.maxParticipants,
            "isPublic": session.isPublic,
            "status": session.status.rawValue,
            "createdAt": session.createdAt.timeIntervalSince1970,
            "participants": [:],
            "teamProgress": [:],
            "challenges": [:]
        ]
        
        sessionsRef.child(session.id.uuidString).setValue(sessionData) { [weak self] error, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Failed to create session: \(error.localizedDescription)"
                } else {
                    self?.currentSession = session
                    self?.joinSession(session.id)
                }
            }
        }
    }
    
    func joinSession(_ sessionId: UUID) {
        guard let currentUserId = getCurrentUserId() else { return }
        
        isLoading = true
        
        let participantData: [String: Any] = [
            "userId": currentUserId,
            "joinedAt": Date().timeIntervalSince1970,
            "isReady": false,
            "progress": [
                "steps": 0,
                "elevation": 0.0,
                "currentCampId": "",
                "altitude": 0.0
            ]
        ]
        
        sessionsRef.child(sessionId.uuidString).child("participants").child(currentUserId).setValue(participantData) { [weak self] error, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Failed to join session: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func leaveSession() {
        guard let session = currentSession,
              let currentUserId = getCurrentUserId() else { return }
        
        sessionsRef.child(session.id.uuidString).child("participants").child(currentUserId).removeValue { [weak self] error, _ in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to leave session: \(error.localizedDescription)"
                } else {
                    self?.currentSession = nil
                    self?.teamMembers = []
                }
            }
        }
    }
    
    func startSession() {
        guard let session = currentSession,
              session.hostUserId == getCurrentUserId() else { return }
        
        let updates: [String: Any] = [
            "status": ClimbingSessionStatus.inProgress.rawValue,
            "startedAt": Date().timeIntervalSince1970
        ]
        
        sessionsRef.child(session.id.uuidString).updateChildValues(updates) { [weak self] error, _ in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to start session: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func endSession() {
        guard let session = currentSession,
              session.hostUserId == getCurrentUserId() else { return }
        
        let updates: [String: Any] = [
            "status": ClimbingSessionStatus.completed.rawValue,
            "endedAt": Date().timeIntervalSince1970
        ]
        
        sessionsRef.child(session.id.uuidString).updateChildValues(updates) { [weak self] error, _ in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to end session: \(error.localizedDescription)"
                } else {
                    self?.currentSession = nil
                    self?.teamMembers = []
                }
            }
        }
    }
    
    // MARK: - Real-time Updates
    
    func updateProgress(steps: Int, elevation: Double, currentCampId: UUID?, altitude: Double) {
        guard let session = currentSession,
              let currentUserId = getCurrentUserId() else { return }
        
        let progressData: [String: Any] = [
            "steps": steps,
            "elevation": elevation,
            "currentCampId": currentCampId?.uuidString ?? "",
            "altitude": altitude,
            "updatedAt": Date().timeIntervalSince1970
        ]
        
        sessionsRef.child(session.id.uuidString).child("participants").child(currentUserId).child("progress").updateChildValues(progressData)
    }
    
    func sendMessage(_ message: String, type: MessageType = .chat) {
        guard let session = currentSession,
              let currentUserId = getCurrentUserId() else { return }
        
        let messageData: [String: Any] = [
            "id": UUID().uuidString,
            "userId": currentUserId,
            "message": message,
            "type": type.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        sessionsRef.child(session.id.uuidString).child("messages").childByAutoId().setValue(messageData)
    }
    
    func updateTeamChallenge(_ challengeId: UUID, progress: Int) {
        guard let session = currentSession,
              let currentUserId = getCurrentUserId() else { return }
        
        let challengeData: [String: Any] = [
            "challengeId": challengeId.uuidString,
            "userId": currentUserId,
            "progress": progress,
            "updatedAt": Date().timeIntervalSince1970
        ]
        
        sessionsRef.child(session.id.uuidString).child("challenges").child(challengeId.uuidString).child(currentUserId).setValue(challengeData)
    }
    
    // MARK: - Ghost Climbers
    
    func addGhostClimber(_ climber: GhostClimber) {
        ghostClimbers.append(climber)
    }
    
    func removeGhostClimber(_ climberId: UUID) {
        ghostClimbers.removeAll { $0.id == climberId }
    }
    
    func updateGhostClimberProgress(_ climberId: UUID, steps: Int, elevation: Double, altitude: Double) {
        if let index = ghostClimbers.firstIndex(where: { $0.id == climberId }) {
            ghostClimbers[index].currentSteps = steps
            ghostClimbers[index].currentElevation = elevation
            ghostClimbers[index].currentAltitude = altitude
        }
    }
    
    // MARK: - Firebase Listeners
    
    private func setupFirebaseListeners() {
        // Listen for active sessions
        sessionListener = sessionsRef.observe(.value) { [weak self] snapshot in
            DispatchQueue.main.async {
                self?.processSessionsSnapshot(snapshot)
            }
        }
        
        // Listen for current session updates
        if let sessionId = currentSession?.id {
            teamListener = sessionsRef.child(sessionId.uuidString).observe(.value) { [weak self] snapshot in
                DispatchQueue.main.async {
                    self?.processSessionSnapshot(snapshot)
                }
            }
        }
    }
    
    private func removeFirebaseListeners() {
        if let sessionListener = sessionListener {
            sessionsRef.removeObserver(withHandle: sessionListener)
        }
        
        if let teamListener = teamListener {
            sessionsRef.removeObserver(withHandle: teamListener)
        }
    }
    
    private func processSessionsSnapshot(_ snapshot: DataSnapshot) {
        var sessions: [ClimbingSession] = []
        
        for child in snapshot.children {
            if let childSnapshot = child as? DataSnapshot,
               let data = childSnapshot.value as? [String: Any] {
                
                if let session = ClimbingSession.fromFirebaseData(data) {
                    sessions.append(session)
                }
            }
        }
        
        activeSessions = sessions.filter { $0.status == .waiting || $0.status == .inProgress }
        isConnected = true
    }
    
    private func processSessionSnapshot(_ snapshot: DataSnapshot) {
        guard let data = snapshot.value as? [String: Any] else { return }
        
        if let session = ClimbingSession.fromFirebaseData(data) {
            currentSession = session
            
            // Process participants
            if let participantsData = data["participants"] as? [String: Any] {
                processParticipants(participantsData)
            }
            
            // Process team challenges
            if let challengesData = data["challenges"] as? [String: Any] {
                processTeamChallenges(challengesData)
            }
        }
    }
    
    private func processParticipants(_ participantsData: [String: Any]) {
        var members: [TeamMember] = []
        
        for (userId, userData) in participantsData {
            if let userInfo = userData as? [String: Any],
               let member = TeamMember.fromFirebaseData(userId: userId, data: userInfo) {
                members.append(member)
            }
        }
        
        teamMembers = members
    }
    
    private func processTeamChallenges(_ challengesData: [String: Any]) {
        // Process team challenge progress
        // This would update team challenge states
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentUserId() -> String {
        // This should return the current user's ID from your auth system
        // For now, return a mock user ID
        return "mock_user_id"
    }
    
    // MARK: - Mock Data for Development
    
    func createMockSession() {
        let mockSession = ClimbingSession(
            id: UUID(),
            mountainId: Mountain.kilimanjaro.id,
            hostUserId: "mock_user_id",
            maxParticipants: 4,
            isPublic: true,
            status: .inProgress,
            createdAt: Date()
        )
        
        currentSession = mockSession
        
        // Add mock team members
        teamMembers = [
            TeamMember(
                userId: "mock_user_id",
                displayName: "You",
                avatar: CharacterAvatar(skinTone: .medium, hairColor: .brown, eyeColor: .blue, facialFeatures: .clean, clothing: .athletic),
                isReady: true,
                progress: ClimbingProgress(steps: 15000, elevation: 500, currentCampId: Mountain.kilimanjaro.camps[1].id, altitude: 2700)
            ),
            TeamMember(
                userId: "mock_user_2",
                displayName: "Alex",
                avatar: CharacterAvatar(skinTone: .light, hairColor: .blonde, eyeColor: .green, facialFeatures: .mustache, clothing: .rugged),
                isReady: true,
                progress: ClimbingProgress(steps: 12000, elevation: 400, currentCampId: Mountain.kilimanjaro.camps[1].id, altitude: 2600)
            ),
            TeamMember(
                userId: "mock_user_3",
                displayName: "Sam",
                avatar: CharacterAvatar(skinTone: .dark, hairColor: .black, eyeColor: .brown, facialFeatures: .beard, clothing: .athletic),
                isReady: false,
                progress: ClimbingProgress(steps: 8000, elevation: 300, currentCampId: Mountain.kilimanjaro.camps[1].id, altitude: 2500)
            )
        ]
        
        // Add mock ghost climbers
        ghostClimbers = [
            GhostClimber(
                id: UUID(),
                displayName: "Emma",
                avatar: CharacterAvatar(skinTone: .medium, hairColor: .red, eyeColor: .blue, facialFeatures: .clean, clothing: .adventurous),
                currentSteps: 18000,
                currentElevation: 600,
                currentAltitude: 2800,
                isOnline: true
            ),
            GhostClimber(
                id: UUID(),
                displayName: "Jake",
                avatar: CharacterAvatar(skinTone: .light, hairColor: .brown, eyeColor: .hazel, facialFeatures: .goatee, clothing: .professional),
                currentSteps: 22000,
                currentElevation: 700,
                currentAltitude: 2900,
                isOnline: false
            )
        ]
    }
}

// MARK: - Supporting Models

struct ClimbingSession: Identifiable, Codable {
    let id: UUID
    let mountainId: UUID
    let hostUserId: String
    let maxParticipants: Int
    let isPublic: Bool
    var status: ClimbingSessionStatus
    let createdAt: Date
    var startedAt: Date?
    var endedAt: Date?
    var participants: [String: TeamMember] = [:]
    var teamProgress: [String: ClimbingProgress] = [:]
    var challenges: [String: TeamChallenge] = [:]
    
    enum ClimbingSessionStatus: String, CaseIterable, Codable {
        case waiting = "Waiting"
        case inProgress = "In Progress"
        case completed = "Completed"
        case cancelled = "Cancelled"
        
        var color: Color {
            switch self {
            case .waiting: return .yellow
            case .inProgress: return .green
            case .completed: return .blue
            case .cancelled: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .waiting: return "clock.fill"
            case .inProgress: return "play.fill"
            case .completed: return "checkmark.circle.fill"
            case .cancelled: return "xmark.circle.fill"
            }
        }
    }
    
    static func fromFirebaseData(_ data: [String: Any]) -> ClimbingSession? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let mountainIdString = data["mountainId"] as? String,
              let mountainId = UUID(uuidString: mountainIdString),
              let hostUserId = data["hostUserId"] as? String,
              let maxParticipants = data["maxParticipants"] as? Int,
              let isPublic = data["isPublic"] as? Bool,
              let statusString = data["status"] as? String,
              let status = ClimbingSessionStatus(rawValue: statusString),
              let createdAtInterval = data["createdAt"] as? TimeInterval else {
            return nil
        }
        
        var session = ClimbingSession(
            id: id,
            mountainId: mountainId,
            hostUserId: hostUserId,
            maxParticipants: maxParticipants,
            isPublic: isPublic,
            status: status,
            createdAt: Date(timeIntervalSince1970: createdAtInterval)
        )
        
        if let startedAtInterval = data["startedAt"] as? TimeInterval {
            session.startedAt = Date(timeIntervalSince1970: startedAtInterval)
        }
        
        if let endedAtInterval = data["endedAt"] as? TimeInterval {
            session.endedAt = Date(timeIntervalSince1970: endedAtInterval)
        }
        
        return session
    }
}

struct TeamMember: Identifiable, Codable {
    let userId: String
    let displayName: String
    let avatar: CharacterAvatar
    var isReady: Bool
    var progress: ClimbingProgress
    var joinedAt: Date
    var lastSeen: Date
    
    var id: String { userId }
    
    init(userId: String, displayName: String, avatar: CharacterAvatar, isReady: Bool, progress: ClimbingProgress) {
        self.userId = userId
        self.displayName = displayName
        self.avatar = avatar
        self.isReady = isReady
        self.progress = progress
        self.joinedAt = Date()
        self.lastSeen = Date()
    }
    
    static func fromFirebaseData(userId: String, data: [String: Any]) -> TeamMember? {
        guard let displayName = data["displayName"] as? String,
              let isReady = data["isReady"] as? Bool,
              let progressData = data["progress"] as? [String: Any],
              let progress = ClimbingProgress.fromFirebaseData(progressData) else {
            return nil
        }
        
        // Mock avatar for now
        let avatar = CharacterAvatar(skinTone: .medium, hairColor: .brown, eyeColor: .blue, facialFeatures: .clean, clothing: .athletic)
        
        return TeamMember(
            userId: userId,
            displayName: displayName,
            avatar: avatar,
            isReady: isReady,
            progress: progress
        )
    }
}

struct ClimbingProgress: Codable {
    var steps: Int
    var elevation: Double
    var currentCampId: UUID?
    var altitude: Double
    var updatedAt: Date
    
    init(steps: Int, elevation: Double, currentCampId: UUID?, altitude: Double) {
        self.steps = steps
        self.elevation = elevation
        self.currentCampId = currentCampId
        self.altitude = altitude
        self.updatedAt = Date()
    }
    
    static func fromFirebaseData(_ data: [String: Any]) -> ClimbingProgress? {
        guard let steps = data["steps"] as? Int,
              let elevation = data["elevation"] as? Double,
              let altitude = data["altitude"] as? Double else {
            return nil
        }
        
        var currentCampId: UUID?
        if let campIdString = data["currentCampId"] as? String, !campIdString.isEmpty {
            currentCampId = UUID(uuidString: campIdString)
        }
        
        return ClimbingProgress(
            steps: steps,
            elevation: elevation,
            currentCampId: currentCampId,
            altitude: altitude
        )
    }
}

struct GhostClimber: Identifiable, Codable {
    let id: UUID
    let displayName: String
    let avatar: CharacterAvatar
    var currentSteps: Int
    var currentElevation: Double
    var currentAltitude: Double
    var isOnline: Bool
    var lastSeen: Date
    
    init(id: UUID, displayName: String, avatar: CharacterAvatar, currentSteps: Int, currentElevation: Double, currentAltitude: Double, isOnline: Bool) {
        self.id = id
        self.displayName = displayName
        self.avatar = avatar
        self.currentSteps = currentSteps
        self.currentElevation = currentElevation
        self.currentAltitude = currentAltitude
        self.isOnline = isOnline
        self.lastSeen = Date()
    }
}

struct TeamChallenge: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let type: ChallengeType
    let targetValue: Int
    var currentProgress: Int
    var isCompleted: Bool
    let reward: ChallengeReward
    let participants: [String] // User IDs
    var participantProgress: [String: Int] = [:]
    
    enum ChallengeType: String, CaseIterable, Codable {
        case steps = "Steps"
        case elevation = "Elevation"
        case time = "Time"
        case teamwork = "Teamwork"
        
        var icon: String {
            switch self {
            case .steps: return "figure.walk"
            case .elevation: return "arrow.up"
            case .time: return "clock"
            case .teamwork: return "person.3.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .steps: return .green
            case .elevation: return .blue
            case .time: return .orange
            case .teamwork: return .purple
            }
        }
    }
    
    struct ChallengeReward: Codable {
        let experience: Int
        let gear: GearItem?
        let title: String?
        
        init(experience: Int = 0, gear: GearItem? = nil, title: String? = nil) {
            self.experience = experience
            self.gear = gear
            self.title = title
        }
    }
}

enum MessageType: String, CaseIterable, Codable {
    case chat = "Chat"
    case system = "System"
    case challenge = "Challenge"
    case achievement = "Achievement"
    
    var color: Color {
        switch self {
        case .chat: return .blue
        case .system: return .gray
        case .challenge: return .orange
        case .achievement: return .yellow
        }
    }
}
