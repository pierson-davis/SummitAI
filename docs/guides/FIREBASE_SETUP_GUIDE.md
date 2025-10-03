# 🔥 Firebase Setup Guide for SummitAI

## Prerequisites
- Firebase account (free tier available)
- Xcode 15.0+
- iOS 17.0+ target

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `summitai-app`
4. Enable Google Analytics (optional but recommended)
5. Choose or create a Google Analytics account
6. Click "Create project"

## Step 2: Add iOS App to Firebase Project

1. In Firebase Console, click "Add app" and select iOS
2. Enter iOS bundle ID: `com.summitai.app`
3. Enter app nickname: `SummitAI`
4. Enter App Store ID (optional for now)
5. Click "Register app"

## Step 3: Download Configuration File

1. Download `GoogleService-Info.plist`
2. Replace the template file in `SummitAI/SummitAI/GoogleService-Info.plist.template`
3. Rename to `GoogleService-Info.plist`
4. Add to Xcode project (drag and drop into project navigator)
5. Make sure "Add to target" is checked for SummitAI

## Step 4: Configure Authentication

1. In Firebase Console, go to "Authentication" > "Sign-in method"
2. Enable "Apple" sign-in provider
3. Enter your Apple Developer Team ID
4. Enter your Apple Services ID (com.summitai.app)
5. Enter your Apple Private Key ID and Private Key
6. Click "Save"

## Step 5: Configure Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location (choose closest to your users)
5. Click "Done"

## Step 6: Update Xcode Project

### Add Firebase SDK Dependencies

1. In Xcode, select your project in the navigator
2. Select the SummitAI target
3. Go to "Package Dependencies" tab
4. Click the "+" button
5. Add these Firebase packages:

```
https://github.com/firebase/firebase-ios-sdk
```

6. Select these specific packages:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseAnalytics
   - FirebaseCrashlytics

### Update Build Settings

1. Go to Build Settings
2. Add these to "Other Linker Flags":
   - `-ObjC`
   - `-lc++`

### Update Info.plist

Add these keys to Info.plist:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## Step 7: Test Firebase Integration

1. Build and run the app
2. Check Xcode console for Firebase initialization messages
3. Test authentication flow
4. Verify Firestore data persistence

## Step 8: Security Rules (Production)

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public read access to mountains
    match /mountains/{mountainId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // User expeditions are private
    match /users/{userId}/expeditions/{expeditionId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 9: Environment Configuration

### Development vs Production

1. Create separate Firebase projects for dev/prod
2. Use different bundle IDs:
   - Development: `com.summitai.app.dev`
   - Production: `com.summitai.app`
3. Use different GoogleService-Info.plist files
4. Configure build schemes accordingly

## Troubleshooting

### Common Issues

1. **Firebase not initializing**: Check GoogleService-Info.plist is added to target
2. **Authentication failing**: Verify Apple Sign-In configuration
3. **Firestore permission denied**: Check security rules
4. **Build errors**: Ensure all Firebase packages are properly linked

### Debug Commands

```bash
# Check Firebase configuration
grep -r "Firebase" SummitAI/

# Verify bundle ID
grep "PRODUCT_BUNDLE_IDENTIFIER" SummitAI.xcodeproj/project.pbxproj

# Check entitlements
cat SummitAI/SummitAI.entitlements
```

## Next Steps

1. Implement real Apple Sign-In with Firebase
2. Set up Firestore data models
3. Configure push notifications
4. Set up analytics tracking
5. Implement offline data sync
6. Configure crash reporting

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk)
- [Apple Sign-In with Firebase](https://firebase.google.com/docs/auth/ios/apple)
