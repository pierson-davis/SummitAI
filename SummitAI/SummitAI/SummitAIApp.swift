import SwiftUI
import HealthKit

@main
struct SummitAIApp: App {
    @StateObject private var healthManager = HealthKitManager()
    @StateObject private var userManager = UserManager()
    @StateObject private var expeditionManager = ExpeditionManager()
    @StateObject private var aiCoachManager = AICoachManager()
    
    init() {
        print("SummitAIApp: App initializing")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthManager)
                .environmentObject(userManager)
                .environmentObject(expeditionManager)
                .environmentObject(aiCoachManager)
                .onAppear {
                    print("SummitAIApp: ContentView appeared")
                    print("SummitAIApp: UserManager state - isAuthenticated: \(userManager.isAuthenticated), currentUser: \(userManager.currentUser != nil)")
                    print("SummitAIApp: ExpeditionManager state - currentExpedition: \(expeditionManager.currentExpedition != nil)")
                    // Temporarily disable HealthKit to test UI
                    // healthManager.requestHealthKitPermissions()
                }
        }
    }
}
