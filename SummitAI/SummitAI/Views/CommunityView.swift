import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var expeditionManager: ExpeditionManager
    @State private var selectedTab = 0
    @State private var squads: [Squad] = []
    @State private var feedPosts: [FeedPost] = []
    @State private var leaderboard: [LeaderboardEntry] = []
    
    private let tabs = ["Feed", "Squads", "Leaderboard"]
    
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
                    
                    // Tab selector
                    tabSelector
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        feedView
                            .tag(0)
                        
                        squadsView
                            .tag(1)
                        
                        leaderboardView
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadCommunityData()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Community")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Connect with fellow climbers")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Create squad button
                Button(action: {}) {
                    Image(systemName: "person.badge.plus")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation {
                        selectedTab = index
                    }
                }) {
                    Text(tabs[index])
                        .font(.headline)
                        .fontWeight(selectedTab == index ? .bold : .medium)
                        .foregroundColor(selectedTab == index ? .orange : .white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var feedView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(feedPosts) { post in
                    FeedPostCard(post: post)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var squadsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Create squad section
                createSquadSection
                
                // My squads
                if !squads.isEmpty {
                    mySquadsSection
                }
                
                // Discover squads
                discoverSquadsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var leaderboardView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Leaderboard header
                leaderboardHeader
                
                // Leaderboard entries
                ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, entry in
                    LeaderboardCard(entry: entry, rank: index + 1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var createSquadSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Create Squad")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "person.badge.plus")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start Your Own Squad")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Create a squad and invite friends to climb together")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding()
                .background(Color.orange.opacity(0.8))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var mySquadsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("My Squads")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            ForEach(squads) { squad in
                SquadCard(squad: squad)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var discoverSquadsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Discover Squads")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(0..<4) { index in
                    DiscoverSquadCard(
                        name: "Squad \(index + 1)",
                        memberCount: Int.random(in: 5...20),
                        currentMountain: "Mount Kilimanjaro",
                        onJoin: {}
                    )
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var leaderboardHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Global Leaderboard")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Text("This Week")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            
            // Top 3 summary
            HStack(spacing: 12) {
                if leaderboard.count >= 3 {
                    LeaderboardPodiumCard(entry: leaderboard[2], rank: 3, color: .brown)
                    LeaderboardPodiumCard(entry: leaderboard[0], rank: 1, color: .yellow)
                    LeaderboardPodiumCard(entry: leaderboard[1], rank: 2, color: .gray)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func loadCommunityData() {
        loadSquads()
        loadFeedPosts()
        loadLeaderboard()
    }
    
    private func loadSquads() {
        // Mock squads data
        squads = [
            Squad(
                name: "Summit Seekers",
                description: "A group of passionate climbers exploring the world's highest peaks",
                leaderId: userManager.currentUser?.id ?? UUID()
            ),
            Squad(
                name: "Weekend Warriors",
                description: "Weekend climbing adventures and fitness challenges",
                leaderId: UUID()
            )
        ]
    }
    
    private func loadFeedPosts() {
        // Mock feed posts
        feedPosts = [
            FeedPost(
                user: "Alex Chen",
                userAvatar: "person.circle.fill",
                content: "Just reached Camp III on Everest! The view is absolutely breathtaking 🏔️",
                timestamp: Date().addingTimeInterval(-3600),
                likes: 24,
                comments: 8,
                type: .expeditionUpdate,
                mountain: "Mount Everest"
            ),
            FeedPost(
                user: "Maya Rodriguez",
                userAvatar: "person.circle.fill",
                content: "Completed my first expedition! Kilimanjaro was incredible. Thanks to everyone who supported me!",
                timestamp: Date().addingTimeInterval(-7200),
                likes: 42,
                comments: 15,
                type: .expeditionComplete,
                mountain: "Mount Kilimanjaro"
            ),
            FeedPost(
                user: "Jordan Kim",
                userAvatar: "person.circle.fill",
                content: "New personal record: 15,000 steps in a single day! The AI coach's training plan is really working 💪",
                timestamp: Date().addingTimeInterval(-10800),
                likes: 18,
                comments: 5,
                type: .personalRecord,
                mountain: nil
            )
        ]
    }
    
    private func loadLeaderboard() {
        // Mock leaderboard data
        leaderboard = [
            LeaderboardEntry(
                user: "Alex Chen",
                avatar: "person.circle.fill",
                totalSteps: 125000,
                expeditionsCompleted: 3,
                currentStreak: 15
            ),
            LeaderboardEntry(
                user: "Maya Rodriguez",
                avatar: "person.circle.fill",
                totalSteps: 98000,
                expeditionsCompleted: 2,
                currentStreak: 8
            ),
            LeaderboardEntry(
                user: "Jordan Kim",
                avatar: "person.circle.fill",
                totalSteps: 87000,
                expeditionsCompleted: 1,
                currentStreak: 22
            ),
            LeaderboardEntry(
                user: "Sam Wilson",
                avatar: "person.circle.fill",
                totalSteps: 76000,
                expeditionsCompleted: 2,
                currentStreak: 5
            ),
            LeaderboardEntry(
                user: "Taylor Swift",
                avatar: "person.circle.fill",
                totalSteps: 65000,
                expeditionsCompleted: 1,
                currentStreak: 12
            )
        ]
    }
}

// MARK: - Supporting Views

struct FeedPostCard: View {
    let post: FeedPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info
            HStack(spacing: 12) {
                Image(systemName: post.userAvatar)
                    .font(.title2)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.user)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(post.timestamp.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Post type indicator
                Image(systemName: post.type.icon)
                    .foregroundColor(post.type.color)
            }
            
            // Content
            Text(post.content)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            // Mountain info (if applicable)
            if let mountain = post.mountain {
                HStack(spacing: 8) {
                    Image(systemName: "mountain.2.fill")
                        .foregroundColor(.orange)
                    Text(mountain)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(16)
            }
            
            // Actions
            HStack(spacing: 24) {
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                        Text("\(post.likes)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                }
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                        Text("\(post.comments)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                }
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SquadCard: View {
    let squad: Squad
    
    var body: some View {
        HStack(spacing: 12) {
            // Squad avatar
            Circle()
                .fill(Color.blue.opacity(0.8))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(squad.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(squad.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                
                HStack(spacing: 16) {
                    Text("\(squad.memberIds.count) members")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    if let mountainId = squad.currentMountainId,
                       let mountain = Mountain.allMountains.first(where: { $0.id == mountainId }) {
                        Text(mountain.name)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DiscoverSquadCard: View {
    let name: String
    let memberCount: Int
    let currentMountain: String
    let onJoin: () -> Void
    
    var body: some View {
        Button(action: onJoin) {
            VStack(spacing: 8) {
                Circle()
                    .fill(Color.purple.opacity(0.8))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.white)
                    )
                
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("\(memberCount) members")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(currentMountain)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.orange)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LeaderboardCard: View {
    let entry: LeaderboardEntry
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("#\(rank)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(rank <= 3 ? .orange : .white.opacity(0.8))
                .frame(width: 30)
            
            // Avatar
            Image(systemName: entry.avatar)
                .font(.title2)
                .foregroundColor(.orange)
            
            // User info
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.user)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    Text("\(entry.totalSteps) steps")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(entry.expeditionsCompleted) expeditions")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Streak
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(entry.currentStreak)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Text("day streak")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct LeaderboardPodiumCard: View {
    let entry: LeaderboardEntry
    let rank: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Podium
            Circle()
                .fill(color)
                .frame(width: rank == 1 ? 60 : 50, height: rank == 1 ? 60 : 50)
                .overlay(
                    Text("\(rank)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            Text(entry.user)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            Text("\(entry.totalSteps)")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Supporting Models

struct FeedPost: Identifiable {
    let id = UUID()
    let user: String
    let userAvatar: String
    let content: String
    let timestamp: Date
    let likes: Int
    let comments: Int
    let type: FeedPostType
    let mountain: String?
    
    enum FeedPostType {
        case expeditionUpdate
        case expeditionComplete
        case personalRecord
        case achievement
        case challengeComplete
        
        var icon: String {
            switch self {
            case .expeditionUpdate:
                return "mountain.2.fill"
            case .expeditionComplete:
                return "flag.fill"
            case .personalRecord:
                return "chart.line.uptrend.xyaxis"
            case .achievement:
                return "star.fill"
            case .challengeComplete:
                return "trophy.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .expeditionUpdate:
                return .blue
            case .expeditionComplete:
                return .green
            case .personalRecord:
                return .orange
            case .achievement:
                return .yellow
            case .challengeComplete:
                return .purple
            }
        }
    }
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let user: String
    let avatar: String
    let totalSteps: Int
    let expeditionsCompleted: Int
    let currentStreak: Int
}

#Preview {
    CommunityView()
        .environmentObject(UserManager())
        .environmentObject(ExpeditionManager())
}
