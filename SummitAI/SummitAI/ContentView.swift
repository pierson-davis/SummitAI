import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var expeditionManager: ExpeditionManager
    @EnvironmentObject var healthManager: HealthKitManager
    
    var body: some View {
        Group {
            if !userManager.isAuthenticated {
                OnboardingView()
            } else if expeditionManager.currentExpedition == nil {
                ExpeditionSelectionView()
            } else {
                MainTabView()
            }
        }
        .overlay(
            // Debug overlay to show current state
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("Auth: \(userManager.isAuthenticated ? "Yes" : "No")")
                            .font(.caption)
                        Text("Expedition: \(expeditionManager.currentExpedition != nil ? "Yes" : "No")")
                            .font(.caption)
                        Text("Mountains: \(expeditionManager.availableMountains.count)")
                            .font(.caption)
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    Spacer()
                }
                .padding(.bottom, 50)
            }
        )
        .animation(.easeInOut, value: userManager.isAuthenticated)
        .animation(.easeInOut, value: expeditionManager.currentExpedition)
        .onAppear {
            print("ContentView appeared - isAuthenticated: \(userManager.isAuthenticated), currentExpedition: \(expeditionManager.currentExpedition != nil)")
        }
        .background(Color.red.opacity(0.1)) // Add a subtle background to see if ContentView is rendering
    }
}

struct MainTabView: View {
    @EnvironmentObject var expeditionManager: ExpeditionManager
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Expedition")
                }
            
            ChallengesView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Challenges")
                }
            
            CommunityView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Community")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.orange)
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager())
        .environmentObject(ExpeditionManager())
        .environmentObject(HealthKitManager())
}
