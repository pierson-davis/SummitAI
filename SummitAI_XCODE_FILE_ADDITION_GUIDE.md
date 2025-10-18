# SummitAI Streak System - Xcode File Addition Guide

## Files to Add to Xcode Project

### 1. NEW FILES (Must be added to Xcode)

#### Services Folder
**File Path**: `SummitAI/SummitAI/Services/StreakManager.swift`
**How to Add**:
1. Right-click on `SummitAI/Services/` folder in Xcode Navigator
2. Select "Add Files to 'SummitAI'"
3. Navigate to the file location
4. Select `StreakManager.swift`
5. Make sure "Add to target: SummitAI" is checked
6. Click "Add"

#### Views/Components Folder
**File Path**: `SummitAI/SummitAI/Views/Components/StreakView.swift`
**How to Add**:
1. Right-click on `SummitAI/Views/` folder in Xcode Navigator
2. Select "New Group" and name it "Components" (if it doesn't exist)
3. Right-click on the new "Components" group
4. Select "Add Files to 'SummitAI'"
5. Navigate to the file location
6. Select `StreakView.swift`
7. Make sure "Add to target: SummitAI" is checked
8. Click "Add"

### 2. MODIFIED FILES (Already in Xcode, verify updates)

#### Models
- `SummitAI/SummitAI/Models/User.swift` ✅ (Already in Xcode)

#### Services
- `SummitAI/SummitAI/Services/HealthKitManager.swift` ✅ (Already in Xcode)

#### Views
- `SummitAI/SummitAI/Views/HomeView.swift` ✅ (Already in Xcode)

## Step-by-Step Xcode Setup

### Step 1: Create Components Group (if needed)
1. In Xcode Navigator, right-click on `SummitAI/Views/`
2. Select "New Group"
3. Name it "Components"
4. Drag it to organize your views

### Step 2: Add StreakManager.swift
1. Right-click on `SummitAI/Services/` folder
2. Select "Add Files to 'SummitAI'"
3. Navigate to: `/Users/piersondavis/Documents/mtn/SummitAI/SummitAI/Services/`
4. Select `StreakManager.swift`
5. Verify "Add to target: SummitAI" is checked
6. Click "Add"

### Step 3: Add StreakView.swift
1. Right-click on `SummitAI/Views/Components/` folder
2. Select "Add Files to 'SummitAI'"
3. Navigate to: `/Users/piersondavis/Documents/mtn/SummitAI/SummitAI/Views/Components/`
4. Select `StreakView.swift`
5. Verify "Add to target: SummitAI" is checked
6. Click "Add"

### Step 4: Verify File Organization
Your Xcode Navigator should look like this:
```
SummitAI/
├── Models/
│   └── User.swift ✅
├── Services/
│   ├── HealthKitManager.swift ✅
│   └── StreakManager.swift ✅ (NEW)
├── Views/
│   ├── Components/
│   │   └── StreakView.swift ✅ (NEW)
│   └── HomeView.swift ✅
└── ...
```

## Common Issues and Solutions

### Issue 1: "File not found" errors
**Solution**: 
1. Check file paths are correct
2. Verify files are added to the correct target
3. Clean build folder (Product → Clean Build Folder)
4. Rebuild project

### Issue 2: "No such module" errors
**Solution**:
1. Verify all files are added to the target
2. Check import statements
3. Clean and rebuild

### Issue 3: Build errors after adding files
**Solution**:
1. Check for syntax errors in new files
2. Verify all dependencies are imported
3. Check for missing closing braces
4. Use Xcode's error navigator to locate issues

### Issue 4: Files not showing in Navigator
**Solution**:
1. Right-click in Navigator
2. Select "Add Files to 'SummitAI'"
3. Navigate to file location
4. Select files and add to target

## Verification Checklist

### After Adding Files
- [ ] `StreakManager.swift` appears in Services folder
- [ ] `StreakView.swift` appears in Views/Components folder
- [ ] Project builds without errors
- [ ] No red error indicators in Navigator
- [ ] All files show correct target membership

### After Building
- [ ] Build succeeds (⌘+B)
- [ ] No compilation errors
- [ ] No linking errors
- [ ] App launches successfully
- [ ] Streak UI appears in home view

## File Dependencies

### StreakManager.swift depends on:
- Foundation
- Combine
- SwiftUI

### StreakView.swift depends on:
- SwiftUI
- StreakManager (via @ObservedObject)

### HomeView.swift depends on:
- StreakView (via StreakView component)
- HealthKitManager (via streakManager property)

## Target Membership

All files should be added to:
- **Target**: SummitAI
- **Platform**: iOS
- **Deployment Target**: iOS 15.0+

## Build Settings

No special build settings required. The streak system uses standard iOS frameworks:
- Foundation
- Combine
- SwiftUI
- HealthKit (already configured)

## Testing the Addition

### Quick Test
1. Build the project (⌘+B)
2. Run on simulator (⌘+R)
3. Navigate to Home tab
4. Verify streak UI appears
5. Check for any runtime errors

### Full Test
1. Follow the comprehensive testing guide
2. Test all streak functionality
3. Verify HealthKit integration
4. Check data persistence

## Troubleshooting

### If Build Fails
1. Check Xcode error navigator
2. Verify all files are added correctly
3. Check import statements
4. Clean build folder and rebuild

### If UI Doesn't Appear
1. Verify StreakView is added to target
2. Check HomeView integration
3. Verify HealthKitManager setup
4. Check for runtime errors in console

### If Streak Doesn't Work
1. Verify StreakManager is initialized
2. Check HealthKit permissions
3. Verify step data is being received
4. Check UserDefaults persistence

## Success Indicators

### Build Success
- ✅ Project builds without errors
- ✅ All files compile successfully
- ✅ No missing dependencies

### Runtime Success
- ✅ App launches without crashes
- ✅ Streak UI appears in home view
- ✅ Streak system responds to step data
- ✅ Data persists across app sessions

## Next Steps

After successfully adding files:
1. Follow the comprehensive testing guide
2. Test all functionality thoroughly
3. Verify integration with existing systems
4. Deploy to TestFlight for beta testing
5. Monitor for any issues in production

## Support

If you encounter issues:
1. Check this guide first
2. Review Xcode error messages
3. Verify file paths and target membership
4. Clean and rebuild project
5. Check for syntax errors in new files
