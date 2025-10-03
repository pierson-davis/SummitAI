import SwiftUI

struct ExpeditionSelectionView: View {
    @EnvironmentObject var expeditionManager: ExpeditionManager
    @EnvironmentObject var userManager: UserManager
    @State private var selectedMountain: Mountain?
    @State private var showingPremiumUpgrade = false
    
    var body: some View {
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
                    VStack(spacing: 16) {
                        Image(systemName: "mountain.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Choose Your Expedition")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Select a mountain to begin your climbing adventure")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
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
                                isPremium: mountain.isPremium && !userManager.isPremiumActive(),
                                onTap: {
                                    if mountain.isPremium && !userManager.isPremiumActive() {
                                        showingPremiumUpgrade = true
                                    } else {
                                        selectedMountain = mountain
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Start expedition button
                    if let selectedMountain = selectedMountain {
                        Button(action: startExpedition) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Expedition")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.orange)
                            .cornerRadius(25)
                        }
                        .padding(.horizontal, 32)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .sheet(isPresented: $showingPremiumUpgrade) {
            PremiumUpgradeView()
        }
    }
    
    private var availableMountains: [Mountain] {
        expeditionManager.getAvailableMountains(for: userManager.currentUser ?? User(username: "", email: "", displayName: ""))
    }
    
    private func startExpedition() {
        guard let mountain = selectedMountain else { return }
        
        expeditionManager.startExpedition(for: mountain)
        userManager.startExpedition(mountain.id)
    }
}

struct MountainCard: View {
    let mountain: Mountain
    let isSelected: Bool
    let isPremium: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Mountain image placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [mountain.difficulty.color.opacity(0.8), mountain.difficulty.color]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 120)
                    
                    VStack {
                        Image(systemName: mountain.difficulty.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        
                        if isPremium {
                            VStack {
                                Image(systemName: "crown.fill")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                                Text("Premium")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                
                // Mountain info
                VStack(alignment: .leading, spacing: 4) {
                    Text(mountain.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(mountain.location)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack {
                        Image(systemName: "arrow.up")
                            .font(.caption)
                        Text("\(Int(mountain.height))m")
                            .font(.caption)
                        Spacer()
                        Text(mountain.difficulty.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(mountain.difficulty.color.opacity(0.2))
                            .foregroundColor(mountain.difficulty.color)
                            .cornerRadius(8)
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.orange : Color.white.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PremiumUpgradeView: View {
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
                        
                        Text("Upgrade to Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Unlock all expeditions and premium features")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // Features list
                    VStack(spacing: 16) {
                        PremiumFeatureRow(
                            icon: "mountain.2.fill",
                            title: "All Expeditions",
                            description: "Access to Everest, K2, El Capitan, and more"
                        )
                        
                        PremiumFeatureRow(
                            icon: "brain.head.profile",
                            title: "Advanced AI Coaching",
                            description: "Detailed form analysis and personalized training plans"
                        )
                        
                        PremiumFeatureRow(
                            icon: "video.fill",
                            title: "Premium Reels Templates",
                            description: "Cinematic templates and AI narrations"
                        )
                        
                        PremiumFeatureRow(
                            icon: "person.3.fill",
                            title: "Squad Creation",
                            description: "Create and manage your own expedition squads"
                        )
                        
                        PremiumFeatureRow(
                            icon: "star.fill",
                            title: "SummitVerse Access",
                            description: "Unlock rare peaks and avatar customization"
                        )
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Pricing options
                    VStack(spacing: 16) {
                        PremiumPricingCard(
                            title: "Monthly",
                            price: "$4.99",
                            period: "month",
                            isPopular: false,
                            onSelect: {
                                userManager.purchasePremium(duration: .monthly)
                                dismiss()
                            }
                        )
                        
                        PremiumPricingCard(
                            title: "Yearly",
                            price: "$49.99",
                            period: "year",
                            isPopular: true,
                            onSelect: {
                                userManager.purchasePremium(duration: .yearly)
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

struct PremiumFeatureRow: View {
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

struct PremiumPricingCard: View {
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
