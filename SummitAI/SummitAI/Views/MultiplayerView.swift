import SwiftUI

struct MultiplayerView: View {
    @EnvironmentObject var multiplayerManager: MultiplayerManager
    @EnvironmentObject var expeditionManager: ExpeditionManager
    @State private var selectedTab = 0
    @State private var showCreateSession = false
    @State private var showJoinSession = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Tab selection
                    tabSelectionView
                    
                    // Content based on selected tab
                    TabView(selection: $selectedTab) {
                        activeSessionsView
                            .tag(0)
                        
                        currentSessionView
                            .tag(1)
                        
                        ghostClimbersView
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showCreateSession) {
            CreateSessionView()
                .environmentObject(multiplayerManager)
                .environmentObject(expeditionManager)
        }
        .sheet(isPresented: $showJoinSession) {
            JoinSessionView()
                .environmentObject(multiplayerManager)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Multiplayer Climbing")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Climb with friends and compete together")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Connection status
                HStack(spacing: 4) {
                    Circle()
                        .fill(multiplayerManager.isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: multiplayerManager.isConnected)
                    
                    Text(multiplayerManager.isConnected ? "Connected" : "Offline")
                        .font(.caption2)
                        .foregroundColor(multiplayerManager.isConnected ? .green : .red)
                }
            }
            
            // Quick actions
            HStack(spacing: 12) {
                Button(action: {
                    showCreateSession = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Session")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(20)
                }
                
                Button(action: {
                    showJoinSession = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.2.fill")
                        Text("Join Session")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(20)
                }
                
                Spacer()
                
                Button(action: {
                    multiplayerManager.createMockSession()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.rays")
                        Text("Mock Data")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.purple)
                    .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - Tab Selection View
    
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcon(for: index))
                            .font(.title3)
                        
                        Text(tabTitle(for: index))
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == index ? .orange : .white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "list.bullet"
        case 1: return "person.3.fill"
        case 2: return "person.crop.circle"
        default: return "circle.fill"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Sessions"
        case 1: return "Current"
        case 2: return "Ghosts"
        default: return "Unknown"
        }
    }
    
    // MARK: - Active Sessions View
    
    private var activeSessionsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if multiplayerManager.activeSessions.isEmpty {
                    emptySessionsView
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(multiplayerManager.activeSessions) { session in
                            SessionCard(session: session, multiplayerManager: multiplayerManager)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptySessionsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.6))
            
            Text("No Active Sessions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Create a new session or join an existing one to start climbing with others")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button("Create Session") {
                showCreateSession = true
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // MARK: - Current Session View
    
    private var currentSessionView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let session = multiplayerManager.currentSession {
                    // Session info
                    sessionInfoView(session)
                    
                    // Team members
                    teamMembersView
                    
                    // Team progress
                    teamProgressView
                    
                    // Team challenges
                    teamChallengesView
                    
                    // Session actions
                    sessionActionsView(session)
                } else {
                    noCurrentSessionView
                }
            }
            .padding()
        }
    }
    
    private func sessionInfoView(_ session: ClimbingSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Session")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Mountain: \(getMountainName(for: session.mountainId))")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(session.status.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(session.status.color)
                    
                    Text("\(multiplayerManager.teamMembers.count)/\(session.maxParticipants)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Status indicator
            HStack {
                Image(systemName: session.status.icon)
                    .foregroundColor(session.status.color)
                
                Text("Status: \(session.status.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var teamMembersView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Team Members")
                .font(.headline)
                .foregroundColor(.white)
            
            if multiplayerManager.teamMembers.isEmpty {
                Text("No team members")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(multiplayerManager.teamMembers) { member in
                        TeamMemberCard(member: member)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var teamProgressView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Team Progress")
                .font(.headline)
                .foregroundColor(.white)
            
            // Team stats
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(multiplayerManager.teamMembers.reduce(0) { $0 + $1.progress.steps })")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Total Steps")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 4) {
                    Text("\(Int(multiplayerManager.teamMembers.reduce(0) { $0 + $1.progress.elevation }))m")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Total Elevation")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 4) {
                    Text("\(Int(multiplayerManager.teamMembers.reduce(0) { $0 + $1.progress.altitude }) / max(1, multiplayerManager.teamMembers.count))m")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("Avg Altitude")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var teamChallengesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Team Challenges")
                .font(.headline)
                .foregroundColor(.white)
            
            // Mock team challenges
            LazyVStack(spacing: 8) {
                TeamChallengeCard(
                    title: "Team Steps Challenge",
                    description: "Reach 100,000 steps together",
                    progress: 45000,
                    target: 100000,
                    color: .green
                )
                
                TeamChallengeCard(
                    title: "Altitude Challenge",
                    description: "Reach 4000m together",
                    progress: 2800,
                    target: 4000,
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func sessionActionsView(_ session: ClimbingSession) -> some View {
        VStack(spacing: 12) {
            if session.status == .waiting {
                Button(action: {
                    multiplayerManager.startSession()
                }) {
                    Text("Start Session")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
            }
            
            Button(action: {
                multiplayerManager.leaveSession()
            }) {
                Text("Leave Session")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
            }
        }
    }
    
    private var noCurrentSessionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))
            
            Text("No Active Session")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Join a session to see team progress and challenges")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button("Join Session") {
                showJoinSession = true
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // MARK: - Ghost Climbers View
    
    private var ghostClimbersView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if multiplayerManager.ghostClimbers.isEmpty {
                    emptyGhostClimbersView
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(multiplayerManager.ghostClimbers) { climber in
                            GhostClimberCard(climber: climber)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyGhostClimbersView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.minus")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))
            
            Text("No Ghost Climbers")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Ghost climbers are AI representations of your friends who have climbed this mountain")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func getMountainName(for mountainId: UUID) -> String {
        if let mountain = Mountain.allMountains.first(where: { $0.id == mountainId }) {
            return mountain.name
        }
        return "Unknown Mountain"
    }
}

// MARK: - Supporting Views

struct SessionCard: View {
    let session: ClimbingSession
    let multiplayerManager: MultiplayerManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(getMountainName(for: session.mountainId))
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Host: \(session.hostUserId)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(session.status.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(session.status.color)
                    
                    Text("\(session.participants.count)/\(session.maxParticipants)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            HStack {
                Image(systemName: session.isPublic ? "globe" : "lock")
                    .foregroundColor(.white.opacity(0.6))
                
                Text(session.isPublic ? "Public" : "Private")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("Created \(session.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Button(action: {
                multiplayerManager.joinSession(session.id)
            }) {
                Text("Join Session")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func getMountainName(for mountainId: UUID) -> String {
        if let mountain = Mountain.allMountains.first(where: { $0.id == mountainId }) {
            return mountain.name
        }
        return "Unknown Mountain"
    }
}

struct TeamMemberCard: View {
    let member: TeamMember
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            CharacterAvatarView(avatar: member.avatar)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(member.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if member.isReady {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Steps")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(member.progress.steps)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Elevation")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(Int(member.progress.elevation))m")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Altitude")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(Int(member.progress.altitude))m")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct TeamChallengeCard: View {
    let title: String
    let description: String
    let progress: Int
    let target: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(Double(progress) / Double(target) * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            ProgressView(value: Double(progress), total: Double(target))
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            HStack {
                Text("\(progress)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("\(target)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct GhostClimberCard: View {
    let climber: GhostClimber
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Avatar
                CharacterAvatarView(avatar: climber.avatar)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(climber.displayName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Online status
                        HStack(spacing: 4) {
                            Circle()
                                .fill(climber.isOnline ? Color.green : Color.gray)
                                .frame(width: 6, height: 6)
                            
                            Text(climber.isOnline ? "Online" : "Offline")
                                .font(.caption2)
                                .foregroundColor(climber.isOnline ? .green : .gray)
                        }
                    }
                    
                    Text("Ghost Climber")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            // Progress
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Steps")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(climber.currentSteps)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Elevation")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(Int(climber.currentElevation))m")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Altitude")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(Int(climber.currentAltitude))m")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Create Session View

struct CreateSessionView: View {
    @EnvironmentObject var multiplayerManager: MultiplayerManager
    @EnvironmentObject var expeditionManager: ExpeditionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMountain = Mountain.kilimanjaro
    @State private var maxParticipants = 4
    @State private var isPublic = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Mountain selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Mountain")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(Mountain.allMountains) { mountain in
                                MountainSelectionCard(
                                    mountain: mountain,
                                    isSelected: selectedMountain.id == mountain.id
                                ) {
                                    selectedMountain = mountain
                                }
                            }
                        }
                    }
                    
                    // Session settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Session Settings")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 16) {
                            HStack {
                                Text("Max Participants")
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Stepper("\(maxParticipants)", value: $maxParticipants, in: 2...8)
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Public Session")
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Toggle("", isOn: $isPublic)
                            }
                        }
                    }
                    
                    // Create button
                    Button(action: {
                        multiplayerManager.createSession(
                            mountainId: selectedMountain.id,
                            maxParticipants: maxParticipants,
                            isPublic: isPublic
                        )
                        dismiss()
                    }) {
                        Text("Create Session")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Create Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MountainSelectionCard: View {
    let mountain: Mountain
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: mountain.difficulty.icon)
                    .font(.title2)
                    .foregroundColor(mountain.difficulty.color)
                
                Text(mountain.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(mountain.difficulty.rawValue)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.orange.opacity(0.3) : Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Join Session View

struct JoinSessionView: View {
    @EnvironmentObject var multiplayerManager: MultiplayerManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if multiplayerManager.activeSessions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.3.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("No Active Sessions")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("No public sessions are currently available")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(multiplayerManager.activeSessions) { session in
                                SessionCard(session: session, multiplayerManager: multiplayerManager)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Join Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MultiplayerView()
        .environmentObject(MultiplayerManager())
        .environmentObject(ExpeditionManager())
        .background(Color.black)
}
