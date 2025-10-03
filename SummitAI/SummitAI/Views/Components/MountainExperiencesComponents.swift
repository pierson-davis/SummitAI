import SwiftUI

// MARK: - Mountain Experiences Component Library
// Step 4: Component Library Creation

// MARK: - Minimal App Bar Component

struct MinimalAppBar: View {
    let showBackButton: Bool
    let onBackTap: () -> Void
    let onMenuTap: () -> Void
    let title: String?
    let backgroundColor: Color
    let isTransparent: Bool
    
    init(
        showBackButton: Bool = true,
        onBackTap: @escaping () -> Void = {},
        onMenuTap: @escaping () -> Void = {},
        title: String? = nil,
        backgroundColor: Color = Color.surfaceElev1,
        isTransparent: Bool = false
    ) {
        self.showBackButton = showBackButton
        self.onBackTap = onBackTap
        self.onMenuTap = onMenuTap
        self.title = title
        self.backgroundColor = backgroundColor
        self.isTransparent = isTransparent
    }
    
    var body: some View {
        HStack {
            if showBackButton {
                Button(action: onBackTap) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(backgroundColor.opacity(isTransparent ? 0.6 : 0.9))
                        )
                }
                .accessibleTapTarget()
            } else {
                Button(action: onMenuTap) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(backgroundColor.opacity(isTransparent ? 0.6 : 0.9))
                        )
                }
                .accessibleTapTarget()
            }
            
            if let title = title {
                Text(title)
                    .font(Typography.titleM)
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
            } else {
                Spacer()
            }
            
            // Right side actions can be added here
            Spacer()
                .frame(width: 44) // Balance the left button
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, 60) // Account for safe area
        .background(
            Color.surface0
                .opacity(isTransparent ? 0 : 0.95)
                .animation(.easeInOut(duration: 0.2), value: isTransparent)
        )
    }
}

// MARK: - Search Field Component

struct SearchField: View {
    @Binding var text: String
    let placeholder: String
    let onFilterTap: () -> Void
    let showFilterButton: Bool
    let backgroundColor: Color
    let height: CGFloat
    
    init(
        text: Binding<String>,
        placeholder: String = "Search mountains, locations...",
        onFilterTap: @escaping () -> Void = {},
        showFilterButton: Bool = true,
        backgroundColor: Color = Color.surfaceElev1,
        height: CGFloat = 52
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onFilterTap = onFilterTap
        self.showFilterButton = showFilterButton
        self.backgroundColor = backgroundColor
        self.height = height
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Left magnifier icon
            Image(systemName: "magnifyingglass")
                .font(.title3)
                .foregroundColor(.textSecondary)
            
            // Search text field
            TextField(placeholder, text: $text)
                .font(Typography.bodyM)
                .foregroundColor(.textPrimary)
                .textFieldStyle(PlainTextFieldStyle())
            
            // Right filter button
            if showFilterButton {
                Button(action: onFilterTap) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                        .foregroundColor(.textSecondary)
                }
                .accessibleTapTarget()
            }
        }
        .frame(height: height)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .background(backgroundColor.opacity(0.9))
        .cornerRadius(ComponentStyles.Input.cornerRadius)
    }
}

// MARK: - Category Chip Component

struct CategoryChip: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let onTap: () -> Void
    let backgroundColor: Color
    let selectedBackgroundColor: Color
    let textColor: Color
    let selectedTextColor: Color
    
    init(
        icon: String,
        label: String,
        isSelected: Bool = false,
        onTap: @escaping () -> Void = {},
        backgroundColor: Color = Color.surfaceElev2,
        selectedBackgroundColor: Color = Color.accent600,
        textColor: Color = Color.textPrimary,
        selectedTextColor: Color = Color.white
    ) {
        self.icon = icon
        self.label = label
        self.isSelected = isSelected
        self.onTap = onTap
        self.backgroundColor = backgroundColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.textColor = textColor
        self.selectedTextColor = selectedTextColor
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(isSelected ? selectedTextColor : Color.textSecondary)
                
                Text(label)
                    .font(Typography.labelM)
                    .foregroundColor(isSelected ? selectedTextColor : textColor)
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .background(
            RoundedRectangle(cornerRadius: ComponentStyles.Chip.cornerRadius)
                .fill(isSelected ? selectedBackgroundColor : backgroundColor)
        )
        .pressState()
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Trip Card Component

struct TripCard: View {
    let trip: Trip
    let onTap: () -> Void
    let onLongPress: () -> Void
    let showRating: Bool
    let showPrice: Bool
    let imageHeight: CGFloat
    let backgroundColor: Color
    
    init(
        trip: Trip,
        onTap: @escaping () -> Void = {},
        onLongPress: @escaping () -> Void = {},
        showRating: Bool = true,
        showPrice: Bool = true,
        imageHeight: CGFloat = 120,
        backgroundColor: Color = Color.surfaceElev1
    ) {
        self.trip = trip
        self.onTap = onTap
        self.onLongPress = onLongPress
        self.showRating = showRating
        self.showPrice = showPrice
        self.imageHeight = imageHeight
        self.backgroundColor = backgroundColor
    }
    
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
                                    .padding(.horizontal, DesignSystem.Spacing.xs)
                            }
                        )
                }
                .frame(height: imageHeight)
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
                    if showRating || showPrice {
                        HStack {
                            if showRating, let rating = trip.rating {
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
                            
                            if showPrice, let price = trip.price {
                                Text("$\(Int(price))")
                                    .font(Typography.labelM)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .background(backgroundColor)
        .cornerRadius(ComponentStyles.Card.cornerRadius)
        .shadow(
            color: ComponentStyles.Card.shadow.color,
            radius: ComponentStyles.Card.shadow.radius,
            x: ComponentStyles.Card.shadow.x,
            y: ComponentStyles.Card.shadow.y
        )
        .onLongPressGesture {
            onLongPress()
        }
        .pressState()
    }
}

// MARK: - Mountain Hero View Component

struct MountainHeroView: View {
    let imageURL: String?
    let locationName: String
    let locationSubtitle: String?
    let flagCode: String?
    let showContextualLabel: Bool
    let contextualLabelText: String?
    let contextualLabelPosition: ContextualLabelPosition
    let overlayGradient: LinearGradient
    let imageHeight: CGFloat
    
    enum ContextualLabelPosition {
        case bottomCenter
        case bottomRight
        case bottomLeft
        case custom(CGPoint)
    }
    
    init(
        imageURL: String? = nil,
        locationName: String,
        locationSubtitle: String? = nil,
        flagCode: String? = nil,
        showContextualLabel: Bool = true,
        contextualLabelText: String? = nil,
        contextualLabelPosition: ContextualLabelPosition = .bottomRight,
        overlayGradient: LinearGradient? = nil,
        imageHeight: CGFloat = 300
    ) {
        self.imageURL = imageURL
        self.locationName = locationName
        self.locationSubtitle = locationSubtitle
        self.flagCode = flagCode
        self.showContextualLabel = showContextualLabel
        self.contextualLabelText = contextualLabelText
        self.contextualLabelPosition = contextualLabelPosition
        self.overlayGradient = overlayGradient ?? LinearGradient(
            gradient: Gradient(colors: [
                Color.clear,
                Color.overlay60,
                Color.surface0
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        self.imageHeight = imageHeight
    }
    
    var body: some View {
        ZStack {
            // Mountain hero image
            AsyncImage(url: imageURL != nil ? URL(string: imageURL!) : nil) { image in
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
            .frame(height: imageHeight)
            .clipped()
            
            // Bottom gradient overlay
            overlayGradient
                .frame(height: imageHeight)
            
            // Contextual location label
            if showContextualLabel {
                contextualLocationLabel
            }
            
            // Location title overlay
            locationTitleOverlay
        }
    }
    
    private var contextualLocationLabel: some View {
        VStack {
            Spacer()
            
            HStack {
                switch contextualLabelPosition {
                case .bottomCenter:
                    Spacer()
                    contextualLabelContent
                    Spacer()
                case .bottomRight:
                    Spacer()
                    contextualLabelContent
                case .bottomLeft:
                    contextualLabelContent
                    Spacer()
                case .custom(let point):
                    contextualLabelContent
                        .position(point)
                }
            }
            .padding(.bottom, 200) // Position above bottom gradient
        }
    }
    
    private var contextualLabelContent: some View {
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
            Text(contextualLabelText ?? locationName)
                .font(Typography.labelM)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(Color.surfaceElev1)
                .cornerRadius(ComponentStyles.Chip.cornerRadius)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
    
    private var locationTitleOverlay: some View {
        VStack {
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    // Flag
                    if let flagCode = flagCode {
                        Text(flagEmoji(for: flagCode))
                            .font(.system(size: 32))
                    }
                    
                    // Location name
                    Text(locationName)
                        .font(Typography.displayXL)
                        .foregroundColor(.textPrimary)
                    
                    // Location subtitle
                    if let subtitle = locationSubtitle {
                        Text(subtitle)
                            .font(Typography.bodyM)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.lg)
        }
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

// MARK: - Stats Card Component

struct StatsCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String?
    let backgroundColor: Color
    let textColor: Color
    let iconColor: Color
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String? = nil,
        backgroundColor: Color = Color.surfaceElev1,
        textColor: Color = Color.textPrimary,
        iconColor: Color = Color.accent600
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.iconColor = iconColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
            }
            
            Text(value)
                .font(Typography.titleL)
                .foregroundColor(textColor)
            
            Text(title)
                .font(Typography.labelM)
                .foregroundColor(.textSecondary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(Typography.caption)
                    .foregroundColor(.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.md)
        .background(backgroundColor)
        .cornerRadius(ComponentStyles.Card.cornerRadius)
        .shadow(
            color: ComponentStyles.Card.shadow.color,
            radius: ComponentStyles.Card.shadow.radius,
            x: ComponentStyles.Card.shadow.x,
            y: ComponentStyles.Card.shadow.y
        )
    }
}

// MARK: - Activity Grid Component

struct ActivityGrid: View {
    let activities: [ActivityItem]
    let columns: Int
    let backgroundColor: Color
    let iconColor: Color
    
    struct ActivityItem {
        let category: TripCategory
        let count: Int
        let icon: String
        
        init(category: TripCategory, count: Int, icon: String? = nil) {
            self.category = category
            self.count = count
            self.icon = icon ?? category.icon
        }
    }
    
    init(
        activities: [ActivityItem],
        columns: Int = 3,
        backgroundColor: Color = Color.surfaceElev1,
        iconColor: Color = Color.accent600
    ) {
        self.activities = activities
        self.columns = columns
        self.backgroundColor = backgroundColor
        self.iconColor = iconColor
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns), spacing: DesignSystem.Spacing.sm) {
            ForEach(activities, id: \.category) { activity in
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: activity.icon)
                        .font(.title2)
                        .foregroundColor(iconColor)
                    
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
                .background(backgroundColor)
                .cornerRadius(DesignSystem.CornerRadius.medium)
            }
        }
    }
}

// MARK: - Empty State Component

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let onAction: (() -> Void)?
    let iconSize: CGFloat
    let iconColor: Color
    let textColor: Color
    
    init(
        icon: String = "mountain.2",
        title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil,
        iconSize: CGFloat = 48,
        iconColor: Color = Color.textTertiary,
        textColor: Color = Color.textSecondary
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.onAction = onAction
        self.iconSize = iconSize
        self.iconColor = iconColor
        self.textColor = textColor
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: iconSize))
                .foregroundColor(iconColor)
            
            Text(title)
                .font(Typography.titleS)
                .foregroundColor(textColor)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(Typography.bodyM)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let onAction = onAction {
                Button(action: onAction) {
                    Text(actionTitle)
                        .font(Typography.labelM)
                        .foregroundColor(.white)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(Color.accent600)
                        .cornerRadius(ComponentStyles.Button.cornerRadius)
                }
                .pressState()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxxl)
    }
}

// MARK: - Filter Modal Component

struct FilterModal: View {
    @Binding var isPresented: Bool
    let categories: [TripCategory]
    let difficulties: [TripDifficulty]
    @Binding var selectedCategory: TripCategory?
    @Binding var selectedDifficulty: TripDifficulty?
    let onApply: () -> Void
    let onClear: () -> Void
    
    init(
        isPresented: Binding<Bool>,
        categories: [TripCategory] = TripCategory.allCases,
        difficulties: [TripDifficulty] = TripDifficulty.allCases,
        selectedCategory: Binding<TripCategory?>,
        selectedDifficulty: Binding<TripDifficulty?>,
        onApply: @escaping () -> Void = {},
        onClear: @escaping () -> Void = {}
    ) {
        self._isPresented = isPresented
        self.categories = categories
        self.difficulties = difficulties
        self._selectedCategory = selectedCategory
        self._selectedDifficulty = selectedDifficulty
        self.onApply = onApply
        self.onClear = onClear
    }
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Filter content
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Filter header
                HStack {
                    Text("Filters")
                        .font(Typography.titleL)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button("Clear") {
                        onClear()
                        isPresented = false
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
                        ForEach(categories, id: \.self) { category in
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
                        ForEach(difficulties, id: \.self) { difficulty in
                            Button(action: {
                                selectedDifficulty = selectedDifficulty == difficulty ? nil : difficulty
                            }) {
                                Text(difficulty.rawValue)
                                    .font(Typography.labelM)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, DesignSystem.Spacing.sm)
                                    .padding(.vertical, DesignSystem.Spacing.xs)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: ComponentStyles.Chip.cornerRadius)
                                    .fill(selectedDifficulty == difficulty ? difficulty.color : Color.surfaceElev2)
                            )
                            .pressState()
                        }
                    }
                }
                
                // Apply button
                Button("Apply Filters") {
                    onApply()
                    isPresented = false
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
    VStack(spacing: 20) {
        // Minimal App Bar
        MinimalAppBar(
            showBackButton: true,
            onBackTap: {},
            onMenuTap: {},
            title: "Test Title"
        )
        
        // Search Field
        SearchField(text: .constant(""))
        
        // Category Chip
        CategoryChip(
            icon: "mountain.2.fill",
            label: "Peaks",
            isSelected: true
        )
        
        // Trip Card
        TripCard(
            trip: Trip.sampleTrips[0]
        )
        
        Spacer()
    }
    .background(Color.surface0)
    .preferredColorScheme(.dark)
}
