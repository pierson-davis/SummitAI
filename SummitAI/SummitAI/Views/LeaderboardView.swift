import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var competitionManager: CompetitionManager
    @State private var selectedTab = 0
    @State private var selectedTimeframe = Timeframe.global
    @State private var selectedCategory = LeaderboardCategory.overall
    
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
                    
                    // Timeframe and category selection
                    selectionView
                    
                    // Tab selection
                    tabSelectionView
                    
                    // Content based on selected tab
                    TabView(selection: $selectedTab) {
                        leaderboardView
                            .tag(0)
                        
                        challengesView
                            .tag(1)
                        
                        achievementsView
                            .tag(2)
                        
                        competitionsView
                            .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Competition Hub")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Compete with climbers worldwide")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // User ranking
                if let rankings = competitionManager.userRankings {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("#\(rankings.globalRank)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("Global Rank")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Top \(String(format: "%.1f", rankings.percentile))%")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Quick stats
            if let rankings = competitionManager.userRankings {
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(rankings.dailyRank)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Daily")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(rankings.weeklyRank)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Weekly")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(competitionManager.achievements.count)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                        
                        Text("Achievements")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - Selection View
    
    private var selectionView: some View {
        VStack(spacing: 12) {
            // Timeframe selection
            HStack(spacing: 12) {
                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                    Button(action: {
                        selectedTimeframe = timeframe
                    }) {
                        Text(timeframe.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedTimeframe == timeframe ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedTimeframe == timeframe ? Color.orange : Color.white.opacity(0.1))
                            .cornerRadius(20)
                    }
                }
            }
            
            // Category selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(LeaderboardCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: category.icon)
                                    .font(.caption)
                                
                                Text(category.rawValue)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(selectedCategory == category ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedCategory == category ? category.color : Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Tab Selection View
    
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
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
        case 0: return "trophy.fill"
        case 1: return "flame.fill"
        case 2: return "star.fill"
        case 3: return "person.3.fill"
        default: return "circle.fill"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Leaderboard"
        case 1: return "Challenges"
        case 2: return "Achievements"
        case 3: return "Competitions"
        default: return "Unknown"
        }
    }
    
    // MARK: - Leaderboard View
    
    private var leaderboardView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Podium
                podiumView
                
                // Leaderboard entries
                LazyVStack(spacing: 8) {
                    ForEach(competitionManager.globalLeaderboard) { entry in
                        LeaderboardEntryCard(
                            entry: entry,
                            isCurrentUser: entry.userId == "current_user_id"
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private var podiumView: some View {
        VStack(spacing: 16) {
            Text("Top 3 Climbers")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(alignment: .bottom, spacing: 20) {
                // 2nd place
                if competitionManager.globalLeaderboard.count > 1 {
                    VStack(spacing: 8) {
                        CharacterAvatarView(avatar: competitionManager.globalLeaderboard[1].avatar)
                            .scaleEffect(0.8)
                        
                        Text(competitionManager.globalLeaderboard[1].displayName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("#2")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        Text("\(competitionManager.globalLeaderboard[1].score)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                }
                
                // 1st place
                if !competitionManager.globalLeaderboard.isEmpty {
                    VStack(spacing: 8) {
                        CharacterAvatarView(avatar: competitionManager.globalLeaderboard[0].avatar)
                            .scaleEffect(1.2)
                        
                        Text(competitionManager.globalLeaderboard[0].displayName)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("#1")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                        
                        Text("\(competitionManager.globalLeaderboard[0].score)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.yellow, lineWidth: 2)
                    )
                }
                
                // 3rd place
                if competitionManager.globalLeaderboard.count > 2 {
                    VStack(spacing: 8) {
                        CharacterAvatarView(avatar: competitionManager.globalLeaderboard[2].avatar)
                            .scaleEffect(0.8)
                        
                        Text(competitionManager.globalLeaderboard[2].displayName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("#3")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("\(competitionManager.globalLeaderboard[2].score)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Challenges View
    
    private var challengesView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Daily challenges
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily Challenges")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    LazyVStack(spacing: 8) {
                        ForEach(competitionManager.dailyChallenges) { challenge in
                            ChallengeCard(challenge: challenge)
                        }
                    }
                }
                
                // Weekly challenges
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weekly Challenges")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    LazyVStack(spacing: 8) {
                        ForEach(competitionManager.weeklyChallenges) { challenge in
                            WeeklyChallengeCard(challenge: challenge)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Achievements View
    
    private var achievementsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Achievement stats
                achievementStatsView
                
                // Achievement grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(competitionManager.achievements) { achievement in
                        AchievementGridCard(achievement: achievement)
                    }
                }
            }
            .padding()
        }
    }
    
    private var achievementStatsView: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("\(competitionManager.achievements.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                
                Text("Unlocked")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 4) {
                Text("\(getRarityCount(.legendary))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text("Legendary")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 4) {
                Text("\(getRarityCount(.epic))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                
                Text("Epic")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Competitions View
    
    private var competitionsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if competitionManager.teamCompetitions.isEmpty {
                    emptyCompetitionsView
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(competitionManager.teamCompetitions) { competition in
                            CompetitionCard(competition: competition)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyCompetitionsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))
            
            Text("No Active Competitions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Join team competitions to compete with other climbers")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button("Create Competition") {
                competitionManager.createTeamCompetition(mountainId: Mountain.kilimanjaro.id)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func getRarityCount(_ rarity: Achievement.AchievementRarity) -> Int {
        return competitionManager.achievements.filter { $0.rarity == rarity }.count
    }
}

// MARK: - Supporting Views

struct LeaderboardEntryCard: View {
    let entry: LeaderboardEntry
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 40, height: 40)
                
                Text("\(entry.rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Avatar
            CharacterAvatarView(avatar: entry.avatar)
                .scaleEffect(0.9)
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isCurrentUser ? .orange : .white)
                    
                    if isCurrentUser {
                        Text("(You)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    Text("Lv. \(entry.level)")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("\(entry.mountainsCompleted) mountains")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(entry.achievements) achievements")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            // Score
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.score)")
                    .font(.headline)
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
        switch entry.rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        case 4...10: return .blue
        default: return .purple
        }
    }
}

struct ChallengeCard: View {
    let challenge: DailyChallenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: challenge.type.icon)
                    .font(.title3)
                    .foregroundColor(challenge.type.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(challenge.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                } else {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(challenge.difficulty.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(challenge.difficulty.color)
                        
                        Text("\(challenge.progress)/\(challenge.targetValue)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            if !challenge.isCompleted {
                ProgressView(value: Double(challenge.progress), total: Double(challenge.targetValue))
                    .progressViewStyle(LinearProgressViewStyle(tint: challenge.type.color))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // Reward
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
                
                if challenge.reward.coins > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                        Text("\(challenge.reward.coins) coins")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                
                if challenge.reward.gear != nil {
                    HStack(spacing: 4) {
                        Image(systemName: "tshirt.fill")
                            .foregroundColor(.blue)
                        Text("Gear")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(challenge.isCompleted ? Color.green.opacity(0.3) : challenge.type.color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct WeeklyChallengeCard: View {
    let challenge: WeeklyChallenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: challenge.type.icon)
                    .font(.title3)
                    .foregroundColor(challenge.type.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(challenge.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                } else {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(challenge.difficulty.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(challenge.difficulty.color)
                        
                        Text("\(challenge.progress)/\(challenge.targetValue)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            if !challenge.isCompleted {
                ProgressView(value: Double(challenge.progress), total: Double(challenge.targetValue))
                    .progressViewStyle(LinearProgressViewStyle(tint: challenge.type.color))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // Time remaining
            HStack {
                Text("Time remaining: \(timeRemaining)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(challenge.isCompleted ? Color.green.opacity(0.3) : challenge.type.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var timeRemaining: String {
        let now = Date()
        let timeInterval = challenge.expiresAt.timeIntervalSince(now)
        
        if timeInterval <= 0 {
            return "Expired"
        }
        
        let days = Int(timeInterval) / 86400
        let hours = Int(timeInterval % 86400) / 3600
        
        if days > 0 {
            return "\(days)d \(hours)h"
        } else {
            return "\(hours)h"
        }
    }
}

struct AchievementGridCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.rarity.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.category.icon)
                    .font(.title3)
                    .foregroundColor(achievement.rarity.color)
            }
            
            VStack(spacing: 2) {
                Text(achievement.name)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(achievement.rarity.rawValue)
                    .font(.caption2)
                    .foregroundColor(achievement.rarity.color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.rarity.color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CompetitionCard: View {
    let competition: TeamCompetition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(competition.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(competition.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(competition.status.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(competition.status.color)
                    
                    Text("\(competition.participatingTeams.count)/\(competition.maxTeams)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Prize info
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("1st Place")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text("\(competition.prize.firstPlace.experience) XP")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                
                VStack(spacing: 4) {
                    Text("2nd Place")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(competition.prize.secondPlace.experience) XP")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 4) {
                    Text("3rd Place")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("\(competition.prize.thirdPlace.experience) XP")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                Spacer()
            }
            
            // Action button
            Button(action: {
                // Join competition logic
            }) {
                Text(competition.status == .registration ? "Join Competition" : "View Details")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(competition.status.color)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Enums

enum Timeframe: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case global = "Global"
}

enum LeaderboardCategory: String, CaseIterable {
    case overall = "Overall"
    case steps = "Steps"
    case elevation = "Elevation"
    case mountains = "Mountains"
    case achievements = "Achievements"
    
    var icon: String {
        switch self {
        case .overall: return "trophy.fill"
        case .steps: return "figure.walk"
        case .elevation: return "arrow.up"
        case .mountains: return "mountain.2.fill"
        case .achievements: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .overall: return .orange
        case .steps: return .green
        case .elevation: return .blue
        case .mountains: return .purple
        case .achievements: return .yellow
        }
    }
}

#Preview {
    LeaderboardView()
        .environmentObject(CompetitionManager())
        .background(Color.black)
}
