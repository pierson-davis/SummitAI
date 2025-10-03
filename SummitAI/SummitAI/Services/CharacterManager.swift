import Foundation
import Combine
import SwiftUI

// MARK: - Character Manager

class CharacterManager: ObservableObject {
    @Published var currentCharacter: Character?
    @Published var availableGear: [GearItem] = []
    @Published var characterCreationInProgress = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let currentCharacterKey = "current_character"
    private let availableGearKey = "available_gear"
    
    init() {
        print("CharacterManager: Initializing CharacterManager")
        loadCharacterData()
        loadAvailableGear()
        generateInitialGear()
        print("CharacterManager: Initialization complete - currentCharacter: \(currentCharacter != nil)")
    }
    
    // MARK: - Character Creation
    
    func createCharacter(name: String, avatar: CharacterAvatar) {
        characterCreationInProgress = true
        isLoading = true
        
        // Simulate character creation process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let newCharacter = Character(name: name, avatar: avatar)
            self.currentCharacter = newCharacter
            self.saveCharacterData()
            self.characterCreationInProgress = false
            self.isLoading = false
        }
    }
    
    func deleteCharacter() {
        currentCharacter = nil
        userDefaults.removeObject(forKey: currentCharacterKey)
    }
    
    // MARK: - Experience and Leveling
    
    func addExperience(_ amount: Int, source: ExperienceSource) {
        guard var character = currentCharacter else { return }
        
        // Apply gear experience bonuses
        let gearBonus = character.equippedGear.totalStats.experienceBonus
        let totalExperience = Int(Double(amount) * (1.0 + gearBonus))
        
        character.addExperience(totalExperience)
        
        // Check for achievements
        checkExperienceAchievements(character.experience, character.level)
        
        currentCharacter = character
        saveCharacterData()
    }
    
    private func checkExperienceAchievements(_ experience: Int, _ level: Int) {
        // Check for experience milestones
        if experience >= 1000 && !hasAchievement("first_thousand") {
            unlockAchievement("First Thousand", "Gained 1,000 experience points")
        }
        
        if experience >= 10000 && !hasAchievement("ten_thousand") {
            unlockAchievement("Experience Master", "Gained 10,000 experience points")
        }
        
        if level >= 10 && !hasAchievement("level_ten") {
            unlockAchievement("Decade Climber", "Reached level 10")
        }
        
        if level >= 25 && !hasAchievement("level_twenty_five") {
            unlockAchievement("Quarter Century", "Reached level 25")
        }
    }
    
    enum ExperienceSource: String, CaseIterable {
        case climbing = "Climbing"
        case survival = "Survival"
        case exploration = "Exploration"
        case achievement = "Achievement"
        case challenge = "Challenge"
        case teamWork = "Team Work"
        
        var multiplier: Double {
            switch self {
            case .climbing: return 1.0
            case .survival: return 1.2
            case .exploration: return 1.5
            case .achievement: return 2.0
            case .challenge: return 1.8
            case .teamWork: return 1.3
            }
        }
    }
    
    // MARK: - Skill System
    
    func upgradeSkill(_ skillId: UUID, in skillTree: CharacterSkills.SkillType) -> Bool {
        guard var character = currentCharacter else { return false }
        
        let skillTree = getSkillTree(for: skillTree, from: character.skills)
        
        guard let skillIndex = skillTree.skills.firstIndex(where: { $0.id == skillId }) else { return false }
        let skill = skillTree.skills[skillIndex]
        
        // Check if skill can be upgraded
        guard skill.canUpgrade && character.skillPoints >= skill.totalCost else { return false }
        
        // Check prerequisites
        guard checkPrerequisites(for: skill, in: skillTree) else { return false }
        
        // Upgrade the skill
        var updatedSkills = skillTree.skills
        updatedSkills[skillIndex].level += 1
        
        // Update character
        character.skillPoints -= skill.totalCost
        
        switch skillTree.type {
        case .survival:
            character.skills.survival.skills = updatedSkills
        case .climbing:
            character.skills.climbing.skills = updatedSkills
        case .leadership:
            character.skills.leadership.skills = updatedSkills
        case .endurance:
            character.skills.endurance.skills = updatedSkills
        }
        
        currentCharacter = character
        saveCharacterData()
        
        // Check for skill achievements
        checkSkillAchievements(skill.name, skill.level)
        
        return true
    }
    
    private func getSkillTree(for type: CharacterSkills.SkillType, from skills: CharacterSkills) -> SkillTree {
        switch type {
        case .survival: return skills.survival
        case .climbing: return skills.climbing
        case .leadership: return skills.leadership
        case .endurance: return skills.endurance
        }
    }
    
    private func checkPrerequisites(for skill: Skill, in skillTree: SkillTree) -> Bool {
        for prerequisite in skill.prerequisites {
            guard let prereqSkill = skillTree.skills.first(where: { $0.name == prerequisite }) else { continue }
            if prereqSkill.level < 1 {
                return false
            }
        }
        return true
    }
    
    private func checkSkillAchievements(_ skillName: String, _ level: Int) {
        if level >= 5 && !hasAchievement("skill_master_\(skillName.lowercased())") {
            unlockAchievement("\(skillName) Master", "Mastered \(skillName) skill")
        }
    }
    
    // MARK: - Gear System
    
    func equipGear(_ item: GearItem) -> GearItem? {
        guard var character = currentCharacter else { return nil }
        
        // Check if character meets level requirement
        guard character.level >= item.unlockLevel else { return nil }
        
        // Equip the gear
        let unequippedItem = character.equippedGear.equip(item)
        
        // Remove from available gear
        if let index = availableGear.firstIndex(where: { $0.id == item.id }) {
            availableGear.remove(at: index)
        }
        
        currentCharacter = character
        saveCharacterData()
        
        // Check for gear achievements
        checkGearAchievements(item)
        
        return unequippedItem
    }
    
    func unequipGear(_ item: GearItem) -> Bool {
        guard var character = currentCharacter else { return false }
        
        let success = character.equippedGear.unequip(item)
        
        if success {
            // Add back to available gear
            availableGear.append(item)
            
            currentCharacter = character
            saveCharacterData()
        }
        
        return success
    }
    
    func acquireGear(_ item: GearItem) {
        availableGear.append(item)
        saveAvailableGear()
        
        // Check for gear collection achievements
        checkGearCollectionAchievements()
    }
    
    func repairGear(_ item: GearItem) -> Bool {
        guard var character = currentCharacter else { return false }
        
        // Find the gear in equipped items
        if let equippedItem = character.equippedGear.allEquippedItems.first(where: { $0.id == item.id }) {
            // Repair logic would go here
            // For now, we'll just simulate repair
            return true
        }
        
        return false
    }
    
    private func generateInitialGear() {
        if availableGear.isEmpty {
            // Give starting gear
            let startingGear = [
                GearItem.basicHelmet,
                GearItem.basicJacket,
                GearItem.basicBoots
            ]
            
            availableGear = startingGear
            saveAvailableGear()
        }
    }
    
    private func checkGearAchievements(_ item: GearItem) {
        switch item.rarity {
        case .rare:
            if !hasAchievement("rare_gear_owner") {
                unlockAchievement("Rare Collector", "Equipped your first rare item")
            }
        case .epic:
            if !hasAchievement("epic_gear_owner") {
                unlockAchievement("Epic Collector", "Equipped your first epic item")
            }
        case .legendary:
            if !hasAchievement("legendary_gear_owner") {
                unlockAchievement("Legendary Collector", "Equipped your first legendary item")
            }
        default:
            break
        }
    }
    
    private func checkGearCollectionAchievements() {
        let totalGear = availableGear.count + (currentCharacter?.equippedGear.allEquippedItems.count ?? 0)
        
        if totalGear >= 10 && !hasAchievement("gear_collector_10") {
            unlockAchievement("Gear Collector", "Collected 10 pieces of gear")
        }
        
        if totalGear >= 25 && !hasAchievement("gear_collector_25") {
            unlockAchievement("Gear Hoarder", "Collected 25 pieces of gear")
        }
    }
    
    // MARK: - Achievement System
    
    func unlockAchievement(_ name: String, _ description: String) {
        guard var character = currentCharacter else { return }
        
        let achievement = Achievement(
            id: UUID(),
            name: name,
            description: description,
            category: .climbing,
            rarity: .common,
            reward: Achievement.AchievementReward(experience: 100, skillPoints: 1),
            unlockedAt: Date(),
            progress: 1,
            maxProgress: 1
        )
        
        character.achievements.append(achievement)
        
        // Apply reward
        character.experience += achievement.reward.experience
        character.skillPoints += achievement.reward.skillPoints
        
        currentCharacter = character
        saveCharacterData()
        
        // Show achievement notification
        showAchievementNotification(achievement)
    }
    
    private func hasAchievement(_ identifier: String) -> Bool {
        guard let character = currentCharacter else { return false }
        return character.achievements.contains { achievement in
            achievement.name.lowercased().replacingOccurrences(of: " ", with: "_") == identifier
        }
    }
    
    private func showAchievementNotification(_ achievement: Achievement) {
        // This would typically show a notification or alert
        print("Achievement Unlocked: \(achievement.name) - \(achievement.description)")
    }
    
    // MARK: - Character Stats
    
    func getTotalStats() -> CharacterStats {
        guard let character = currentCharacter else { return CharacterStats() }
        
        var totalStats = character.stats
        let gearStats = character.equippedGear.totalStats
        
        // Add gear bonuses to base stats
        totalStats.strength += gearStats.strength
        totalStats.agility += gearStats.agility
        totalStats.intelligence += gearStats.intelligence
        totalStats.charisma += gearStats.charisma
        
        return totalStats
    }
    
    func getEffectiveSkillLevel(_ skillType: CharacterSkills.SkillType) -> Double {
        guard let character = currentCharacter else { return 0.0 }
        
        let skillTree = getSkillTree(for: skillType, from: character.skills)
        let totalSkillLevel = skillTree.skills.reduce(0) { $0 + $1.level }
        
        // Apply gear bonuses
        let gearBonus = character.equippedGear.totalStats
        
        switch skillType {
        case .survival:
            return Double(totalSkillLevel) + Double(gearBonus.survival) * 0.1
        case .climbing:
            return Double(totalSkillLevel) + Double(gearBonus.climbing) * 0.1
        case .leadership:
            return Double(totalSkillLevel) + Double(gearBonus.charisma) * 0.1
        case .endurance:
            return Double(totalSkillLevel) + Double(gearBonus.strength + gearBonus.agility) * 0.05
        }
    }
    
    // MARK: - Character Actions
    
    func rest() {
        guard var character = currentCharacter else { return }
        
        // Restore health and stamina
        character.stats.currentHealth = min(character.stats.maxHealth, character.stats.currentHealth + 20)
        character.stats.currentStamina = min(character.stats.maxStamina, character.stats.currentStamina + 30)
        
        currentCharacter = character
        saveCharacterData()
        
        // Gain some experience for resting
        addExperience(10, source: .survival)
    }
    
    func train() {
        guard var character = currentCharacter else { return }
        
        // Training costs stamina but gives experience
        character.stats.currentStamina = max(0, character.stats.currentStamina - 20)
        
        currentCharacter = character
        saveCharacterData()
        
        // Gain experience for training
        addExperience(25, source: .climbing)
    }
    
    // MARK: - Data Persistence
    
    private func saveCharacterData() {
        guard let character = currentCharacter else {
            userDefaults.removeObject(forKey: currentCharacterKey)
            return
        }
        
        do {
            let data = try JSONEncoder().encode(character)
            userDefaults.set(data, forKey: currentCharacterKey)
        } catch {
            print("Failed to save character data: \(error)")
        }
    }
    
    private func loadCharacterData() {
        if let data = userDefaults.data(forKey: currentCharacterKey) {
            do {
                currentCharacter = try JSONDecoder().decode(Character.self, from: data)
            } catch {
                print("Failed to load character data: \(error)")
            }
        }
    }
    
    private func saveAvailableGear() {
        do {
            let data = try JSONEncoder().encode(availableGear)
            userDefaults.set(data, forKey: availableGearKey)
        } catch {
            print("Failed to save available gear: \(error)")
        }
    }
    
    private func loadAvailableGear() {
        if let data = userDefaults.data(forKey: availableGearKey) {
            do {
                availableGear = try JSONDecoder().decode([GearItem].self, from: data)
            } catch {
                print("Failed to load available gear: \(error)")
            }
        }
    }
    
    // MARK: - Mock Data for Development
    
    func createMockCharacter() {
        let avatar = CharacterAvatar(
            skinTone: .medium,
            hairColor: .brown,
            eyeColor: .blue,
            facialFeatures: .clean,
            clothing: .athletic
        )
        
        createCharacter(name: "Test Climber", avatar: avatar)
    }
    
    func addMockGear() {
        let mockGear = [
            GearItem.insulatedJacket,
            GearItem.technicalBoots,
            GearItem.expeditionJacket,
            GearItem.advancedHelmet
        ]
        
        for item in mockGear {
            acquireGear(item)
        }
    }
}
