import SwiftUI

struct TeamChallengesView: View {
    @EnvironmentObject var multiplayerManager: MultiplayerManager
    @EnvironmentObject var characterManager: CharacterManager
    @State private var selectedTab = 0
    @State private var showCreateChallenge = false
    
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
                        activeChallengesView
                            .tag(0)
                        
                        completedChallengesView
                            .tag(1)
                        
                        leaderboardView
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showCreateChallenge) {
            CreateChallengeView()
                .environmentObject(multiplayerManager)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Team Challenges")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Compete and cooperate with your team")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Team status
                HStack(spacing: 4) {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.blue)
                    
                    Text("\(multiplayerManager.teamMembers.count) members")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Quick actions
            HStack(spacing: 12) {
                Button(action: {
                    showCreateChallenge = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Challenge")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(20)
                }
                
                Spacer()
                
                Button(action: {
                    // Refresh challenges
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
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
        case 0: return "flame.fill"
        case 1: return "checkmark.circle.fill"
        case 2: return "trophy.fill"
        default: return "circle.fill"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Active"
        case 1: return "Completed"
        case 2: return "Leaderboard"
        default: return "Unknown"
        }
    }
    
    // MARK: - Active Challenges View
    
    private var activeChallengesView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Mock active challenges
                LazyVStack(spacing: 12) {
                    TeamChallengeDetailCard(
                        challenge: TeamChallenge(
                            id: UUID(),
                            title: "Team Steps Challenge",
                            description: "Reach 100,000 steps together as a team",
                            type: .steps,
                            targetValue: 100000,
                            currentProgress: 45000,
                            isCompleted: false,
                            reward: TeamChallenge.ChallengeReward(experience: 500, gear: nil, title: "Step Master"),
                            participants: multiplayerManager.teamMembers.map { $0.userId }
                        ),
                        multiplayerManager: multiplayerManager
                    )
                    
                    TeamChallengeDetailCard(
                        challenge: TeamChallenge(
                            id: UUID(),
                            title: "Altitude Challenge",
                            description: "Reach 4000m elevation together",
                            type: .elevation,
                            targetValue: 4000,
                            currentProgress: 2800,
                            isCompleted: false,
                            reward: TeamChallenge.ChallengeReward(experience: 750, gear: GearItem.insulatedJacket, title: "Altitude Ace"),
                            participants: multiplayerManager.teamMembers.map { $0.userId }
                        ),
                        multiplayerManager: multiplayerManager
                    )
                    
                    TeamChallengeDetailCard(
                        challenge: TeamChallenge(
                            id: UUID(),
                            title: "Teamwork Challenge",
                            description: "Complete 10 cooperative actions together",
                            type: .teamwork,
                            targetValue: 10,
                            currentProgress: 6,
                            isCompleted: false,
                            reward: TeamChallenge.ChallengeReward(experience: 1000, gear: nil, title: "Team Player"),
                            participants: multiplayerManager.teamMembers.map { $0.userId }
                        ),
                        multiplayerManager: multiplayerManager
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Completed Challenges View
    
    private var completedChallengesView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Mock completed challenges
                LazyVStack(spacing: 12) {
                    TeamChallengeDetailCard(
                        challenge: TeamChallenge(
                            id: UUID(),
                            title: "First Steps Together",
                            description: "Complete your first 10,000 steps as a team",
                            type: .steps,
                            targetValue: 10000,
                            currentProgress: 10000,
                            isCompleted: true,
                            reward: TeamChallenge.ChallengeReward(experience: 200, gear: nil, title: "Team Starter"),
                            participants: multiplayerManager.teamMembers.map { $0.userId }
                        ),
                        multiplayerManager: multiplayerManager
                    )
                    
                    TeamChallengeDetailCard(
                        challenge: TeamChallenge(
                            id: UUID(),
                            title: "Base Camp Challenge",
                            description: "Reach the first camp together",
                            type: .elevation,
                            targetValue: 1000,
                            currentProgress: 1000,
                            isCompleted: true,
                            reward: TeamChallenge.ChallengeReward(experience: 300, gear: GearItem.basicHelmet, title: "Base Camp Hero"),
                            participants: multiplayerManager.teamMembers.map { $0.userId }
                        ),
                        multiplayerManager: multiplayerManager
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Leaderboard View
    
    private var leaderboardView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Team stats
                teamStatsView
                
                // Individual leaderboard
                individualLeaderboardView
                
                // Team achievements
                teamAchievementsView
            }
            .padding()
        }
    }
    
    private var teamStatsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Team Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(getTotalTeamSteps())")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Total Steps")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 4) {
                    Text("\(Int(getTotalTeamElevation()))m")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Total Elevation")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 4) {
                    Text("\(getCompletedChallenges())")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("Challenges")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var individualLeaderboardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Individual Leaderboard")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(multiplayerManager.teamMembers.enumerated()), id: \.element.id) { index, member in
                    LeaderboardEntry(
                        rank: index + 1,
                        member: member,
                        isCurrentUser: member.userId == "mock_user_id"
                    )
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var teamAchievementsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Team Achievements")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVStack(spacing: 8) {
                TeamAchievementCard(
                    title: "First Summit",
                    description: "Reached the summit together",
                    isUnlocked: true,
                    rarity: .rare
                )
                
                TeamAchievementCard(
                    title: "Step Masters",
                    description: "Completed 50,000 steps as a team",
                    isUnlocked: true,
                    rarity: .uncommon
                )
                
                TeamAchievementCard(
                    title: "Perfect Team",
                    description: "Complete 10 challenges without losing a member",
                    isUnlocked: false,
                    rarity: .epic
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Helper Methods
    
    private func getTotalTeamSteps() -> Int {
        return multiplayerManager.teamMembers.reduce(0) { $0 + $1.progress.steps }
    }
    
    private func getTotalTeamElevation() -> Double {
        return multiplayerManager.teamMembers.reduce(0) { $0 + $1.progress.elevation }
    }
    
    private func getCompletedChallenges() -> Int {
        // Mock data - would come from actual challenge completion
        return 2
    }
}

// MARK: - Supporting Views

struct TeamChallengeDetailCard: View {
    let challenge: TeamChallenge
    let multiplayerManager: MultiplayerManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: challenge.type.icon)
                    .font(.title2)
                    .foregroundColor(challenge.type.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(challenge.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            
            // Progress
            VStack(spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(challenge.currentProgress) / \(challenge.targetValue)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                ProgressView(value: Double(challenge.currentProgress), total: Double(challenge.targetValue))
                    .progressViewStyle(LinearProgressViewStyle(tint: challenge.type.color))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                Text("\(Int(Double(challenge.currentProgress) / Double(challenge.targetValue) * 100))% Complete")
                    .font(.caption)
                    .foregroundColor(challenge.type.color)
            }
            
            // Participants
            VStack(alignment: .leading, spacing: 8) {
                Text("Participants (\(challenge.participants.count))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(challenge.participants, id: \.self) { userId in
                            if let member = multiplayerManager.teamMembers.first(where: { $0.userId == userId }) {
                                ParticipantAvatar(member: member)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // Reward
            if !challenge.isCompleted {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reward")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 12) {
                        if challenge.reward.experience > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(challenge.reward.experience) XP")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if challenge.reward.gear != nil {
                            HStack(spacing: 4) {
                                Image(systemName: "tshirt.fill")
                                    .foregroundColor(.blue)
                                Text("Gear Reward")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if let title = challenge.reward.title {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.orange)
                                Text(title)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                    }
                }
            } else {
                // Completed reward display
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reward Earned")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("Challenge completed successfully!")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(challenge.isCompleted ? Color.green.opacity(0.3) : challenge.type.color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ParticipantAvatar: View {
    let member: TeamMember
    
    var body: some View {
        VStack(spacing: 4) {
            CharacterAvatarView(avatar: member.avatar)
                .scaleEffect(0.8)
            
            Text(member.displayName)
                .font(.caption2)
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(width: 60)
    }
}

struct LeaderboardEntry: View {
    let rank: Int
    let member: TeamMember
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 30, height: 30)
                
                Text("\(rank)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Avatar
            CharacterAvatarView(avatar: member.avatar)
                .scaleEffect(0.8)
            
            // Name and stats
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(member.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isCurrentUser ? .orange : .white)
                    
                    if isCurrentUser {
                        Text("(You)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                HStack(spacing: 12) {
                    Text("\(member.progress.steps) steps")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(Int(member.progress.elevation))m")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(calculateScore())")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text("Score")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(isCurrentUser ? Color.orange.opacity(0.1) : Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentUser ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
    
    private func calculateScore() -> Int {
        // Simple scoring based on steps and elevation
        return member.progress.steps / 1000 + Int(member.progress.elevation / 100)
    }
}

struct TeamAchievementCard: View {
    let title: String
    let description: String
    let isUnlocked: Bool
    let rarity: Achievement.AchievementRarity
    
    var body: some View {
        HStack(spacing: 12) {
            // Achievement icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? rarity.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: isUnlocked ? rarity.icon : "lock.fill")
                    .font(.title3)
                    .foregroundColor(isUnlocked ? rarity.color : .gray)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isUnlocked ? .white : .white.opacity(0.6))
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(isUnlocked ? .white.opacity(0.8) : .white.opacity(0.4))
                
                if !isUnlocked {
                    Text("Locked")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Rarity indicator
            if isUnlocked {
                Text(rarity.rawValue)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(rarity.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(rarity.color.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isUnlocked ? rarity.color.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Create Challenge View

struct CreateChallengeView: View {
    @EnvironmentObject var multiplayerManager: MultiplayerManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedType = TeamChallenge.ChallengeType.steps
    @State private var targetValue = 1000
    @State private var experienceReward = 100
    @State private var selectedGear: GearItem?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Basic info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Challenge Details")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Title")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                TextField("Challenge title", text: $title)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                TextField("Challenge description", text: $description, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(3...6)
                            }
                        }
                    }
                    
                    // Challenge type
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Challenge Type")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(TeamChallenge.ChallengeType.allCases, id: \.self) { type in
                                ChallengeTypeCard(
                                    type: type,
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                    }
                    
                    // Target value
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Target Value")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Target: \(targetValue)")
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            Stepper("", value: $targetValue, in: 1...10000)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Rewards
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rewards")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Experience Points")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Stepper("\(experienceReward) XP", value: $experienceReward, in: 50...2000, step: 50)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Gear Reward (Optional)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Button(action: {
                                    // Show gear selection
                                }) {
                                    HStack {
                                        Text(selectedGear?.name ?? "Select Gear")
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Create button
                    Button(action: {
                        // Create challenge logic would go here
                        dismiss()
                    }) {
                        Text("Create Challenge")
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
            .navigationTitle("Create Challenge")
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

struct ChallengeTypeCard: View {
    let type: TeamChallenge.ChallengeType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(type.color)
                
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? type.color.opacity(0.3) : Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? type.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TeamChallengesView()
        .environmentObject(MultiplayerManager())
        .environmentObject(CharacterManager())
        .background(Color.black)
}
