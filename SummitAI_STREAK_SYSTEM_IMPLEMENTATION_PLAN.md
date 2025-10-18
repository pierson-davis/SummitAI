# SummitAI Streak System Implementation Plan

## Overview
Implement a Duolingo-style streak system for SummitAI that tracks daily step goals and maintains consecutive day streaks with visual fire indicators.

## Requirements
- **Target Steps**: 5000 steps per day (configurable)
- **Streak Logic**: Count consecutive days above target
- **Visual Indicators**: Fire emojis for different streak lengths (🔥 for 2+ days, 🔥🔥 for 3+ days, etc.)
- **Persistence**: Save streak data and maintain across app sessions
- **Integration**: Work with existing HealthKit step tracking
- **UI**: Display streak prominently in home view

## Implementation Steps

### Step 1: Create StreakManager Service (30 min)
Create a dedicated service to manage streak logic and data persistence.

**Files to create:**
- `SummitAI/Services/StreakManager.swift`

**Key features:**
- Daily step target management (default: 5000)
- Streak calculation logic
- Streak data persistence
- Integration with HealthKitManager
- Streak validation and reset logic

### Step 2: Update User Model with Streak Data (15 min)
Enhance the User model to include comprehensive streak information.

**Files to modify:**
- `SummitAI/Models/User.swift`

**New properties:**
- `dailyStepTarget: Int` (default: 5000)
- `currentStreak: Int`
- `longestStreak: Int`
- `streakHistory: [StreakDay]`
- `lastStreakUpdate: Date`

### Step 3: Integrate with HealthKit Daily Step Tracking (30 min)
Connect the streak system with existing HealthKit step tracking.

**Files to modify:**
- `SummitAI/Services/HealthKitManager.swift`
- `SummitAI/Services/UserManager.swift`

**Integration points:**
- Daily step count updates
- Streak validation on step changes
- Automatic streak updates at midnight
- Background app refresh handling

### Step 4: Create Streak UI Components (45 min)
Build reusable UI components for displaying streak information.

**Files to create:**
- `SummitAI/Views/Components/StreakView.swift`
- `SummitAI/Views/Components/StreakFireView.swift`
- `SummitAI/Views/Components/StreakProgressView.swift`

**Components:**
- Main streak display with fire indicators
- Daily progress bar
- Streak history calendar
- Streak achievements

### Step 5: Add Streak to Home View (30 min)
Integrate streak display into the main home view.

**Files to modify:**
- `SummitAI/Views/HomeView.swift`

**Integration:**
- Prominent streak display
- Daily step progress
- Streak motivation messages
- Quick access to streak settings

### Step 6: Test Streak Functionality (30 min)
Comprehensive testing of streak system.

**Test scenarios:**
- Daily step target achievement
- Streak continuation and breaking
- Data persistence across app sessions
- UI updates and animations
- Edge cases (timezone changes, app backgrounding)

## Technical Implementation Details

### StreakManager Service Architecture

```swift
class StreakManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var dailyStepTarget: Int = 5000
    @Published var todaySteps: Int = 0
    @Published var streakHistory: [StreakDay] = []
    
    // Core streak logic
    func updateStreak(with steps: Int)
    func validateStreak()
    func resetStreak()
    func getStreakFireLevel() -> Int
}
```

### Streak Data Models

```swift
struct StreakDay: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let steps: Int
    let target: Int
    let isStreakDay: Bool
    let fireLevel: Int
}

enum StreakFireLevel: Int, CaseIterable {
    case none = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    
    var fireEmoji: String {
        switch self {
        case .none: return ""
        case .one: return "🔥"
        case .two: return "🔥🔥"
        case .three: return "🔥🔥🔥"
        case .four: return "🔥🔥🔥🔥"
        case .five: return "🔥🔥🔥🔥🔥"
        case .six: return "🔥🔥🔥🔥🔥🔥"
        case .seven: return "🔥🔥🔥🔥🔥🔥🔥"
        case .eight: return "🔥🔥🔥🔥🔥🔥🔥🔥"
        case .nine: return "🔥🔥🔥🔥🔥🔥🔥🔥🔥"
        case .ten: return "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
        }
    }
}
```

### UI Component Design

#### StreakView (Main Component)
- Large streak number with fire indicators
- Daily progress bar
- "X days in a row" text
- Motivational messages

#### StreakFireView (Fire Animation)
- Animated fire emojis
- Particle effects for streak milestones
- Celebration animations

#### StreakProgressView (Daily Progress)
- Circular progress ring
- Steps remaining indicator
- Target adjustment controls

## Integration Points

### HealthKit Integration
- Monitor daily step changes
- Update streak when steps exceed target
- Handle timezone changes and date transitions
- Background app refresh support

### UserManager Integration
- Persist streak data with user profile
- Sync streak across devices
- Handle user authentication changes

### UI Integration
- Home view streak display
- Settings for step target adjustment
- Streak history and statistics
- Achievement integration

## Success Criteria

### Functional Requirements
- ✅ Streak counts consecutive days above step target
- ✅ Visual fire indicators scale with streak length
- ✅ Data persists across app sessions
- ✅ Integrates with existing HealthKit step tracking
- ✅ Handles edge cases (timezone, backgrounding)

### Performance Requirements
- ✅ Streak updates in real-time
- ✅ Smooth UI animations
- ✅ Efficient data persistence
- ✅ Minimal battery impact

### User Experience Requirements
- ✅ Clear visual feedback
- ✅ Motivational messaging
- ✅ Easy target adjustment
- ✅ Streak history visibility

## Risk Mitigation

### Technical Risks
- **Data Loss**: Implement robust persistence with UserDefaults and CloudKit
- **Performance**: Use efficient data structures and caching
- **Battery**: Optimize HealthKit queries and background updates

### User Experience Risks
- **Confusion**: Clear UI and helpful tooltips
- **Frustration**: Graceful handling of missed days
- **Motivation**: Positive reinforcement and celebration

## Future Enhancements

### Phase 2 Features
- Streak freeze/repair items
- Social streak sharing
- Streak challenges and competitions
- Advanced streak analytics

### Phase 3 Features
- AI-powered streak predictions
- Personalized step targets
- Streak-based rewards and achievements
- Integration with Apple Watch complications

## Timeline

**Total Estimated Time**: 3 hours
- Step 1: 30 min
- Step 2: 15 min
- Step 3: 30 min
- Step 4: 45 min
- Step 5: 30 min
- Step 6: 30 min

**Priority**: High - Core gamification feature
**Dependencies**: HealthKitManager, UserManager, existing UI components
**Testing**: Manual testing with HealthKit simulator and real device
