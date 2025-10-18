import SwiftUI

// MARK: - Main Streak View
struct StreakView: View {
    @ObservedObject var streakManager: StreakManager
    @State private var showingSettings = false
    @State private var showingHistory = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Streak Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Streak")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Text("\(streakManager.currentStreak)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(streakManager.isStreakActive ? .orange : .primary)
                        
                        StreakFireView(fireLevel: streakManager.getStreakFireLevel())
                    }
                    
                    Text(streakManager.streakMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: { showingHistory = true }) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Daily Progress
            StreakProgressView(
                currentSteps: streakManager.todaySteps,
                targetSteps: streakManager.dailyStepTarget,
                progress: streakManager.getStreakProgress()
            )
            
            // Quick Stats
            HStack(spacing: 20) {
                VStack {
                    Text("\(streakManager.getStepsRemaining())")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("Steps Left")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack {
                    Text("\(streakManager.streakHistory.filter { $0.isStreakDay }.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Streak Days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack {
                    Text("\(streakManager.getStreakStatistics().longestStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("Best Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .sheet(isPresented: $showingSettings) {
            StreakSettingsView(streakManager: streakManager)
        }
        .sheet(isPresented: $showingHistory) {
            StreakHistoryView(streakManager: streakManager)
        }
    }
}

// MARK: - Streak Fire View
struct StreakFireView: View {
    let fireLevel: Int
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<min(fireLevel, 10), id: \.self) { _ in
                Text("🔥")
                    .font(.title2)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...0.5)),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Streak Progress View
struct StreakProgressView: View {
    let currentSteps: Int
    let targetSteps: Int
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Today's Progress")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(currentSteps) / \(targetSteps)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: progress >= 1.0 ? [.green, .blue] : [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 12)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 12)
            
            // Progress Percentage
            HStack {
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(progress >= 1.0 ? .green : .orange)
            }
        }
    }
}

// MARK: - Streak Settings View
struct StreakSettingsView: View {
    @ObservedObject var streakManager: StreakManager
    @Environment(\.dismiss) private var dismiss
    @State private var tempTarget: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Daily Step Target")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter target steps", text: $tempTarget)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .onAppear {
                            tempTarget = String(streakManager.dailyStepTarget)
                        }
                    
                    Text("Recommended: 5,000 - 10,000 steps per day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Current Settings")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("Current Target:")
                        Spacer()
                        Text("\(streakManager.dailyStepTarget) steps")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Current Streak:")
                        Spacer()
                        Text("\(streakManager.currentStreak) days")
                            .fontWeight(.medium)
                            .foregroundColor(streakManager.isStreakActive ? .orange : .secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Streak Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let newTarget = Int(tempTarget), newTarget > 0 {
                            streakManager.setDailyStepTarget(newTarget)
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Streak History View
struct StreakHistoryView: View {
    @ObservedObject var streakManager: StreakManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Statistics
                let stats = streakManager.getStreakStatistics()
                
                HStack(spacing: 20) {
                    VStack {
                        Text("\(stats.currentStreak)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Text("Current")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(stats.longestStreak)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text("Longest")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(stats.streakDays)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Total Days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                // History List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(streakManager.streakHistory.sorted(by: { $0.date > $1.date })) { day in
                            StreakHistoryRow(day: day)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Streak History")
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
}

// MARK: - Streak History Row
struct StreakHistoryRow: View {
    let day: StreakDay
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(day.date, style: .date)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(day.steps) / \(day.target) steps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if day.isStreakDay {
                HStack(spacing: 2) {
                    ForEach(0..<min(day.fireLevel, 5), id: \.self) { _ in
                        Text("🔥")
                            .font(.caption)
                    }
                }
            } else {
                Text("❌")
                    .font(.caption)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(day.isStreakDay ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        )
    }
}

// MARK: - Preview
struct StreakView_Previews: PreviewProvider {
    static var previews: some View {
        let streakManager = StreakManager()
        streakManager.updateStreak(with: 7500)
        streakManager.updateStreak(with: 8200)
        streakManager.updateStreak(with: 6800)
        
        return VStack {
            StreakView(streakManager: streakManager)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
