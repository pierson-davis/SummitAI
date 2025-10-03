import SwiftUI

// MARK: - Mountain Experiences Home View
// Step 7: Navigation & User Flow

struct MountainExperiencesHomeView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var dataManager = MountainExperiencesDataManager()
    @StateObject private var searchManager = SearchManager()
    @StateObject private var filterManager = FilterManager()
    
    @State private var showingSearch = false
    @State private var selectedTrip: Trip?
    @State private var selectedLocation: Location?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.surface0
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header with search and navigation
                        headerView
                        
                        // Quick actions
                        quickActionsView
                        
                        // Featured locations
                        featuredLocationsView
                        
                        // Popular trips
                        popularTripsView
                        
                        // Categories
                        categoriesView
                        
                        // Recent searches
                        if !dataManager.userSearchHistory.isEmpty {
                            recentSearchesView
                        }
                        
                        // Bottom spacing
                        Spacer(minLength: 100)
                    }
                }
                .refreshable {
                    await refreshData()
                }
                
                // Floating search button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            navigationManager.presentFullScreenCover(.searchResults)
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.accent600)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $selectedTrip) { trip in
            TripDetailSheet(trip: trip)
        }
        .sheet(item: $selectedLocation) { location in
            LocationDetailSheet(location: location)
        }
        .onAppear {
            loadData()
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Top navigation
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Mountain")
                        .font(Typography.displayXL)
                        .foregroundColor(.textPrimary)
                    
                    Text("Experiences")
                        .font(Typography.displayXL)
                        .foregroundColor(.accent600)
                }
                
                Spacer()
                
                // Profile button
                Button(action: {
                    navigationManager.selectTab(.profile)
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.textSecondary)
                }
                .accessibleTapTarget()
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, 60) // Safe area
            
            // Search bar
            Button(action: {
                navigationManager.presentFullScreenCover(.searchResults)
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textSecondary)
                    
                    Text("Search mountains, locations...")
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.textSecondary)
                }
                .padding(DesignSystem.Spacing.md)
                .background(Color.surfaceElev1)
                .cornerRadius(DesignSystem.CornerRadius.medium)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Quick Actions")
                    .font(Typography.titleM)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    QuickActionCard(
                        title: "Discover",
                        subtitle: "Find new adventures",
                        icon: "mountain.2.fill",
                        color: .accent600
                    ) {
                        navigationManager.presentFullScreenCover(.mountainExperiencesHome)
                    }
                    
                    QuickActionCard(
                        title: "Bookmarks",
                        subtitle: "\(dataManager.userBookmarkedTrips.count) saved",
                        icon: "bookmark.fill",
                        color: .orange
                    ) {
                        navigationManager.presentSheet(.bookmarkManager)
                    }
                    
                    QuickActionCard(
                        title: "Preferences",
                        subtitle: "Customize experience",
                        icon: "gearshape.fill",
                        color: .purple
                    ) {
                        navigationManager.presentSheet(.userPreferences)
                    }
                    
                    QuickActionCard(
                        title: "Start Expedition",
                        subtitle: "Begin your journey",
                        icon: "play.circle.fill",
                        color: .green
                    ) {
                        // Navigate to expedition selection or create from trip
                        navigationManager.selectTab(.expedition)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }
    
    // MARK: - Featured Locations
    
    private var featuredLocationsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Featured Locations")
                    .font(Typography.titleM)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to all locations
                }
                .font(Typography.labelM)
                .foregroundColor(.accent600)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(dataManager.availableLocations.prefix(4)) { location in
                        LocationCard(location: location) {
                            selectedLocation = location
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }
    
    // MARK: - Popular Trips
    
    private var popularTripsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Popular Trips")
                    .font(Typography.titleM)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to all trips
                }
                .font(Typography.labelM)
                .foregroundColor(.accent600)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)
            ], spacing: DesignSystem.Spacing.md) {
                ForEach(dataManager.getPopularTrips(limit: 6)) { trip in
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
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }
    
    // MARK: - Categories
    
    private var categoriesView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Categories")
                    .font(Typography.titleM)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.sm) {
                ForEach(TripCategory.allCases, id: \.self) { category in
                    CategoryCard(category: category) {
                        // Navigate to category trips
                        navigationManager.presentFullScreenCover(.searchResults)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }
    
    // MARK: - Recent Searches
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Recent Searches")
                    .font(Typography.titleM)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("Clear") {
                    dataManager.clearSearchHistory()
                }
                .font(Typography.labelM)
                .foregroundColor(.accent600)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(dataManager.userSearchHistory.prefix(5), id: \.self) { search in
                        Button(action: {
                            // Perform search
                            navigationManager.presentFullScreenCover(.searchResults)
                        }) {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "clock")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                
                                Text(search)
                                    .font(Typography.labelM)
                                    .foregroundColor(.textPrimary)
                            }
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                            .padding(.vertical, DesignSystem.Spacing.xs)
                        }
                        .background(Color.surfaceElev1)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                        .pressState()
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }
    
    // MARK: - Helper Methods
    
    private func loadData() {
        // Data is loaded automatically by the data manager
    }
    
    private func refreshData() async {
        // Simulate refresh
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        // Data manager will automatically update the UI
    }
}

// MARK: - Supporting Views

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(Typography.bodyM)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 120, height: 100)
            .padding(DesignSystem.Spacing.sm)
        }
        .background(Color.surfaceElev1)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .pressState()
    }
}

struct LocationCard: View {
    let location: Location
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                AsyncImage(url: URL(string: location.coverImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.surfaceElev1)
                }
                .frame(height: 120)
                .clipped()
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(location.name)
                        .font(Typography.bodyM)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Text(location.country)
                        .font(Typography.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text("\(location.trips.count) trips")
                        .font(Typography.labelS)
                        .foregroundColor(.accent600)
                }
                .padding(DesignSystem.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color.surfaceElev1)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .frame(width: 160)
        .pressState()
    }
}

struct CategoryCard: View {
    let category: TripCategory
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(.accent600)
                
                Text(category.rawValue)
                    .font(Typography.labelM)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
        .background(Color.surfaceElev1)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .pressState()
    }
}

#Preview {
    MountainExperiencesHomeView()
        .environmentObject(NavigationManager())
        .preferredColorScheme(.dark)
}
