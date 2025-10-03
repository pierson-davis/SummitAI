import Foundation
import SwiftUI
import Combine

// MARK: - Navigation Manager
// Step 7: Navigation & User Flow

class NavigationManager: ObservableObject {
    @Published var currentTab: TabItem = .expedition
    @Published var navigationPath: NavigationPath = NavigationPath()
    @Published var presentedSheet: PresentedSheet?
    @Published var presentedFullScreenCover: PresentedFullScreenCover?
    @Published var navigationHistory: [NavigationState] = []
    @Published var canGoBack: Bool = false
    
    // Deep linking support
    @Published var pendingDeepLink: DeepLink?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupNavigationBindings()
    }
    
    // MARK: - Tab Management
    
    enum TabItem: String, CaseIterable {
        case expedition = "Expedition"
        case mountainExperiences = "Mountain Experiences"
        case challenges = "Challenges"
        case community = "Community"
        case profile = "Profile"
        
        var icon: String {
            switch self {
            case .expedition: return "house.fill"
            case .mountainExperiences: return "mountain.2.fill"
            case .challenges: return "star.fill"
            case .community: return "person.3.fill"
            case .profile: return "person.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .expedition: return .blue
            case .mountainExperiences: return .green
            case .challenges: return .orange
            case .community: return .purple
            case .profile: return .gray
            }
        }
    }
    
    func selectTab(_ tab: TabItem) {
        currentTab = tab
        addToNavigationHistory(.tabChange(tab))
    }
    
    // MARK: - Sheet Presentation
    
    enum PresentedSheet: Identifiable {
        case filterModal
        case tripDetail(Trip)
        case locationDetail(Location)
        case userPreferences
        case searchResults
        case bookmarkManager
        case tripPlanner(Trip)
        case expeditionCreator(Trip)
        
        var id: String {
            switch self {
            case .filterModal: return "filter_modal"
            case .tripDetail(let trip): return "trip_detail_\(trip.id)"
            case .locationDetail(let location): return "location_detail_\(location.id)"
            case .userPreferences: return "user_preferences"
            case .searchResults: return "search_results"
            case .bookmarkManager: return "bookmark_manager"
            case .tripPlanner(let trip): return "trip_planner_\(trip.id)"
            case .expeditionCreator(let trip): return "expedition_creator_\(trip.id)"
            }
        }
    }
    
    func presentSheet(_ sheet: PresentedSheet) {
        presentedSheet = sheet
        addToNavigationHistory(.sheetPresented(sheet))
    }
    
    func dismissSheet() {
        presentedSheet = nil
        addToNavigationHistory(.sheetDismissed)
    }
    
    // MARK: - Full Screen Cover Presentation
    
    enum PresentedFullScreenCover: Identifiable {
        case searchResults
        case onboarding
        case authentication
        case expeditionSelection
        case mountainExperiencesHome
        
        var id: String {
            switch self {
            case .searchResults: return "search_results_fullscreen"
            case .onboarding: return "onboarding"
            case .authentication: return "authentication"
            case .expeditionSelection: return "expedition_selection"
            case .mountainExperiencesHome: return "mountain_experiences_home"
            }
        }
    }
    
    func presentFullScreenCover(_ cover: PresentedFullScreenCover) {
        presentedFullScreenCover = cover
        addToNavigationHistory(.fullScreenCoverPresented(cover))
    }
    
    func dismissFullScreenCover() {
        presentedFullScreenCover = nil
        addToNavigationHistory(.fullScreenCoverDismissed)
    }
    
    // MARK: - Navigation Path Management
    
    func navigateToTrip(_ trip: Trip) {
        navigationPath.append(trip)
        addToNavigationHistory(.navigateToTrip(trip))
    }
    
    func navigateToLocation(_ location: Location) {
        navigationPath.append(location)
        addToNavigationHistory(.navigateToLocation(location))
    }
    
    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
            addToNavigationHistory(.navigateBack)
        } else if !navigationHistory.isEmpty {
            // Go back in history
            navigationHistory.removeLast()
            updateNavigationState()
        }
    }
    
    func navigateToRoot() {
        navigationPath = NavigationPath()
        addToNavigationHistory(.navigateToRoot)
    }
    
    // MARK: - Deep Linking
    
    enum DeepLink {
        case trip(UUID)
        case location(String)
        case search(String)
        case mountainExperience(String)
        case expedition(UUID)
        case profile
        case challenges
        
        var url: URL? {
            switch self {
            case .trip(let id):
                return URL(string: "summitai://trip/\(id)")
            case .location(let id):
                return URL(string: "summitai://location/\(id)")
            case .search(let query):
                return URL(string: "summitai://search?q=\(query)")
            case .mountainExperience(let id):
                return URL(string: "summitai://mountain-experience/\(id)")
            case .expedition(let id):
                return URL(string: "summitai://expedition/\(id)")
            case .profile:
                return URL(string: "summitai://profile")
            case .challenges:
                return URL(string: "summitai://challenges")
            }
        }
    }
    
    func handleDeepLink(_ url: URL) {
        guard url.scheme == "summitai" else { return }
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        switch pathComponents.first {
        case "trip":
            if let tripIdString = pathComponents.last,
               let tripId = UUID(uuidString: tripIdString) {
                pendingDeepLink = .trip(tripId)
            }
        case "location":
            if let locationId = pathComponents.last {
                pendingDeepLink = .location(locationId)
            }
        case "mountain-experience":
            if let experienceId = pathComponents.last {
                pendingDeepLink = .mountainExperience(experienceId)
            }
        case "expedition":
            if let expeditionIdString = pathComponents.last,
               let expeditionId = UUID(uuidString: expeditionIdString) {
                pendingDeepLink = .expedition(expeditionId)
            }
        case "search":
            if let query = url.query?.removingPercentEncoding {
                pendingDeepLink = .search(query)
            }
        case "profile":
            pendingDeepLink = .profile
        case "challenges":
            pendingDeepLink = .challenges
        default:
            break
        }
    }
    
    func processPendingDeepLink() {
        guard let deepLink = pendingDeepLink else { return }
        
        switch deepLink {
        case .trip(let id):
            // Find trip and navigate to it
            if let trip = findTrip(by: id) {
                presentSheet(.tripDetail(trip))
            }
        case .location(let id):
            // Find location and navigate to it
            if let location = findLocation(by: id) {
                presentSheet(.locationDetail(location))
            }
        case .search(let query):
            // Navigate to search with query
            selectTab(.mountainExperiences)
            presentFullScreenCover(.searchResults)
        case .mountainExperience(let id):
            // Navigate to mountain experience
            selectTab(.mountainExperiences)
        case .expedition(let id):
            // Navigate to expedition
            selectTab(.expedition)
        case .profile:
            selectTab(.profile)
        case .challenges:
            selectTab(.challenges)
        }
        
        pendingDeepLink = nil
    }
    
    // MARK: - Navigation History
    
    enum NavigationState: Identifiable {
        case tabChange(TabItem)
        case sheetPresented(PresentedSheet)
        case sheetDismissed
        case fullScreenCoverPresented(PresentedFullScreenCover)
        case fullScreenCoverDismissed
        case navigateToTrip(Trip)
        case navigateToLocation(Location)
        case navigateBack
        case navigateToRoot
        
        var id: String {
            switch self {
            case .tabChange(let tab): return "tab_\(tab.rawValue)"
            case .sheetPresented(let sheet): return "sheet_\(sheet.id)"
            case .sheetDismissed: return "sheet_dismissed"
            case .fullScreenCoverPresented(let cover): return "cover_\(cover.id)"
            case .fullScreenCoverDismissed: return "cover_dismissed"
            case .navigateToTrip(let trip): return "trip_\(trip.id)"
            case .navigateToLocation(let location): return "location_\(location.id)"
            case .navigateBack: return "navigate_back"
            case .navigateToRoot: return "navigate_root"
            }
        }
    }
    
    private func addToNavigationHistory(_ state: NavigationState) {
        navigationHistory.append(state)
        
        // Limit history to 50 items
        if navigationHistory.count > 50 {
            navigationHistory = Array(navigationHistory.suffix(50))
        }
        
        updateCanGoBack()
    }
    
    private func updateCanGoBack() {
        canGoBack = !navigationPath.isEmpty || !navigationHistory.isEmpty
    }
    
    private func updateNavigationState() {
        // Update navigation state based on history
        // This could be used to restore previous navigation state
    }
    
    // MARK: - User Flow Optimization
    
    func optimizeUserFlow(for userAction: UserAction) {
        switch userAction {
        case .discoverTrips:
            selectTab(.mountainExperiences)
            presentFullScreenCover(.mountainExperiencesHome)
        case .searchTrips:
            selectTab(.mountainExperiences)
            presentFullScreenCover(.searchResults)
        case .planTrip(let trip):
            presentSheet(.tripPlanner(trip))
        case .startExpedition(let trip):
            presentSheet(.expeditionCreator(trip))
        case .viewBookmarks:
            presentSheet(.bookmarkManager)
        case .updatePreferences:
            presentSheet(.userPreferences)
        case .viewProfile:
            selectTab(.profile)
        }
    }
    
    enum UserAction {
        case discoverTrips
        case searchTrips
        case planTrip(Trip)
        case startExpedition(Trip)
        case viewBookmarks
        case updatePreferences
        case viewProfile
    }
    
    // MARK: - Navigation Bindings
    
    private func setupNavigationBindings() {
        // Update canGoBack when navigation path changes
        $navigationPath
            .map { !$0.isEmpty }
            .sink { [weak self] _ in
                self?.updateCanGoBack()
            }
            .store(in: &cancellables)
        
        // Process pending deep links when they change
        $pendingDeepLink
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.processPendingDeepLink()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    
    private func findTrip(by id: UUID) -> Trip? {
        // This would integrate with the data managers to find trips
        return Trip.sampleTrips.first { $0.id == id }
    }
    
    private func findLocation(by id: String) -> Location? {
        // This would integrate with the data managers to find locations
        return Location.allSampleLocations.first { $0.id == id }
    }
    
    // MARK: - Navigation Analytics
    
    func trackNavigationEvent(_ event: NavigationEvent) {
        // This would integrate with analytics services
        print("Navigation Event: \(event)")
    }
    
    enum NavigationEvent {
        case tabSelected(TabItem)
        case tripViewed(Trip)
        case locationViewed(Location)
        case searchPerformed(String)
        case deepLinkOpened(DeepLink)
        case userFlowCompleted(UserAction)
    }
}

// MARK: - Navigation State Extensions

extension NavigationManager.PresentedSheet {
    var title: String {
        switch self {
        case .filterModal: return "Filters"
        case .tripDetail: return "Trip Details"
        case .locationDetail: return "Location Details"
        case .userPreferences: return "Preferences"
        case .searchResults: return "Search Results"
        case .bookmarkManager: return "Bookmarks"
        case .tripPlanner: return "Plan Trip"
        case .expeditionCreator: return "Create Expedition"
        }
    }
}

extension NavigationManager.PresentedFullScreenCover {
    var title: String {
        switch self {
        case .searchResults: return "Search"
        case .onboarding: return "Welcome"
        case .authentication: return "Sign In"
        case .expeditionSelection: return "Select Expedition"
        case .mountainExperiencesHome: return "Mountain Experiences"
        }
    }
}
