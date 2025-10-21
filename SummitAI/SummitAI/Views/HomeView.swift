import SwiftUI

struct HomeView: View {
    @EnvironmentObject var expeditionManager: ExpeditionManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var aiCoachManager: AICoachManager
    // RealisticClimbingManager temporarily removed to fix compilation issues
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Streak System
                        if let streakManager = healthManager.streakManager {
                            StreakView(streakManager: streakManager)
                        }
                        
                        // Current expedition status
                        if let expedition = expeditionManager.currentExpedition,
                           let mountain = expeditionManager.getMountain(by: expedition.mountainId) {
                            expeditionStatusView(expedition: expedition, mountain: mountain)
                            
                            // Enhanced mountain visualization
                            mountainVisualizationView(expedition: expedition, mountain: mountain)
                            
                        // Survival Dashboard - temporarily removed
                        // SurvivalDashboardView()
                            
                            // Realistic climbing conditions - temporarily disabled
                            // realisticClimbingConditionsView
                        } else {
                            // No active expedition - show mountain selection
                            VStack(spacing: 16) {
                                Text("No Active Expedition")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Choose a mountain to begin your climbing adventure")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                
                                // Start new expedition button
                                Button(action: {
                                    // This will trigger the ContentView to show ExpeditionSelectionView
                                    expeditionManager.abandonExpedition()
                                }) {
                                    HStack {
                                        Image(systemName: "mountain.2.fill")
                                        Text("Choose Mountain")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.orange)
                                    .cornerRadius(25)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                        
                        // Today's progress
                        todayProgressView
                        
                        // AI Coach recommendations
                        aiRecommendationsView
                        
                        // Quick actions
                        quickActionsView
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            updateExpeditionProgress()
            generateAIContent()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(userManager.currentUser?.displayName ?? "Explorer")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Reset steps button
                Button(action: {
                    healthManager.resetStepsToActual()
                    expeditionManager.resetExpeditionProgress()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Profile avatar
                Button(action: {}) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                        )
                }
            }
        }
    }
    
    private func expeditionStatusView(expedition: ExpeditionProgress, mountain: Mountain) -> some View {
        VStack(spacing: 16) {
            // Mountain header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Expedition")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(mountain.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(mountain.location)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: mountain.difficulty.icon)
                    .font(.title)
                    .foregroundColor(mountain.difficulty.color)
            }
            
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("Expedition Progress")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(Int(expeditionManager.getExpeditionProgress() * 100))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                // Steps progress
                HStack {
                    Text("Steps: \(expedition.totalSteps)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    if let mountain = expeditionManager.getMountain(by: expedition.mountainId),
                       let summit = mountain.camps.first(where: { $0.isSummit }) {
                        Text("of \(summit.stepsRequired)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                ProgressView(value: expeditionManager.getExpeditionProgress())
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // Current camp info
            if let currentCamp = expeditionManager.getCurrentCamp() {
                HStack {
                    Image(systemName: "tent.fill")
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current Location")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(currentCamp.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("\(Int(currentCamp.altitude))m elevation")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Start new expedition button
                    Button(action: {
                        expeditionManager.abandonExpedition()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "mountain.2.fill")
                            Text("New")
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Next camp info
            if let nextCamp = expeditionManager.getNextCamp(),
               let distance = expeditionManager.getDistanceToNextCamp() {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Next Camp")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(nextCamp.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            Text("\(distance.steps) steps to go")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("\(Int(distance.elevation))m elevation")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var todayProgressView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            HStack(spacing: 20) {
                // Steps
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Button(action: {
                            healthManager.resetStepsToActual()
                            expeditionManager.resetExpeditionProgress()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text("\(healthManager.todaySteps)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Steps")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                
                // Elevation
                VStack(spacing: 8) {
                    Image(systemName: "arrow.up")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("\(Int(healthManager.todayElevation))m")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Elevation")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                
                // Workouts
                VStack(spacing: 8) {
                    Image(systemName: "dumbbell.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text("\(healthManager.todayWorkouts.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Workouts")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Realistic Climbing Conditions View
    
    // Temporarily simplified - complex VStack causing compilation issues
    /*
    private var realisticClimbingConditionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "mountain.2.fill")
                    .foregroundColor(.white)
                    .font(.title2)
                Text("Climbing Conditions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            // Weather and Risk Summary
            HStack(spacing: 16) {
                // Weather
                VStack(spacing: 4) {
                    Image(systemName: weatherIcon)
                        .foregroundColor(weatherColor)
                        .font(.title3)
                    Text("Clear") // Temporarily hardcoded - realistic weather disabled
                        .font(.caption)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                
                // Altitude
                VStack(spacing: 4) {
                    Text("\(Int(expeditionManager.getCurrentAltitude()))m")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Altitude")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                
                // Risk Level
                VStack(spacing: 4) {
                    Image(systemName: riskIcon)
                        .foregroundColor(riskColor)
                        .font(.title3)
                    Text(riskLevel)
                        .font(.caption)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Health Status
            if expeditionManager.getHealthStatus().altitudeSicknessSeverity > 0 || 
               expeditionManager.getHealthStatus().fatigueLevel > 0.7 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Health Alert: Monitor your condition closely")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
            }
            
            // Progress Impact
            if let progress = expeditionManager.realisticProgress {
                HStack {
                    Text("Progress Impact:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("\(Int(progress.weatherImpact * progress.healthImpact * progress.equipmentImpact * progress.acclimatizationImpact * 100))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(progress.weatherImpact * progress.healthImpact * progress.equipmentImpact * progress.acclimatizationImpact >= 0.8 ? .green : .orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    */
    
    // MARK: - Helper Properties
    
    private var weatherIcon: String {
        switch "Clear" { // Temporarily hardcoded - realistic weather disabled
        case "Clear": return "sun.max.fill"
        case "Cloudy": return "cloud.fill"
        case "Windy": return "wind"
        case "Storm": return "cloud.bolt.fill"
        case "Blizzard": return "cloud.snow.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private var weatherColor: Color {
        switch "Clear" { // Temporarily hardcoded - realistic weather disabled
        case "Clear": return .yellow
        case "Cloudy": return .gray
        case "Windy": return .blue
        case "Storm": return .purple
        case "Blizzard": return .white
        default: return .gray
        }
    }
    
    private var riskLevel: String {
        let riskCount = 0 // Temporarily hardcoded - realistic risk factors disabled
        if riskCount == 0 {
            return "Low"
        } else if riskCount <= 2 {
            return "Moderate"
        } else {
            return "High"
        }
    }
    
    private var riskIcon: String {
        let riskCount = 0 // Temporarily hardcoded - realistic risk factors disabled
        if riskCount == 0 {
            return "checkmark.circle.fill"
        } else if riskCount <= 2 {
            return "exclamationmark.triangle.fill"
        } else {
            return "xmark.octagon.fill"
        }
    }
    
    private var riskColor: Color {
        let riskCount = 0 // Temporarily hardcoded - realistic risk factors disabled
        if riskCount == 0 {
            return .green
        } else if riskCount <= 2 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var quickActionsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Quick Actions")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    icon: "video.fill",
                    title: "Generate Reel",
                    color: .purple,
                    action: {}
                )
                
                QuickActionButton(
                    icon: "brain.head.profile",
                    title: "AI Coach",
                    color: .blue,
                    action: {}
                )
                
                QuickActionButton(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "View Stats",
                    color: .orange,
                    action: {}
                )
                
                QuickActionButton(
                    icon: "flame.fill",
                    title: "Challenges",
                    color: .red,
                    action: {}
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func updateExpeditionProgress() {
        guard let expedition = expeditionManager.currentExpedition else { return }
        
        // Convert today's health data to workout data
        var workouts: [WorkoutData] = []
        
        for hkWorkout in healthManager.todayWorkouts {
            let workout = healthManager.convertHKWorkoutToWorkoutData(hkWorkout)
            workouts.append(workout)
        }
        
        // Update expedition progress with enhanced features
        expeditionManager.updateExpeditionProgress(
            steps: healthManager.todaySteps,
            elevation: healthManager.todayElevation,
            workouts: workouts,
            heartRateData: healthManager.heartRateData,
            workoutIntensity: healthManager.workoutIntensity,
            sleepQuality: healthManager.sleepData?.quality ?? 0.5
        )
        
        // Update user stats
        userManager.updateUserStats(
            steps: healthManager.todaySteps,
            elevation: healthManager.todayElevation,
            workout: workouts.first
        )
    }
    
    // MARK: - AI Coach Integration
    
    private var aiRecommendationsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("AI Coach Recommendations")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
            }
            
            if aiCoachManager.personalizedRecommendations.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.title)
                        .foregroundColor(.blue.opacity(0.6))
                    
                    Text("Generating personalized recommendations...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(aiCoachManager.personalizedRecommendations.prefix(3)) { recommendation in
                        AIRecommendationCard(recommendation: recommendation)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func generateAIContent() {
        guard let user = userManager.currentUser else { return }
        
        // Generate AI recommendations and content
        aiCoachManager.generatePersonalizedRecommendations(for: user, healthData: healthManager)
        aiCoachManager.generateMotivationalMessages(for: user, healthData: healthManager)
        aiCoachManager.generateContent(for: user, healthData: healthManager)
        aiCoachManager.generateFitnessInsights(for: user, healthData: healthManager)
        aiCoachManager.createAdaptiveGoals(for: user, healthData: healthManager)
    }
    
    // MARK: - Enhanced Mountain Visualization
    
    private func mountainVisualizationView(expedition: ExpeditionProgress, mountain: Mountain) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Mountain Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Weather indicator
                HStack(spacing: 4) {
                    Image(systemName: "cloud.sun.fill")
                        .foregroundColor(.yellow)
                    Text("Clear")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // 3D-style mountain visualization
            ZStack {
                // Mountain silhouette
                MountainSilhouetteView(
                    progress: expeditionManager.getExpeditionProgress(),
                    camps: mountain.camps,
                    currentCampId: expedition.currentCampId
                )
                .frame(height: 50)
                
                // Progress indicator
                VStack {
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Altitude")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            if let currentCamp = expeditionManager.getCurrentCamp() {
                                Text("\(Int(currentCamp.altitude))m")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            } else {
                                Text("Base Camp")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Summit")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("\(Int(mountain.camps.last?.altitude ?? 0))m")
                                .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(12)
                }
            }
            
            // Camp milestones
            campMilestonesView(mountain: mountain, expedition: expedition)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func campMilestonesView(mountain: Mountain, expedition: ExpeditionProgress) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Camp Milestones")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(mountain.camps) { camp in
                        CampMilestoneView(
                            camp: camp,
                            isReached: expedition.totalSteps >= camp.stepsRequired,
                            isCurrent: expedition.currentCampId == camp.id,
                            progress: expedition.totalSteps >= camp.stepsRequired ? 1.0 : Double(expedition.totalSteps) / Double(camp.stepsRequired)
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(color.opacity(0.8))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Mountain Visualization Components

struct MountainSilhouetteView: View {
    let progress: Double
    let camps: [Camp]
    let currentCampId: UUID?
    
    var body: some View {
        ZStack {
            // Mountain background
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 200)
            
            // Mountain peaks
            HStack(spacing: 0) {
                ForEach(0..<3) { index in
                    MountainPeakView(
                        height: 120 + CGFloat(index * 20),
                        progress: progress,
                        isActive: index == 1
                    )
                }
            }
            
            // Camp markers
            ForEach(camps) { camp in
                CampMarkerView(
                    camp: camp,
                    isReached: camp.stepsRequired <= Int(progress * Double(camps.last?.stepsRequired ?? 1)),
                    isCurrent: camp.id == currentCampId
                )
            }
        }
    }
}

struct MountainPeakView: View {
    let height: CGFloat
    let progress: Double
    let isActive: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            Path { path in
                let width: CGFloat = 60
                let peakHeight = height * progress
                
                path.move(to: CGPoint(x: 0, y: height))
                path.addLine(to: CGPoint(x: width/2, y: height - peakHeight))
                path.addLine(to: CGPoint(x: width, y: height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        isActive ? Color.orange.opacity(0.8) : Color.gray.opacity(0.4),
                        isActive ? Color.orange.opacity(0.4) : Color.gray.opacity(0.2)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 60, height: height)
        }
    }
}

struct CampMarkerView: View {
    let camp: Camp
    let isReached: Bool
    let isCurrent: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            Button(action: {}) {
                Image(systemName: camp.isSummit ? "flag.fill" : "tent.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isCurrent ? Color.orange : (isReached ? Color.green : Color.gray))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .scaleEffect(isCurrent ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isCurrent)
            }
            .offset(y: -CGFloat(camp.altitude) * 0.2) // Position based on altitude
            
            Text(camp.name)
                .font(.caption2)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .offset(y: -CGFloat(camp.altitude) * 0.2 - 20)
        }
    }
}

struct CampMilestoneView: View {
    let camp: Camp
    let isReached: Bool
    let isCurrent: Bool
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isReached ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                if isReached {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else if isCurrent {
                    Image(systemName: "person.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: camp.isSummit ? "flag" : "tent")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            VStack(spacing: 2) {
                Text(camp.name)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("\(Int(camp.altitude))m")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                
                if !isReached && !isCurrent {
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .frame(width: 80)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isCurrent ? Color.orange.opacity(0.2) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isCurrent ? Color.orange : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - AI Recommendation Components

struct AIRecommendationCard: View {
    let recommendation: AIRecommendation
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: iconForType(recommendation.type))
                .font(.title2)
                .foregroundColor(colorForPriority(recommendation.priority))
                .frame(width: 30, height: 30)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(recommendation.message)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                
                if recommendation.estimatedTime > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("\(recommendation.estimatedTime) min")
                            .font(.caption2)
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            // Action button
            Button(action: {}) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func iconForType(_ type: AIRecommendation.RecommendationType) -> String {
        switch type {
        case .activity:
            return "figure.walk"
        case .recovery:
            return "moon.zzz"
        case .challenge:
            return "flame.fill"
        case .achievement:
            return "trophy.fill"
        case .motivation:
            return "heart.fill"
        }
    }
    
    private func colorForPriority(_ priority: AIRecommendation.Priority) -> Color {
        switch priority {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .red
        }
    }
}

// MARK: - Everest Mountain Visualization Components

struct EverestSilhouetteView: View {
    let progress: Double
    let camps: [Camp]
    let currentCampId: UUID?
    
    var body: some View {
        ZStack {
            // Everest base with ice and snow
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.3, blue: 0.5),
                            Color(red: 0.1, green: 0.2, blue: 0.4),
                            Color(red: 0.05, green: 0.1, blue: 0.2)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 120)
            
            // Everest peaks with realistic proportions
            HStack(spacing: 0) {
                ForEach(0..<5) { index in
                    EverestPeakView(
                        height: 100 + CGFloat(index * 8),
                        progress: progress,
                        isActive: index == 2, // Center peak is main summit
                        isMainPeak: index == 2
                    )
                }
            }
            
            // Everest camp markers with danger zones
            ForEach(camps) { camp in
                EverestCampMarkerView(
                    camp: camp,
                    isReached: camp.stepsRequired <= Int(progress * Double(camps.last?.stepsRequired ?? 1)),
                    isCurrent: camp.id == currentCampId
                )
            }
            
            // Summit flag
            if progress > 0.95 {
                VStack {
                    Image(systemName: "flag.fill")
                        .font(.title)
                        .foregroundColor(.red)
                        .shadow(color: .black, radius: 2)
                        .offset(y: -50)
                    
                    Text("SUMMIT")
                        .font(.caption2)
                        .fontWeight(.black)
                        .foregroundColor(.red)
                        .shadow(color: .black, radius: 1)
                        .offset(y: -45)
                }
                .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
    }
}

struct EverestPeakView: View {
    let height: CGFloat
    let progress: Double
    let isActive: Bool
    let isMainPeak: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            Path { path in
                let width: CGFloat = 60
                let peakHeight = height * progress
                
                // Main peak shape
                path.move(to: CGPoint(x: 0, y: height))
                path.addLine(to: CGPoint(x: width/3, y: height - peakHeight * 0.6))
                path.addLine(to: CGPoint(x: width/2, y: height - peakHeight))
                path.addLine(to: CGPoint(x: 2*width/3, y: height - peakHeight * 0.6))
                path.addLine(to: CGPoint(x: width, y: height))
                path.closeSubpath()
                
                // Ice cap
                if isMainPeak {
                    path.move(to: CGPoint(x: width/3, y: height - peakHeight * 0.6))
                    path.addLine(to: CGPoint(x: width/2, y: height - peakHeight))
                    path.addLine(to: CGPoint(x: 2*width/3, y: height - peakHeight * 0.6))
                    path.closeSubpath()
                }
            }
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        isMainPeak ? Color.white.opacity(0.9) : (isActive ? Color(red: 0.8, green: 0.4, blue: 0.4) : Color(red: 0.4, green: 0.5, blue: 0.6)),
                        isMainPeak ? Color.white.opacity(0.7) : (isActive ? Color(red: 0.6, green: 0.3, blue: 0.3) : Color(red: 0.2, green: 0.3, blue: 0.4))
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 60, height: height)
        }
    }
}

struct EverestCampMarkerView: View {
    let camp: Camp
    let isReached: Bool
    let isCurrent: Bool
    
    private var dangerLevel: Color {
        if camp.altitude > 6000 {
            return .red
        } else if camp.altitude > 4000 {
            return .orange
        } else {
            return .green
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Button(action: {}) {
                ZStack {
                    // Danger zone indicator
                    Circle()
                        .fill(dangerLevel.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(dangerLevel, lineWidth: 2)
                        )
                    
                    // Camp icon
                    Image(systemName: camp.isSummit ? "flag.fill" : "tent.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1)
                }
                .scaleEffect(isCurrent ? 1.3 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isCurrent)
            }
            .offset(y: -CGFloat(camp.altitude) * 0.08) // Position based on altitude
            
            // Camp label with danger info
            VStack(spacing: 2) {
                Text(camp.name.uppercased())
                    .font(.caption2)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 1)
                    .multilineTextAlignment(.center)
                
                Text("\(Int(camp.altitude))M")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(dangerLevel)
                    .shadow(color: .black, radius: 1)
                
                if camp.altitude > 6000 {
                    Text("DEATH ZONE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                } else if camp.altitude > 4000 {
                    Text("HIGH RISK")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
            .offset(y: -CGFloat(camp.altitude) * 0.08 - 25)
        }
    }
}

struct EverestCampMilestoneView: View {
    let camp: Camp
    let isReached: Bool
    let isCurrent: Bool
    let progress: Double
    
    private var dangerLevel: Color {
        if camp.altitude > 6000 {
            return .red
        } else if camp.altitude > 4000 {
            return .orange
        } else {
            return .green
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Danger zone background
                Circle()
                    .fill(dangerLevel.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(dangerLevel, lineWidth: isCurrent ? 3 : 2)
                    )
                
                if isReached {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1)
                } else if isCurrent {
                    Image(systemName: "person.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1)
                } else {
                    Image(systemName: camp.isSummit ? "flag" : "tent")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(color: .black, radius: 1)
                }
            }
            
            VStack(spacing: 3) {
                Text(camp.name.uppercased())
                    .font(.caption2)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 1)
                    .multilineTextAlignment(.center)
                
                Text("\(Int(camp.altitude))M")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(dangerLevel)
                    .shadow(color: .black, radius: 1)
                
                if camp.altitude > 6000 {
                    Text("DEATH ZONE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                } else if camp.altitude > 4000 {
                    Text("HIGH RISK")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                } else {
                    Text("SAFE ZONE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                if !isReached && !isCurrent {
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
        }
        .frame(width: 90)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrent ? dangerLevel.opacity(0.2) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isCurrent ? dangerLevel : Color.clear, lineWidth: 2)
                )
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(ExpeditionManager())
        .environmentObject(UserManager())
        .environmentObject(HealthKitManager())
        .environmentObject(AICoachManager())
}
