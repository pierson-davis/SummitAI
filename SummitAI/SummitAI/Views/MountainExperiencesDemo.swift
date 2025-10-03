import SwiftUI

// MARK: - Mountain Experiences Demo
// This is a simplified demo to show the Mountain Experiences interface

struct MountainExperiencesDemo: View {
    @State private var searchText = ""
    @State private var showingFilter = false
    @State private var selectedCategory: String? = nil
    @State private var snowParticles: [SnowParticle] = []
    
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
                        .padding(.top, 32)
                    
                    // Category chips
                    categoryChipsView
                        .padding(.top, 32)
                    
                    // Popular trips grid
                    popularTripsView
                        .padding(.top, 32)
                        .padding(.bottom, 100) // Bottom spacing
                }
            }
            
            // Atmospheric effects overlay
            atmosphericEffectsOverlay
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onAppear {
            startSnowAnimation()
        }
    }
    
    // MARK: - Mountain Hero Background
    
    private var mountainHeroBackground: some View {
        ZStack {
            // Main mountain image placeholder
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color.black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Bottom gradient overlay (40% screen height)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.6),
                    Color.black
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
                
                VStack(spacing: 8) {
                    // Pin marker
                    Image(systemName: "mappin.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    // Dashed vertical guide line
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 2, height: 40)
                        .overlay(
                            Rectangle()
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                        )
                    
                    // Location text pill
                    Text("Nepal, Himalayas")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.08, green: 0.09, blue: 0.10))
                        .cornerRadius(12)
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
            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color(red: 0.08, green: 0.09, blue: 0.10).opacity(0.8))
                    .cornerRadius(12)
            }
            
            Spacer()
            
            // "Need help?" chip with avatar
            Button(action: {}) {
                HStack(spacing: 8) {
                    Text("Need help?")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(red: 0.08, green: 0.09, blue: 0.10).opacity(0.8))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Title Block & Search
    
    private var titleBlockView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Main title
            Text("Mountain\nExperiences")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            // Subtitle
            Text("The best guides for mountaineers")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
            
            // Search input
            HStack(spacing: 16) {
                // Left magnifier icon
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                // Search text field
                TextField("Search mountains, locations...", text: $searchText)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                
                // Right filter button
                Button(action: { showingFilter = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 52)
            .padding(.horizontal, 16)
            .background(Color(red: 0.08, green: 0.09, blue: 0.10).opacity(0.9))
            .cornerRadius(12)
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Category Chips Row
    
    private var categoryChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(["Peaks", "Hiking", "Climbing", "Guides"], id: \.self) { category in
                    Button(action: {
                        selectedCategory = selectedCategory == category ? nil : category
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: iconForCategory(category))
                                .font(.caption)
                                .foregroundColor(selectedCategory == category ? .white : .gray)
                            
                            Text(category)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(selectedCategory == category ? .white : .white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedCategory == category ? Color.blue : Color(red: 0.11, green: 0.12, blue: 0.13))
                    )
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Popular Trips Grid
    
    private var popularTripsView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Popular Trips")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("See all") {
                    // Navigate to full trips list
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 24)
            
            // Trip cards grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(0..<4) { index in
                    tripCard(index: index)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func tripCard(index: Int) -> some View {
        Button(action: {}) {
            VStack(spacing: 0) {
                // Trip image (16:10 aspect ratio)
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.8),
                                Color.purple.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                    .overlay(
                        VStack {
                            Image(systemName: "mountain.2.fill")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.8))
                            Text("Everest Base Camp")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    )
                
                // Trip metadata
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(tripTitles[index])
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Metadata capsules
                    HStack(spacing: 8) {
                        // Category
                        Text(tripCategories[index])
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.11, green: 0.12, blue: 0.13))
                            .cornerRadius(4)
                        
                        // Duration
                        Text("\(tripDurations[index])d")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.11, green: 0.12, blue: 0.13))
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        // Difficulty
                        Text(tripDifficulties[index])
                            .font(.caption)
                            .foregroundColor(difficultyColor(tripDifficulties[index]))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(difficultyColor(tripDifficulties[index]).opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    // Rating and price
                    HStack {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text("4.8")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("$\(tripPrices[index])")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(16)
            }
        }
        .background(Color(red: 0.08, green: 0.09, blue: 0.10))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
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
            }
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Helper Functions
    
    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Peaks": return "mountain.2.fill"
        case "Hiking": return "figure.walk"
        case "Climbing": return "figure.climbing"
        case "Guides": return "person.2.fill"
        default: return "circle.fill"
        }
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy": return .green
        case "Moderate": return .orange
        case "Hard": return .red
        default: return .gray
        }
    }
    
    private func startSnowAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if snowParticles.count < 30 {
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
    
    // MARK: - Sample Data
    
    private let tripTitles = [
        "Everest Base Camp Trek",
        "Annapurna Circuit",
        "Kilimanjaro Summit",
        "Mont Blanc Ascent"
    ]
    
    private let tripCategories = [
        "Hiking", "Hiking", "Climbing", "Climbing"
    ]
    
    private let tripDurations = [14, 21, 8, 5]
    
    private let tripDifficulties = [
        "Hard", "Moderate", "Hard", "Hard"
    ]
    
    private let tripPrices = [2500, 1800, 3200, 1800]
}

struct SnowParticle {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
    let duration: Double
}

#Preview {
    MountainExperiencesDemo()
}
