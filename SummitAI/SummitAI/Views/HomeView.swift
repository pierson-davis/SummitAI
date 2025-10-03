import SwiftUI

struct HomeView: View {
    @EnvironmentObject var expeditionManager: ExpeditionManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var healthManager: HealthKitManager
    
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
                        
                        // Current expedition status
                        if let expedition = expeditionManager.currentExpedition,
                           let mountain = expeditionManager.getMountain(by: expedition.mountainId) {
                            expeditionStatusView(expedition: expedition, mountain: mountain)
                        }
                        
                        // Today's progress
                        todayProgressView
                        
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
                            Text("\(distance.steps) steps")
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
                    Image(systemName: "figure.walk")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
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
        
        // Update expedition progress
        expeditionManager.updateExpeditionProgress(
            steps: healthManager.todaySteps,
            elevation: healthManager.todayElevation,
            workouts: workouts
        )
        
        // Update user stats
        userManager.updateUserStats(
            steps: healthManager.todaySteps,
            elevation: healthManager.todayElevation,
            workout: workouts.first
        )
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

#Preview {
    HomeView()
        .environmentObject(ExpeditionManager())
        .environmentObject(UserManager())
        .environmentObject(HealthKitManager())
}
