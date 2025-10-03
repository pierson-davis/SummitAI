import SwiftUI

struct ChallengesView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var expeditionManager: ExpeditionManager
    @State private var activeChallenges: [Challenge] = []
    @State private var completedChallenges: [Challenge] = []
    
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Streak section
                        streakSection
                        
                        // Active challenges
                        if !activeChallenges.isEmpty {
                            challengesSection(title: "Active Challenges", challenges: activeChallenges)
                        }
                        
                        // Completed challenges
                        if !completedChallenges.isEmpty {
                            challengesSection(title: "Completed", challenges: completedChallenges)
                        }
                        
                        // Join new challenge
                        joinNewChallengeSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadChallenges()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Challenges")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Push your limits and earn rewards")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Start new expedition button
                Button(action: {
                    expeditionManager.abandonExpedition()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "mountain.2.fill")
                        Text("New")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.8))
                    .cornerRadius(12)
                }
                
                // Notifications
                Button(action: {}) {
                    Image(systemName: "bell.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var streakSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Streak")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                // Streak count
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(userManager.currentUser?.streakCount ?? 0)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("Day Streak")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                
                // Longest streak
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text("\(userManager.currentUser?.stats.longestStreak ?? 0)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("Best Streak")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func challengesSection(title: String, challenges: [Challenge]) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            ForEach(challenges) { challenge in
                ChallengeCard(challenge: challenge)
            }
        }
    }
    
    private var joinNewChallengeSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Join New Challenges")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NewChallengeCard(
                    title: "Daily Steps",
                    description: "Walk 10,000 steps today",
                    icon: "figure.walk",
                    color: .green,
                    onTap: {
                        joinChallenge(createDailyStepsChallenge())
                    }
                )
                
                NewChallengeCard(
                    title: "Weekly Elevation",
                    description: "Climb 1,000m this week",
                    icon: "arrow.up",
                    color: .blue,
                    onTap: {
                        joinChallenge(createWeeklyElevationChallenge())
                    }
                )
                
                NewChallengeCard(
                    title: "Monthly Expedition",
                    description: "Complete an expedition this month",
                    icon: "mountain.2.fill",
                    color: .orange,
                    onTap: {
                        joinChallenge(createMonthlyExpeditionChallenge())
                    }
                )
                
                NewChallengeCard(
                    title: "Workout Streak",
                    description: "Work out for 7 days straight",
                    icon: "flame.fill",
                    color: .red,
                    onTap: {
                        joinChallenge(createWorkoutStreakChallenge())
                    }
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func loadChallenges() {
        // Load mock challenges
        activeChallenges = [
            createDailyStepsChallenge(),
            createWeeklyElevationChallenge()
        ]
        
        completedChallenges = [
            createCompletedChallenge()
        ]
    }
    
    private func joinChallenge(_ challenge: Challenge) {
        var updatedChallenge = challenge
        if let userId = userManager.currentUser?.id {
            updatedChallenge.participants.append(UUID(uuidString: userId) ?? UUID())
        } else {
            updatedChallenge.participants.append(UUID())
        }
        updatedChallenge.isActive = true
        
        activeChallenges.append(updatedChallenge)
    }
    
    // MARK: - Challenge Creation Methods
    
    private func createDailyStepsChallenge() -> Challenge {
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        
        return Challenge(
            name: "Daily Steps Goal",
            description: "Walk 10,000 steps today",
            type: .daily,
            difficulty: .beginner,
            startDate: Date(),
            endDate: endDate,
            requirements: Challenge.ChallengeRequirements(steps: 10000),
            rewards: [.points(100)]
        )
    }
    
    private func createWeeklyElevationChallenge() -> Challenge {
        let endDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
        
        return Challenge(
            name: "Weekly Elevation",
            description: "Climb 1,000 meters this week",
            type: .weekly,
            difficulty: .intermediate,
            startDate: Date(),
            endDate: endDate,
            requirements: Challenge.ChallengeRequirements(elevation: 1000),
            rewards: [.points(500), .badge(.mountainGoat)]
        )
    }
    
    private func createMonthlyExpeditionChallenge() -> Challenge {
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        
        return Challenge(
            name: "Monthly Expedition",
            description: "Complete any expedition this month",
            type: .monthly,
            difficulty: .advanced,
            startDate: Date(),
            endDate: endDate,
            requirements: Challenge.ChallengeRequirements(workouts: 1), // Simplified
            rewards: [.points(1000), .badge(.expeditionLeader)]
        )
    }
    
    private func createWorkoutStreakChallenge() -> Challenge {
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        
        return Challenge(
            name: "7-Day Workout Streak",
            description: "Work out for 7 consecutive days",
            type: .weekly,
            difficulty: .intermediate,
            startDate: Date(),
            endDate: endDate,
            requirements: Challenge.ChallengeRequirements(workouts: 7),
            rewards: [.points(700), .badge(.streakMaster)]
        )
    }
    
    private func createCompletedChallenge() -> Challenge {
        let endDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        
        return Challenge(
            name: "First Steps",
            description: "Take your first 1,000 steps",
            type: .daily,
            difficulty: .beginner,
            startDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            endDate: endDate,
            requirements: Challenge.ChallengeRequirements(steps: 1000),
            rewards: [.points(100), .badge(.firstSteps)]
        )
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(challenge.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: challenge.type.icon)
                        .font(.title2)
                        .foregroundColor(challenge.difficulty.color)
                    
                    Text(challenge.difficulty.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(challenge.difficulty.color)
                }
            }
            
            // Progress (for active challenges)
            if challenge.isActive && !challenge.isCompleted {
                VStack(spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("3 days left")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    ProgressView(value: 0.6)
                        .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                }
            }
            
            // Rewards
            HStack {
                Text("Rewards:")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                ForEach(challenge.rewards, id: \.self) { reward in
                    rewardView(reward)
                }
                
                Spacer()
            }
            
            // Status
            HStack {
                if challenge.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Completed")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                } else if challenge.isActive {
                    HStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.blue)
                        Text("Active")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Text("\(challenge.participants.count) participants")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func rewardView(_ reward: Challenge.ChallengeReward) -> some View {
        HStack(spacing: 4) {
            switch reward {
            case .points(let amount):
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("\(amount)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.yellow)
            case .badge(let badge):
                Image(systemName: badge.iconName)
                    .foregroundColor(badge.color.color)
                Text(badge.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            case .accessDays(let days):
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                Text("\(days)d")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.yellow)
            case .custom(let text):
                Text(text)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct NewChallengeCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .padding()
            .background(color.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ChallengesView()
        .environmentObject(UserManager())
        .environmentObject(ExpeditionManager())
}
