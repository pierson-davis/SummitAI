import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var currentPage = 0
    @State private var showingSignUp = false
    @State private var showingSignIn = false
    @State private var selectedColorScheme = 0 // 0: Clean White, 1: Mountain Blue, 2: Sunset Orange, 3: Forest Green
    
    private let pages = [
        OnboardingPage(
            title: "Turn Every Step Into An Adventure",
            subtitle: "Transform your daily workouts into exciting mountain climbing journeys",
            imageName: "mountain.2.fill",
            color: .orange
        ),
        OnboardingPage(
            title: "AI-Powered Coaching",
            subtitle: "Get personalized feedback and training plans from our AI coach",
            imageName: "brain.head.profile",
            color: .blue
        ),
        OnboardingPage(
            title: "Social Adventures",
            subtitle: "Join squads, compete on leaderboards, and share your achievements",
            imageName: "person.3.fill",
            color: .green
        ),
        OnboardingPage(
            title: "Auto-Generated Content",
            subtitle: "Create stunning social media content automatically from your progress",
            imageName: "video.fill",
            color: .purple
        )
    ]
    
    private var colorScheme: ColorScheme {
        switch selectedColorScheme {
        case 0: return .cleanWhite
        case 1: return .mountainBlue
        case 2: return .sunsetOrange
        case 3: return .forestGreen
        default: return .cleanWhite
        }
    }
    
    var body: some View {
        ZStack {
            // Dynamic background based on color scheme
            colorScheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page indicator
                HStack {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? colorScheme.primaryColor : colorScheme.secondaryColor)
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Onboarding pages
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        WelcomeOnboardingPageView(
                            page: pages[index], 
                            index: index,
                            colorScheme: colorScheme
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        // Final page - Get started
                        VStack(spacing: 16) {
                            // Welcome message
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(colorScheme.primaryColor)
                                
                                Text("Ready to start your fitness journey?")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorScheme.textColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(colorScheme.primaryColor.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(colorScheme.primaryColor.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            
                            // Get started button
                            Button(action: { showingSignUp = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.badge.plus")
                                        .font(.title2)
                                    
                                    VStack(spacing: 2) {
                                        Text("Get Started")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        
                                        Text("Create Your Account")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [colorScheme.primaryColor, colorScheme.primaryColor.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(30)
                                .shadow(color: colorScheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            Button(action: { showingSignIn = true }) {
                                Text("Already have an account? Sign In")
                                    .font(.subheadline)
                                    .foregroundColor(colorScheme.secondaryColor)
                            }
                            
                            // Test mode button
                            Button(action: { 
                                userManager.createMockUser()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.fill")
                                    Text("Try Demo Mode")
                                }
                                .font(.subheadline)
                                .foregroundColor(colorScheme.secondaryColor)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(colorScheme.secondaryColor.opacity(0.1))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(colorScheme.secondaryColor.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            // Color scheme selector (only on last page)
                            VStack(spacing: 8) {
                                Text("Choose Your Theme")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorScheme.secondaryColor)
                                
                                HStack(spacing: 12) {
                                    ForEach(0..<4, id: \.self) { index in
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedColorScheme = index
                                            }
                                        }) {
                                            Circle()
                                                .fill(ColorScheme.allCases[index].primaryColor)
                                                .frame(width: 30, height: 30)
                                                .overlay(
                                                    Circle()
                                                        .stroke(selectedColorScheme == index ? colorScheme.primaryColor : Color.clear, lineWidth: 3)
                                                )
                                                .scaleEffect(selectedColorScheme == index ? 1.1 : 1.0)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    } else {
                        // Show next button
                        Button(action: {
                            withAnimation {
                                if currentPage < pages.count - 1 {
                                    currentPage += 1
                                }
                            }
                        }) {
                            HStack {
                                Text("Next")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(colorScheme.primaryColor)
                            .cornerRadius(25)
                            .shadow(color: colorScheme.primaryColor.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
        .sheet(isPresented: $showingSignIn) {
            SignInView()
        }
        .onAppear {
            print("OnboardingView appeared")
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
    let color: Color
}

// MARK: - Color Schemes
enum ColorScheme: CaseIterable {
    case cleanWhite
    case mountainBlue
    case sunsetOrange
    case forestGreen
    
    var primaryColor: Color {
        switch self {
        case .cleanWhite: return Color(red: 0.2, green: 0.4, blue: 0.8) // Soft blue
        case .mountainBlue: return Color(red: 0.1, green: 0.5, blue: 0.9) // Mountain blue
        case .sunsetOrange: return Color(red: 1.0, green: 0.5, blue: 0.1) // Sunset orange
        case .forestGreen: return Color(red: 0.1, green: 0.7, blue: 0.3) // Forest green
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .cleanWhite: return Color(red: 0.4, green: 0.4, blue: 0.4) // Soft gray
        case .mountainBlue: return Color(red: 0.3, green: 0.5, blue: 0.7) // Blue gray
        case .sunsetOrange: return Color(red: 0.8, green: 0.4, blue: 0.2) // Warm orange
        case .forestGreen: return Color(red: 0.2, green: 0.6, blue: 0.4) // Green gray
        }
    }
    
    var textColor: Color {
        switch self {
        case .cleanWhite: return Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
        case .mountainBlue: return Color(red: 0.9, green: 0.9, blue: 1.0) // Light blue-white
        case .sunsetOrange: return Color(red: 1.0, green: 0.95, blue: 0.9) // Warm white
        case .forestGreen: return Color(red: 0.9, green: 1.0, blue: 0.95) // Light green-white
        }
    }
    
    var background: some View {
        switch self {
        case .cleanWhite:
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        Color(red: 0.98, green: 0.98, blue: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .mountainBlue:
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.95, blue: 1.0),
                        Color(red: 0.8, green: 0.9, blue: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .sunsetOrange:
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.95, blue: 0.9),
                        Color(red: 1.0, green: 0.9, blue: 0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .forestGreen:
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 1.0, blue: 0.95),
                        Color(red: 0.8, green: 0.95, blue: 0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct WelcomeOnboardingPageView: View {
    let page: OnboardingPage
    let index: Int
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon with welcoming design
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                colorScheme.primaryColor.opacity(0.2),
                                colorScheme.primaryColor.opacity(0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(colorScheme.primaryColor)
            }
            
            VStack(spacing: 16) {
                // Title
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme.textColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Subtitle
                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(colorScheme.secondaryColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    OnboardingView()
}
