import SwiftUI

// MARK: - Search Results View
// Step 5: Search & Filter Functionality

struct SearchResultsView: View {
    @StateObject private var searchManager = SearchManager()
    @StateObject private var filterManager = FilterManager()
    @StateObject private var dataManager = MountainExperiencesDataManager()
    @State private var showingFilterModal = false
    @State private var showingSearchHistory = false
    @State private var selectedTrip: Trip?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.surface0
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search header
                    searchHeaderView
                    
                    // Search content
                    if searchManager.searchText.isEmpty {
                        searchEmptyStateView
                    } else if searchManager.isSearching {
                        searchLoadingView
                    } else if filteredResults.isEmpty {
                        searchNoResultsView
                    } else {
                        searchResultsContentView
                    }
                }
                
                // Filter modal
                if showingFilterModal {
                    filterModalView
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingFilterModal) {
                FilterModal(
                    isPresented: $showingFilterModal,
                    selectedCategory: $filterManager.selectedCategories.first,
                    selectedDifficulty: $filterManager.selectedDifficulties.first,
                    onApply: {
                        // Filters are applied automatically
                    },
                    onClear: {
                        filterManager.clearAllFilters()
                    }
                )
            }
            .sheet(item: $selectedTrip) { trip in
                TripDetailView(trip: trip)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Computed Properties
    
    private var filteredResults: [Trip] {
        let results = searchManager.searchResults
        return filterManager.applyFilters(to: results)
    }
    
    private var searchSuggestions: [String] {
        searchManager.getSearchSuggestions(for: searchManager.searchText)
    }
    
    // MARK: - Search Header
    
    private var searchHeaderView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // App bar
            HStack {
                // Back button
                Button(action: {
                    // Navigate back
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.surfaceElev1.opacity(0.9))
                        )
                }
                .accessibleTapTarget()
                
                // Search field
                SearchField(
                    text: $searchManager.searchText,
                    placeholder: "Search mountains, locations...",
                    onFilterTap: {
                        showingFilterModal = true
                    }
                )
                
                // Filter indicator
                if filterManager.hasActiveFilters {
                    Button(action: {
                        showingFilterModal = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.accent600)
                                .frame(width: 24, height: 24)
                            
                            Text("\(filterManager.filterCount)")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                    }
                    .accessibleTapTarget()
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, 60) // Safe area
            
            // Search suggestions (when typing)
            if !searchManager.searchText.isEmpty && !searchSuggestions.isEmpty {
                searchSuggestionsView
            }
            
            // Active filters
            if filterManager.hasActiveFilters {
                activeFiltersView
            }
        }
    }
    
    private var searchSuggestionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(searchSuggestions, id: \.self) { suggestion in
                    Button(action: {
                        searchManager.searchText = suggestion
                    }) {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "magnifyingglass")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            
                            Text(suggestion)
                                .font(Typography.labelM)
                                .foregroundColor(.textPrimary)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                    }
                    .background(Color.surfaceElev1)
                    .cornerRadius(ComponentStyles.Chip.cornerRadius)
                    .pressState()
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
    
    private var activeFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                // Filter presets
                ForEach(FilterManager.FilterPreset.allCases, id: \.self) { preset in
                    FilterPresetChip(
                        preset: preset,
                        isSelected: filterManager.activePreset == preset,
                        onTap: {
                            filterManager.applyPreset(preset)
                        }
                    )
                }
                
                // Clear all filters
                if filterManager.hasActiveFilters {
                    Button(action: {
                        filterManager.clearAllFilters()
                    }) {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            
                            Text("Clear All")
                                .font(Typography.labelM)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                    }
                    .background(Color.surfaceElev2)
                    .cornerRadius(ComponentStyles.Chip.cornerRadius)
                    .pressState()
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
    
    // MARK: - Search Empty State
    
    private var searchEmptyStateView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Search icon
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 64))
                    .foregroundColor(.textTertiary)
                    .padding(.top, DesignSystem.Spacing.xxxl)
                
                // Title
                Text("Discover Mountain Adventures")
                    .font(Typography.titleL)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Subtitle
                Text("Search for epic climbs, scenic hikes, and mountain experiences around the world")
                    .font(Typography.bodyL)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                
                // Popular destinations
                popularDestinationsView
                
                // Recent searches
                if !searchManager.recentSearches.isEmpty {
                    recentSearchesView
                }
                
                // Filter presets
                filterPresetsView
                
                Spacer(minLength: 100)
            }
        }
    }
    
    private var popularDestinationsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Popular Destinations")
                .font(Typography.titleM)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.lg)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(popularDestinations, id: \.name) { destination in
                        PopularDestinationCard(destination: destination) {
                            searchManager.searchText = destination.name
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
        }
    }
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Recent Searches")
                    .font(Typography.titleM)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("Clear") {
                    searchManager.clearSearchHistory()
                }
                .font(Typography.labelM)
                .foregroundColor(.accent600)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(searchManager.recentSearches, id: \.self) { search in
                    HStack {
                        Image(systemName: "clock")
                            .font(.title3)
                            .foregroundColor(.textSecondary)
                            .frame(width: 20)
                        
                        Button(action: {
                            searchManager.searchText = search
                        }) {
                            Text(search)
                                .font(Typography.bodyM)
                                .foregroundColor(.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Button(action: {
                            searchManager.removeFromSearchHistory(search)
                        }) {
                            Image(systemName: "xmark")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        .accessibleTapTarget()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(Color.surfaceElev1)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }
            }
        }
    }
    
    private var filterPresetsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Quick Filters")
                .font(Typography.titleM)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.lg)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.sm) {
                ForEach(FilterManager.FilterPreset.allCases.filter { $0 != .none }, id: \.self) { preset in
                    FilterPresetCard(
                        preset: preset,
                        onTap: {
                            filterManager.applyPreset(preset)
                            showingFilterModal = true
                        }
                    )
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
    }
    
    // MARK: - Search Loading State
    
    private var searchLoadingView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .accent600))
                .scaleEffect(1.2)
            
            Text("Searching...")
                .font(Typography.bodyM)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surface0)
    }
    
    // MARK: - Search No Results
    
    private var searchNoResultsView: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No results found",
            subtitle: "Try adjusting your search terms or filters",
            actionTitle: "Clear Filters",
            onAction: {
                filterManager.clearAllFilters()
            }
        )
    }
    
    // MARK: - Search Results Content
    
    private var searchResultsContentView: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                // Results header
                HStack {
                    Text("\(filteredResults.count) results for \"\(searchManager.searchText)\"")
                        .font(Typography.bodyM)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    // Sort button
                    Button(action: {}) {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Text("Sort")
                                .font(Typography.labelM)
                                .foregroundColor(.textSecondary)
                            
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .pressState()
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.md)
                
                // Trip cards
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)
                ], spacing: DesignSystem.Spacing.md) {
                    ForEach(filteredResults) { trip in
                        TripCard(
                            trip: trip,
                            onTap: {
                                selectedTrip = trip
                            },
                            onLongPress: {
                                dataManager.toggleTripBookmark(trip.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                Spacer(minLength: 100)
            }
        }
    }
    
    // MARK: - Filter Modal
    
    private var filterModalView: some View {
        FilterModal(
            isPresented: $showingFilterModal,
            selectedCategory: $filterManager.selectedCategories.first,
            selectedDifficulty: $filterManager.selectedDifficulties.first,
            onApply: {
                // Filters applied automatically
            },
            onClear: {
                filterManager.clearAllFilters()
            }
        )
    }
    
    // MARK: - Sample Data
    
    private var popularDestinations: [PopularDestination] {
        [
            PopularDestination(name: "Everest", country: "Nepal", flag: "🇳🇵", tripCount: 12),
            PopularDestination(name: "Kilimanjaro", country: "Tanzania", flag: "🇹🇿", tripCount: 8),
            PopularDestination(name: "Mont Blanc", country: "France", flag: "🇫🇷", tripCount: 6),
            PopularDestination(name: "Mount Fuji", country: "Japan", flag: "🇯🇵", tripCount: 4)
        ]
    }
}

// MARK: - Supporting Views

struct FilterPresetChip: View {
    let preset: FilterManager.FilterPreset
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: preset.icon)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .textSecondary)
                
                Text(preset.rawValue)
                    .font(Typography.labelM)
                    .foregroundColor(isSelected ? .white : .textPrimary)
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .background(
            RoundedRectangle(cornerRadius: ComponentStyles.Chip.cornerRadius)
                .fill(isSelected ? Color.accent600 : Color.surfaceElev2)
        )
        .pressState()
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct FilterPresetCard: View {
    let preset: FilterManager.FilterPreset
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Image(systemName: preset.icon)
                    .font(.title2)
                    .foregroundColor(.accent600)
                
                Text(preset.rawValue)
                    .font(Typography.bodyM)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(preset.description)
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.md)
        }
        .background(Color.surfaceElev1)
        .cornerRadius(ComponentStyles.Card.cornerRadius)
        .pressState()
    }
}

struct PopularDestinationCard: View {
    let destination: PopularDestination
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(destination.flag)
                    .font(.system(size: 32))
                
                Text(destination.name)
                    .font(Typography.bodyM)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(destination.country)
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
                
                Text("\(destination.tripCount) trips")
                    .font(Typography.labelS)
                    .foregroundColor(.accent600)
            }
            .frame(width: 120)
            .padding(DesignSystem.Spacing.md)
        }
        .background(Color.surfaceElev1)
        .cornerRadius(ComponentStyles.Card.cornerRadius)
        .pressState()
    }
}

struct TripDetailView: View {
    let trip: Trip
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Trip image
                    AsyncImage(url: URL(string: trip.coverImageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.surfaceElev1)
                    }
                    .frame(height: 250)
                    .clipped()
                    
                    // Trip details
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text(trip.title)
                            .font(Typography.displayM)
                            .foregroundColor(.textPrimary)
                        
                        Text(trip.description)
                            .font(Typography.bodyL)
                            .foregroundColor(.textSecondary)
                        
                        // Metadata
                        HStack(spacing: DesignSystem.Spacing.lg) {
                            VStack(alignment: .leading) {
                                Text("Duration")
                                    .font(Typography.labelM)
                                    .foregroundColor(.textSecondary)
                                Text("\(trip.durationDays) days")
                                    .font(Typography.bodyM)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textPrimary)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Difficulty")
                                    .font(Typography.labelM)
                                    .foregroundColor(.textSecondary)
                                Text(trip.difficulty.rawValue)
                                    .font(Typography.bodyM)
                                    .fontWeight(.semibold)
                                    .foregroundColor(trip.difficulty.color)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Price")
                                    .font(Typography.labelM)
                                    .foregroundColor(.textSecondary)
                                Text("$\(Int(trip.price ?? 0))")
                                    .font(Typography.bodyM)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Models

struct PopularDestination {
    let name: String
    let country: String
    let flag: String
    let tripCount: Int
}

#Preview {
    SearchResultsView()
}
