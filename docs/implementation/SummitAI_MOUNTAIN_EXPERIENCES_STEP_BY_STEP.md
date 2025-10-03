# SummitAI Mountain Experiences - Step-by-Step Implementation Guide

## Phase 1: Design System Foundation (2 hours)

### Step 1.1: Create Design System Files (30 min)

Create the following files in `SummitAI/Views/DesignSystem/`:

#### ColorTokens.swift
```swift
import SwiftUI

struct ColorTokens {
    // Dark theme color palette
    static let surface0 = Color(red: 0.059, green: 0.063, blue: 0.071) // #0F1012
    static let textPrimary = Color(red: 0.871, green: 0.871, blue: 0.871) // #DEDEDE
    static let textSecondary = Color(red: 0.647, green: 0.647, blue: 0.651) // #A5A5A6
    static let textTertiary = Color(red: 0.443, green: 0.451, blue: 0.510) // #717382
    static let borderMuted = Color(red: 0.357, green: 0.361, blue: 0.373) // #5B5C5F
    static let accent600 = Color(red: 0.106, green: 0.188, blue: 0.294) // #1B304B
    static let accent500 = Color(red: 0.208, green: 0.278, blue: 0.369) // #35475E
    
    // Derived tokens
    static let surfaceElev1 = Color(red: 0.082, green: 0.090, blue: 0.102) // #15171A
    static let surfaceElev2 = Color(red: 0.106, green: 0.118, blue: 0.133) // #1B1E22
    static let overlay60 = Color.black.opacity(0.6)
    static let overlay30 = Color.black.opacity(0.3)
    
    // Interaction states
    static let pressOverlay = Color.white.opacity(0.08)
    static let focusRing = Color.textPrimary.opacity(0.4)
}
```

#### Typography.swift
```swift
import SwiftUI

struct Typography {
    // Display styles
    static let displayXL = Font.system(size: 34, weight: .bold, design: .default)
    static let titleL = Font.system(size: 28, weight: .bold, design: .default)
    static let bodyM = Font.system(size: 16, weight: .regular, design: .default)
    static let labelS = Font.system(size: 12, weight: .medium, design: .default)
    
    // Line heights
    static let displayXLLineHeight: CGFloat = 44
    static let titleLLineHeight: CGFloat = 34
    static let bodyMLineHeight: CGFloat = 24
    static let labelSLineHeight: CGFloat = 16
}
```

#### Spacing.swift
```swift
import SwiftUI

struct Spacing {
    // 8-pt spacing system
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 48
    static let xxxxl: CGFloat = 56
    static let xxxxxl: CGFloat = 64
    
    // Component specific
    static let cardPadding: CGFloat = 16
    static let screenPadding: CGFloat = 24
    static let chipHeight: CGFloat = 32
    static let searchHeight: CGFloat = 52
}
```

#### CornerRadius.swift
```swift
import SwiftUI

struct CornerRadius {
    static let card: CGFloat = 20
    static let input: CGFloat = 12
    static let chip: CGFloat = 12
    static let button: CGFloat = 12
    static let small: CGFloat = 8
}
```

### Step 1.2: Create Design System Manager (30 min)

#### DesignSystem.swift
```swift
import SwiftUI

struct DesignSystem {
    // Color system
    static let colors = ColorTokens.self
    static let typography = Typography.self
    static let spacing = Spacing.self
    static let cornerRadius = CornerRadius.self
    
    // Shadow system
    static let shadowElev1 = Shadow(
        color: Color.black.opacity(0.25),
        radius: 2,
        x: 0,
        y: 2
    )
    
    static let shadowElev2 = Shadow(
        color: Color.black.opacity(0.25),
        radius: 4,
        x: 0,
        y: 4
    )
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}
```

## Phase 2: Home/Discover Screen Transformation (3 hours)

### Step 2.1: Create Mountain Hero Component (1 hour)

#### MountainHeroView.swift
```swift
import SwiftUI

struct MountainHeroView: View {
    let location: Location
    @State private var animateParticles = false
    
    var body: some View {
        ZStack {
            // Full-bleed mountain image
            AsyncImage(url: URL(string: location.coverImageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(DesignSystem.colors.surfaceElev1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            
            // Bottom gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    DesignSystem.colors.overlay60
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: UIScreen.main.bounds.height * 0.4)
            .frame(maxHeight: .infinity, alignment: .bottom)
            
            // Contextual label with pin
            VStack {
                HStack {
                    Spacer()
                    
                    // Pin with dashed line
                    VStack(spacing: 8) {
                        // Dashed line
                        Rectangle()
                            .fill(DesignSystem.colors.textPrimary)
                            .frame(width: 2, height: 40)
                            .opacity(0.6)
                        
                        // Pin and label
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(DesignSystem.colors.accent500)
                                .font(.title2)
                            
                            Text(location.name)
                                .font(DesignSystem.typography.labelS)
                                .foregroundColor(DesignSystem.colors.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(DesignSystem.colors.surfaceElev2)
                                )
                            
                            // Flag
                            Text(location.flagCode.uppercased())
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.colors.textPrimary)
                                .frame(width: 18, height: 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(DesignSystem.colors.accent600)
                                )
                        }
                    }
                    .padding(.trailing, DesignSystem.spacing.lg)
                    .padding(.top, 100)
                }
                
                Spacer()
            }
            
            // Atmospheric effects
            ForEach(0..<20, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        Animation.linear(duration: Double.random(in: 3...8))
                            .repeatForever(autoreverses: false),
                        value: animateParticles
                    )
            }
        }
        .onAppear {
            animateParticles = true
        }
    }
}
```

### Step 2.2: Create Home Discover View (1 hour)

#### HomeDiscoverView.swift
```swift
import SwiftUI

struct HomeDiscoverView: View {
    @StateObject private var searchManager = SearchManager()
    @StateObject private var filterManager = FilterManager()
    @State private var searchText = ""
    @State private var showingFilter = false
    @State private var selectedLocation: Location?
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.colors.surface0
                .ignoresSafeArea()
            
            if let location = selectedLocation {
                // Full-bleed mountain hero
                MountainHeroView(location: location)
                    .ignoresSafeArea()
                
                // Content overlay
                VStack {
                    // Header
                    headerView
                    
                    Spacer()
                    
                    // Title block
                    titleBlockView
                    
                    // Search field
                    searchFieldView
                        .padding(.bottom, DesignSystem.spacing.lg)
                }
            } else {
                // Default state
                defaultStateView
            }
        }
        .sheet(isPresented: $showingFilter) {
            FilterModalView(filterManager: filterManager)
        }
    }
    
    private var headerView: some View {
        HStack {
            // Hamburger menu
            Button(action: {}) {
                Image(systemName: "line.horizontal.3")
                    .font(.title2)
                    .foregroundColor(DesignSystem.colors.textPrimary)
            }
            .frame(width: 44, height: 44)
            
            Spacer()
            
            // Help chip
            Button(action: {}) {
                HStack(spacing: 8) {
                    Text("Need help?")
                        .font(DesignSystem.typography.labelS)
                        .foregroundColor(DesignSystem.colors.textPrimary)
                    
                    Circle()
                        .fill(DesignSystem.colors.accent500)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundColor(DesignSystem.colors.textPrimary)
                        )
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(DesignSystem.colors.surfaceElev2)
                )
            }
        }
        .padding(.horizontal, DesignSystem.spacing.lg)
        .padding(.top, DesignSystem.spacing.lg)
    }
    
    private var titleBlockView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mountain\nExperiences")
                .font(DesignSystem.typography.displayXL)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.colors.textPrimary)
                .lineLimit(2)
            
            Text("The best guides for mountaineers.")
                .font(DesignSystem.typography.bodyM)
                .foregroundColor(DesignSystem.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DesignSystem.spacing.lg)
    }
    
    private var searchFieldView: some View {
        HStack(spacing: 0) {
            // Search icon
            Image(systemName: "magnifyingglass")
                .foregroundColor(DesignSystem.colors.textTertiary)
                .padding(.leading, DesignSystem.spacing.md)
            
            // Search text field
            TextField("Search", text: $searchText)
                .font(DesignSystem.typography.bodyM)
                .foregroundColor(DesignSystem.colors.textPrimary)
                .padding(.horizontal, DesignSystem.spacing.md)
                .padding(.vertical, DesignSystem.spacing.md)
                .onSubmit {
                    performSearch()
                }
            
            // Filter button
            Button(action: { showingFilter = true }) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(DesignSystem.colors.textTertiary)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.small)
                            .fill(DesignSystem.colors.surfaceElev1)
                    )
            }
            .padding(.trailing, DesignSystem.spacing.sm)
        }
        .frame(height: DesignSystem.spacing.searchHeight)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.input)
                .fill(DesignSystem.colors.surfaceElev2)
        )
        .padding(.horizontal, DesignSystem.spacing.lg)
    }
    
    private var defaultStateView: some View {
        VStack(spacing: DesignSystem.spacing.lg) {
            Image(systemName: "mountain.2.fill")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.colors.accent500)
            
            Text("Discover Mountain Adventures")
                .font(DesignSystem.typography.titleL)
                .foregroundColor(DesignSystem.colors.textPrimary)
            
            Text("Explore amazing destinations and plan your next mountain adventure")
                .font(DesignSystem.typography.bodyM)
                .foregroundColor(DesignSystem.colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: {}) {
                Text("Get Started")
                    .font(DesignSystem.typography.bodyM)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.input)
                            .fill(DesignSystem.colors.accent500)
                    )
            }
            .padding(.horizontal, DesignSystem.spacing.lg)
        }
        .padding(.horizontal, DesignSystem.spacing.lg)
    }
    
    private func performSearch() {
        searchManager.search(query: searchText)
    }
}
```

### Step 2.3: Create Search Field Component (1 hour)

#### SearchField.swift
```swift
import SwiftUI

struct SearchField: View {
    @Binding var text: String
    let placeholder: String
    let onFilterTap: () -> Void
    let onSubmit: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Search icon
            Image(systemName: "magnifyingglass")
                .foregroundColor(DesignSystem.colors.textTertiary)
                .padding(.leading, DesignSystem.spacing.md)
            
            // Text field
            TextField(placeholder, text: $text)
                .font(DesignSystem.typography.bodyM)
                .foregroundColor(DesignSystem.colors.textPrimary)
                .padding(.horizontal, DesignSystem.spacing.md)
                .padding(.vertical, DesignSystem.spacing.md)
                .onSubmit {
                    onSubmit()
                }
            
            // Filter button
            Button(action: onFilterTap) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(DesignSystem.colors.textTertiary)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.small)
                            .fill(DesignSystem.colors.surfaceElev1)
                    )
            }
            .padding(.trailing, DesignSystem.spacing.sm)
        }
        .frame(height: DesignSystem.spacing.searchHeight)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.input)
                .fill(DesignSystem.colors.surfaceElev2)
        )
    }
}
```

## Phase 3: Location Detail Screen Implementation (2 hours)

### Step 3.1: Create Location Detail View (1 hour)

#### LocationDetailView.swift
```swift
import SwiftUI

struct LocationDetailView: View {
    let location: Location
    @State private var selectedCategory: TripCategory?
    @State private var trips: [Trip] = []
    
    var body: some View {
        ZStack {
            DesignSystem.colors.surface0
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: DesignSystem.spacing.lg) {
                    // Header
                    headerView
                    
                    // Location content
                    locationContentView
                    
                    // Category chips
                    categoryChipsView
                    
                    // Trip cards
                    tripCardsView
                }
                .padding(.horizontal, DesignSystem.spacing.lg)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadTrips()
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(DesignSystem.colors.textPrimary)
            }
            .frame(width: 44, height: 44)
            
            Spacer()
        }
        .padding(.top, DesignSystem.spacing.lg)
    }
    
    private var locationContentView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing.md) {
            Text(location.name)
                .font(DesignSystem.typography.titleL)
                .foregroundColor(DesignSystem.colors.textPrimary)
            
            Text(location.summary)
                .font(DesignSystem.typography.bodyM)
                .foregroundColor(DesignSystem.colors.textSecondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var categoryChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.spacing.md) {
                ForEach(TripCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        icon: category.icon,
                        label: category.rawValue,
                        isSelected: selectedCategory == category,
                        onTap: {
                            selectedCategory = selectedCategory == category ? nil : category
                            filterTrips()
                        }
                    )
                }
            }
            .padding(.horizontal, DesignSystem.spacing.lg)
        }
        .padding(.horizontal, -DesignSystem.spacing.lg)
    }
    
    private var tripCardsView: some View {
        LazyVStack(spacing: DesignSystem.spacing.md) {
            ForEach(filteredTrips) { trip in
                TripCard(trip: trip) {
                    // Handle trip tap
                } onLongPress: {
                    // Handle long press (bookmark)
                }
            }
        }
    }
    
    private var filteredTrips: [Trip] {
        if let category = selectedCategory {
            return trips.filter { $0.category == category }
        }
        return trips
    }
    
    private func loadTrips() {
        trips = location.trips
    }
    
    private func filterTrips() {
        // Filter logic handled by computed property
    }
}
```

### Step 3.2: Create Category Chip Component (1 hour)

#### CategoryChip.swift
```swift
import SwiftUI

struct CategoryChip: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Icon
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? DesignSystem.colors.textPrimary : DesignSystem.colors.surface0)
                
                // Label
                Text(label)
                    .font(DesignSystem.typography.labelS)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? DesignSystem.colors.textPrimary : DesignSystem.colors.surface0)
            }
            .frame(width: 64, height: 64)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.chip)
                    .fill(isSelected ? DesignSystem.colors.accent500 : DesignSystem.colors.textPrimary.opacity(0.96))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
```

## Phase 4: Trip Card Component (1 hour)

### Step 4.1: Create Trip Card Component

#### TripCard.swift
```swift
import SwiftUI

struct TripCard: View {
    let trip: Trip
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Trip image
                AsyncImage(url: URL(string: trip.coverImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(16/10, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(DesignSystem.colors.surfaceElev1)
                }
                .frame(height: 220)
                .clipped()
                .cornerRadius(DesignSystem.cornerRadius.card)
                
                // Metadata capsule
                VStack {
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(trip.title)
                                .font(DesignSystem.typography.bodyM)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignSystem.colors.surface0)
                                .lineLimit(1)
                            
                            HStack(spacing: 8) {
                                Text(trip.category.rawValue)
                                    .font(DesignSystem.typography.labelS)
                                    .fontWeight(.medium)
                                    .foregroundColor(DesignSystem.colors.surface0)
                                
                                Text("•")
                                    .font(DesignSystem.typography.labelS)
                                    .foregroundColor(DesignSystem.colors.surface0)
                                
                                Text("\(trip.durationDays) days")
                                    .font(DesignSystem.typography.labelS)
                                    .fontWeight(.medium)
                                    .foregroundColor(DesignSystem.colors.surface0)
                                
                                Text("•")
                                    .font(DesignSystem.typography.labelS)
                                    .foregroundColor(DesignSystem.colors.surface0)
                                
                                Text(trip.difficulty.rawValue)
                                    .font(DesignSystem.typography.labelS)
                                    .fontWeight(.medium)
                                    .foregroundColor(DesignSystem.colors.surface0)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.95))
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture {
            onLongPress()
        }
    }
}
```

## Phase 5: Data Models (1 hour)

### Step 5.1: Create Trip Data Model

#### Trip.swift
```swift
import Foundation

struct Trip: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let category: TripCategory
    let durationDays: Int
    let difficulty: TripDifficulty
    let coverImageURL: String
    let locationId: String
    let description: String
    let price: Double?
    let rating: Double?
    let isBookmarked: Bool
    
    init(title: String, category: TripCategory, durationDays: Int, difficulty: TripDifficulty, coverImageURL: String, locationId: String, description: String, price: Double? = nil, rating: Double? = nil, isBookmarked: Bool = false) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.durationDays = durationDays
        self.difficulty = difficulty
        self.coverImageURL = coverImageURL
        self.locationId = locationId
        self.description = description
        self.price = price
        self.rating = rating
        self.isBookmarked = isBookmarked
    }
}

enum TripCategory: String, CaseIterable, Codable {
    case peaks = "Peaks"
    case hiking = "Hiking"
    case climbing = "Climbing"
    case guides = "Guides"
    
    var icon: String {
        switch self {
        case .peaks:
            return "mountain.2.fill"
        case .hiking:
            return "figure.hiking"
        case .climbing:
            return "figure.climbing"
        case .guides:
            return "person.2.fill"
        }
    }
}

enum TripDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case moderate = "Moderate"
    case hard = "Hard"
    
    var color: Color {
        switch self {
        case .easy:
            return .green
        case .moderate:
            return .orange
        case .hard:
            return .red
        }
    }
}
```

### Step 5.2: Create Location Data Model

#### Location.swift
```swift
import Foundation

struct Location: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let summary: String
    let flagCode: String
    let coverImageURL: String
    let trips: [Trip]
    
    init(id: String, name: String, summary: String, flagCode: String, coverImageURL: String, trips: [Trip] = []) {
        self.id = id
        self.name = name
        self.summary = summary
        self.flagCode = flagCode
        self.coverImageURL = coverImageURL
        self.trips = trips
    }
}

// Sample data
extension Location {
    static let nepal = Location(
        id: "np",
        name: "Nepal",
        summary: "Nepal contains part of the Himalayas, the highest mountain range in the world. Explore Nepal guides!",
        flagCode: "np",
        coverImageURL: "https://example.com/nepal-hero.jpg",
        trips: [
            Trip(
                title: "Around Annapurna",
                category: .hiking,
                durationDays: 7,
                difficulty: .hard,
                coverImageURL: "https://example.com/annapurna.jpg",
                locationId: "np",
                description: "A challenging trek around the Annapurna massif",
                price: 1200.0,
                rating: 4.8
            )
        ]
    )
}
```

## Phase 6: Search and Filter Implementation (2 hours)

### Step 6.1: Create Search Manager

#### SearchManager.swift
```swift
import Foundation
import Combine

class SearchManager: ObservableObject {
    @Published var searchResults: [Trip] = []
    @Published var isSearching = false
    @Published var searchQuery = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let searchDelay: TimeInterval = 0.5
    
    init() {
        setupSearchDebouncing()
    }
    
    private func setupSearchDebouncing() {
        $searchQuery
            .debounce(for: .seconds(searchDelay), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    func search(query: String) {
        searchQuery = query
    }
    
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        // Simulate search delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // In real implementation, this would call an API
            self.searchResults = self.mockSearchResults(for: query)
            self.isSearching = false
        }
    }
    
    private func mockSearchResults(for query: String) -> [Trip] {
        // Mock search results based on query
        return Location.nepal.trips.filter { trip in
            trip.title.localizedCaseInsensitiveContains(query) ||
            trip.description.localizedCaseInsensitiveContains(query) ||
            trip.category.rawValue.localizedCaseInsensitiveContains(query)
        }
    }
}
```

### Step 6.2: Create Filter Manager

#### FilterManager.swift
```swift
import Foundation
import Combine

class FilterManager: ObservableObject {
    @Published var selectedCategories: Set<TripCategory> = []
    @Published var selectedDifficulties: Set<TripDifficulty> = []
    @Published var minDuration: Int = 1
    @Published var maxDuration: Int = 30
    @Published var priceRange: ClosedRange<Double> = 0...5000
    
    var hasActiveFilters: Bool {
        !selectedCategories.isEmpty ||
        !selectedDifficulties.isEmpty ||
        minDuration > 1 ||
        maxDuration < 30 ||
        priceRange.lowerBound > 0 ||
        priceRange.upperBound < 5000
    }
    
    func resetFilters() {
        selectedCategories.removeAll()
        selectedDifficulties.removeAll()
        minDuration = 1
        maxDuration = 30
        priceRange = 0...5000
    }
    
    func applyFilters(to trips: [Trip]) -> [Trip] {
        return trips.filter { trip in
            // Category filter
            if !selectedCategories.isEmpty && !selectedCategories.contains(trip.category) {
                return false
            }
            
            // Difficulty filter
            if !selectedDifficulties.isEmpty && !selectedDifficulties.contains(trip.difficulty) {
                return false
            }
            
            // Duration filter
            if trip.durationDays < minDuration || trip.durationDays > maxDuration {
                return false
            }
            
            // Price filter
            if let price = trip.price {
                if price < priceRange.lowerBound || price > priceRange.upperBound {
                    return false
                }
            }
            
            return true
        }
    }
}
```

### Step 6.3: Create Filter Modal

#### FilterModalView.swift
```swift
import SwiftUI

struct FilterModalView: View {
    @ObservedObject var filterManager: FilterManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.colors.surface0
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.spacing.lg) {
                        // Category filter
                        categoryFilterSection
                        
                        // Difficulty filter
                        difficultyFilterSection
                        
                        // Duration filter
                        durationFilterSection
                        
                        // Price filter
                        priceFilterSection
                    }
                    .padding(.horizontal, DesignSystem.spacing.lg)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        filterManager.resetFilters()
                    }
                    .foregroundColor(DesignSystem.colors.accent500)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.colors.accent500)
                }
            }
        }
    }
    
    private var categoryFilterSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing.md) {
            Text("Category")
                .font(DesignSystem.typography.bodyM)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.colors.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.spacing.md) {
                ForEach(TripCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: filterManager.selectedCategories.contains(category),
                        onTap: {
                            if filterManager.selectedCategories.contains(category) {
                                filterManager.selectedCategories.remove(category)
                            } else {
                                filterManager.selectedCategories.insert(category)
                            }
                        }
                    )
                }
            }
        }
    }
    
    private var difficultyFilterSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing.md) {
            Text("Difficulty")
                .font(DesignSystem.typography.bodyM)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.colors.textPrimary)
            
            HStack(spacing: DesignSystem.spacing.md) {
                ForEach(TripDifficulty.allCases, id: \.self) { difficulty in
                    FilterChip(
                        title: difficulty.rawValue,
                        icon: "star.fill",
                        isSelected: filterManager.selectedDifficulties.contains(difficulty),
                        onTap: {
                            if filterManager.selectedDifficulties.contains(difficulty) {
                                filterManager.selectedDifficulties.remove(difficulty)
                            } else {
                                filterManager.selectedDifficulties.insert(difficulty)
                            }
                        }
                    )
                }
            }
        }
    }
    
    private var durationFilterSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing.md) {
            Text("Duration (days)")
                .font(DesignSystem.typography.bodyM)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.colors.textPrimary)
            
            HStack {
                Text("Min: \(filterManager.minDuration)")
                    .font(DesignSystem.typography.labelS)
                    .foregroundColor(DesignSystem.colors.textSecondary)
                
                Slider(value: Binding(
                    get: { Double(filterManager.minDuration) },
                    set: { filterManager.minDuration = Int($0) }
                ), in: 1...30)
                
                Text("Max: \(filterManager.maxDuration)")
                    .font(DesignSystem.typography.labelS)
                    .foregroundColor(DesignSystem.colors.textSecondary)
            }
        }
    }
    
    private var priceFilterSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing.md) {
            Text("Price Range")
                .font(DesignSystem.typography.bodyM)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.colors.textPrimary)
            
            HStack {
                Text("$\(Int(filterManager.priceRange.lowerBound))")
                    .font(DesignSystem.typography.labelS)
                    .foregroundColor(DesignSystem.colors.textSecondary)
                
                Slider(value: Binding(
                    get: { filterManager.priceRange.lowerBound },
                    set: { filterManager.priceRange = $0...filterManager.priceRange.upperBound }
                ), in: 0...5000)
                
                Text("$\(Int(filterManager.priceRange.upperBound))")
                    .font(DesignSystem.typography.labelS)
                    .foregroundColor(DesignSystem.colors.textSecondary)
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(DesignSystem.typography.labelS)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.chip)
                    .fill(isSelected ? DesignSystem.colors.accent500 : DesignSystem.colors.surfaceElev1)
            )
            .foregroundColor(isSelected ? DesignSystem.colors.textPrimary : DesignSystem.colors.textSecondary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

## Phase 7: Integration and Testing (2 hours)

### Step 7.1: Update Main App Structure

#### ContentView.swift (Update)
```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var searchManager = SearchManager()
    @StateObject private var filterManager = FilterManager()
    @State private var selectedLocation: Location?
    @State private var showingLocationDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if showingLocationDetail, let location = selectedLocation {
                    LocationDetailView(location: location)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .trailing)
                        ))
                } else {
                    HomeDiscoverView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .leading)
                        ))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showingLocationDetail)
        }
        .environmentObject(searchManager)
        .environmentObject(filterManager)
    }
}
```

### Step 7.2: Create Sample Data

#### SampleData.swift
```swift
import Foundation

struct SampleData {
    static let locations: [Location] = [
        Location(
            id: "np",
            name: "Nepal",
            summary: "Nepal contains part of the Himalayas, the highest mountain range in the world. Explore Nepal guides!",
            flagCode: "np",
            coverImageURL: "https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=2000",
            trips: [
                Trip(
                    title: "Around Annapurna",
                    category: .hiking,
                    durationDays: 7,
                    difficulty: .hard,
                    coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800",
                    locationId: "np",
                    description: "A challenging trek around the Annapurna massif with stunning mountain views",
                    price: 1200.0,
                    rating: 4.8
                ),
                Trip(
                    title: "Everest Base Camp",
                    category: .hiking,
                    durationDays: 14,
                    difficulty: .hard,
                    coverImageURL: "https://images.unsplash.com/photo-1581833971358-2c8b550f87b3?w=800",
                    locationId: "np",
                    description: "Journey to the base of the world's highest mountain",
                    price: 1800.0,
                    rating: 4.9
                )
            ]
        ),
        Location(
            id: "ch",
            name: "Switzerland",
            summary: "Home to the majestic Alps and some of the world's most beautiful mountain landscapes.",
            flagCode: "ch",
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=2000",
            trips: [
                Trip(
                    title: "Matterhorn Ascent",
                    category: .climbing,
                    durationDays: 3,
                    difficulty: .hard,
                    coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800",
                    locationId: "ch",
                    description: "Technical climb of the iconic Matterhorn peak",
                    price: 2500.0,
                    rating: 4.7
                )
            ]
        )
    ]
}
```

This comprehensive step-by-step guide provides everything needed to integrate the Mountain Experiences design into SummitAI, including all code examples, component structures, and implementation details.
