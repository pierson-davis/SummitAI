import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var expeditionManager: ExpeditionManager
    @State private var showingSettings = false
    @State private var showingSummitVerse = false
    @State private var showingBadges = false
    
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
                        // Profile header
                        profileHeader
                        
                        // Stats overview
                        statsOverview
                        
                        // Access section
                        if !userManager.hasAccessActive() {
                            accessSection
                        }
                        
                        // Achievements
                        achievementsSection
                        
                        // SummitVerse
                        summitVerseSection
                        
                        // Settings
                        settingsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingSummitVerse) {
            SummitVerseView()
        }
        .sheet(isPresented: $showingBadges) {
            BadgesView()
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar and basic info
            HStack(spacing: 16) {
                // Avatar
                Circle()
                    .fill(Color.orange)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(userManager.currentUser?.displayName ?? "Explorer")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("@\(userManager.currentUser?.username ?? "user")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text("Joined \(userManager.currentUser?.joinDate.formatted(date: .abbreviated, time: .omitted) ?? "Unknown")")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Access badge
                if userManager.hasAccessActive() {
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        
                        Text("Full Access")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Bio
            Text("Passionate climber exploring the world's highest peaks. Every step is a new adventure! 🏔️")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var statsOverview: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Stats")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Total Steps",
                    value: "\(userManager.currentUser?.totalSteps ?? 0)",
                    icon: "figure.walk",
                    color: .orange
                )
                
                StatCard(
                    title: "Elevation Climbed",
                    value: "\(Int(userManager.currentUser?.totalElevation ?? 0))m",
                    icon: "arrow.up",
                    color: .blue
                )
                
                StatCard(
                    title: "Expeditions",
                    value: "\(userManager.currentUser?.completedExpeditions.count ?? 0)",
                    icon: "mountain.2.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "\(userManager.currentUser?.streakCount ?? 0) days",
                    icon: "flame.fill",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var accessSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock Full Access")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Access all expeditions and features after onboarding")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("Unlock")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var achievementsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showingBadges = true }) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(userManager.currentUser?.badges.prefix(5) ?? [], id: \.id) { badge in
                        BadgeCard(badge: badge)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var summitVerseSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("SummitVerse")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showingSummitVerse = true }) {
                    Text("Explore")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            
            Button(action: { showingSummitVerse = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Mountain Collection")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("\(userManager.currentUser?.completedExpeditions.count ?? 0) peaks conquered")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack(spacing: 8) {
                            ForEach(0..<min(3, userManager.currentUser?.completedExpeditions.count ?? 0), id: \.self) { index in
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 8, height: 8)
                            }
                            
                            if (userManager.currentUser?.completedExpeditions.count ?? 0) > 3 {
                                Text("+\((userManager.currentUser?.completedExpeditions.count ?? 0) - 3) more")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "map.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color.orange.opacity(0.2))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var settingsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "mountain.2.fill",
                    title: "Start New Expedition",
                    action: {
                        expeditionManager.abandonExpedition()
                    }
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                SettingsRow(
                    icon: "gearshape.fill",
                    title: "Account Settings",
                    action: { showingSettings = true }
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                SettingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    action: {}
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                SettingsRow(
                    icon: "heart.fill",
                    title: "Privacy & Safety",
                    action: {}
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                SettingsRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    action: {}
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                SettingsRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: "Sign Out",
                    action: {
                        userManager.signOut()
                    },
                    isDestructive: true
                )
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct BadgeCard: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badge.iconName)
                .font(.title2)
                .foregroundColor(badge.color.color)
            
            Text(badge.name)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80, height: 80)
        .padding(8)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isDestructive ? .red : .orange)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(isDestructive ? .red : .white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Views

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager
    
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
                        // Profile settings
                        profileSettingsSection
                        
                        // Health settings
                        healthSettingsSection
                        
                        // App settings
                        appSettingsSection
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button("Done") { dismiss() }
            )
        }
    }
    
    private var profileSettingsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsRow(icon: "person.fill", title: "Edit Profile", action: {})
                Divider().background(Color.white.opacity(0.2))
                SettingsRow(icon: "camera.fill", title: "Change Avatar", action: {})
                Divider().background(Color.white.opacity(0.2))
                SettingsRow(icon: "envelope.fill", title: "Email Settings", action: {})
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var healthSettingsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Health & Fitness")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsRow(icon: "heart.fill", title: "Health Data", action: {})
                Divider().background(Color.white.opacity(0.2))
                SettingsRow(icon: "figure.walk", title: "Activity Goals", action: {})
                Divider().background(Color.white.opacity(0.2))
                SettingsRow(icon: "bell.fill", title: "Workout Reminders", action: {})
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var appSettingsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("App Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsRow(icon: "globe", title: "Language", action: {})
                Divider().background(Color.white.opacity(0.2))
                SettingsRow(icon: "moon.fill", title: "Dark Mode", action: {})
                Divider().background(Color.white.opacity(0.2))
                SettingsRow(icon: "lock.fill", title: "Privacy", action: {})
                Divider().background(Color.white.opacity(0.2))
                SettingsRow(icon: "trash.fill", title: "Clear Cache", action: {}, isDestructive: true)
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct SummitVerseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager
    
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
                        VStack(spacing: 8) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("SummitVerse")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Your personal mountain collection")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 40)
                        
                        // Mountain collection
                        mountainCollectionView
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("SummitVerse")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button("Done") { dismiss() }
            )
        }
    }
    
    private var mountainCollectionView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Conquered Peaks")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(userManager.currentUser?.completedExpeditions.count ?? 0) / \(Mountain.allMountains.count)")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Mountain.allMountains) { mountain in
                    MountainCollectionCard(
                        mountain: mountain,
                        isConquered: userManager.currentUser?.completedExpeditions.contains(mountain.id.uuidString) ?? false
                    )
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct MountainCollectionCard: View {
    let mountain: Mountain
    let isConquered: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isConquered ? Color.orange : Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Image(systemName: mountain.difficulty.icon)
                    .font(.title2)
                    .foregroundColor(isConquered ? .white : .gray)
                
                if isConquered {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: 20, y: -20)
                }
            }
            
            Text(mountain.name)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(height: 100)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .opacity(isConquered ? 1.0 : 0.6)
    }
}

struct BadgesView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager
    
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
                        VStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)
                            
                            Text("Achievements")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Your climbing accomplishments")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 40)
                        
                        // Badges grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(Badge.allBadges) { badge in
                                let userBadge = userManager.currentUser?.badges.first { $0.name == badge.name }
                                BadgeDetailCard(badge: userBadge ?? badge)
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Badges")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button("Done") { dismiss() }
            )
        }
    }
}

struct BadgeDetailCard: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: badge.iconName)
                .font(.system(size: 40))
                .foregroundColor(badge.color.color)
                .opacity(badge.isUnlocked ? 1.0 : 0.3)
            
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(badge.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                Text(badge.rarity.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(badge.color.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(badge.color.color.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .opacity(badge.isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserManager())
        .environmentObject(ExpeditionManager())
}
