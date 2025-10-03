import SwiftUI

struct RealisticClimbingView: View {
    @ObservedObject var expeditionManager: ExpeditionManager
    @State private var showingRiskDetails = false
    @State private var showingTips = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Weather and Conditions Section
                weatherSection
                
                // Altitude and Progress Section
                altitudeSection
                
                // Health and Safety Section
                healthSection
                
                // Risk Factors Section
                riskFactorsSection
                
                // Climbing Tips Section
                climbingTipsSection
                
                // Action Buttons
                actionButtons
            }
            .padding()
        }
        .navigationTitle("Climbing Conditions")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Weather Section
    
    private var weatherSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: weatherIcon)
                    .foregroundColor(weatherColor)
                    .font(.title2)
                Text("Current Weather")
                    .font(.headline)
                Spacer()
            }
            
            Text(expeditionManager.currentWeather.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Progress Impact:")
                Spacer()
                Text("\(Int(expeditionManager.currentWeather.progressModifier * 100))%")
                    .foregroundColor(weatherColor)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Altitude Section
    
    private var altitudeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "mountain.2.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Altitude & Progress")
                    .font(.headline)
                Spacer()
            }
            
            if let progress = expeditionManager.realisticProgress {
                VStack(spacing: 8) {
                    HStack {
                        Text("Current Altitude:")
                        Spacer()
                        Text("\(Int(expeditionManager.getCurrentAltitude()))m")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Altitude Gained Today:")
                        Spacer()
                        Text("+\(Int(progress.altitudeGain))m")
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Weather Impact:")
                        Spacer()
                        Text("\(Int(progress.weatherImpact * 100))%")
                            .fontWeight(.semibold)
                            .foregroundColor(progress.weatherImpact >= 0.8 ? .green : .orange)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Health Section
    
    private var healthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                Text("Health & Safety")
                    .font(.headline)
                Spacer()
            }
            
            let healthStatus = expeditionManager.getHealthStatus()
            let acclimatization = expeditionManager.getAcclimatizationStatus()
            
            VStack(spacing: 8) {
                // Altitude Sickness
                HStack {
                    Text("Altitude Sickness:")
                    Spacer()
                    if healthStatus.altitudeSicknessSeverity == 0 {
                        Text("None")
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    } else {
                        Text("Severity: \(healthStatus.altitudeSicknessSeverity)/3")
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                }
                
                // Fatigue Level
                HStack {
                    Text("Fatigue Level:")
                    Spacer()
                    Text("\(Int(healthStatus.fatigueLevel * 100))%")
                        .fontWeight(.semibold)
                        .foregroundColor(healthStatus.fatigueLevel > 0.7 ? .red : healthStatus.fatigueLevel > 0.4 ? .orange : .green)
                }
                
                // Hydration Level
                HStack {
                    Text("Hydration:")
                    Spacer()
                    Text("\(Int(healthStatus.hydrationLevel * 100))%")
                        .fontWeight(.semibold)
                        .foregroundColor(healthStatus.hydrationLevel > 0.7 ? .green : healthStatus.hydrationLevel > 0.4 ? .orange : .red)
                }
                
                // Acclimatization Risk
                HStack {
                    Text("Altitude Sickness Risk:")
                    Spacer()
                    Text("\(Int(acclimatization.altitudeSicknessRisk * 100))%")
                        .fontWeight(.semibold)
                        .foregroundColor(acclimatization.altitudeSicknessRisk > 0.7 ? .red : acclimatization.altitudeSicknessRisk > 0.4 ? .orange : .green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Risk Factors Section
    
    private var riskFactorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("Risk Factors")
                    .font(.headline)
                Spacer()
                
                if !expeditionManager.riskFactors.isEmpty {
                    Button("Details") {
                        showingRiskDetails = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            if expeditionManager.riskFactors.isEmpty {
                Text("No current risk factors detected")
                    .font(.subheadline)
                    .foregroundColor(.green)
            } else {
                ForEach(expeditionManager.riskFactors.prefix(2), id: \.description) { risk in
                    HStack {
                        Image(systemName: riskIcon(for: risk.severity))
                            .foregroundColor(riskColor(for: risk.severity))
                        Text(risk.description)
                            .font(.subheadline)
                            .lineLimit(2)
                        Spacer()
                    }
                }
                
                if expeditionManager.riskFactors.count > 2 {
                    Text("+ \(expeditionManager.riskFactors.count - 2) more risks")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Climbing Tips Section
    
    private var climbingTipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                Text("Climbing Tips")
                    .font(.headline)
                Spacer()
                
                if !expeditionManager.climbingTips.isEmpty {
                    Button("All Tips") {
                        showingTips = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            if expeditionManager.climbingTips.isEmpty {
                Text("No specific tips for current conditions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(expeditionManager.climbingTips.prefix(2), id: \.title) { tip in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tip.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(tip.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if expeditionManager.climbingTips.count > 2 {
                    Text("+ \(expeditionManager.climbingTips.count - 2) more tips")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: {
                    expeditionManager.rest()
                }) {
                    HStack {
                        Image(systemName: "bed.double.fill")
                        Text("Rest")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    expeditionManager.hydrate()
                }) {
                    HStack {
                        Image(systemName: "drop.fill")
                        Text("Hydrate")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            Button(action: {
                expeditionManager.descend()
            }) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Descend for Safety")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private var weatherIcon: String {
        switch expeditionManager.currentWeather.name {
        case "Clear": return "sun.max.fill"
        case "Cloudy": return "cloud.fill"
        case "Windy": return "wind"
        case "Storm": return "cloud.bolt.fill"
        case "Blizzard": return "cloud.snow.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private var weatherColor: Color {
        switch expeditionManager.currentWeather.name {
        case "Clear": return .yellow
        case "Cloudy": return .gray
        case "Windy": return .blue
        case "Storm": return .purple
        case "Blizzard": return .white
        default: return .gray
        }
    }
    
    private func riskIcon(for severity: RiskFactor.RiskSeverity) -> String {
        switch severity {
        case .low: return "info.circle.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.octagon.fill"
        case .extreme: return "xmark.octagon.fill"
        }
    }
    
    private func riskColor(for severity: RiskFactor.RiskSeverity) -> Color {
        switch severity {
        case .low: return .blue
        case .moderate: return .orange
        case .high: return .red
        case .extreme: return .purple
        }
    }
}

// MARK: - Risk Details Sheet

struct RiskDetailsSheet: View {
    let riskFactors: [RiskFactor]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(riskFactors, id: \.description) { risk in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: riskIcon(for: risk.severity))
                            .foregroundColor(riskColor(for: risk.severity))
                        Text(risk.type.rawValue.capitalized)
                            .font(.headline)
                        Spacer()
                        Text(risk.severity.rawValue.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(riskColor(for: risk.severity).opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Text(risk.description)
                        .font(.subheadline)
                    
                    Text("Mitigation: \(risk.mitigation)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
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
    
    private func riskIcon(for severity: RiskFactor.RiskSeverity) -> String {
        switch severity {
        case .low: return "info.circle.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.octagon.fill"
        case .extreme: return "xmark.octagon.fill"
        }
    }
    
    private func riskColor(for severity: RiskFactor.RiskSeverity) -> Color {
        switch severity {
        case .low: return .blue
        case .moderate: return .orange
        case .high: return .red
        case .extreme: return .purple
        }
    }
}

// MARK: - Climbing Tips Sheet

struct ClimbingTipsSheet: View {
    let tips: [ClimbingTip]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(tips, id: \.title) { tip in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(tip.title)
                            .font(.headline)
                        Spacer()
                        Text(tip.category.rawValue.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(categoryColor(for: tip.category).opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Text(tip.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Climbing Tips")
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
    
    private func categoryColor(for category: ClimbingTip.TipCategory) -> Color {
        switch category {
        case .altitude: return .blue
        case .weather: return .cyan
        case .equipment: return .gray
        case .health: return .red
        case .technique: return .green
        case .safety: return .orange
        }
    }
}

#Preview {
    RealisticClimbingView(expeditionManager: ExpeditionManager())
}
