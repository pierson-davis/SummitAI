import Foundation
import SwiftUI

// MARK: - Mountain Experiences Data Models
// Step 5: Search & Filter Functionality

// MARK: - Trip Model

struct Trip: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let category: TripCategory
    let durationDays: Int
    let difficulty: TripDifficulty
    let coverImageURL: String
    let locationId: String
    let description: String
    let price: Double?
    let rating: Double?
    let isBookmarked: Bool
    let tags: [String]
    let highlights: [String]
    let requirements: [String]
    let inclusions: [String]
    let exclusions: [String]
    
    init(
        id: UUID = UUID(),
        title: String,
        category: TripCategory,
        durationDays: Int,
        difficulty: TripDifficulty,
        coverImageURL: String,
        locationId: String,
        description: String,
        price: Double? = nil,
        rating: Double? = nil,
        isBookmarked: Bool = false,
        tags: [String] = [],
        highlights: [String] = [],
        requirements: [String] = [],
        inclusions: [String] = [],
        exclusions: [String] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.durationDays = durationDays
        self.difficulty = difficulty
        self.coverImageURL = coverImageURL
        self.locationId = locationId
        self.description = description
        self.price = price
        self.rating = rating
        self.isBookmarked = isBookmarked
        self.tags = tags
        self.highlights = highlights
        self.requirements = requirements
        self.inclusions = inclusions
        self.exclusions = exclusions
    }
}

// MARK: - Trip Category

enum TripCategory: String, CaseIterable, Codable {
    case peaks = "Peaks"
    case hiking = "Hiking"
    case climbing = "Climbing"
    case guides = "Guides"
    
    var icon: String {
        switch self {
        case .peaks: return "mountain.2.fill"
        case .hiking: return "figure.walk"
        case .climbing: return "figure.climbing"
        case .guides: return "person.2.fill"
        }
    }
    
    var description: String {
        switch self {
        case .peaks: return "Mountain peak expeditions"
        case .hiking: return "Scenic hiking adventures"
        case .climbing: return "Technical climbing routes"
        case .guides: return "Professional mountain guides"
        }
    }
}

// MARK: - Trip Difficulty

enum TripDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case moderate = "Moderate"
    case hard = "Hard"
    
    var icon: String {
        switch self {
        case .easy: return "person.walk"
        case .moderate: return "figure.walk"
        case .hard: return "figure.climbing"
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .moderate: return .orange
        case .hard: return .red
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "Suitable for beginners"
        case .moderate: return "Some experience recommended"
        case .hard: return "Advanced skills required"
        }
    }
}

// MARK: - Location Model

struct Location: Identifiable, Codable {
    let id: String
    let name: String
    let country: String
    let flagCode: String
    let coverImageURL: String
    let summary: String
    let description: String
    let trips: [Trip]
    let coordinates: Coordinates
    let timeZone: String
    let bestTimeToVisit: String
    let currency: String
    let language: String
    
    init(
        id: String,
        name: String,
        country: String,
        flagCode: String,
        coverImageURL: String,
        summary: String,
        description: String,
        trips: [Trip] = [],
        coordinates: Coordinates,
        timeZone: String,
        bestTimeToVisit: String,
        currency: String,
        language: String
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.flagCode = flagCode
        self.coverImageURL = coverImageURL
        self.summary = summary
        self.description = description
        self.trips = trips
        self.coordinates = coordinates
        self.timeZone = timeZone
        self.bestTimeToVisit = bestTimeToVisit
        self.currency = currency
        self.language = language
    }
}

// MARK: - Coordinates

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Sample Data

extension Trip {
    static let sampleTrips: [Trip] = [
        Trip(
            title: "Everest Base Camp Trek",
            category: .hiking,
            durationDays: 14,
            difficulty: .hard,
            coverImageURL: "https://images.unsplash.com/photo-1519904981063-b0cf448d479e",
            locationId: "nepal",
            description: "Classic trek to the base of the world's highest mountain",
            price: 2500,
            rating: 4.8,
            isBookmarked: false,
            tags: ["Everest", "Base Camp", "Trekking", "Himalayas"],
            highlights: ["Everest Base Camp", "Kala Patthar", "Namche Bazaar", "Tengboche Monastery"],
            requirements: ["Good physical fitness", "Trekking experience", "Altitude training"],
            inclusions: ["Guide", "Porter", "Accommodation", "Meals"],
            exclusions: ["International flights", "Travel insurance", "Personal equipment"]
        ),
        Trip(
            title: "Annapurna Circuit",
            category: .hiking,
            durationDays: 21,
            difficulty: .moderate,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "nepal",
            description: "Diverse landscapes and cultural experiences",
            price: 1800,
            rating: 4.6,
            isBookmarked: true,
            tags: ["Annapurna", "Circuit", "Trekking", "Nepal"],
            highlights: ["Thorong La Pass", "Manang Valley", "Muktinath", "Poon Hill"],
            requirements: ["Moderate fitness", "Trekking experience"],
            inclusions: ["Guide", "Accommodation", "Meals", "Permits"],
            exclusions: ["International flights", "Travel insurance", "Personal equipment"]
        ),
        Trip(
            title: "Kilimanjaro Summit",
            category: .climbing,
            durationDays: 8,
            difficulty: .moderate,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "tanzania",
            description: "Africa's highest peak adventure",
            price: 3200,
            rating: 4.9,
            isBookmarked: false,
            tags: ["Kilimanjaro", "Summit", "Africa", "Tanzania"],
            highlights: ["Uhuru Peak", "Lava Tower", "Barranco Wall", "Stella Point"],
            requirements: ["Good physical fitness", "Altitude experience"],
            inclusions: ["Guide", "Cook", "Porters", "Equipment", "Meals"],
            exclusions: ["International flights", "Travel insurance", "Personal gear"]
        ),
        Trip(
            title: "Mont Blanc Ascent",
            category: .climbing,
            durationDays: 5,
            difficulty: .hard,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "france",
            description: "Western Europe's highest peak",
            price: 1800,
            rating: 4.7,
            isBookmarked: false,
            tags: ["Mont Blanc", "Alps", "France", "Climbing"],
            highlights: ["Mont Blanc Summit", "Aiguille du Midi", "Valley Blanche", "Chamonix"],
            requirements: ["Advanced climbing skills", "Ice climbing experience", "Good fitness"],
            inclusions: ["Guide", "Equipment", "Accommodation", "Meals"],
            exclusions: ["International flights", "Travel insurance", "Personal gear"]
        ),
        Trip(
            title: "Mount Fuji Climb",
            category: .hiking,
            durationDays: 2,
            difficulty: .moderate,
            coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            locationId: "japan",
            description: "Japan's iconic mountain climb",
            price: 800,
            rating: 4.5,
            isBookmarked: false,
            tags: ["Fuji", "Japan", "Hiking", "Volcano"],
            highlights: ["Fuji Summit", "Sunrise view", "Volcanic landscape", "Traditional culture"],
            requirements: ["Good fitness", "Hiking experience"],
            inclusions: ["Guide", "Accommodation", "Meals", "Equipment"],
            exclusions: ["International flights", "Travel insurance", "Personal gear"]
        )
    ]
}

extension Location {
    static let sampleNepal = Location(
        id: "nepal",
        name: "Nepal",
        country: "Nepal",
        flagCode: "NP",
        coverImageURL: "https://images.unsplash.com/photo-1519904981063-b0cf448d479e",
        summary: "Home to 8 of the world's 14 highest peaks, Nepal offers unparalleled mountain adventures.",
        description: "Nepal is a landlocked country in South Asia, known for its majestic Himalayan mountain range. It's home to Mount Everest, the world's highest peak, and offers some of the most spectacular trekking and climbing opportunities on Earth. The country's diverse landscapes range from the low-lying Terai plains to the towering Himalayas, providing a unique blend of cultural experiences and natural beauty.",
        trips: Trip.sampleTrips.filter { $0.locationId == "nepal" },
        coordinates: Coordinates(latitude: 28.3949, longitude: 84.1240),
        timeZone: "NPT (UTC+5:45)",
        bestTimeToVisit: "October to November, March to May",
        currency: "Nepalese Rupee (NPR)",
        language: "Nepali"
    )
    
    static let sampleTanzania = Location(
        id: "tanzania",
        name: "Tanzania",
        country: "Tanzania",
        flagCode: "TZ",
        coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
        summary: "Home to Mount Kilimanjaro, Africa's highest peak and one of the Seven Summits.",
        description: "Tanzania is an East African country known for its vast wilderness areas and Mount Kilimanjaro, Africa's highest peak. The country offers incredible wildlife safaris and mountain adventures, with Kilimanjaro being one of the most accessible of the Seven Summits. The mountain's unique position near the equator means climbers experience multiple climate zones during their ascent.",
        trips: Trip.sampleTrips.filter { $0.locationId == "tanzania" },
        coordinates: Coordinates(latitude: -6.3690, longitude: 34.8888),
        timeZone: "EAT (UTC+3)",
        bestTimeToVisit: "June to October, December to March",
        currency: "Tanzanian Shilling (TZS)",
        language: "Swahili"
    )
    
    static let sampleFrance = Location(
        id: "france",
        name: "France",
        country: "France",
        flagCode: "FR",
        coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
        summary: "Home to Mont Blanc, Western Europe's highest peak in the stunning French Alps.",
        description: "France is home to the French Alps, a mountain range that offers some of Europe's most spectacular alpine experiences. Mont Blanc, standing at 4,808 meters, is the highest peak in Western Europe and attracts climbers and mountaineers from around the world. The region around Chamonix is particularly famous for its world-class climbing and skiing opportunities.",
        trips: Trip.sampleTrips.filter { $0.locationId == "france" },
        coordinates: Coordinates(latitude: 46.6034, longitude: 1.8883),
        timeZone: "CET (UTC+1)",
        bestTimeToVisit: "June to September",
        currency: "Euro (EUR)",
        language: "French"
    )
    
    static let sampleJapan = Location(
        id: "japan",
        name: "Japan",
        country: "Japan",
        flagCode: "JP",
        coverImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
        summary: "Home to Mount Fuji, Japan's most iconic mountain and a UNESCO World Heritage site.",
        description: "Japan is home to Mount Fuji, an active volcano and the country's highest peak at 3,776 meters. Fuji-san, as it's known locally, is deeply ingrained in Japanese culture and is considered one of Japan's Three Holy Mountains. The mountain offers a unique climbing experience with well-maintained trails and traditional mountain huts, making it accessible to climbers of various skill levels.",
        trips: Trip.sampleTrips.filter { $0.locationId == "japan" },
        coordinates: Coordinates(latitude: 36.2048, longitude: 138.2529),
        timeZone: "JST (UTC+9)",
        bestTimeToVisit: "July to August",
        currency: "Japanese Yen (JPY)",
        language: "Japanese"
    )
    
    static let allSampleLocations: [Location] = [
        sampleNepal,
        sampleTanzania,
        sampleFrance,
        sampleJapan
    ]
}
