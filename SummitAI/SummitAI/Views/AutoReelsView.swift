import SwiftUI
import AVFoundation
import Photos

struct AutoReelsView: View {
    @EnvironmentObject var expeditionManager: ExpeditionManager
    @EnvironmentObject var userManager: UserManager
    @State private var selectedMilestone: Camp?
    @State private var selectedTemplate: ReelTemplate = .epic
    @State private var generatedReelURL: URL?
    @State private var isGenerating = false
    @State private var showingShareSheet = false
    
    private let availableTemplates: [ReelTemplate] = [
        .epic, .cinematic, .motivational, .adventure
    ]
    
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
                        
                        // Milestone selection
                        milestoneSelectionView
                        
                        // Template selection
                        templateSelectionView
                        
                        // Preview section
                        previewSection
                        
                        // Generate button
                        generateButton
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = generatedReelURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Auto Reels Generator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Create stunning social media content automatically")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "video.fill")
                    .font(.title)
                    .foregroundColor(.purple)
            }
        }
    }
    
    private var milestoneSelectionView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Select Milestone")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if let expedition = expeditionManager.currentExpedition,
               let mountain = expeditionManager.getMountain(by: expedition.mountainId) {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(mountain.camps) { camp in
                            MilestoneCard(
                                camp: camp,
                                isSelected: selectedMilestone?.id == camp.id,
                                isReached: expedition.totalSteps >= camp.stepsRequired && expedition.totalElevation >= camp.elevationRequired,
                                onTap: { selectedMilestone = camp }
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "mountain.2")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("No Active Expedition")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Start an expedition to create milestone reels")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
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
    
    private var templateSelectionView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Choose Template")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(availableTemplates, id: \.self) { template in
                    TemplateCard(
                        template: template,
                        isSelected: selectedTemplate == template,
                        onTap: { selectedTemplate = template }
                    )
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var previewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Preview")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if let milestone = selectedMilestone {
                ReelPreviewCard(
                    milestone: milestone,
                    template: selectedTemplate,
                    isGenerated: generatedReelURL != nil
                )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "play.rectangle")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("Select a Milestone")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Choose a milestone to preview your reel")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var generateButton: some View {
        VStack(spacing: 16) {
            Button(action: generateReel) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "play.fill")
                    }
                    
                    Text(isGenerating ? "Generating Reel..." : "Generate Reel")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.purple)
                .cornerRadius(25)
            }
            .disabled(isGenerating || selectedMilestone == nil)
            .opacity((isGenerating || selectedMilestone == nil) ? 0.6 : 1.0)
            
            if generatedReelURL != nil {
                HStack(spacing: 12) {
                    Button(action: { showingShareSheet = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(25)
                    }
                    
                    Button(action: saveToPhotos) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Save")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .cornerRadius(25)
                    }
                }
            }
        }
    }
    
    private func generateReel() {
        guard let milestone = selectedMilestone else { return }
        
        isGenerating = true
        print("Generating reel for milestone: \(milestone.name)")
        
        // Simulate video generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // In a real implementation, this would generate an actual video
            // For now, we'll create a placeholder URL
            self.generatedReelURL = URL(string: "generated_reel.mp4")
            self.isGenerating = false
        }
    }
    
    private func saveToPhotos() {
        guard let url = generatedReelURL else { return }
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            // Show success message
                        } else {
                            // Show error message
                        }
                    }
                }
            }
        }
    }
}

struct MilestoneCard: View {
    let camp: Camp
    let isSelected: Bool
    let isReached: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isReached ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    if isReached {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "mountain.2.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(spacing: 2) {
                    Text(camp.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text("\(Int(camp.altitude))m")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(width: 100, height: 100)
            .padding(8)
            .background(isSelected ? Color.purple.opacity(0.3) : Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isReached ? 1.0 : 0.6)
    }
}

struct TemplateCard: View {
    let template: ReelTemplate
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: template.icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                VStack(spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .padding()
            .background(isSelected ? Color.purple : Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ReelPreviewCard: View {
    let milestone: Camp
    let template: ReelTemplate
    let isGenerated: Bool
    
    var body: some View {
        ZStack {
            // Background video placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    gradient: Gradient(colors: template.colors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 200)
            
            VStack(spacing: 12) {
                // Milestone info
                VStack(spacing: 4) {
                    Text(milestone.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(Int(milestone.altitude))m elevation")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Template style indicator
                HStack(spacing: 8) {
                    Image(systemName: template.icon)
                        .foregroundColor(.white)
                    
                    Text(template.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.2))
                .cornerRadius(16)
                
                // Play button or generated indicator
                if isGenerated {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Generated")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Reel Template Model

enum ReelTemplate: CaseIterable {
    case epic
    case cinematic
    case motivational
    case adventure
    
    var name: String {
        switch self {
        case .epic:
            return "Epic"
        case .cinematic:
            return "Cinematic"
        case .motivational:
            return "Motivational"
        case .adventure:
            return "Adventure"
        }
    }
    
    var description: String {
        switch self {
        case .epic:
            return "Dramatic music with bold text overlays"
        case .cinematic:
            return "Film-like quality with smooth transitions"
        case .motivational:
            return "Inspirational quotes and uplifting music"
        case .adventure:
            return "Energetic and adventurous vibes"
        }
    }
    
    var icon: String {
        switch self {
        case .epic:
            return "crown.fill"
        case .cinematic:
            return "film.fill"
        case .motivational:
            return "quote.bubble.fill"
        case .adventure:
            return "map.fill"
        }
    }
    
    var colors: [Color] {
        switch self {
        case .epic:
            return [Color.purple, Color.blue]
        case .cinematic:
            return [Color.black, Color.gray]
        case .motivational:
            return [Color.orange, Color.yellow]
        case .adventure:
            return [Color.green, Color.blue]
        }
    }
}

#Preview {
    AutoReelsView()
        .environmentObject(ExpeditionManager())
        .environmentObject(UserManager())
}
