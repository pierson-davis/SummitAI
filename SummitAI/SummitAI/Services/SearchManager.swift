import Foundation
import Combine

// MARK: - Search Manager
// Step 5: Search & Filter Functionality

class SearchManager: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [Trip] = []
    @Published var isSearching: Bool = false
    @Published var searchHistory: [String] = []
    @Published var recentSearches: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var searchWorkItem: DispatchWorkItem?
    private let debounceDelay: TimeInterval = 0.3
    
    // Sample data for demonstration
    private let allTrips: [Trip] = [
        // Nepal trips
        Trip(
            id: UUID(),
            title: "Everest Base Camp Trek",
            category: .hiking,
            durationDays: 14,
            difficulty: .hard,
            coverImageURL: "https://images.unsplash.com/photo-1519904981063-b0cf448d479e",
            locationId: "nepal",
            description: "Classic trek to the base of the world's highest mountain",
            price: 2500,
            rating: 4.8,
            isBookmarked: false
        ),
        Trip(
            id: UUID(),
            title: "Annapurna Circuit",
            category: .hiking,
            durationDays: 21,
            difficulty: .moderate,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "nepal",
            description: "Diverse landscapes and cultural experiences",
            price: 1800,
            rating: 4.6,
            isBookmarked: true
        ),
        Trip(
            id: UUID(),
            title: "Manaslu Circuit Trek",
            category: .hiking,
            durationDays: 18,
            difficulty: .hard,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "nepal",
            description: "Remote and challenging trek around Manaslu",
            price: 2200,
            rating: 4.7,
            isBookmarked: false
        ),
        Trip(
            id: UUID(),
            title: "Everest Summit Expedition",
            category: .climbing,
            durationDays: 60,
            difficulty: .hard,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "nepal",
            description: "Ultimate mountaineering challenge to the world's highest peak",
            price: 45000,
            rating: 4.9,
            isBookmarked: false
        ),
        Trip(
            id: UUID(),
            title: "Ama Dablam Climb",
            category: .climbing,
            durationDays: 25,
            difficulty: .hard,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "nepal",
            description: "Technical climbing on one of the most beautiful peaks",
            price: 8500,
            rating: 4.8,
            isBookmarked: false
        ),
        
        // Tanzania trips
        Trip(
            id: UUID(),
            title: "Kilimanjaro Summit",
            category: .climbing,
            durationDays: 8,
            difficulty: .moderate,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "tanzania",
            description: "Africa's highest peak adventure",
            price: 3200,
            rating: 4.9,
            isBookmarked: false
        ),
        Trip(
            id: UUID(),
            title: "Kilimanjaro Lemosho Route",
            category: .hiking,
            durationDays: 9,
            difficulty: .moderate,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "tanzania",
            description: "Scenic route with high success rate",
            price: 3800,
            rating: 4.7,
            isBookmarked: true
        ),
        
        // France trips
        Trip(
            id: UUID(),
            title: "Mont Blanc Ascent",
            category: .climbing,
            durationDays: 5,
            difficulty: .hard,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "france",
            description: "Western Europe's highest peak",
            price: 1800,
            rating: 4.7,
            isBookmarked: false
        ),
        Trip(
            id: UUID(),
            title: "Chamonix Mountain Guides",
            category: .guides,
            durationDays: 3,
            difficulty: .easy,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "france",
            description: "Professional mountain guiding services",
            price: 1200,
            rating: 4.8,
            isBookmarked: false
        ),
        
        // Japan trips
        Trip(
            id: UUID(),
            title: "Mount Fuji Climb",
            category: .hiking,
            durationDays: 2,
            difficulty: .moderate,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "japan",
            description: "Japan's iconic mountain climb",
            price: 800,
            rating: 4.5,
            isBookmarked: false
        ),
        Trip(
            id: UUID(),
            title: "Fuji Five Lakes Hiking",
            category: .hiking,
            durationDays: 4,
            difficulty: .easy,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "japan",
            description: "Scenic hiking around Mount Fuji",
            price: 600,
            rating: 4.4,
            isBookmarked: false
        )
    ]
    
    init() {
        setupSearchPublisher()
        loadSearchHistory()
    }
    
    // MARK: - Search Functionality
    
    private func setupSearchPublisher() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.performSearch(searchText)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(_ searchText: String) {
        // Cancel previous search
        searchWorkItem?.cancel()
        
        // Create new search work item
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isSearching = true
            }
            
            // Simulate network delay
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.2) {
                let results = self.searchTrips(searchText)
                
                DispatchQueue.main.async {
                    self.searchResults = results
                    self.isSearching = false
                    
                    // Add to search history if not empty
                    if !searchText.isEmpty && !self.searchHistory.contains(searchText) {
                        self.addToSearchHistory(searchText)
                    }
                }
            }
        }
        
        searchWorkItem = workItem
        DispatchQueue.global(qos: .userInitiated).async(execute: workItem)
    }
    
    private func searchTrips(_ searchText: String) -> [Trip] {
        guard !searchText.isEmpty else {
            return []
        }
        
        let lowercaseSearchText = searchText.lowercased()
        
        return allTrips.filter { trip in
            trip.title.lowercased().contains(lowercaseSearchText) ||
            trip.description.lowercased().contains(lowercaseSearchText) ||
            trip.category.rawValue.lowercased().contains(lowercaseSearchText) ||
            trip.difficulty.rawValue.lowercased().contains(lowercaseSearchText) ||
            getLocationName(for: trip.locationId).lowercased().contains(lowercaseSearchText)
        }
    }
    
    // MARK: - Search History Management
    
    private func addToSearchHistory(_ searchText: String) {
        searchHistory.insert(searchText, at: 0)
        
        // Limit history to 20 items
        if searchHistory.count > 20 {
            searchHistory = Array(searchHistory.prefix(20))
        }
        
        saveSearchHistory()
    }
    
    private func loadSearchHistory() {
        if let data = UserDefaults.standard.data(forKey: "searchHistory"),
           let history = try? JSONDecoder().decode([String].self, from: data) {
            searchHistory = history
        }
        
        // Set recent searches (last 5)
        recentSearches = Array(searchHistory.prefix(5))
    }
    
    private func saveSearchHistory() {
        if let data = try? JSONEncoder().encode(searchHistory) {
            UserDefaults.standard.set(data, forKey: "searchHistory")
        }
    }
    
    func clearSearchHistory() {
        searchHistory.removeAll()
        recentSearches.removeAll()
        UserDefaults.standard.removeObject(forKey: "searchHistory")
    }
    
    func removeFromSearchHistory(_ searchText: String) {
        searchHistory.removeAll { $0 == searchText }
        recentSearches = Array(searchHistory.prefix(5))
        saveSearchHistory()
    }
    
    // MARK: - Location Helpers
    
    private func getLocationName(for locationId: String) -> String {
        switch locationId {
        case "nepal": return "Nepal"
        case "tanzania": return "Tanzania"
        case "france": return "France"
        case "japan": return "Japan"
        default: return locationId.capitalized
        }
    }
    
    // MARK: - Public Methods
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        searchWorkItem?.cancel()
    }
    
    func searchForPopularDestinations() -> [Trip] {
        return allTrips.filter { trip in
            trip.rating ?? 0 >= 4.7 // High-rated trips
        }.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
    }
    
    func searchForNearbyTrips(locationId: String) -> [Trip] {
        return allTrips.filter { $0.locationId == locationId }
    }
    
    func getSearchSuggestions(for searchText: String) -> [String] {
        guard !searchText.isEmpty else { return [] }
        
        let lowercaseSearchText = searchText.lowercased()
        var suggestions: Set<String> = []
        
        // Add matching search history
        suggestions.formUnion(searchHistory.filter { 
            $0.lowercased().contains(lowercaseSearchText) 
        })
        
        // Add matching location names
        let locations = ["Nepal", "Tanzania", "France", "Japan", "Himalayas", "Kilimanjaro", "Mont Blanc", "Mount Fuji"]
        suggestions.formUnion(locations.filter { 
            $0.lowercased().contains(lowercaseSearchText) 
        })
        
        // Add matching categories
        suggestions.formUnion(TripCategory.allCases.compactMap { category in
            category.rawValue.lowercased().contains(lowercaseSearchText) ? category.rawValue : nil
        })
        
        return Array(suggestions).prefix(5).map { $0 }
    }
}

// MARK: - Search Result Model

struct SearchResult: Identifiable {
    let id = UUID()
    let trip: Trip
    let relevanceScore: Double
    let matchedFields: [String]
    
    init(trip: Trip, searchText: String) {
        self.trip = trip
        var score: Double = 0
        var fields: [String] = []
        
        let lowercaseSearchText = searchText.lowercased()
        
        // Title match (highest weight)
        if trip.title.lowercased().contains(lowercaseSearchText) {
            score += 10
            fields.append("title")
        }
        
        // Description match
        if trip.description.lowercased().contains(lowercaseSearchText) {
            score += 5
            fields.append("description")
        }
        
        // Category match
        if trip.category.rawValue.lowercased().contains(lowercaseSearchText) {
            score += 3
            fields.append("category")
        }
        
        // Difficulty match
        if trip.difficulty.rawValue.lowercased().contains(lowercaseSearchText) {
            score += 2
            fields.append("difficulty")
        }
        
        // Rating boost for popular trips
        if let rating = trip.rating, rating >= 4.7 {
            score += 1
        }
        
        self.relevanceScore = score
        self.matchedFields = fields
    }
}
