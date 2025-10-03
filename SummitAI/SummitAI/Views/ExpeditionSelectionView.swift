import SwiftUI

struct ExpeditionSelectionView: View {
    @EnvironmentObject var expeditionManager: ExpeditionManager
    @EnvironmentObject var userManager: UserManager
    @State private var selectedMountain: Mountain?
    @State private var showingAccessUpgrade = false
    
    var body: some View {
        ZStack {
            // Everest-inspired background with atmospheric effects
            ZStack {
                // Base gradient - ice and storm
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.15, blue: 0.25), // Deep storm blue
                        Color(red: 0.05, green: 0.1, blue: 0.2),   // Midnight blue
                        Color(red: 0.02, green: 0.05, blue: 0.1)   // Deep black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Atmospheric overlay - snow and ice particles
                ForEach(0..<30, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: CGFloat.random(in: 1...4))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .animation(
                            Animation.linear(duration: Double.random(in: 5...15))
                                .repeatForever(autoreverses: false),
                            value: UUID()
                        )
                }
            }
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Everest expedition header
                    VStack(spacing: 20) {
                        // Everest icon with atmospheric effects
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red.opacity(0.3), Color.orange.opacity(0.2)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "mountain.2.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                                .shadow(color: .black, radius: 3)
                        }
                        
                        VStack(spacing: 8) {
                            Text("EXPEDITION SELECTION")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.7, green: 0.8, blue: 1.0).opacity(0.8))
                            
                            Text("CHOOSE YOUR EVEREST")
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .foregroundColor(.white)
                                .shadow(color: Color.red.opacity(0.5), radius: 2)
                            
                            Text("Select your mountain to begin the ultimate climbing challenge")
                                .font(.subheadline)
                                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        // Welcome message
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.orange)
                            
                            Text("Choose your adventure destination")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.top, 40)
                    
                    // Mountains grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(availableMountains, id: \.id) { mountain in
                            MountainCard(
                                mountain: mountain,
                                isSelected: selectedMountain?.id == mountain.id,
                                isPaywalled: mountain.isPaywalled && !userManager.hasAccessActive(),
                                onTap: {
                                    if mountain.isPaywalled && !userManager.hasAccessActive() {
                                        showingAccessUpgrade = true
                                    } else {
                                        selectedMountain = mountain
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Everest expedition launch button
                    if let selectedMountain = selectedMountain {
                        VStack(spacing: 12) {
                            // Ready to start message
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                
                                Text("Ready to begin your adventure!")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.green.opacity(0.4), lineWidth: 1)
                                    )
                            )
                            
                            // Launch expedition button
                            Button(action: startExpedition) {
                                HStack(spacing: 12) {
                                    Image(systemName: "mountain.2.fill")
                                        .font(.title2)
                                    
                                    VStack(spacing: 2) {
                                        Text("Start Adventure")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        
                                        Text("Begin \(selectedMountain.name) Journey")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red.opacity(0.8), Color.orange.opacity(0.9)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.red.opacity(0.6), lineWidth: 2)
                                )
                                .shadow(color: Color.red.opacity(0.5), radius: 8, x: 0, y: 4)
                            }
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.2))
                        }
                        .padding(.horizontal, 32)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .sheet(isPresented: $showingAccessUpgrade) {
            AccessUpgradeView()
        }
    }
    
    private var availableMountains: [Mountain] {
        expeditionManager.getAvailableMountains(for: userManager.currentUser ?? User(username: "", email: "", displayName: ""))
    }
    
    private func startExpedition() {
        guard let mountain = selectedMountain else { return }
        
        print("ExpeditionSelectionView: Starting expedition for \(mountain.name)")
        expeditionManager.startExpedition(for: mountain)
        userManager.startExpedition(mountain.id)
        print("ExpeditionSelectionView: Expedition started - currentExpedition: \(expeditionManager.currentExpedition != nil)")
    }
}

struct MountainCard: View {
    let mountain: Mountain
    let isSelected: Bool
    let isPaywalled: Bool
    let onTap: () -> Void
    
    private var dangerLevel: Color {
        if mountain.height > 6000 {
            return .red
        } else if mountain.height > 4000 {
            return .orange
        } else {
            return .green
        }
    }
    
    private var isDeathZone: Bool {
        mountain.height > 6000
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Everest-style mountain visualization
                ZStack {
                    // Mountain background with atmospheric effects
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    dangerLevel.opacity(0.8),
                                    dangerLevel.opacity(0.6),
                                    Color(red: 0.1, green: 0.2, blue: 0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 140)
                    
                    // Atmospheric effects
                    if isDeathZone {
                        ForEach(0..<8, id: \.self) { _ in
                            Image(systemName: "snow")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                                .position(
                                    x: CGFloat.random(in: 20...UIScreen.main.bounds.width * 0.4),
                                    y: CGFloat.random(in: 20...120)
                                )
                        }
                    }
                    
                    VStack(spacing: 8) {
                        // Mountain icon with danger indicator
                        ZStack {
                            Circle()
                                .fill(dangerLevel.opacity(0.4))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: mountain.difficulty.icon)
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2)
                        }
                        
                        // Difficulty indicator
                        if mountain.height > 6000 {
                            VStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                
                                Text("EXPERT")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                        } else if mountain.height > 4000 {
                            VStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                
                                Text("ADVANCED")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                        } else {
                            VStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text("BEGINNER")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        if isPaywalled {
                            VStack(spacing: 2) {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                
                                Text("PAYWALLED")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }
                
                // Mountain expedition info
                VStack(alignment: .leading, spacing: 6) {
                    Text(mountain.name.uppercased())
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .shadow(color: dangerLevel.opacity(0.5), radius: 1)
                        .lineLimit(2)
                    
                    Text(mountain.location.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.7, green: 0.8, blue: 1.0).opacity(0.8))
                    
                    // Altitude and difficulty with danger indicators
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ALTITUDE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.7, green: 0.8, blue: 1.0).opacity(0.8))
                            
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up")
                                    .font(.caption)
                                    .foregroundColor(dangerLevel)
                                
                                Text("\(Int(mountain.height))M")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(dangerLevel)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("DIFFICULTY")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.7, green: 0.8, blue: 1.0).opacity(0.8))
                            
                            Text(mountain.difficulty.rawValue.uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(dangerLevel.opacity(0.2))
                                .foregroundColor(dangerLevel)
                                .cornerRadius(8)
                        }
                    }
                    
                    // Challenge level
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(dangerLevel)
                        
                        Text(mountain.height > 6000 ? "HIGH CHALLENGE" : mountain.height > 4000 ? "MODERATE CHALLENGE" : "PERFECT START")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(dangerLevel)
                        
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? dangerLevel : Color(red: 0.7, green: 0.8, blue: 1.0).opacity(0.3),
                                lineWidth: isSelected ? 3 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AccessUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Unlock Full Access")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Unlock all expeditions and features after onboarding")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // Features list
                    VStack(spacing: 16) {
                        AccessFeatureRow(
                            icon: "mountain.2.fill",
                            title: "All Expeditions",
                            description: "Access to Everest, K2, El Capitan, and more"
                        )
                        
                        AccessFeatureRow(
                            icon: "brain.head.profile",
                            title: "Advanced AI Coaching",
                            description: "Detailed form analysis and personalized training plans"
                        )
                        
                        AccessFeatureRow(
                            icon: "video.fill",
                            title: "Premium Reels Templates",
                            description: "Cinematic templates and AI narrations"
                        )
                        
                        AccessFeatureRow(
                            icon: "person.3.fill",
                            title: "Squad Creation",
                            description: "Create and manage your own expedition squads"
                        )
                        
                        AccessFeatureRow(
                            icon: "star.fill",
                            title: "SummitVerse Access",
                            description: "Unlock rare peaks and avatar customization"
                        )
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Pricing options
                    VStack(spacing: 16) {
                        AccessPricingCard(
                            title: "Monthly",
                            price: "$4.99",
                            period: "month",
                            isPopular: false,
                            onSelect: {
                                userManager.purchaseAccess(duration: .monthly)
                                dismiss()
                            }
                        )
                        
                        AccessPricingCard(
                            title: "Yearly",
                            price: "$49.99",
                            period: "year",
                            isPopular: true,
                            onSelect: {
                                userManager.purchaseAccess(duration: .yearly)
                                dismiss()
                            }
                        )
                    }
                    .padding(.horizontal, 32)
                    
                    // Close button
                    Button(action: { dismiss() }) {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct AccessFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}

struct AccessPricingCard: View {
    let title: String
    let price: String
    let period: String
    let isPopular: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                if isPopular {
                    Text("Most Popular")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text(price)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("/\(period)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                if isPopular {
                    Text("Save 17%")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isPopular ? 0.2 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isPopular ? Color.orange : Color.white.opacity(0.2), lineWidth: isPopular ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ExpeditionSelectionView()
        .environmentObject(ExpeditionManager())
        .environmentObject(UserManager())
}

