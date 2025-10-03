import SwiftUI

// MARK: - Mountain Experiences Home/Discover Screen
// Step 2: Home/Discover Screen Transformation

struct HomeDiscoverView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var searchManager = SearchManager()
    @StateObject private var filterManager = FilterManager()
    @StateObject private var dataManager = MountainExperiencesDataManager()
    @State private var showingFilter = false
    @State private var showingDrawer = false
    @State private var showingSearchResults = false
    @State private var snowParticles: [SnowParticle] = []
    @State private var weatherEffect: WeatherEffect = .clear
    
    // Sample data for demonstration
    @State private var featuredLocation: Location = Location.sampleNepal
    
    // Computed property for filtered trips
    private var popularTrips: [Trip] {
        filterManager.applyFilters(to: dataManager.availableTrips)
    }
    
    var body: some View {
        ZStack {
            // Full-bleed mountain hero background
            mountainHeroBackground
            
            // Main content
            ScrollView {
                VStack(spacing: 0) {
                    // Header with navigation
                    headerView
                        .padding(.top, 60) // Account for safe area
                    
                    // Title block and search
                    titleBlockView
                        .padding(.top, DesignSystem.Spacing.xl)
                    
                    // Category chips
                    categoryChipsView
                        .padding(.top, DesignSystem.Spacing.lg)
                    
                    // Popular trips grid
                    popularTripsView
                        .padding(.top, DesignSystem.Spacing.lg)
                        .padding(.bottom, 100) // Bottom spacing
                }
            }
            
            // Atmospheric effects overlay
            atmosphericEffectsOverlay
            
            // Filter modal
            if showingFilter {
                filterModal
            }
            
            // Drawer overlay
            if showingDrawer {
                drawerOverlay
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onAppear {
            startSnowAnimation()
            startWeatherEffects()
        }
    }
    
    // MARK: - Full-Bleed Mountain Hero Background
    
    private var mountainHeroBackground: some View {
        ZStack {
            // Main mountain image
            Image("mountain_hero_everest") // Placeholder - would be actual mountain image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            
            // Bottom gradient overlay (40% screen height)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.overlay60,
                    Color.surface0
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: UIScreen.main.bounds.height * 0.4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            
            // Contextual location label with pin
            contextualLocationLabel
        }
    }
    
    private var contextualLocationLabel: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(spacing: DesignSystem.Spacing.xs) {
                    // Pin marker
                    Image(systemName: "mappin.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accent600)
                    
                    // Dashed vertical guide line
                    Rectangle()
                        .fill(Color.accent600)
                        .frame(width: 2, height: 40)
                        .overlay(
                            Rectangle()
                                .stroke(Color.accent600, style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                        )
                    
                    // Location text pill
                    Text("Nepal, Himalayas")
                        .font(Typography.labelM)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(Color.surfaceElev1)
                        .cornerRadius(ComponentStyles.Chip.cornerRadius)
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
                Spacer()
            }
            .padding(.bottom, 200) // Position above bottom gradient
        }
    }
    
    // MARK: - Header & Navigation
    
    private var headerView: some View {
        HStack {
            // Hamburger menu (24pt from left, 24pt from top safe area)
            Button(action: { showingDrawer = true }) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.surfaceElev1.opacity(0.8))
                    .cornerRadius(DesignSystem.CornerRadius.small)
            }
            .accessibleTapTarget()
            
            Spacer()
            
            // "Need help?" chip with avatar
            Button(action: {}) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Need help?")
                        .font(Typography.labelM)
                        .foregroundColor(.textPrimary)
                    
                    Circle()
                        .fill(Color.accent600)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(Color.surfaceElev1.opacity(0.8))
                .cornerRadius(ComponentStyles.Chip.cornerRadius)
            }
            .accessibleTapTarget()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    // MARK: - Title Block & Search
    
    private var titleBlockView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Main title
            Text("Mountain\nExperiences")
                .font(Typography.displayXL)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
            
            // Subtitle
            Text("The best guides for mountaineers")
                .font(Typography.bodyM)
                .foregroundColor(.textSecondary)
            
            // Search input
            HStack(spacing: DesignSystem.Spacing.sm) {
                // Left magnifier icon
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .foregroundColor(.textSecondary)
                
                // Search text field
                TextField("Search mountains, locations...", text: $searchManager.searchText)
                    .font(Typography.bodyM)
                    .foregroundColor(.textPrimary)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onTapGesture {
                        navigationManager.presentFullScreenCover(.searchResults)
                    }
                
                // Right filter button
                Button(action: { navigationManager.presentSheet(.filterModal) }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                        .foregroundColor(.textSecondary)
                }
                .accessibleTapTarget()
            }
            .inputStyle()
            .background(Color.surfaceElev1.opacity(0.9))
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    // MARK: - Category Chips Row
    
    private var categoryChipsView: some View {
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
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
    
    // MARK: - Popular Trips Grid
    
    private var popularTripsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Popular Trips")
                    .font(Typography.titleL)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("See all") {
                    // Navigate to full trips list
                }
                .font(Typography.labelM)
                .foregroundColor(.accent600)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            
            // Trip cards grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)
            ], spacing: DesignSystem.Spacing.md) {
                        ForEach(popularTrips.prefix(4)) { trip in
                            TripCard(trip: trip) {
                                // Navigate to trip detail
                            } onLongPress: {
                                dataManager.toggleTripBookmark(trip.id)
                            }
                        }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
    
    // MARK: - Atmospheric Effects
    
    private var atmosphericEffectsOverlay: some View {
        ZStack {
            // Snow particles
            ForEach(snowParticles, id: \.id) { particle in
                Circle()
                    .fill(Color.white.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .animation(.linear(duration: particle.duration), value: particle.position)
            }
            
            // Weather effects
            weatherEffectView
        }
        .allowsHitTesting(false)
    }
    
    private var weatherEffectView: some View {
        Group {
            switch weatherEffect {
            case .clear:
                EmptyView()
            case .snow:
                // Snow overlay
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
            case .storm:
                // Storm overlay
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
            }
        }
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
            VStack(spacing: DesignSystem.Spacing.md) {
                // Filter header
                HStack {
                    Text("Filters")
                        .font(Typography.titleL)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button("Clear") {
                        filterManager.clearAllFilters()
                        showingFilter = false
                    }
                    .font(Typography.labelM)
                    .foregroundColor(.accent600)
                }
                
                // Category filter
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
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
                                isSelected: filterManager.selectedCategories.contains(category),
                                onTap: {
                                    filterManager.toggleCategory(category)
                                }
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
    
    // MARK: - Drawer Overlay
    
    private var drawerOverlay: some View {
        HStack {
            // Drawer content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // Drawer header
                HStack {
                    Text("Menu")
                        .font(Typography.titleL)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { showingDrawer = false }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                // Menu items
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    DrawerMenuItem(icon: "house", title: "Home", action: {})
                    DrawerMenuItem(icon: "person", title: "Profile", action: {})
                    DrawerMenuItem(icon: "heart", title: "Saved Trips", action: {})
                    DrawerMenuItem(icon: "gear", title: "Settings", action: {})
                    DrawerMenuItem(icon: "questionmark.circle", title: "Help", action: {})
                }
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(width: 280)
            .background(Color.surfaceElev1)
            .cornerRadius(DesignSystem.CornerRadius.large, corners: [.topRight, .bottomRight])
            
            Spacer()
        }
        .background(Color.black.opacity(0.3))
        .onTapGesture {
            showingDrawer = false
        }
    }
    
    // MARK: - Animation Functions
    
    private func startSnowAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if snowParticles.count < 50 {
                let particle = SnowParticle(
                    position: CGPoint(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: -10
                    ),
                    size: CGFloat.random(in: 2...6),
                    opacity: Double.random(in: 0.3...0.8),
                    duration: Double.random(in: 3...8)
                )
                snowParticles.append(particle)
            }
            
            // Update existing particles
            snowParticles = snowParticles.compactMap { particle in
                var updatedParticle = particle
                updatedParticle.position.y += 2
                updatedParticle.opacity -= 0.01
                
                if updatedParticle.position.y > UIScreen.main.bounds.height + 10 || updatedParticle.opacity <= 0 {
                    return nil
                }
                return updatedParticle
            }
        }
    }
    
    private func startWeatherEffects() {
        // Simulate weather changes
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2)) {
                weatherEffect = WeatherEffect.allCases.randomElement() ?? .clear
            }
        }
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
                        .fill(Color.surfaceElev2)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .textSecondary))
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

struct DrawerMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.textSecondary)
                    .frame(width: 24)
                
                Text(title)
                    .font(Typography.bodyM)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .pressState()
    }
}

// MARK: - Data Models

struct SnowParticle {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
    let duration: Double
}

enum WeatherEffect: CaseIterable {
    case clear, snow, storm
}

struct Location: Identifiable {
    let id: String
    let name: String
    let summary: String
    let flagCode: String
    let coverImageURL: String
    let trips: [Trip]
    
    static let sampleNepal = Location(
        id: "nepal",
        name: "Nepal",
        summary: "Nepal contains part of the Himalayas, the highest mountain range in the world. Eight of the fourteen eight-thousanders are located in the country.",
        flagCode: "np",
        coverImageURL: "https://images.unsplash.com/photo-1519904981063-b0cf448d479e",
        trips: Trip.sampleTrips
    )
}

struct Trip: Identifiable {
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
    
    static let sampleTrips = [
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
            title: "Kilimanjaro Summit",
            category: .climbing,
            durationDays: 8,
            difficulty: .hard,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "tanzania",
            description: "Africa's highest peak adventure",
            price: 3200,
            rating: 4.9,
            isBookmarked: false
        ),
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
        )
    ]
}

enum TripCategory: String, CaseIterable {
    case peaks = "Peaks"
    case hiking = "Hiking"
    case climbing = "Climbing"
    case guides = "Guides"
    
    var icon: String {
        switch self {
        case .peaks: return "mountain.2.fill"
        case .hiking: return "figure.walk"
        case .climbing: return "figure.climbing"
        case .guides: return "person.2.fill"
        }
    }
}

enum TripDifficulty: String, CaseIterable {
    case easy = "Easy"
    case moderate = "Moderate"
    case hard = "Hard"
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .moderate: return .orange
        case .hard: return .red
        }
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    HomeDiscoverView()
}
