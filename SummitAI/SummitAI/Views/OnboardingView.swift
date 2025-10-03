import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showingSignUp = false
    @State private var showingSignIn = false
    
    private let pages = [
        OnboardingPage(
            title: "Turn Every Step Into An Expedition",
            subtitle: "Transform your daily workouts into epic mountain climbing adventures",
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
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page indicator
                HStack {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        // Final page - show sign up options
                        VStack(spacing: 12) {
                            Button(action: { showingSignUp = true }) {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                    Text("Sign Up")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.orange)
                                .cornerRadius(25)
                            }
                            
                            Button(action: { showingSignIn = true }) {
                                Text("Already have an account? Sign In")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
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
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.orange)
                            .cornerRadius(25)
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

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(page.color)
                .padding(.bottom, 20)
            
            // Title
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Subtitle
            Text(page.subtitle)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 40)
    }
}

#Preview {
    OnboardingView()
}
