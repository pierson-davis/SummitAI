import SwiftUI
import HealthKit

@main
struct SummitAIApp: App {
    @StateObject private var healthManager = HealthKitManager()
    @StateObject private var userManager = UserManager()
    @StateObject private var expeditionManager = ExpeditionManager()
    @StateObject private var aiCoachManager = AICoachManager()
    // Complex managers temporarily removed to fix compilation issues
    // @StateObject private var characterManager = CharacterManager()
    // @StateObject private var competitionManager = CompetitionManager()
    // @StateObject private var realisticClimbingManager = RealisticClimbingManager()
    
    init() {
        print("SummitAIApp: App initializing")
        // Firebase will be initialized later when needed
        print("SummitAIApp: App initialized")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthManager)
                .environmentObject(userManager)
                .environmentObject(expeditionManager)
                .environmentObject(aiCoachManager)
                // Complex managers temporarily removed
                // .environmentObject(characterManager)
                // .environmentObject(competitionManager)
                // .environmentObject(realisticClimbingManager)
                .onAppear {
                    print("SummitAIApp: ContentView appeared")
                    print("SummitAIApp: UserManager state - isAuthenticated: \(userManager.isAuthenticated), currentUser: \(userManager.currentUser != nil)")
                    print("SummitAIApp: ExpeditionManager state - currentExpedition: \(expeditionManager.currentExpedition != nil)")
                    // Enable HealthKit for real fitness data
                    healthManager.requestHealthKitPermissions()
                    // Connect AI Coach with Expedition Manager
                    aiCoachManager.setExpeditionManager(expeditionManager)
                }
        }
    }
}
