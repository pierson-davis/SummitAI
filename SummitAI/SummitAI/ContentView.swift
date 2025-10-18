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
        .animation(.easeInOut, value: userManager.isAuthenticated)
        .animation(.easeInOut, value: expeditionManager.currentExpedition)
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
