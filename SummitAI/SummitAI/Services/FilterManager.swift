import Foundation
import Combine

// MARK: - Filter Manager
// Step 5: Search & Filter Functionality

class FilterManager: ObservableObject {
    @Published var selectedCategories: Set<TripCategory> = []
    @Published var selectedDifficulties: Set<TripDifficulty> = []
    @Published var selectedDurationRange: ClosedRange<Int> = 1...60
    @Published var selectedPriceRange: ClosedRange<Double> = 0...50000
    @Published var selectedRating: Double = 0.0
    @Published var selectedLocations: Set<String> = []
    @Published var showBookmarkedOnly: Bool = false
    
    // Filter presets
    @Published var activePreset: FilterPreset = .none
    
    enum FilterPreset: String, CaseIterable {
        case none = "All"
        case beginner = "Beginner Friendly"
        case advanced = "Advanced Climbers"
        case budget = "Budget Trips"
        case luxury = "Luxury Expeditions"
        case quick = "Quick Getaways"
        case epic = "Epic Adventures"
        
        var description: String {
            switch self {
            case .none: return "Show all trips"
            case .beginner: return "Easy to moderate difficulty"
            case .advanced: return "Hard difficulty, technical climbs"
            case .budget: return "Under $2000"
            case .luxury: return "Premium experiences"
            case .quick: return "Under 7 days"
            case .epic: return "High-rated, challenging trips"
            }
        }
        
        var icon: String {
            switch self {
            case .none: return "list.bullet"
            case .beginner: return "person.walk"
            case .advanced: return "figure.climbing"
            case .budget: return "dollarsign.circle"
            case .luxury: return "crown.fill"
            case .quick: return "clock"
            case .epic: return "star.fill"
            }
        }
    }
    
    // Computed properties
    var hasActiveFilters: Bool {
        !selectedCategories.isEmpty ||
        !selectedDifficulties.isEmpty ||
        selectedDurationRange != 1...60 ||
        selectedPriceRange != 0...50000 ||
        selectedRating > 0.0 ||
        !selectedLocations.isEmpty ||
        showBookmarkedOnly ||
        activePreset != .none
    }
    
    var filterCount: Int {
        var count = 0
        if !selectedCategories.isEmpty { count += 1 }
        if !selectedDifficulties.isEmpty { count += 1 }
        if selectedDurationRange != 1...60 { count += 1 }
        if selectedPriceRange != 0...50000 { count += 1 }
        if selectedRating > 0.0 { count += 1 }
        if !selectedLocations.isEmpty { count += 1 }
        if showBookmarkedOnly { count += 1 }
        return count
    }
    
    init() {
        setupFilterPublisher()
    }
    
    // MARK: - Filter Application
    
    private func setupFilterPublisher() {
        Publishers.CombineLatest4(
            $selectedCategories,
            $selectedDifficulties,
            $selectedDurationRange,
            $selectedPriceRange
        )
        .combineLatest($selectedRating, $selectedLocations, $showBookmarkedOnly)
        .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func applyFilters(to trips: [Trip]) -> [Trip] {
        var filteredTrips = trips
        
        // Category filter
        if !selectedCategories.isEmpty {
            filteredTrips = filteredTrips.filter { selectedCategories.contains($0.category) }
        }
        
        // Difficulty filter
        if !selectedDifficulties.isEmpty {
            filteredTrips = filteredTrips.filter { selectedDifficulties.contains($0.difficulty) }
        }
        
        // Duration filter
        filteredTrips = filteredTrips.filter { trip in
            selectedDurationRange.contains(trip.durationDays)
        }
        
        // Price filter
        filteredTrips = filteredTrips.filter { trip in
            guard let price = trip.price else { return true }
            return selectedPriceRange.contains(price)
        }
        
        // Rating filter
        if selectedRating > 0.0 {
            filteredTrips = filteredTrips.filter { trip in
                guard let rating = trip.rating else { return false }
                return rating >= selectedRating
            }
        }
        
        // Location filter
        if !selectedLocations.isEmpty {
            filteredTrips = filteredTrips.filter { selectedLocations.contains($0.locationId) }
        }
        
        // Bookmarked filter
        if showBookmarkedOnly {
            filteredTrips = filteredTrips.filter { $0.isBookmarked }
        }
        
        return filteredTrips
    }
    
    // MARK: - Preset Management
    
    func applyPreset(_ preset: FilterPreset) {
        clearAllFilters()
        activePreset = preset
        
        switch preset {
        case .none:
            break
            
        case .beginner:
            selectedDifficulties = [.easy, .moderate]
            selectedDurationRange = 1...14
            
        case .advanced:
            selectedDifficulties = [.hard]
            selectedRating = 4.5
            
        case .budget:
            selectedPriceRange = 0...2000
            
        case .luxury:
            selectedPriceRange = 5000...50000
            selectedRating = 4.7
            
        case .quick:
            selectedDurationRange = 1...7
            
        case .epic:
            selectedRating = 4.8
            selectedDifficulties = [.hard]
            selectedDurationRange = 14...60
        }
    }
    
    func clearAllFilters() {
        selectedCategories.removeAll()
        selectedDifficulties.removeAll()
        selectedDurationRange = 1...60
        selectedPriceRange = 0...50000
        selectedRating = 0.0
        selectedLocations.removeAll()
        showBookmarkedOnly = false
        activePreset = .none
    }
    
    func clearCategoryFilters() {
        selectedCategories.removeAll()
    }
    
    func clearDifficultyFilters() {
        selectedDifficulties.removeAll()
    }
    
    func clearDurationFilter() {
        selectedDurationRange = 1...60
    }
    
    func clearPriceFilter() {
        selectedPriceRange = 0...50000
    }
    
    func clearRatingFilter() {
        selectedRating = 0.0
    }
    
    func clearLocationFilters() {
        selectedLocations.removeAll()
    }
    
    func clearBookmarkFilter() {
        showBookmarkedOnly = false
    }
    
    // MARK: - Filter Toggle Methods
    
    func toggleCategory(_ category: TripCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        activePreset = .none
    }
    
    func toggleDifficulty(_ difficulty: TripDifficulty) {
        if selectedDifficulties.contains(difficulty) {
            selectedDifficulties.remove(difficulty)
        } else {
            selectedDifficulties.insert(difficulty)
        }
        activePreset = .none
    }
    
    func toggleLocation(_ locationId: String) {
        if selectedLocations.contains(locationId) {
            selectedLocations.remove(locationId)
        } else {
            selectedLocations.insert(locationId)
        }
        activePreset = .none
    }
    
    func toggleBookmarked() {
        showBookmarkedOnly.toggle()
        activePreset = .none
    }
    
    // MARK: - Filter Statistics
    
    func getFilterStatistics(for trips: [Trip]) -> FilterStatistics {
        let categories = Dictionary(grouping: trips, by: { $0.category })
        let difficulties = Dictionary(grouping: trips, by: { $0.difficulty })
        let locations = Dictionary(grouping: trips, by: { $0.locationId })
        
        let priceRange = trips.compactMap { $0.price }
        let ratingRange = trips.compactMap { $0.rating }
        let durationRange = trips.map { $0.durationDays }
        
        return FilterStatistics(
            categoryCounts: categories.mapValues { $0.count },
            difficultyCounts: difficulties.mapValues { $0.count },
            locationCounts: locations.mapValues { $0.count },
            priceRange: priceRange.isEmpty ? nil : (priceRange.min()!...priceRange.max()!),
            ratingRange: ratingRange.isEmpty ? nil : (ratingRange.min()!...ratingRange.max()!),
            durationRange: durationRange.isEmpty ? nil : (durationRange.min()!...durationRange.max()!),
            totalTrips: trips.count,
            bookmarkedTrips: trips.filter { $0.isBookmarked }.count
        )
    }
    
    // MARK: - Smart Filter Suggestions
    
    func getSmartSuggestions(for trips: [Trip]) -> [FilterSuggestion] {
        var suggestions: [FilterSuggestion] = []
        
        // Popular categories
        let categoryCounts = Dictionary(grouping: trips, by: { $0.category })
        let popularCategories = categoryCounts.sorted { $0.value.count > $1.value.count }.prefix(3)
        
        for (category, trips) in popularCategories {
            if !selectedCategories.contains(category) {
                suggestions.append(FilterSuggestion(
                    type: .category,
                    title: category.rawValue,
                    subtitle: "\(trips.count) trips available",
                    icon: category.icon,
                    action: { [weak self] in
                        self?.toggleCategory(category)
                    }
                ))
            }
        }
        
        // Popular difficulties
        let difficultyCounts = Dictionary(grouping: trips, by: { $0.difficulty })
        let popularDifficulties = difficultyCounts.sorted { $0.value.count > $1.value.count }.prefix(2)
        
        for (difficulty, trips) in popularDifficulties {
            if !selectedDifficulties.contains(difficulty) {
                suggestions.append(FilterSuggestion(
                    type: .difficulty,
                    title: difficulty.rawValue,
                    subtitle: "\(trips.count) trips available",
                    icon: difficulty.icon,
                    action: { [weak self] in
                        self?.toggleDifficulty(difficulty)
                    }
                ))
            }
        }
        
        return suggestions
    }
}

// MARK: - Filter Statistics Model

struct FilterStatistics {
    let categoryCounts: [TripCategory: Int]
    let difficultyCounts: [TripDifficulty: Int]
    let locationCounts: [String: Int]
    let priceRange: ClosedRange<Double>?
    let ratingRange: ClosedRange<Double>?
    let durationRange: ClosedRange<Int>?
    let totalTrips: Int
    let bookmarkedTrips: Int
}

// MARK: - Filter Suggestion Model

struct FilterSuggestion: Identifiable {
    let id = UUID()
    let type: SuggestionType
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    enum SuggestionType {
        case category
        case difficulty
        case location
        case duration
        case price
        case rating
    }
}

// MARK: - Trip Difficulty Extension

extension TripDifficulty {
    var icon: String {
        switch self {
        case .easy: return "person.walk"
        case .moderate: return "figure.walk"
        case .hard: return "figure.climbing"
        }
    }
}

// MARK: - Trip Category Extension

extension TripCategory {
    var icon: String {
        switch self {
        case .peaks: return "mountain.2.fill"
        case .hiking: return "figure.walk"
        case .climbing: return "figure.climbing"
        case .guides: return "person.2.fill"
        }
    }
}
