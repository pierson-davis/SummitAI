import SwiftUI

struct AICoachView: View {
    @EnvironmentObject var aiCoachManager: AICoachManager
    @State private var showingPlanCreation = false
    
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
                        
                        // Training plans
                        trainingPlansSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingPlanCreation) {
            TrainingPlanCreationView()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Coach")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Get personalized training plans and coaching")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "brain.head.profile")
                    .font(.title)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var trainingPlansSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Training Plans")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showingPlanCreation = true }) {
                    Text("Create Plan")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            
            if aiCoachManager.trainingPlans.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("No Training Plans")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Create a personalized training plan based on your goals")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            } else {
                ForEach(aiCoachManager.trainingPlans) { plan in
                    TrainingPlanCard(plan: plan)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct TrainingPlanCard: View {
    let plan: TrainingPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(plan.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(plan.difficulty.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(plan.difficulty.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(plan.difficulty.color.opacity(0.2))
                        .cornerRadius(8)
                    
                    Text("\(plan.duration.weeks) weeks")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("Week \(plan.currentWeek) of \(plan.duration.weeks)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                ProgressView(value: Double(plan.currentWeek) / Double(plan.duration.weeks))
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
            }
            
            // Goals
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(plan.goals, id: \.self) { goal in
                        Text(goal.rawValue)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TrainingPlanCreationView: View {
    @EnvironmentObject var aiCoachManager: AICoachManager
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedGoals: Set<FitnessGoal> = []
    @State private var selectedDuration: PlanDuration = .eightWeeks
    
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
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Create Training Plan")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Get a personalized training plan based on your goals")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                        // Goals selection
                        goalsSection
                        
                        // Duration selection
                        durationSection
                        
                        // Create button
                        Button(action: createPlan) {
                            HStack {
                                Text("Create Training Plan")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                        }
                        .disabled(selectedGoals.isEmpty)
                        .opacity(selectedGoals.isEmpty ? 0.6 : 1.0)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Training Plan")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
    }
    
    private var goalsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Select Your Goals")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(FitnessGoal.allCases, id: \.self) { goal in
                    GoalCard(
                        goal: goal,
                        isSelected: selectedGoals.contains(goal),
                        onTap: {
                            if selectedGoals.contains(goal) {
                                selectedGoals.remove(goal)
                            } else {
                                selectedGoals.insert(goal)
                            }
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var durationSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Plan Duration")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(PlanDuration.allCases, id: \.self) { duration in
                    DurationCard(
                        duration: duration,
                        isSelected: selectedDuration == duration,
                        onTap: { selectedDuration = duration }
                    )
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func createPlan() {
        guard let user = userManager.currentUser else { return }
        
        aiCoachManager.generatePersonalizedPlan(
            for: user,
            goals: Array(selectedGoals),
            duration: selectedDuration
        )
        
        dismiss()
    }
}

struct GoalCard: View {
    let goal: FitnessGoal
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: goalIcon(for: goal))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                Text(goal.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(isSelected ? Color.blue : Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func goalIcon(for goal: FitnessGoal) -> String {
        switch goal {
        case .endurance:
            return "heart.fill"
        case .strength:
            return "dumbbell.fill"
        case .climbing:
            return "mountain.2.fill"
        case .weightLoss:
            return "figure.walk"
        case .generalFitness:
            return "star.fill"
        }
    }
}

struct DurationCard: View {
    let duration: PlanDuration
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(duration.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("\(duration.weeks) weeks of training")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .white.opacity(0.6))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AICoachView()
        .environmentObject(AICoachManager())
}