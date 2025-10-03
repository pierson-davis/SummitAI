import SwiftUI

struct SurvivalDashboardView: View {
    @EnvironmentObject var expeditionManager: ExpeditionManager
    @EnvironmentObject var realisticClimbingManager: RealisticClimbingManager
    
    @State private var showSurvivalDetails = false
    @State private var showEnvironmentalZones = false
    @State private var showRiskFactors = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            headerView
            
            // Main survival status cards
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // Weather Status
                SurvivalStatusCard(
                    title: "Weather",
                    icon: weatherIcon,
                    status: currentWeatherStatus,
                    color: weatherColor,
                    action: { showSurvivalDetails.toggle() }
                )
                
                // Health Status
                SurvivalStatusCard(
                    title: "Health",
                    icon: healthIcon,
                    status: currentHealthStatus,
                    color: healthColor,
                    action: { showSurvivalDetails.toggle() }
                )
                
                // Environmental Zone
                SurvivalStatusCard(
                    title: "Zone",
                    icon: environmentalZoneIcon,
                    status: currentEnvironmentalZone,
                    color: environmentalZoneColor,
                    action: { showEnvironmentalZones.toggle() }
                )
                
                // Risk Level
                SurvivalStatusCard(
                    title: "Risk",
                    icon: riskIcon,
                    status: currentRiskLevel,
                    color: riskColor,
                    action: { showRiskFactors.toggle() }
                )
            }
            
            // Environmental conditions detail
            environmentalConditionsView
            
            // Survival warnings
            if !realisticClimbingManager.riskFactors.isEmpty {
                survivalWarningsView
            }
            
            // Survival tips
            if !realisticClimbingManager.climbingTips.isEmpty {
                survivalTipsView
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .sheet(isPresented: $showSurvivalDetails) {
            SurvivalDetailsView()
                .environmentObject(realisticClimbingManager)
        }
        .sheet(isPresented: $showEnvironmentalZones) {
            EnvironmentalZonesView()
                .environmentObject(realisticClimbingManager)
        }
        .sheet(isPresented: $showRiskFactors) {
            RiskFactorsView()
                .environmentObject(realisticClimbingManager)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Survival Dashboard")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Monitor your climbing conditions")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Real-time indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: true)
                
                Text("Live")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
    }
    
    // MARK: - Environmental Conditions View
    
    private var environmentalConditionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Environmental Conditions")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                // Temperature
                VStack(spacing: 4) {
                    Image(systemName: "thermometer")
                        .foregroundColor(.orange)
                        .font(.title3)
                    
                    Text("\(Int(calculateTemperature()))°C")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Temperature")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                
                // Wind Speed
                VStack(spacing: 4) {
                    Image(systemName: "wind")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    Text("\(Int(calculateWindSpeed())) km/h")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Wind Speed")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                
                // Visibility
                VStack(spacing: 4) {
                    Image(systemName: "eye")
                        .foregroundColor(.green)
                        .font(.title3)
                    
                    Text("\(Int(calculateVisibility())) km")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Visibility")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Survival Warnings View
    
    private var survivalWarningsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text("Survival Warnings")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVStack(spacing: 8) {
                ForEach(realisticClimbingManager.riskFactors.prefix(3)) { risk in
                    SurvivalWarningCard(riskFactor: risk)
                }
            }
        }
    }
    
    // MARK: - Survival Tips View
    
    private var survivalTipsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                
                Text("Survival Tips")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVStack(spacing: 8) {
                ForEach(realisticClimbingManager.climbingTips.prefix(2)) { tip in
                    SurvivalTipCard(tip: tip)
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var weatherIcon: String {
        switch realisticClimbingManager.currentWeather.name {
        case "Clear": return "sun.max.fill"
        case "Cloudy": return "cloud.fill"
        case "Windy": return "wind"
        case "Storm": return "cloud.bolt.fill"
        case "Blizzard": return "cloud.snow.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private var weatherColor: Color {
        switch realisticClimbingManager.currentWeather.safetyRisk {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .extreme: return .red
        }
    }
    
    private var currentWeatherStatus: String {
        realisticClimbingManager.currentWeather.name
    }
    
    private var healthIcon: String {
        if realisticClimbingManager.healthStatus.altitudeSicknessSeverity > 0 {
            return "heart.text.square.fill"
        } else if realisticClimbingManager.healthStatus.fatigueLevel > 0.7 {
            return "heart.fill"
        } else {
            return "heart.fill"
        }
    }
    
    private var healthColor: Color {
        if realisticClimbingManager.healthStatus.altitudeSicknessSeverity > 2 {
            return .red
        } else if realisticClimbingManager.healthStatus.altitudeSicknessSeverity > 0 || realisticClimbingManager.healthStatus.fatigueLevel > 0.7 {
            return .orange
        } else {
            return .green
        }
    }
    
    private var currentHealthStatus: String {
        if realisticClimbingManager.healthStatus.altitudeSicknessSeverity > 0 {
            return "Altitude Sick"
        } else if realisticClimbingManager.healthStatus.fatigueLevel > 0.7 {
            return "Fatigued"
        } else {
            return "Healthy"
        }
    }
    
    private var environmentalZoneIcon: String {
        switch getCurrentEnvironmentalZone() {
        case "Rainforest": return "leaf.fill"
        case "Moorland": return "tree.fill"
        case "Alpine Desert": return "mountain.2.fill"
        case "Summit": return "crown.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private var environmentalZoneColor: Color {
        switch getCurrentEnvironmentalZone() {
        case "Rainforest": return .green
        case "Moorland": return .brown
        case "Alpine Desert": return .gray
        case "Summit": return .white
        default: return .gray
        }
    }
    
    private var currentEnvironmentalZone: String {
        getCurrentEnvironmentalZone()
    }
    
    private var riskIcon: String {
        let riskCount = realisticClimbingManager.riskFactors.count
        if riskCount == 0 {
            return "checkmark.circle.fill"
        } else if riskCount <= 2 {
            return "exclamationmark.triangle.fill"
        } else {
            return "xmark.octagon.fill"
        }
    }
    
    private var riskColor: Color {
        let riskCount = realisticClimbingManager.riskFactors.count
        if riskCount == 0 {
            return .green
        } else if riskCount <= 2 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var currentRiskLevel: String {
        let riskCount = realisticClimbingManager.riskFactors.count
        if riskCount == 0 {
            return "Low"
        } else if riskCount <= 2 {
            return "Moderate"
        } else {
            return "High"
        }
    }
    
    // MARK: - Helper Functions
    
    private func getCurrentEnvironmentalZone() -> String {
        let altitude = realisticClimbingManager.currentAltitude
        
        if altitude < 2000 {
            return "Rainforest"
        } else if altitude < 3000 {
            return "Moorland"
        } else if altitude < 5000 {
            return "Alpine Desert"
        } else {
            return "Summit"
        }
    }
    
    private func calculateTemperature() -> Double {
        // Base temperature decreases with altitude (6.5°C per 1000m)
        let baseTemp = 20.0 // Sea level temperature
        let altitudeFactor = realisticClimbingManager.currentAltitude * 0.0065
        let weatherFactor = realisticClimbingManager.currentWeather.name == "Storm" ? -10.0 : 0.0
        
        return baseTemp - altitudeFactor + weatherFactor
    }
    
    private func calculateWindSpeed() -> Double {
        let baseWind = 5.0 // Base wind speed
        let altitudeFactor = realisticClimbingManager.currentAltitude * 0.01
        let weatherFactor = realisticClimbingManager.currentWeather.name == "Windy" ? 20.0 : 
                           realisticClimbingManager.currentWeather.name == "Storm" ? 40.0 : 0.0
        
        return baseWind + altitudeFactor + weatherFactor
    }
    
    private func calculateVisibility() -> Double {
        let baseVisibility = 10.0 // Base visibility in km
        let weatherFactor = realisticClimbingManager.currentWeather.name == "Clear" ? 0.0 :
                           realisticClimbingManager.currentWeather.name == "Cloudy" ? -2.0 :
                           realisticClimbingManager.currentWeather.name == "Storm" ? -8.0 : -5.0
        
        return max(0.1, baseVisibility + weatherFactor)
    }
}

// MARK: - Supporting Views

struct SurvivalStatusCard: View {
    let title: String
    let icon: String
    let status: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(status)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SurvivalWarningCard: View {
    let riskFactor: RiskFactor
    
    var body: some View {
        HStack(spacing: 12) {
            // Warning icon
            Image(systemName: warningIcon)
                .font(.title3)
                .foregroundColor(warningColor)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(riskFactor.description)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(riskFactor.mitigation)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(warningColor.opacity(0.2))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(warningColor, lineWidth: 1)
        )
    }
    
    private var warningIcon: String {
        switch riskFactor.severity {
        case .low: return "info.circle.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.triangle.fill"
        case .extreme: return "xmark.octagon.fill"
        }
    }
    
    private var warningColor: Color {
        switch riskFactor.severity {
        case .low: return .blue
        case .moderate: return .yellow
        case .high: return .orange
        case .extreme: return .red
        }
    }
}

struct SurvivalTipCard: View {
    let tip: ClimbingTip
    
    var body: some View {
        HStack(spacing: 12) {
            // Tip icon
            Image(systemName: tipIcon)
                .font(.title3)
                .foregroundColor(.yellow)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(tip.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var tipIcon: String {
        switch tip.category {
        case .altitude: return "arrow.up.circle.fill"
        case .weather: return "cloud.fill"
        case .equipment: return "wrench.fill"
        case .health: return "heart.fill"
        case .technique: return "figure.climbing"
        case .safety: return "shield.fill"
        }
    }
}

// MARK: - Detail Views

struct SurvivalDetailsView: View {
    @EnvironmentObject var realisticClimbingManager: RealisticClimbingManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Health Status
                    healthStatusSection
                    
                    // Weather Details
                    weatherDetailsSection
                    
                    // Equipment Status
                    equipmentStatusSection
                    
                    // Acclimatization
                    acclimatizationSection
                }
                .padding()
            }
            .navigationTitle("Survival Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var healthStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health Status")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                HealthMetricView(
                    title: "Altitude Sickness",
                    value: realisticClimbingManager.healthStatus.altitudeSicknessSeverity,
                    maxValue: 3,
                    color: .red
                )
                
                HealthMetricView(
                    title: "Fatigue Level",
                    value: Int(realisticClimbingManager.healthStatus.fatigueLevel * 100),
                    maxValue: 100,
                    color: .orange
                )
                
                HealthMetricView(
                    title: "Hydration Level",
                    value: Int(realisticClimbingManager.healthStatus.hydrationLevel * 100),
                    maxValue: 100,
                    color: .blue
                )
                
                HealthMetricView(
                    title: "Nutrition Level",
                    value: Int(realisticClimbingManager.healthStatus.nutritionLevel * 100),
                    maxValue: 100,
                    color: .green
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var weatherDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weather Conditions")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Weather")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(realisticClimbingManager.currentWeather.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(realisticClimbingManager.currentWeather.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Safety Risk")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(realisticClimbingManager.currentWeather.safetyRisk.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(safetyRiskColor)
                    
                    Text("Progress Impact")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(Int(realisticClimbingManager.currentWeather.progressModifier * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var equipmentStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Equipment Status")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVStack(spacing: 8) {
                ForEach(realisticClimbingManager.equipmentStatus.equipment, id: \.name) { item in
                    EquipmentItemView(item: item)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var acclimatizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acclimatization Status")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Days at Current Altitude")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(realisticClimbingManager.acclimatizationStatus.daysAtCurrentAltitude)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Altitude Sickness Risk")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(Int(realisticClimbingManager.acclimatizationStatus.altitudeSicknessRisk * 100))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(realisticClimbingManager.acclimatizationStatus.altitudeSicknessRisk > 0.5 ? .red : .green)
                }
                
                HStack {
                    Text("Max Altitude Reached")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(Int(realisticClimbingManager.acclimatizationStatus.maxAltitudeReached))m")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var safetyRiskColor: Color {
        switch realisticClimbingManager.currentWeather.safetyRisk {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .extreme: return .red
        }
    }
}

struct HealthMetricView: View {
    let title: String
    let value: Int
    let maxValue: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("\(value)/\(maxValue)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            ProgressView(value: Double(value), total: Double(maxValue))
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
    }
}

struct EquipmentItemView: View {
    let item: EquipmentItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "wrench.fill")
                .foregroundColor(durabilityColor)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Durability: \(item.durability)%")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text(durabilityStatus)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(durabilityColor)
        }
        .padding(.vertical, 4)
    }
    
    private var durabilityColor: Color {
        if item.durability > 80 {
            return .green
        } else if item.durability > 50 {
            return .yellow
        } else {
            return .red
        }
    }
    
    private var durabilityStatus: String {
        if item.durability > 80 {
            return "Good"
        } else if item.durability > 50 {
            return "Fair"
        } else {
            return "Poor"
        }
    }
}

struct EnvironmentalZonesView: View {
    @EnvironmentObject var realisticClimbingManager: RealisticClimbingManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current zone
                    currentZoneSection
                    
                    // All zones
                    allZonesSection
                }
                .padding()
            }
            .navigationTitle("Environmental Zones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var currentZoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Zone")
                .font(.headline)
                .foregroundColor(.white)
            
            let currentZone = getCurrentEnvironmentalZone()
            EnvironmentalZoneCard(zone: currentZone, isCurrent: true)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var allZonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Zones")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVStack(spacing: 12) {
                ForEach(getAllEnvironmentalZones(), id: \.name) { zone in
                    EnvironmentalZoneCard(zone: zone, isCurrent: false)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func getCurrentEnvironmentalZone() -> EnvironmentalZone {
        let altitude = realisticClimbingManager.currentAltitude
        
        if altitude < 2000 {
            return EnvironmentalZone(
                name: "Rainforest",
                altitudeRange: 0...2000,
                description: "Lush vegetation, high humidity, moderate temperatures",
                challenges: ["High humidity", "Dense vegetation", "Wildlife encounters"],
                tips: ["Stay hydrated", "Watch for wildlife", "Use insect repellent"],
                color: .green
            )
        } else if altitude < 3000 {
            return EnvironmentalZone(
                name: "Moorland",
                altitudeRange: 2000...3000,
                description: "Open grasslands, cooler temperatures, variable weather",
                challenges: ["Temperature changes", "Wind exposure", "Limited shelter"],
                tips: ["Layer clothing", "Watch weather changes", "Find shelter"],
                color: .brown
            )
        } else if altitude < 5000 {
            return EnvironmentalZone(
                name: "Alpine Desert",
                altitudeRange: 3000...5000,
                description: "Rocky terrain, extreme temperatures, high altitude",
                challenges: ["Extreme temperatures", "High altitude", "Rocky terrain"],
                tips: ["Protect from sun", "Manage altitude", "Use proper gear"],
                color: .gray
            )
        } else {
            return EnvironmentalZone(
                name: "Summit Zone",
                altitudeRange: 5000...8848,
                description: "Extreme conditions, death zone, ultimate challenge",
                challenges: ["Death zone", "Extreme cold", "Oxygen deprivation"],
                tips: ["Use oxygen", "Limit time", "Descend quickly"],
                color: .white
            )
        }
    }
    
    private func getAllEnvironmentalZones() -> [EnvironmentalZone] {
        [
            EnvironmentalZone(
                name: "Rainforest",
                altitudeRange: 0...2000,
                description: "Lush vegetation, high humidity, moderate temperatures",
                challenges: ["High humidity", "Dense vegetation", "Wildlife encounters"],
                tips: ["Stay hydrated", "Watch for wildlife", "Use insect repellent"],
                color: .green
            ),
            EnvironmentalZone(
                name: "Moorland",
                altitudeRange: 2000...3000,
                description: "Open grasslands, cooler temperatures, variable weather",
                challenges: ["Temperature changes", "Wind exposure", "Limited shelter"],
                tips: ["Layer clothing", "Watch weather changes", "Find shelter"],
                color: .brown
            ),
            EnvironmentalZone(
                name: "Alpine Desert",
                altitudeRange: 3000...5000,
                description: "Rocky terrain, extreme temperatures, high altitude",
                challenges: ["Extreme temperatures", "High altitude", "Rocky terrain"],
                tips: ["Protect from sun", "Manage altitude", "Use proper gear"],
                color: .gray
            ),
            EnvironmentalZone(
                name: "Summit Zone",
                altitudeRange: 5000...8848,
                description: "Extreme conditions, death zone, ultimate challenge",
                challenges: ["Death zone", "Extreme cold", "Oxygen deprivation"],
                tips: ["Use oxygen", "Limit time", "Descend quickly"],
                color: .white
            )
        ]
    }
}

struct RiskFactorsView: View {
    @EnvironmentObject var realisticClimbingManager: RealisticClimbingManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Risk summary
                    riskSummarySection
                    
                    // All risk factors
                    riskFactorsSection
                }
                .padding()
            }
            .navigationTitle("Risk Factors")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var riskSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Risk Summary")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(realisticClimbingManager.riskFactors.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Active Risks")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 4) {
                    Text(overallRiskLevel)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(overallRiskColor)
                    
                    Text("Overall Risk")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var riskFactorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Risk Factors")
                .font(.headline)
                .foregroundColor(.white)
            
            if realisticClimbingManager.riskFactors.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                    
                    Text("No active risks")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Text("Continue climbing safely")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(realisticClimbingManager.riskFactors, id: \.description) { risk in
                        RiskFactorDetailCard(riskFactor: risk)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var overallRiskLevel: String {
        let riskCount = realisticClimbingManager.riskFactors.count
        if riskCount == 0 {
            return "Low"
        } else if riskCount <= 2 {
            return "Moderate"
        } else {
            return "High"
        }
    }
    
    private var overallRiskColor: Color {
        let riskCount = realisticClimbingManager.riskFactors.count
        if riskCount == 0 {
            return .green
        } else if riskCount <= 2 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Supporting Models

struct EnvironmentalZone {
    let name: String
    let altitudeRange: ClosedRange<Double>
    let description: String
    let challenges: [String]
    let tips: [String]
    let color: Color
}

struct EnvironmentalZoneCard: View {
    let zone: EnvironmentalZone
    let isCurrent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(zone.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(Int(zone.altitudeRange.lowerBound))m - \(Int(zone.altitudeRange.upperBound))m")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                if isCurrent {
                    Text("CURRENT")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Text(zone.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Challenges:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
                
                ForEach(zone.challenges, id: \.self) { challenge in
                    Text("• \(challenge)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Tips:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
                
                ForEach(zone.tips, id: \.self) { tip in
                    Text("• \(tip)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding()
        .background(zone.color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(zone.color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct RiskFactorDetailCard: View {
    let riskFactor: RiskFactor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: riskIcon)
                    .font(.title3)
                    .foregroundColor(riskColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(riskFactor.type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(riskFactor.severity.rawValue + " Risk")
                        .font(.caption)
                        .foregroundColor(riskColor)
                }
                
                Spacer()
            }
            
            Text(riskFactor.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Mitigation:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(riskFactor.mitigation)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(riskColor.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(riskColor, lineWidth: 1)
        )
    }
    
    private var riskIcon: String {
        switch riskFactor.severity {
        case .low: return "info.circle.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.triangle.fill"
        case .extreme: return "xmark.octagon.fill"
        }
    }
    
    private var riskColor: Color {
        switch riskFactor.severity {
        case .low: return .blue
        case .moderate: return .yellow
        case .high: return .orange
        case .extreme: return .red
        }
    }
}

// MARK: - Extensions for RiskFactor

extension RiskFactor: Identifiable {
    var id: String { description }
}

extension RiskFactor.RiskType: RawRepresentable {
    var rawValue: String {
        switch self {
        case .altitudeSickness: return "Altitude Sickness"
        case .weather: return "Weather"
        case .equipment: return "Equipment"
        case .fatigue: return "Fatigue"
        case .dehydration: return "Dehydration"
        case .hypothermia: return "Hypothermia"
        }
    }
    
    init?(rawValue: String) {
        switch rawValue {
        case "Altitude Sickness": self = .altitudeSickness
        case "Weather": self = .weather
        case "Equipment": self = .equipment
        case "Fatigue": self = .fatigue
        case "Dehydration": self = .dehydration
        case "Hypothermia": self = .hypothermia
        default: return nil
        }
    }
}

extension RiskFactor.RiskSeverity: RawRepresentable {
    var rawValue: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .extreme: return "Extreme"
        }
    }
    
    init?(rawValue: String) {
        switch rawValue {
        case "Low": self = .low
        case "Moderate": self = .moderate
        case "High": self = .high
        case "Extreme": self = .extreme
        default: return nil
        }
    }
}

#Preview {
    SurvivalDashboardView()
        .environmentObject(ExpeditionManager())
        .environmentObject(RealisticClimbingManager())
        .background(Color.black)
}
