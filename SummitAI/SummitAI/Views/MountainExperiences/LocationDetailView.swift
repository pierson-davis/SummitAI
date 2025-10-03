import SwiftUI

// MARK: - Mountain Experiences Location Detail Screen
// Step 3: Location Detail Screen Implementation

struct LocationDetailView: View {
    let location: Location
    @State private var selectedCategory: TripCategory? = nil
    @State private var showingFilter = false
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.presentationMode) var presentationMode
    
    // Computed properties for dynamic content
    private var filteredTrips: [Trip] {
        if let selectedCategory = selectedCategory {
            return location.trips.filter { $0.category == selectedCategory }
        }
        return location.trips
    }
    
    private var shouldShowSolidHeader: Bool {
        scrollOffset > 100
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.surface0
                .ignoresSafeArea()
            
            // Main content
            ScrollView {
                VStack(spacing: 0) {
                    // Header image with overlay
                    headerImageView
                    
                    // Location content
                    locationContentView
                    
                    // Category chips row
                    categoryChipsView
                    
                    // Trip cards grid
                    tripCardsView
                    
                    // Bottom spacing
                    Spacer(minLength: 100)
                }
            }
            .coordinateSpace(name: "scroll")
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, 
                                  value: geometry.frame(in: .named("scroll")).minY)
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = -value
            }
            
            // App bar overlay
            appBarOverlay
            
            // Filter modal
            if showingFilter {
                filterModal
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Header Image with Overlay
    
    private var headerImageView: some View {
        ZStack {
            // Location hero image
            AsyncImage(url: URL(string: location.coverImageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.accent600,
                                Color.accent500,
                                Color.surfaceElev1
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .frame(height: 300)
            .clipped()
            
            // Bottom gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.overlay60,
                    Color.surface0
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 300)
            
            // Location flag and title overlay
            VStack {
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        // Flag
                        Text(flagEmoji(for: location.flagCode))
                            .font(.system(size: 32))
                        
                        // Location name
                        Text(location.name)
                            .font(Typography.displayXL)
                            .foregroundColor(.textPrimary)
                        
                        // Trip count
                        Text("\(location.trips.count) experiences available")
                            .font(Typography.bodyM)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.lg)
            }
        }
    }
    
    // MARK: - Location Content
    
    private var locationContentView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Location description
            Text(location.summary)
                .font(Typography.bodyL)
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
            
            // Location stats
            locationStatsView
            
            // Popular activities
            popularActivitiesView
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.lg)
    }
    
    private var locationStatsView: some View {
        HStack(spacing: DesignSystem.Spacing.xl) {
            // Total trips
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("\(location.trips.count)")
                    .font(Typography.titleL)
                    .foregroundColor(.textPrimary)
                
                Text("Total Trips")
                    .font(Typography.labelM)
                    .foregroundColor(.textSecondary)
            }
            
            // Average duration
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("\(averageDuration)")
                    .font(Typography.titleL)
                    .foregroundColor(.textPrimary)
                
                Text("Avg Duration")
                    .font(Typography.labelM)
                    .foregroundColor(.textSecondary)
            }
            
            // Average rating
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(String(format: "%.1f", averageRating))
                    .font(Typography.titleL)
                    .foregroundColor(.textPrimary)
                
                Text("Avg Rating")
                    .font(Typography.labelM)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.lg)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .background(Color.surfaceElev1)
        .cornerRadius(DesignSystem.CornerRadius.large)
    }
    
    private var popularActivitiesView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Popular Activities")
                .font(Typography.titleM)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.sm) {
                ForEach(activityCounts, id: \.category) { activity in
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: activity.category.icon)
                            .font(.title2)
                            .foregroundColor(.accent600)
                        
                        Text(activity.category.rawValue)
                            .font(Typography.labelS)
                            .foregroundColor(.textSecondary)
                        
                        Text("\(activity.count)")
                            .font(Typography.labelM)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(Color.surfaceElev1)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
            }
        }
    }
    
    // MARK: - Category Chips Row
    
    private var categoryChipsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Filter by Category")
                    .font(Typography.titleM)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("Clear") {
                    selectedCategory = nil
                }
                .font(Typography.labelM)
                .foregroundColor(.accent600)
                .opacity(selectedCategory == nil ? 0.5 : 1.0)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(TripCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            icon: category.icon,
                            label: category.rawValue,
                            isSelected: selectedCategory == category,
                            onTap: {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }
    
    // MARK: - Trip Cards Grid
    
    private var tripCardsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Available Trips")
                    .font(Typography.titleM)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(filteredTrips.count) trips")
                    .font(Typography.labelM)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            if filteredTrips.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)
                ], spacing: DesignSystem.Spacing.md) {
                    ForEach(filteredTrips) { trip in
                        TripCard(trip: trip) {
                            // Navigate to trip detail
                        } onLongPress: {
                            // Quick save action
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "mountain.2")
                .font(.system(size: 48))
                .foregroundColor(.textTertiary)
            
            Text("No trips found")
                .font(Typography.titleS)
                .foregroundColor(.textSecondary)
            
            Text("Try selecting a different category")
                .font(Typography.bodyM)
                .foregroundColor(.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxxl)
    }
    
    // MARK: - App Bar Overlay
    
    private var appBarOverlay: some View {
        VStack {
            HStack {
                // Back chevron (24pt from left)
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.surfaceElev1.opacity(shouldShowSolidHeader ? 0.9 : 0.6))
                        )
                }
                .accessibleTapTarget()
                
                Spacer()
                
                // Share button
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundColor(.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.surfaceElev1.opacity(shouldShowSolidHeader ? 0.9 : 0.6))
                        )
                }
                .accessibleTapTarget()
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, 60) // Account for safe area
            
            Spacer()
        }
        .background(
            // Dynamic background based on scroll
            Color.surface0
                .opacity(shouldShowSolidHeader ? 0.95 : 0)
                .animation(.easeInOut(duration: 0.2), value: shouldShowSolidHeader)
        )
    }
    
    // MARK: - Filter Modal
    
    private var filterModal: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    showingFilter = false
                }
            
            // Filter content
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Filter header
                HStack {
                    Text("Filter Trips")
                        .font(Typography.titleL)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button("Clear") {
                        selectedCategory = nil
                        showingFilter = false
                    }
                    .font(Typography.labelM)
                    .foregroundColor(.accent600)
                }
                
                // Category filter
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Category")
                        .font(Typography.bodyM)
                        .foregroundColor(.textPrimary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DesignSystem.Spacing.sm) {
                        ForEach(TripCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                icon: category.icon,
                                label: category.rawValue,
                                isSelected: selectedCategory == category,
                                onTap: {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }
                            )
                        }
                    }
                }
                
                // Difficulty filter
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Difficulty")
                        .font(Typography.bodyM)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(TripDifficulty.allCases, id: \.self) { difficulty in
                            Button(action: {}) {
                                Text(difficulty.rawValue)
                                    .font(Typography.labelM)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, DesignSystem.Spacing.sm)
                                    .padding(.vertical, DesignSystem.Spacing.xs)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: ComponentStyles.Chip.cornerRadius)
                                    .fill(Color.surfaceElev2)
                            )
                        }
                    }
                }
                
                // Apply button
                Button("Apply Filters") {
                    showingFilter = false
                }
                .buttonStyle(isPrimary: true)
                .frame(maxWidth: .infinity)
            }
            .padding(DesignSystem.Spacing.lg)
            .background(Color.surfaceElev1)
            .cornerRadius(DesignSystem.CornerRadius.xl)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, 100) // Position from top
        }
    }
    
    // MARK: - Helper Computed Properties
    
    private var averageDuration: Int {
        guard !location.trips.isEmpty else { return 0 }
        let totalDuration = location.trips.reduce(0) { $0 + $1.durationDays }
        return totalDuration / location.trips.count
    }
    
    private var averageRating: Double {
        let tripsWithRatings = location.trips.compactMap { $0.rating }
        guard !tripsWithRatings.isEmpty else { return 0.0 }
        return tripsWithRatings.reduce(0, +) / Double(tripsWithRatings.count)
    }
    
    private var activityCounts: [(category: TripCategory, count: Int)] {
        let counts = Dictionary(grouping: location.trips, by: { $0.category })
            .mapValues { $0.count }
        
        return TripCategory.allCases.map { category in
            (category: category, count: counts[category] ?? 0)
        }.filter { $0.count > 0 }
    }
    
    private func flagEmoji(for flagCode: String) -> String {
        let base = 127397
        var result = ""
        for char in flagCode.uppercased() {
            result += String(UnicodeScalar(base + Int(char.asciiValue!))!)
        }
        return result
    }
}

// MARK: - Supporting Views

struct CategoryChip: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .textSecondary)
                
                Text(label)
                    .font(Typography.labelM)
                    .foregroundColor(isSelected ? .white : .textPrimary)
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .chipStyle(isSelected: isSelected)
        .pressState()
    }
}

struct TripCard: View {
    let trip: Trip
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Trip image (16:10 aspect ratio)
                AsyncImage(url: URL(string: trip.coverImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.accent600.opacity(0.8),
                                    Color.accent500.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            VStack {
                                Image(systemName: trip.category.icon)
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.8))
                                Text(trip.title)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                        )
                }
                .frame(height: 120)
                .clipped()
                
                // Trip metadata
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    // Title
                    Text(trip.title)
                        .font(Typography.bodyM)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Metadata capsules
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        // Category
                        Text(trip.category.rawValue)
                            .font(Typography.caption)
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, DesignSystem.Spacing.xs)
                            .padding(.vertical, 2)
                            .background(Color.surfaceElev2)
                            .cornerRadius(4)
                        
                        // Duration
                        Text("\(trip.durationDays)d")
                            .font(Typography.caption)
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, DesignSystem.Spacing.xs)
                            .padding(.vertical, 2)
                            .background(Color.surfaceElev2)
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        // Difficulty
                        Text(trip.difficulty.rawValue)
                            .font(Typography.caption)
                            .foregroundColor(trip.difficulty.color)
                            .padding(.horizontal, DesignSystem.Spacing.xs)
                            .padding(.vertical, 2)
                            .background(trip.difficulty.color.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    // Rating and price
                    HStack {
                        if let rating = trip.rating {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", rating))
                                    .font(Typography.caption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        if let price = trip.price {
                            Text("$\(Int(price))")
                                .font(Typography.labelM)
                                .fontWeight(.semibold)
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .cardStyle()
        .onLongPressGesture {
            onLongPress()
        }
        .pressState()
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Trip Difficulty Extension

extension TripDifficulty {
    var color: Color {
        switch self {
        case .easy: return .green
        case .moderate: return .orange
        case .hard: return .red
        }
    }
}

#Preview {
    LocationDetailView(location: Location.sampleNepal)
}
