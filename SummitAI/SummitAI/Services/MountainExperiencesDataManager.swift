import Foundation
import Combine
import SwiftUI

// MARK: - Mountain Experiences Data Manager
// Step 6: Data Model Integration

class MountainExperiencesDataManager: ObservableObject {
    @Published var availableTrips: [Trip] = []
    @Published var availableLocations: [Location] = []
    @Published var userBookmarkedTrips: Set<UUID> = []
    @Published var userSearchHistory: [String] = []
    @Published var userFilterPreferences: FilterPreferences = FilterPreferences()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Integration with existing SummitAI models
    @Published var userTrips: [UserTrip] = []
    @Published var userExpeditions: [UserExpedition] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    
    // UserDefaults keys
    private let bookmarkedTripsKey = "mountain_experiences_bookmarked_trips"
    private let searchHistoryKey = "mountain_experiences_search_history"
    private let filterPreferencesKey = "mountain_experiences_filter_preferences"
    private let userTripsKey = "mountain_experiences_user_trips"
    private let userExpeditionsKey = "mountain_experiences_user_expeditions"
    
    init() {
        loadData()
        setupBindings()
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        loadAvailableTrips()
        loadAvailableLocations()
        loadUserPreferences()
        loadUserTrips()
        loadUserExpeditions()
    }
    
    private func loadAvailableTrips() {
        availableTrips = Trip.sampleTrips
    }
    
    private func loadAvailableLocations() {
        availableLocations = Location.allSampleLocations
    }
    
    private func loadUserPreferences() {
        // Load bookmarked trips
        if let data = userDefaults.data(forKey: bookmarkedTripsKey),
           let bookmarkedIds = try? JSONDecoder().decode([UUID].self, from: data) {
            userBookmarkedTrips = Set(bookmarkedIds)
        }
        
        // Load search history
        if let data = userDefaults.data(forKey: searchHistoryKey),
           let history = try? JSONDecoder().decode([String].self, from: data) {
            userSearchHistory = history
        }
        
        // Load filter preferences
        if let data = userDefaults.data(forKey: filterPreferencesKey),
           let preferences = try? JSONDecoder().decode(FilterPreferences.self, from: data) {
            userFilterPreferences = preferences
        }
    }
    
    private func loadUserTrips() {
        if let data = userDefaults.data(forKey: userTripsKey),
           let trips = try? JSONDecoder().decode([UserTrip].self, from: data) {
            userTrips = trips
        }
    }
    
    private func loadUserExpeditions() {
        if let data = userDefaults.data(forKey: userExpeditionsKey),
           let expeditions = try? JSONDecoder().decode([UserExpedition].self, from: data) {
            userExpeditions = expeditions
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveUserPreferences() {
        // Save bookmarked trips
        if let data = try? JSONEncoder().encode(Array(userBookmarkedTrips)) {
            userDefaults.set(data, forKey: bookmarkedTripsKey)
        }
        
        // Save search history
        if let data = try? JSONEncoder().encode(userSearchHistory) {
            userDefaults.set(data, forKey: searchHistoryKey)
        }
        
        // Save filter preferences
        if let data = try? JSONEncoder().encode(userFilterPreferences) {
            userDefaults.set(data, forKey: filterPreferencesKey)
        }
    }
    
    private func saveUserTrips() {
        if let data = try? JSONEncoder().encode(userTrips) {
            userDefaults.set(data, forKey: userTripsKey)
        }
    }
    
    private func saveUserExpeditions() {
        if let data = try? JSONEncoder().encode(userExpeditions) {
            userDefaults.set(data, forKey: userExpeditionsKey)
        }
    }
    
    // MARK: - Bindings Setup
    
    private func setupBindings() {
        // Auto-save user preferences when they change
        $userBookmarkedTrips
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveUserPreferences()
            }
            .store(in: &cancellables)
        
        $userSearchHistory
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveUserPreferences()
            }
            .store(in: &cancellables)
        
        $userFilterPreferences
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveUserPreferences()
            }
            .store(in: &cancellables)
        
        // Auto-save user trips and expeditions
        $userTrips
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveUserTrips()
            }
            .store(in: &cancellables)
        
        $userExpeditions
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveUserExpeditions()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Trip Management
    
    func toggleTripBookmark(_ tripId: UUID) {
        if userBookmarkedTrips.contains(tripId) {
            userBookmarkedTrips.remove(tripId)
        } else {
            userBookmarkedTrips.insert(tripId)
        }
    }
    
    func isTripBookmarked(_ tripId: UUID) -> Bool {
        return userBookmarkedTrips.contains(tripId)
    }
    
    func getBookmarkedTrips() -> [Trip] {
        return availableTrips.filter { userBookmarkedTrips.contains($0.id) }
    }
    
    // MARK: - Search History Management
    
    func addToSearchHistory(_ searchText: String) {
        if !searchText.isEmpty && !userSearchHistory.contains(searchText) {
            userSearchHistory.insert(searchText, at: 0)
            
            // Limit to 20 searches
            if userSearchHistory.count > 20 {
                userSearchHistory = Array(userSearchHistory.prefix(20))
            }
        }
    }
    
    func clearSearchHistory() {
        userSearchHistory.removeAll()
    }
    
    func removeFromSearchHistory(_ searchText: String) {
        userSearchHistory.removeAll { $0 == searchText }
    }
    
    // MARK: - Trip Planning and Booking
    
    func planTrip(_ trip: Trip) -> UserTrip {
        let userTrip = UserTrip(
            id: UUID(),
            tripId: trip.id,
            status: .planned,
            plannedDate: nil,
            participants: 1,
            notes: ""
        )
        
        userTrips.append(userTrip)
        return userTrip
    }
    
    func bookTrip(_ trip: Trip, plannedDate: Date, participants: Int = 1, notes: String = "") -> UserTrip {
        let userTrip = UserTrip(
            id: UUID(),
            tripId: trip.id,
            status: .booked,
            plannedDate: plannedDate,
            participants: participants,
            notes: notes
        )
        
        userTrips.append(userTrip)
        return userTrip
    }
    
    func updateUserTrip(_ userTrip: UserTrip) {
        if let index = userTrips.firstIndex(where: { $0.id == userTrip.id }) {
            userTrips[index] = userTrip
        }
    }
    
    func cancelUserTrip(_ userTripId: UUID) {
        if let index = userTrips.firstIndex(where: { $0.id == userTripId }) {
            userTrips[index].status = .cancelled
        }
    }
    
    func completeUserTrip(_ userTripId: UUID) {
        if let index = userTrips.firstIndex(where: { $0.id == userTripId }) {
            userTrips[index].status = .completed
            userTrips[index].completedDate = Date()
        }
    }
    
    // MARK: - Expedition Integration
    
    func createExpeditionFromTrip(_ trip: Trip) -> UserExpedition {
        let userExpedition = UserExpedition(
            id: UUID(),
            tripId: trip.id,
            mountainId: getMountainIdForTrip(trip),
            status: .active,
            startDate: Date(),
            progress: 0.0,
            notes: ""
        )
        
        userExpeditions.append(userExpedition)
        return userExpedition
    }
    
    func updateExpeditionProgress(_ expeditionId: UUID, progress: Double) {
        if let index = userExpeditions.firstIndex(where: { $0.id == expeditionId }) {
            userExpeditions[index].progress = progress
            userExpeditions[index].lastUpdatedDate = Date()
            
            if progress >= 1.0 {
                userExpeditions[index].status = .completed
                userExpeditions[index].completedDate = Date()
            }
        }
    }
    
    func getActiveExpeditions() -> [UserExpedition] {
        return userExpeditions.filter { $0.status == .active }
    }
    
    func getCompletedExpeditions() -> [UserExpedition] {
        return userExpeditions.filter { $0.status == .completed }
    }
    
    // MARK: - Data Integration Helpers
    
    private func getMountainIdForTrip(_ trip: Trip) -> UUID {
        // Map trip locations to mountain IDs from existing SummitAI data
        switch trip.locationId {
        case "nepal":
            return Mountain.everest.id
        case "tanzania":
            return Mountain.kilimanjaro.id
        case "france":
            return Mountain.blanc.id
        case "japan":
            return Mountain.fuji.id
        default:
            return UUID() // Generate new ID for unknown locations
        }
    }
    
    func getTripsForLocation(_ locationId: String) -> [Trip] {
        return availableTrips.filter { $0.locationId == locationId }
    }
    
    func getTripsForCategory(_ category: TripCategory) -> [Trip] {
        return availableTrips.filter { $0.category == category }
    }
    
    func getTripsForDifficulty(_ difficulty: TripDifficulty) -> [Trip] {
        return availableTrips.filter { $0.difficulty == difficulty }
    }
    
    func getPopularTrips(limit: Int = 10) -> [Trip] {
        return availableTrips
            .sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
            .prefix(limit)
            .map { $0 }
    }
    
    func getRecommendedTrips(for userPreferences: FilterPreferences, limit: Int = 10) -> [Trip] {
        var filteredTrips = availableTrips
        
        // Apply user preferences
        if !userPreferences.preferredCategories.isEmpty {
            filteredTrips = filteredTrips.filter { userPreferences.preferredCategories.contains($0.category) }
        }
        
        if !userPreferences.preferredDifficulties.isEmpty {
            filteredTrips = filteredTrips.filter { userPreferences.preferredDifficulties.contains($0.difficulty) }
        }
        
        if let maxDuration = userPreferences.maxDuration {
            filteredTrips = filteredTrips.filter { $0.durationDays <= maxDuration }
        }
        
        if let maxPrice = userPreferences.maxPrice {
            filteredTrips = filteredTrips.filter { ($0.price ?? 0) <= maxPrice }
        }
        
        if let minRating = userPreferences.minRating {
            filteredTrips = filteredTrips.filter { ($0.rating ?? 0) >= minRating }
        }
        
        return filteredTrips
            .sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Statistics and Analytics
    
    func getUserTripStatistics() -> TripStatistics {
        let completedTrips = userTrips.filter { $0.status == .completed }
        let plannedTrips = userTrips.filter { $0.status == .planned }
        let bookedTrips = userTrips.filter { $0.status == .booked }
        
        let totalSpent = completedTrips.compactMap { userTrip in
            availableTrips.first { $0.id == userTrip.tripId }?.price
        }.reduce(0, +)
        
        let averageRating = completedTrips.compactMap { userTrip in
            availableTrips.first { $0.id == userTrip.tripId }?.rating
        }.reduce(0, +) / Double(max(completedTrips.count, 1))
        
        return TripStatistics(
            totalTripsPlanned: userTrips.count,
            totalTripsCompleted: completedTrips.count,
            totalTripsBooked: bookedTrips.count,
            totalSpent: totalSpent,
            averageRating: averageRating,
            favoriteCategory: getMostUsedCategory(),
            favoriteDifficulty: getMostUsedDifficulty(),
            totalBookmarked: userBookmarkedTrips.count
        )
    }
    
    private func getMostUsedCategory() -> TripCategory? {
        let categoryCounts = Dictionary(grouping: userTrips, by: { userTrip in
            availableTrips.first { $0.id == userTrip.tripId }?.category
        }).compactMapValues { $0.count }
        
        return categoryCounts.max(by: { $0.value < $1.value })?.key
    }
    
    private func getMostUsedDifficulty() -> TripDifficulty? {
        let difficultyCounts = Dictionary(grouping: userTrips, by: { userTrip in
            availableTrips.first { $0.id == userTrip.tripId }?.difficulty
        }).compactMapValues { $0.count }
        
        return difficultyCounts.max(by: { $0.value < $1.value })?.key
    }
    
    // MARK: - Data Sync with Existing SummitAI
    
    func syncWithExpeditionManager(_ expeditionManager: ExpeditionManager) {
        // Sync user expeditions with existing expedition progress
        for expedition in userExpeditions where expedition.status == .active {
            // Create or update expedition progress in ExpeditionManager
            // This would require extending ExpeditionManager to support Mountain Experiences trips
        }
    }
    
    func syncWithUserManager(_ userManager: UserManager) {
        // Sync user preferences and statistics with existing user data
        // This would require extending UserManager to support Mountain Experiences data
    }
}

// MARK: - Supporting Models

struct FilterPreferences: Codable {
    var preferredCategories: Set<TripCategory> = []
    var preferredDifficulties: Set<TripDifficulty> = []
    var maxDuration: Int?
    var maxPrice: Double?
    var minRating: Double?
    var preferredLocations: Set<String> = []
    var showBookmarkedOnly: Bool = false
    
    init() {}
}

struct UserTrip: Identifiable, Codable {
    let id: UUID
    let tripId: UUID
    var status: TripStatus
    var plannedDate: Date?
    var participants: Int
    var notes: String
    var bookedDate: Date?
    var completedDate: Date?
    var cancelledDate: Date?
    
    init(id: UUID = UUID(), tripId: UUID, status: TripStatus, plannedDate: Date? = nil, participants: Int = 1, notes: String = "") {
        self.id = id
        self.tripId = tripId
        self.status = status
        self.plannedDate = plannedDate
        self.participants = participants
        self.notes = notes
        self.bookedDate = status == .booked ? Date() : nil
    }
    
    enum TripStatus: String, Codable, CaseIterable {
        case planned = "Planned"
        case booked = "Booked"
        case completed = "Completed"
        case cancelled = "Cancelled"
        
        var color: Color {
            switch self {
            case .planned: return .blue
            case .booked: return .orange
            case .completed: return .green
            case .cancelled: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .planned: return "calendar"
            case .booked: return "checkmark.circle"
            case .completed: return "checkmark.circle.fill"
            case .cancelled: return "xmark.circle"
            }
        }
    }
}

struct UserExpedition: Identifiable, Codable {
    let id: UUID
    let tripId: UUID
    let mountainId: UUID
    var status: ExpeditionStatus
    let startDate: Date
    var progress: Double // 0.0 to 1.0
    var notes: String
    var lastUpdatedDate: Date
    var completedDate: Date?
    
    init(id: UUID = UUID(), tripId: UUID, mountainId: UUID, status: ExpeditionStatus, startDate: Date = Date(), progress: Double = 0.0, notes: String = "") {
        self.id = id
        self.tripId = tripId
        self.mountainId = mountainId
        self.status = status
        self.startDate = startDate
        self.progress = progress
        self.notes = notes
        self.lastUpdatedDate = Date()
        self.completedDate = nil
    }
    
    enum ExpeditionStatus: String, Codable, CaseIterable {
        case active = "Active"
        case completed = "Completed"
        case paused = "Paused"
        case abandoned = "Abandoned"
        
        var color: Color {
            switch self {
            case .active: return .green
            case .completed: return .blue
            case .paused: return .orange
            case .abandoned: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .active: return "play.circle.fill"
            case .completed: return "checkmark.circle.fill"
            case .paused: return "pause.circle.fill"
            case .abandoned: return "xmark.circle.fill"
            }
        }
    }
}

struct TripStatistics: Codable {
    let totalTripsPlanned: Int
    let totalTripsCompleted: Int
    let totalTripsBooked: Int
    let totalSpent: Double
    let averageRating: Double
    let favoriteCategory: TripCategory?
    let favoriteDifficulty: TripDifficulty?
    let totalBookmarked: Int
}
