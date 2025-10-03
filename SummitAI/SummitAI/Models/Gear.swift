import Foundation
import SwiftUI

// MARK: - Gear Item Model

struct GearItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let category: GearCategory
    let rarity: GearRarity
    let stats: GearStats
    var durability: Int
    let maxDurability: Int
    let weight: Double // in kg
    let value: Int // in-game currency
    let imageName: String
    let unlockLevel: Int
    let isEquippable: Bool
    let specialEffects: [GearSpecialEffect]
    
    init(name: String, description: String, category: GearCategory, rarity: GearRarity, stats: GearStats, durability: Int, maxDurability: Int, weight: Double, value: Int, imageName: String, unlockLevel: Int, isEquippable: Bool, specialEffects: [GearSpecialEffect] = []) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.category = category
        self.rarity = rarity
        self.stats = stats
        self.durability = durability
        self.maxDurability = maxDurability
        self.weight = weight
        self.value = value
        self.imageName = imageName
        self.unlockLevel = unlockLevel
        self.isEquippable = isEquippable
        self.specialEffects = specialEffects
    }
    
    var durabilityPercentage: Double {
        return Double(durability) / Double(maxDurability)
    }
    
    var isBroken: Bool {
        return durability <= 0
    }
    
    var needsRepair: Bool {
        return durabilityPercentage < 0.5
    }
    
    var totalStatBonus: Int {
        return stats.strength + stats.agility + stats.intelligence + stats.charisma + stats.survival + stats.climbing
    }
}

// MARK: - Gear Category

enum GearCategory: String, CaseIterable, Codable {
    case clothing = "Clothing"
    case climbing = "Climbing"
    case safety = "Safety"
    case navigation = "Navigation"
    case camping = "Camping"
    case medical = "Medical"
    case tools = "Tools"
    case consumables = "Consumables"
    
    var icon: String {
        switch self {
        case .clothing: return "tshirt.fill"
        case .climbing: return "figure.climbing"
        case .safety: return "shield.fill"
        case .navigation: return "map.fill"
        case .camping: return "tent.fill"
        case .medical: return "cross.fill"
        case .tools: return "wrench.fill"
        case .consumables: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .clothing: return .blue
        case .climbing: return .orange
        case .safety: return .red
        case .navigation: return .purple
        case .camping: return .green
        case .medical: return .pink
        case .tools: return .gray
        case .consumables: return .yellow
        }
    }
}

// MARK: - Gear Rarity

enum GearRarity: String, CaseIterable, Codable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    var borderColor: Color {
        switch self {
        case .common: return .gray.opacity(0.3)
        case .uncommon: return .green.opacity(0.5)
        case .rare: return .blue.opacity(0.7)
        case .epic: return .purple.opacity(0.8)
        case .legendary: return .orange.opacity(0.9)
        }
    }
    
    var glowColor: Color {
        switch self {
        case .common: return .clear
        case .uncommon: return .green.opacity(0.2)
        case .rare: return .blue.opacity(0.3)
        case .epic: return .purple.opacity(0.4)
        case .legendary: return .orange.opacity(0.5)
        }
    }
    
    var dropChance: Double {
        switch self {
        case .common: return 0.6
        case .uncommon: return 0.25
        case .rare: return 0.1
        case .epic: return 0.04
        case .legendary: return 0.01
        }
    }
    
    var statMultiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 1.2
        case .rare: return 1.5
        case .epic: return 2.0
        case .legendary: return 3.0
        }
    }
}

// MARK: - Gear Stats

struct GearStats: Codable {
    var strength: Int
    var agility: Int
    var intelligence: Int
    var charisma: Int
    var survival: Int
    var climbing: Int
    
    // Environmental resistances
    var frostbiteResistance: Int
    var heatResistance: Int
    var windResistance: Int
    var altitudeResistance: Int
    
    // Special bonuses
    var experienceBonus: Double
    var durabilityBonus: Double
    var weightReduction: Double
    
    init(strength: Int = 0, agility: Int = 0, intelligence: Int = 0, charisma: Int = 0, survival: Int = 0, climbing: Int = 0, frostbiteResistance: Int = 0, heatResistance: Int = 0, windResistance: Int = 0, altitudeResistance: Int = 0, experienceBonus: Double = 0.0, durabilityBonus: Double = 0.0, weightReduction: Double = 0.0) {
        self.strength = strength
        self.agility = agility
        self.intelligence = intelligence
        self.charisma = charisma
        self.survival = survival
        self.climbing = climbing
        self.frostbiteResistance = frostbiteResistance
        self.heatResistance = heatResistance
        self.windResistance = windResistance
        self.altitudeResistance = altitudeResistance
        self.experienceBonus = experienceBonus
        self.durabilityBonus = durabilityBonus
        self.weightReduction = weightReduction
    }
    
    var totalCombatStats: Int {
        return strength + agility + intelligence + charisma
    }
    
    var totalSurvivalStats: Int {
        return survival + climbing
    }
    
    var totalResistance: Int {
        return frostbiteResistance + heatResistance + windResistance + altitudeResistance
    }
}

// MARK: - Gear Special Effect

struct GearSpecialEffect: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let effectType: EffectType
    let value: Double
    let duration: TimeInterval?
    let trigger: EffectTrigger
    let condition: EffectCondition?
    
    enum EffectType: String, CaseIterable, Codable {
        case statBoost = "Stat Boost"
        case resistance = "Resistance"
        case experience = "Experience"
        case durability = "Durability"
        case special = "Special"
        
        var icon: String {
            switch self {
            case .statBoost: return "arrow.up.circle.fill"
            case .resistance: return "shield.fill"
            case .experience: return "star.fill"
            case .durability: return "wrench.fill"
            case .special: return "sparkles"
            }
        }
        
        var color: Color {
            switch self {
            case .statBoost: return .blue
            case .resistance: return .green
            case .experience: return .yellow
            case .durability: return .orange
            case .special: return .purple
            }
        }
    }
    
    enum EffectTrigger: String, CaseIterable, Codable {
        case passive = "Passive"
        case onEquip = "On Equip"
        case onUse = "On Use"
        case onCondition = "On Condition"
        case onCombat = "On Combat"
    }
    
    enum EffectCondition: String, CaseIterable, Codable {
        case lowHealth = "Low Health"
        case highAltitude = "High Altitude"
        case extremeWeather = "Extreme Weather"
        case nightTime = "Night Time"
        case teamMember = "Team Member"
    }
}

// MARK: - Equipped Gear

struct EquippedGear: Codable {
    var helmet: GearItem?
    var jacket: GearItem?
    var pants: GearItem?
    var boots: GearItem?
    var gloves: GearItem?
    var backpack: GearItem?
    var climbingGear: GearItem?
    var safetyGear: GearItem?
    var navigationGear: GearItem?
    var medicalGear: GearItem?
    
    var allEquippedItems: [GearItem] {
        return [
            helmet, jacket, pants, boots, gloves,
            backpack, climbingGear, safetyGear, navigationGear, medicalGear
        ].compactMap { $0 }
    }
    
    var totalWeight: Double {
        return allEquippedItems.reduce(0) { $0 + $1.weight }
    }
    
    var totalStats: GearStats {
        let stats = GearStats()
        return allEquippedItems.reduce(stats) { totalStats, item in
            var combined = totalStats
            combined.strength += item.stats.strength
            combined.agility += item.stats.agility
            combined.intelligence += item.stats.intelligence
            combined.charisma += item.stats.charisma
            combined.survival += item.stats.survival
            combined.climbing += item.stats.climbing
            combined.frostbiteResistance += item.stats.frostbiteResistance
            combined.heatResistance += item.stats.heatResistance
            combined.windResistance += item.stats.windResistance
            combined.altitudeResistance += item.stats.altitudeResistance
            combined.experienceBonus += item.stats.experienceBonus
            combined.durabilityBonus += item.stats.durabilityBonus
            combined.weightReduction += item.stats.weightReduction
            return combined
        }
    }
    
    mutating func equip(_ item: GearItem) -> GearItem? {
        let unequippedItem: GearItem?
        
        switch item.category {
        case .clothing:
            switch item.name.lowercased() {
            case let name where name.contains("helmet"):
                unequippedItem = helmet
                helmet = item
            case let name where name.contains("jacket") || name.contains("coat"):
                unequippedItem = jacket
                jacket = item
            case let name where name.contains("pants") || name.contains("trousers"):
                unequippedItem = pants
                pants = item
            case let name where name.contains("boots") || name.contains("shoes"):
                unequippedItem = boots
                boots = item
            case let name where name.contains("gloves"):
                unequippedItem = gloves
                gloves = item
            default:
                unequippedItem = nil
            }
        case .climbing:
            unequippedItem = climbingGear
            climbingGear = item
        case .safety:
            unequippedItem = safetyGear
            safetyGear = item
        case .navigation:
            unequippedItem = navigationGear
            navigationGear = item
        case .medical:
            unequippedItem = medicalGear
            medicalGear = item
        case .camping:
            unequippedItem = backpack
            backpack = item
        default:
            unequippedItem = nil
        }
        
        return unequippedItem
    }
    
    mutating func unequip(_ item: GearItem) -> Bool {
        switch item.category {
        case .clothing:
            switch item.name.lowercased() {
            case let name where name.contains("helmet"):
                if helmet?.id == item.id {
                    helmet = nil
                    return true
                }
            case let name where name.contains("jacket") || name.contains("coat"):
                if jacket?.id == item.id {
                    jacket = nil
                    return true
                }
            case let name where name.contains("pants") || name.contains("trousers"):
                if pants?.id == item.id {
                    pants = nil
                    return true
                }
            case let name where name.contains("boots") || name.contains("shoes"):
                if boots?.id == item.id {
                    boots = nil
                    return true
                }
            case let name where name.contains("gloves"):
                if gloves?.id == item.id {
                    gloves = nil
                    return true
                }
            default:
                break
            }
        case .climbing:
            if climbingGear?.id == item.id {
                climbingGear = nil
                return true
            }
        case .safety:
            if safetyGear?.id == item.id {
                safetyGear = nil
                return true
            }
        case .navigation:
            if navigationGear?.id == item.id {
                navigationGear = nil
                return true
            }
        case .medical:
            if medicalGear?.id == item.id {
                medicalGear = nil
                return true
            }
        case .camping:
            if backpack?.id == item.id {
                backpack = nil
                return true
            }
        default:
            break
        }
        
        return false
    }
}

// MARK: - Predefined Gear Items

extension GearItem {
    // MARK: - Common Gear
    static let basicHelmet = GearItem(
        name: "Basic Climbing Helmet",
        description: "Standard protection for your head",
        category: .clothing,
        rarity: .common,
        stats: GearStats(survival: 2, frostbiteResistance: 1),
        durability: 100,
        maxDurability: 100,
        weight: 0.4,
        value: 50,
        imageName: "helmet_basic",
        unlockLevel: 1,
        isEquippable: true
    )
    
    static let basicJacket = GearItem(
        name: "Basic Climbing Jacket",
        description: "Protects against wind and cold",
        category: .clothing,
        rarity: .common,
        stats: GearStats(survival: 3, windResistance: 2, frostbiteResistance: 2),
        durability: 100,
        maxDurability: 100,
        weight: 0.8,
        value: 75,
        imageName: "jacket_basic",
        unlockLevel: 1,
        isEquippable: true
    )
    
    static let basicBoots = GearItem(
        name: "Basic Climbing Boots",
        description: "Sturdy boots for mountain terrain",
        category: .clothing,
        rarity: .common,
        stats: GearStats(agility: 2, survival: 2),
        durability: 100,
        maxDurability: 100,
        weight: 1.2,
        value: 100,
        imageName: "boots_basic",
        unlockLevel: 1,
        isEquippable: true
    )
    
    // MARK: - Uncommon Gear
    static let insulatedJacket = GearItem(
        name: "Insulated Climbing Jacket",
        description: "Advanced protection against extreme cold",
        category: .clothing,
        rarity: .uncommon,
        stats: GearStats(survival: 5, windResistance: 4, frostbiteResistance: 5),
        durability: 120,
        maxDurability: 120,
        weight: 1.0,
        value: 200,
        imageName: "jacket_insulated",
        unlockLevel: 5,
        isEquippable: true
    )
    
    static let technicalBoots = GearItem(
        name: "Technical Climbing Boots",
        description: "Precision boots for technical climbing",
        category: .clothing,
        rarity: .uncommon,
        stats: GearStats(agility: 4, climbing: 3, survival: 2),
        durability: 120,
        maxDurability: 120,
        weight: 1.4,
        value: 250,
        imageName: "boots_technical",
        unlockLevel: 8,
        isEquippable: true
    )
    
    // MARK: - Rare Gear
    static let expeditionJacket = GearItem(
        name: "Expedition Jacket",
        description: "Professional-grade jacket for extreme conditions",
        category: .clothing,
        rarity: .rare,
        stats: GearStats(survival: 8, windResistance: 6, frostbiteResistance: 8, altitudeResistance: 3),
        durability: 150,
        maxDurability: 150,
        weight: 1.2,
        value: 500,
        imageName: "jacket_expedition",
        unlockLevel: 12,
        isEquippable: true,
        specialEffects: [
            GearSpecialEffect(
                id: UUID(),
                name: "Cold Resistance",
                description: "Reduces frostbite risk by 25%",
                effectType: .resistance,
                value: 25.0,
                duration: nil,
                trigger: .passive,
                condition: nil
            )
        ]
    )
    
    static let advancedHelmet = GearItem(
        name: "Advanced Safety Helmet",
        description: "High-tech helmet with built-in communication",
        category: .clothing,
        rarity: .rare,
        stats: GearStats(intelligence: 3, survival: 4, climbing: 2),
        durability: 150,
        maxDurability: 150,
        weight: 0.6,
        value: 400,
        imageName: "helmet_advanced",
        unlockLevel: 10,
        isEquippable: true,
        specialEffects: [
            GearSpecialEffect(
                id: UUID(),
                name: "Communication Boost",
                description: "Improves team coordination",
                effectType: .statBoost,
                value: 15.0,
                duration: nil,
                trigger: .passive,
                condition: .teamMember
            )
        ]
    )
    
    // MARK: - Epic Gear
    static let legendaryJacket = GearItem(
        name: "Legendary Summit Jacket",
        description: "The ultimate protection for extreme altitude",
        category: .clothing,
        rarity: .epic,
        stats: GearStats(survival: 12, windResistance: 10, frostbiteResistance: 12, altitudeResistance: 8, experienceBonus: 0.15),
        durability: 200,
        maxDurability: 200,
        weight: 1.5,
        value: 1000,
        imageName: "jacket_legendary",
        unlockLevel: 20,
        isEquippable: true,
        specialEffects: [
            GearSpecialEffect(
                id: UUID(),
                name: "Summit Protection",
                description: "Immune to frostbite above 6000m",
                effectType: .special,
                value: 100.0,
                duration: nil,
                trigger: .onCondition,
                condition: .highAltitude
            ),
            GearSpecialEffect(
                id: UUID(),
                name: "Experience Boost",
                description: "Gain 15% more experience",
                effectType: .experience,
                value: 15.0,
                duration: nil,
                trigger: .passive,
                condition: nil
            )
        ]
    )
    
    // MARK: - Legendary Gear
    static let ultimateGear = GearItem(
        name: "Ultimate Climber's Set",
        description: "The most powerful gear in existence",
        category: .clothing,
        rarity: .legendary,
        stats: GearStats(strength: 10, agility: 10, intelligence: 10, charisma: 10, survival: 15, climbing: 15, frostbiteResistance: 15, heatResistance: 15, windResistance: 15, altitudeResistance: 15, experienceBonus: 0.25, durabilityBonus: 0.5),
        durability: 300,
        maxDurability: 300,
        weight: 2.0,
        value: 5000,
        imageName: "gear_ultimate",
        unlockLevel: 30,
        isEquippable: true,
        specialEffects: [
            GearSpecialEffect(
                id: UUID(),
                name: "Ultimate Protection",
                description: "Immune to all environmental damage",
                effectType: .special,
                value: 100.0,
                duration: nil,
                trigger: .passive,
                condition: nil
            ),
            GearSpecialEffect(
                id: UUID(),
                name: "Master Climber",
                description: "All climbing skills work as if maxed",
                effectType: .special,
                value: 100.0,
                duration: nil,
                trigger: .passive,
                condition: nil
            ),
            GearSpecialEffect(
                id: UUID(),
                name: "Experience Mastery",
                description: "Gain 25% more experience and skill points",
                effectType: .experience,
                value: 25.0,
                duration: nil,
                trigger: .passive,
                condition: nil
            )
        ]
    )
    
    // MARK: - All Gear Items
    static let allGearItems: [GearItem] = [
        .basicHelmet, .basicJacket, .basicBoots,
        .insulatedJacket, .technicalBoots,
        .expeditionJacket, .advancedHelmet,
        .legendaryJacket, .ultimateGear
    ]
}
