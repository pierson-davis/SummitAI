import SwiftUI

// MARK: - Navigation Sheet Views
// Step 7: Navigation & User Flow

// MARK: - Trip Detail Sheet

struct TripDetailSheet: View {
    let trip: Trip
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var dataManager: MountainExperiencesDataManager
    
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
                            .lineSpacing(4)
                        
                        // Metadata
                        tripMetadataView
                        
                        // Highlights
                        if !trip.highlights.isEmpty {
                            highlightsView
                        }
                        
                        // Requirements
                        if !trip.requirements.isEmpty {
                            requirementsView
                        }
                        
                        // Inclusions
                        if !trip.inclusions.isEmpty {
                            inclusionsView
                        }
                        
                        // Action buttons
                        actionButtonsView
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        navigationManager.dismissSheet()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dataManager.toggleTripBookmark(trip.id)
                    }) {
                        Image(systemName: dataManager.isTripBookmarked(trip.id) ? "bookmark.fill" : "bookmark")
                            .foregroundColor(dataManager.isTripBookmarked(trip.id) ? .accent600 : .textSecondary)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var tripMetadataView: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            MetadataItem(
                title: "Duration",
                value: "\(trip.durationDays) days",
                icon: "calendar"
            )
            
            MetadataItem(
                title: "Difficulty",
                value: trip.difficulty.rawValue,
                icon: "figure.climbing",
                color: trip.difficulty.color
            )
            
            MetadataItem(
                title: "Category",
                value: trip.category.rawValue,
                icon: trip.category.icon
            )
        }
    }
    
    private var highlightsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Highlights")
                .font(Typography.titleS)
                .foregroundColor(.textPrimary)
            
            ForEach(trip.highlights, id: \.self) { highlight in
                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.accent600)
                        .padding(.top, 2)
                    
                    Text(highlight)
                        .font(Typography.bodyM)
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
    
    private var requirementsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Requirements")
                .font(Typography.titleS)
                .foregroundColor(.textPrimary)
            
            ForEach(trip.requirements, id: \.self) { requirement in
                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.top, 2)
                    
                    Text(requirement)
                        .font(Typography.bodyM)
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
    
    private var inclusionsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("What's Included")
                .font(Typography.titleS)
                .foregroundColor(.textPrimary)
            
            ForEach(trip.inclusions, id: \.self) { inclusion in
                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.accent600)
                        .padding(.top, 2)
                    
                    Text(inclusion)
                        .font(Typography.bodyM)
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Plan Trip Button
            Button(action: {
                navigationManager.presentSheet(.tripPlanner(trip))
            }) {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text("Plan Trip")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(isPrimary: true)
            
            // Create Expedition Button
            Button(action: {
                navigationManager.presentSheet(.expeditionCreator(trip))
            }) {
                HStack {
                    Image(systemName: "mountain.2.fill")
                    Text("Create Expedition")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(isSecondary: true)
        }
        .padding(.top, DesignSystem.Spacing.md)
    }
}

// MARK: - Location Detail Sheet

struct LocationDetailSheet: View {
    let location: Location
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Location image
                    AsyncImage(url: URL(string: location.coverImageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.surfaceElev1)
                    }
                    .frame(height: 250)
                    .clipped()
                    
                    // Location details
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text(location.name)
                            .font(Typography.displayM)
                            .foregroundColor(.textPrimary)
                        
                        Text(location.summary)
                            .font(Typography.bodyL)
                            .foregroundColor(.textSecondary)
                            .lineSpacing(4)
                        
                        // Location info
                        locationInfoView
                        
                        // Available trips
                        availableTripsView
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        navigationManager.dismissSheet()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var locationInfoView: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            InfoRow(title: "Country", value: location.country, icon: "flag.fill")
            InfoRow(title: "Time Zone", value: location.timeZone, icon: "clock.fill")
            InfoRow(title: "Best Time", value: location.bestTimeToVisit, icon: "calendar")
            InfoRow(title: "Currency", value: location.currency, icon: "dollarsign.circle.fill")
            InfoRow(title: "Language", value: location.language, icon: "globe")
        }
        .padding(DesignSystem.Spacing.md)
        .background(Color.surfaceElev1)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
    
    private var availableTripsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Available Trips")
                .font(Typography.titleS)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.sm) {
                ForEach(location.trips.prefix(4)) { trip in
                    TripCard(
                        trip: trip,
                        onTap: {
                            navigationManager.presentSheet(.tripDetail(trip))
                        },
                        onLongPress: {}
                    )
                }
            }
        }
    }
}

// MARK: - User Preferences Sheet

struct UserPreferencesSheet: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var userManager: UserManager
    @State private var preferences: UserMountainExperiencesPreferences
    
    init() {
        _preferences = State(initialValue: UserMountainExperiencesPreferences())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Experience Level") {
                    Picker("Experience Level", selection: $preferences.experienceLevel) {
                        ForEach(UserMountainExperiencesPreferences.ExperienceLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Preferred Categories") {
                    ForEach(TripCategory.allCases, id: \.self) { category in
                        Toggle(category.rawValue, isOn: Binding(
                            get: { preferences.favoriteCategories.contains(category) },
                            set: { isOn in
                                if isOn {
                                    preferences.favoriteCategories.append(category)
                                } else {
                                    preferences.favoriteCategories.removeAll { $0 == category }
                                }
                            }
                        ))
                    }
                }
                
                Section("Budget") {
                    HStack {
                        Text("Max Budget")
                        Spacer()
                        TextField("$0", value: $preferences.maxBudget, format: .currency(code: "USD"))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Group Size") {
                    Picker("Group Size", selection: $preferences.groupSizePreference) {
                        ForEach(UserMountainExperiencesPreferences.GroupSizePreference.allCases, id: \.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                }
            }
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        navigationManager.dismissSheet()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userManager.updateMountainExperiencesPreferences(preferences)
                        navigationManager.dismissSheet()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            preferences = userManager.mountainExperiencesPreferences ?? UserMountainExperiencesPreferences()
        }
    }
}

// MARK: - Bookmark Manager Sheet

struct BookmarkManagerSheet: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var dataManager: MountainExperiencesDataManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.getBookmarkedTrips()) { trip in
                    TripRow(trip: trip) {
                        navigationManager.presentSheet(.tripDetail(trip))
                    } onBookmarkToggle: {
                        dataManager.toggleTripBookmark(trip.id)
                    }
                }
            }
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        navigationManager.dismissSheet()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Trip Planner Sheet

struct TripPlannerSheet: View {
    let trip: Trip
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var dataManager: MountainExperiencesDataManager
    
    @State private var plannedDate = Date()
    @State private var participants = 1
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Trip Details") {
                    HStack {
                        Text("Trip")
                        Spacer()
                        Text(trip.title)
                            .foregroundColor(.textSecondary)
                    }
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(trip.durationDays) days")
                            .foregroundColor(.textSecondary)
                    }
                    
                    HStack {
                        Text("Price")
                        Spacer()
                        if let price = trip.price {
                            Text("$\(Int(price))")
                                .foregroundColor(.textSecondary)
                        } else {
                            Text("TBD")
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                
                Section("Planning") {
                    DatePicker("Planned Date", selection: $plannedDate, displayedComponents: .date)
                    
                    Stepper("Participants: \(participants)", value: $participants, in: 1...20)
                    
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Plan Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        navigationManager.dismissSheet()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Plan") {
                        dataManager.planTrip(trip)
                        navigationManager.dismissSheet()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Expedition Creator Sheet

struct ExpeditionCreatorSheet: View {
    let trip: Trip
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var dataManager: MountainExperiencesDataManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                Text("Create Expedition")
                    .font(Typography.titleL)
                    .foregroundColor(.textPrimary)
                
                Text("Transform this trip into a SummitAI expedition")
                    .font(Typography.bodyM)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Trip: \(trip.title)")
                        .font(Typography.bodyM)
                        .foregroundColor(.textPrimary)
                    
                    Text("Duration: \(trip.durationDays) days")
                        .font(Typography.bodyM)
                        .foregroundColor(.textSecondary)
                    
                    Text("Difficulty: \(trip.difficulty.rawValue)")
                        .font(Typography.bodyM)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DesignSystem.Spacing.lg)
                .background(Color.surfaceElev1)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                
                Spacer()
                
                Button("Create Expedition") {
                    dataManager.createExpeditionFromTrip(trip)
                    navigationManager.selectTab(.expedition)
                    navigationManager.dismissSheet()
                }
                .buttonStyle(isPrimary: true)
                .frame(maxWidth: .infinity)
            }
            .padding(DesignSystem.Spacing.lg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        navigationManager.dismissSheet()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Supporting Views

struct MetadataItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    init(title: String, value: String, icon: String, color: Color = .textSecondary) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(title)
                .font(Typography.caption)
                .foregroundColor(.textSecondary)
            
            Text(value)
                .font(Typography.labelM)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accent600)
                .frame(width: 20)
            
            Text(title)
                .font(Typography.bodyM)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(Typography.bodyM)
                .foregroundColor(.textSecondary)
        }
    }
}

struct TripRow: View {
    let trip: Trip
    let onTap: () -> Void
    let onBookmarkToggle: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                AsyncImage(url: URL(string: trip.coverImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.surfaceElev1)
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.title)
                        .font(Typography.bodyM)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Text("\(trip.durationDays) days • \(trip.difficulty.rawValue)")
                        .font(Typography.caption)
                        .foregroundColor(.textSecondary)
                    
                    if let price = trip.price {
                        Text("$\(Int(price))")
                            .font(Typography.labelM)
                            .foregroundColor(.accent600)
                    }
                }
                
                Spacer()
                
                Button(action: onBookmarkToggle) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.accent600)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TripDetailSheet(trip: Trip.sampleTrips[0])
        .environmentObject(NavigationManager())
        .environmentObject(MountainExperiencesDataManager())
}
