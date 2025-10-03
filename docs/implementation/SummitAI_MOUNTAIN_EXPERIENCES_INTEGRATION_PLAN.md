# SummitAI Mountain Experiences Integration Plan

## Overview
This document provides a comprehensive step-by-step plan to integrate the Mountain Experiences travel app design handoff spec into SummitAI, transforming it into a dark-themed mobile app for discovering and planning mountain adventures.

## Design System Integration

### Step 1: Design System & Color Tokens Implementation (2 hours)

#### 1.1 Create Design System Foundation (30 min)
- Create `DesignSystem.swift` with color tokens, typography, spacing, and component styles
- Implement 8-pt spacing system (8, 16, 24, 32, 40, 48, 56, 64)
- Define corner radius system (12 for inputs/chips, 20 for cards)

#### 1.2 Implement Color Palette (30 min)
```swift
// Dark theme color tokens
--surface-0: #0F1012 (App background)
--text-primary: #DEDEDE (Primary text)
--text-secondary: #A5A5A6 (Secondary text)
--text-tertiary: #717382 (Tertiary text)
--border-muted: #5B5C5F (Hairlines/dividers)
--accent-600: #1B304B (Deep blue accent)
--accent-500: #35475E (Lighter accent)
--surface-elev-1: #15171A (Elevated surfaces)
--surface-elev-2: #1B1E22 (Higher elevation)
--overlay-60: rgba(0,0,0,.60) (Overlays)
--overlay-30: rgba(0,0,0,.30) (Light overlays)
```

#### 1.3 Typography System (30 min)
- Display XL: 34-36pt / 44 line height
- Title L: 28pt / 34 line height  
- Body M: 16pt / 24 line height
- Label S: 12-13pt / 16 line height
- Use Inter or SF Pro for iOS, Roboto for Android

#### 1.4 Component Base Styles (30 min)
- Card radius: 20pt
- Input radius: 12pt
- Chip radius: 12pt
- Shadows: Elev-1: 2dp, Elev-2: 4dp
- Press states: 8% overlay
- Focus rings: 2px outside stroke

### Step 2: Home/Discover Screen Transformation (3 hours)

#### 2.1 Full-Bleed Mountain Hero Implementation (1 hour)
- Replace current background with full-bleed mountain image
- Add bottom gradient overlay (40% screen height → bottom)
- Implement contextual label with pin/marker + text pill
- Add dashed vertical guide line to mountain point

#### 2.2 Header & Navigation (45 min)
- Top left: Hamburger menu (24pt from left, 24pt from top safe area)
- Top right: "Need help?" chip with avatar
- Implement drawer launcher functionality

#### 2.3 Title Block & Search (45 min)
- Display title "Mountain\nExperiences" (two lines)
- Subtitle: "The best guides for mountaineers"
- Search input: Height 52pt, left magnifier icon, right filter button
- Implement search functionality with keyboard handling

#### 2.4 Atmospheric Effects (30 min)
- Add snow particles animation
- Implement weather effects
- Create immersive mountain environment

### Step 3: Location Detail Screen Implementation (2 hours)

#### 3.1 App Bar & Header (30 min)
- Back chevron (24pt) at left
- No title in bar
- Transparent background over header, solid when scrolled

#### 3.2 Location Content (45 min)
- Large "Nepal" title
- Body text: "Nepal contains part of the Himalayas…"
- Implement dynamic content based on selected location

#### 3.3 Category Chips Row (45 min)
- Horizontal scrollable chips (48-56pt width, 56-64pt height)
- Icons: Peaks, Hiking, Climbing, Guides
- Background: near-white tile, dark icons
- Selected state: accent background, white text

### Step 4: Component Library Creation (2 hours)

#### 4.1 App Bar Component (30 min)
```swift
struct MinimalAppBar: View {
    let showBackButton: Bool
    let onBackTap: () -> Void
    let onMenuTap: () -> Void
}
```

#### 4.2 Search Field Component (30 min)
```swift
struct SearchField: View {
    @Binding var text: String
    let placeholder: String
    let onFilterTap: () -> Void
}
```

#### 4.3 Category Chip Component (30 min)
```swift
struct CategoryChip: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let onTap: () -> Void
}
```

#### 4.4 Trip Card Component (30 min)
```swift
struct TripCard: View {
    let trip: Trip
    let onTap: () -> Void
    let onLongPress: () -> Void
}
```

### Step 5: Search & Filter Functionality (2 hours)

#### 5.1 Search Implementation (1 hour)
- Real-time search with debouncing
- Search by location, mountain name, activity type
- Results list with same card style
- Empty state handling

#### 5.2 Filter Modal (1 hour)
- Category filter (Peaks, Hiking, Climbing, Guides)
- Difficulty filter (Easy, Moderate, Hard)
- Duration filter (days range)
- Apply/Reset functionality

### Step 6: Data Model Integration (1 hour)

#### 6.1 Trip Data Model (30 min)
```swift
struct Trip: Identifiable, Codable {
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
}

enum TripCategory: String, CaseIterable {
    case peaks = "Peaks"
    case hiking = "Hiking"
    case climbing = "Climbing"
    case guides = "Guides"
}

enum TripDifficulty: String, CaseIterable {
    case easy = "Easy"
    case moderate = "Moderate"
    case hard = "Hard"
}
```

#### 6.2 Location Data Model (30 min)
```swift
struct Location: Identifiable, Codable {
    let id: String
    let name: String
    let summary: String
    let flagCode: String
    let coverImageURL: String
    let trips: [Trip]
}
```

### Step 7: Navigation & User Flow (1 hour)

#### 7.1 Navigation Structure (30 min)
- Home → Search Results
- Home → Location Detail
- Location Detail → Trip Detail
- Filter Modal presentation
- Drawer navigation (future)

#### 7.2 User Flow Implementation (30 min)
- Search submit → Results list
- Location tap → Location Detail
- Category chip tap → Filter list
- Trip card tap → Trip Detail
- Long press → Quick save

### Step 8: Testing & Refinement (1 hour)

#### 8.1 Component Testing (30 min)
- Test all components in isolation
- Verify accessibility compliance
- Check tap targets (≥44×44)
- Test dynamic type support

#### 8.2 Integration Testing (30 min)
- Test complete user flows
- Verify search functionality
- Test filter interactions
- Check responsive design

## Implementation Details

### File Structure
```
SummitAI/
├── Views/
│   ├── MountainExperiences/
│   │   ├── HomeDiscoverView.swift
│   │   ├── LocationDetailView.swift
│   │   ├── TripDetailView.swift
│   │   └── SearchResultsView.swift
│   ├── Components/
│   │   ├── MinimalAppBar.swift
│   │   ├── SearchField.swift
│   │   ├── CategoryChip.swift
│   │   ├── TripCard.swift
│   │   └── MountainHeroView.swift
│   └── DesignSystem/
│       ├── DesignSystem.swift
│       ├── ColorTokens.swift
│       └── Typography.swift
├── Models/
│   ├── Trip.swift
│   ├── Location.swift
│   └── TripCategory.swift
└── Services/
    ├── SearchManager.swift
    └── FilterManager.swift
```

### Key Features to Implement

#### 1. Full-Bleed Mountain Hero
- High-quality mountain imagery
- Bottom gradient overlay for text legibility
- Contextual location labels with pins
- Atmospheric effects (snow, weather)

#### 2. Search & Discovery
- Real-time search with instant results
- Category-based filtering
- Difficulty and duration filters
- Location-based browsing

#### 3. Trip Cards
- 16:10 aspect ratio images
- White metadata capsules
- Category, duration, difficulty labels
- Tap and long-press interactions

#### 4. Category System
- Peaks, Hiking, Climbing, Guides
- Icon-based visual representation
- Selected state styling
- Horizontal scrolling

### Accessibility Requirements
- Minimum 4.5:1 text contrast ratio
- 3:1 contrast for large titles
- Tap targets ≥44×44 points
- Dynamic Type support up to 120%
- VoiceOver/TalkBack compatibility
- Meaningful labels and reading order

### Performance Considerations
- Lazy loading for trip cards
- Image prefetching (next 2 cards)
- Progressive JPEG/AVIF support
- 1x/2x/3x image assets
- Hero images ~2000px width
- Card images ~800×500

### Assets Required
- Icons: menu, chevron-back, search, sliders/filter, peaks, hiking, climbing, guides
- Flags: Nepal (np), other countries as needed
- Photos: Grayscale hero for Home, color photos for trip cards
- Mountain imagery: High-quality photos for hero sections

## Success Criteria

### Visual Fidelity
- [ ] Home screen matches design spec exactly
- [ ] Location detail screen matches layout
- [ ] Trip cards use correct styling and proportions
- [ ] Color tokens applied consistently
- [ ] Typography matches specified scale

### Functionality
- [ ] Search works with real-time results
- [ ] Filter modal functions correctly
- [ ] Category chips show selected states
- [ ] Trip cards respond to tap/long-press
- [ ] Navigation flows work smoothly

### Accessibility
- [ ] All text meets contrast requirements
- [ ] Tap targets are properly sized
- [ ] Dynamic Type scaling works
- [ ] VoiceOver provides meaningful descriptions
- [ ] Focus management is correct

### Performance
- [ ] Images load efficiently
- [ ] Search responds quickly
- [ ] Smooth scrolling performance
- [ ] No memory leaks
- [ ] App launches quickly

## Timeline Summary
- **Total Time**: 14 hours
- **Phase 1**: Design System (2 hours)
- **Phase 2**: Home Screen (3 hours)
- **Phase 3**: Location Detail (2 hours)
- **Phase 4**: Components (2 hours)
- **Phase 5**: Search & Filter (2 hours)
- **Phase 6**: Data Models (1 hour)
- **Phase 7**: Navigation (1 hour)
- **Phase 8**: Testing (1 hour)

This plan provides a comprehensive roadmap for integrating the Mountain Experiences design into SummitAI while maintaining the existing functionality and adding the new travel app features.
