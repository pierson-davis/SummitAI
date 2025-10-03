import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var characterManager: CharacterManager
    @State private var selectedTab = 0
    @State private var showGearDetail = false
    @State private var selectedGear: GearItem?
    @State private var showSkillDetail = false
    @State private var selectedSkillTree: CharacterSkills.SkillType = .survival
    
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
                
                if characterManager.currentCharacter == nil {
                    characterCreationView
                } else {
                    VStack(spacing: 0) {
                        // Character header
                        characterHeaderView
                        
                        // Tab selection
                        tabSelectionView
                        
                        // Content based on selected tab
                        TabView(selection: $selectedTab) {
                            characterOverviewView
                                .tag(0)
                            
                            skillsView
                                .tag(1)
                            
                            gearView
                                .tag(2)
                            
                            achievementsView
                                .tag(3)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showGearDetail) {
            if let gear = selectedGear {
                GearDetailView(gear: gear, characterManager: characterManager)
            }
        }
        .sheet(isPresented: $showSkillDetail) {
            SkillDetailView(skillTree: selectedSkillTree, characterManager: characterManager)
        }
    }
    
    // MARK: - Character Creation View
    
    private var characterCreationView: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("Create Your Climber")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Customize your character and start your mountain climbing journey")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button("Create Character") {
                characterManager.createMockCharacter()
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button("Add Test Gear") {
                characterManager.addMockGear()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
    }
    
    // MARK: - Character Header View
    
    private var characterHeaderView: some View {
        VStack(spacing: 16) {
            if let character = characterManager.currentCharacter {
                HStack {
                    // Character avatar
                    CharacterAvatarView(avatar: character.avatar)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(character.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Level \(character.level)")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        
                        // Experience bar
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Experience")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Spacer()
                                
                                Text("\(character.experience) / \(character.experienceToNextLevel)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            ProgressView(value: Double(character.experience), total: Double(character.experienceToNextLevel))
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("\(character.skillPoints)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Skill Points")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Stats overview
                HStack(spacing: 20) {
                    StatView(title: "Health", value: character.stats.currentHealth, maxValue: character.stats.maxHealth, color: .red)
                    StatView(title: "Stamina", value: character.stats.currentStamina, maxValue: character.stats.maxStamina, color: .green)
                    StatView(title: "Strength", value: character.stats.strength, color: .orange)
                    StatView(title: "Agility", value: character.stats.agility, color: .blue)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - Tab Selection View
    
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcon(for: index))
                            .font(.title3)
                        
                        Text(tabTitle(for: index))
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == index ? .orange : .white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "person.fill"
        case 1: return "brain.head.profile"
        case 2: return "tshirt.fill"
        case 3: return "trophy.fill"
        default: return "circle.fill"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Overview"
        case 1: return "Skills"
        case 2: return "Gear"
        case 3: return "Achievements"
        default: return "Unknown"
        }
    }
    
    // MARK: - Character Overview View
    
    private var characterOverviewView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let character = characterManager.currentCharacter {
                    // Personality traits
                    personalityTraitsView(character.personalityTraits)
                    
                    // Climbing style
                    climbingStyleView(character.climbingStyle)
                    
                    // Quick actions
                    quickActionsView
                    
                    // Recent achievements
                    recentAchievementsView(character.achievements)
                }
            }
            .padding()
        }
    }
    
    private func personalityTraitsView(_ traits: PersonalityTraits) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personality Traits")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                TraitCard(title: "Risk Tolerance", value: traits.riskTolerance.rawValue, color: .red)
                TraitCard(title: "Social Preference", value: traits.socialPreference.rawValue, color: .blue)
                TraitCard(title: "Decision Style", value: traits.decisionStyle.rawValue, color: .purple)
                TraitCard(title: "Motivation", value: traits.motivationType.rawValue, color: .green)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func climbingStyleView(_ style: ClimbingStyle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Climbing Style")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: style.icon)
                    .font(.title2)
                    .foregroundColor(style.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(style.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(style.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var quickActionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                Button(action: {
                    characterManager.rest()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "moon.zzz.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Rest")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    characterManager.train()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "dumbbell.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Train")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.8))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func recentAchievementsView(_ achievements: [Achievement]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Achievements")
                .font(.headline)
                .foregroundColor(.white)
            
            if achievements.isEmpty {
                Text("No achievements yet")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(achievements.suffix(3)) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Skills View
    
    private var skillsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let character = characterManager.currentCharacter {
                    LazyVStack(spacing: 16) {
                        ForEach([CharacterSkills.SkillType.survival, .climbing, .leadership, .endurance], id: \.self) { skillType in
                            SkillTreeCard(
                                skillTree: getSkillTree(for: skillType, from: character.skills),
                                characterManager: characterManager
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func getSkillTree(for type: CharacterSkills.SkillType, from skills: CharacterSkills) -> SkillTree {
        switch type {
        case .survival: return skills.survival
        case .climbing: return skills.climbing
        case .leadership: return skills.leadership
        case .endurance: return skills.endurance
        }
    }
    
    // MARK: - Gear View
    
    private var gearView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let character = characterManager.currentCharacter {
                    // Equipped gear
                    equippedGearView(character.equippedGear)
                    
                    // Available gear
                    availableGearView
                }
            }
            .padding()
        }
    }
    
    private func equippedGearView(_ equippedGear: EquippedGear) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Equipped Gear")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(equippedGear.allEquippedItems) { item in
                    GearCard(gear: item, isEquipped: true) {
                        selectedGear = item
                        showGearDetail = true
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var availableGearView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Gear")
                .font(.headline)
                .foregroundColor(.white)
            
            if characterManager.availableGear.isEmpty {
                Text("No available gear")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(characterManager.availableGear) { item in
                        GearCard(gear: item, isEquipped: false) {
                            selectedGear = item
                            showGearDetail = true
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Achievements View
    
    private var achievementsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let character = characterManager.currentCharacter {
                    if character.achievements.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "trophy")
                                .font(.system(size: 60))
                                .foregroundColor(.orange.opacity(0.6))
                            
                            Text("No Achievements Yet")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Complete challenges and climb mountains to unlock achievements")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(character.achievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views

struct CharacterAvatarView: View {
    let avatar: CharacterAvatar
    
    var body: some View {
        ZStack {
            Circle()
                .fill(avatar.skinTone.color)
                .frame(width: 60, height: 60)
            
            // Hair
            Circle()
                .fill(avatar.hairColor.color)
                .frame(width: 50, height: 50)
                .offset(y: -5)
            
            // Eyes
            HStack(spacing: 8) {
                Circle()
                    .fill(avatar.eyeColor.color)
                    .frame(width: 8, height: 8)
                
                Circle()
                    .fill(avatar.eyeColor.color)
                    .frame(width: 8, height: 8)
            }
            .offset(y: -2)
        }
    }
}

struct StatView: View {
    let title: String
    let value: Int
    let maxValue: Int?
    let color: Color
    
    init(title: String, value: Int, maxValue: Int? = nil, color: Color) {
        self.title = title
        self.value = value
        self.color = color
        self.maxValue = maxValue
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if let maxValue = maxValue {
                ProgressView(value: Double(value), total: Double(maxValue))
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                Text("\(value)/\(maxValue)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            } else {
                Text("\(value)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct TraitCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct SkillTreeCard: View {
    let skillTree: SkillTree
    let characterManager: CharacterManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: skillTree.type.icon)
                    .font(.title2)
                    .foregroundColor(skillTree.type.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(skillTree.type.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(skillTree.type.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text("\(skillTree.totalPointsInvested) pts")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(skillTree.skills.prefix(6)) { skill in
                    SkillCard(skill: skill, skillTree: skillTree, characterManager: characterManager)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct SkillCard: View {
    let skill: Skill
    let skillTree: SkillTree
    let characterManager: CharacterManager
    
    var body: some View {
        VStack(spacing: 8) {
            // Skill icon and level
            ZStack {
                Circle()
                    .fill(skill.level > 0 ? Color.orange : Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                if skill.level > 0 {
                    Text("\(skill.level)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            VStack(spacing: 2) {
                Text(skill.name)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                if skill.level < skill.maxLevel {
                    Text("\(skill.totalCost) pts")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
        .onTapGesture {
            if skill.canUpgrade && characterManager.currentCharacter?.skillPoints ?? 0 >= skill.totalCost {
                characterManager.upgradeSkill(skill.id, in: skillTree.type)
            }
        }
    }
}

struct GearCard: View {
    let gear: GearItem
    let isEquipped: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Gear icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(gear.rarity.color.opacity(0.2))
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(gear.rarity.borderColor, lineWidth: 2)
                    )
                
                Image(systemName: gear.category.icon)
                    .font(.title2)
                    .foregroundColor(gear.rarity.color)
            }
            
            VStack(spacing: 4) {
                Text(gear.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(gear.rarity.rawValue)
                    .font(.caption2)
                    .foregroundColor(gear.rarity.color)
                
                if isEquipped {
                    Text("EQUIPPED")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .onTapGesture {
            onTap()
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            // Achievement icon
            ZStack {
                Circle()
                    .fill(achievement.rarity.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.category.icon)
                    .font(.title3)
                    .foregroundColor(achievement.rarity.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                
                if let unlockedAt = achievement.unlockedAt {
                    Text(unlockedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.rarity.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(Color.orange)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(Color.blue.opacity(0.8))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Detail Views

struct GearDetailView: View {
    let gear: GearItem
    let characterManager: CharacterManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Gear header
                    gearHeaderView
                    
                    // Stats
                    gearStatsView
                    
                    // Special effects
                    if !gear.specialEffects.isEmpty {
                        specialEffectsView
                    }
                    
                    // Actions
                    gearActionsView
                }
                .padding()
            }
            .navigationTitle(gear.name)
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
    
    private var gearHeaderView: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(gear.rarity.color.opacity(0.2))
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(gear.rarity.borderColor, lineWidth: 3)
                    )
                
                Image(systemName: gear.category.icon)
                    .font(.system(size: 50))
                    .foregroundColor(gear.rarity.color)
            }
            
            VStack(spacing: 8) {
                Text(gear.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(gear.rarity.rawValue)
                    .font(.subheadline)
                    .foregroundColor(gear.rarity.color)
                
                Text(gear.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var gearStatsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                if gear.stats.strength > 0 {
                    StatItem(title: "Strength", value: gear.stats.strength, color: .red)
                }
                if gear.stats.agility > 0 {
                    StatItem(title: "Agility", value: gear.stats.agility, color: .blue)
                }
                if gear.stats.intelligence > 0 {
                    StatItem(title: "Intelligence", value: gear.stats.intelligence, color: .purple)
                }
                if gear.stats.charisma > 0 {
                    StatItem(title: "Charisma", value: gear.stats.charisma, color: .green)
                }
                if gear.stats.survival > 0 {
                    StatItem(title: "Survival", value: gear.stats.survival, color: .orange)
                }
                if gear.stats.climbing > 0 {
                    StatItem(title: "Climbing", value: gear.stats.climbing, color: .cyan)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var specialEffectsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Special Effects")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVStack(spacing: 8) {
                ForEach(gear.specialEffects) { effect in
                    HStack(spacing: 12) {
                        Image(systemName: effect.effectType.icon)
                            .font(.title3)
                            .foregroundColor(effect.effectType.color)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(effect.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text(effect.description)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var gearActionsView: some View {
        VStack(spacing: 12) {
            if gear.isEquippable {
                Button(action: {
                    characterManager.equipGear(gear)
                }) {
                    Text("Equip")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
            }
            
            if gear.needsRepair {
                Button(action: {
                    characterManager.repairGear(gear)
                }) {
                    Text("Repair")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
        }
    }
}

struct StatItem: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SkillDetailView: View {
    let skillTree: CharacterSkills.SkillType
    let characterManager: CharacterManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Skill tree header
                    skillTreeHeaderView
                    
                    // All skills
                    allSkillsView
                }
                .padding()
            }
            .navigationTitle(skillTree.rawValue)
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
    
    private var skillTreeHeaderView: some View {
        VStack(spacing: 16) {
            Image(systemName: skillTree.icon)
                .font(.system(size: 50))
                .foregroundColor(skillTree.color)
            
            Text(skillTree.rawValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(skillTree.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var allSkillsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Skills")
                .font(.headline)
                .foregroundColor(.white)
            
            if let character = characterManager.currentCharacter {
                let skillTree = getSkillTree(for: skillTree, from: character.skills)
                
                LazyVStack(spacing: 12) {
                    ForEach(skillTree.skills) { skill in
                        SkillDetailCard(skill: skill, skillTree: skillTree, characterManager: characterManager)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func getSkillTree(for type: CharacterSkills.SkillType, from skills: CharacterSkills) -> SkillTree {
        switch type {
        case .survival: return skills.survival
        case .climbing: return skills.climbing
        case .leadership: return skills.leadership
        case .endurance: return skills.endurance
        }
    }
}

struct SkillDetailCard: View {
    let skill: Skill
    let skillTree: SkillTree
    let characterManager: CharacterManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(skill.level > 0 ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                    
                    if skill.level > 0 {
                        Text("\(skill.level)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(skill.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(skill.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("\(skill.level)/\(skill.maxLevel)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if skill.canUpgrade {
                        Text("\(skill.totalCost) pts")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            // Prerequisites
            if !skill.prerequisites.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prerequisites:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.7))
                    
                    ForEach(skill.prerequisites, id: \.self) { prerequisite in
                        Text("• \(prerequisite)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            // Upgrade button
            if skill.canUpgrade && characterManager.currentCharacter?.skillPoints ?? 0 >= skill.totalCost {
                Button(action: {
                    characterManager.upgradeSkill(skill.id, in: skillTree.type)
                }) {
                    Text("Upgrade")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    CharacterView()
        .environmentObject(CharacterManager())
        .background(Color.black)
}
