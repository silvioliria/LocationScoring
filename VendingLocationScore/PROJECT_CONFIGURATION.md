# Xcode Project Configuration for Google Sign-In

## Overview
Since this project uses `GENERATE_INFOPLIST_FILE = YES`, we need to configure Google Sign-In through Xcode project settings rather than a manual Info.plist file.

## Step 1: Configure Google Sign-In in Xcode

### 1.1 Add URL Schemes
1. Open your project in Xcode
2. Select your project in the navigator
3. Select your app target
4. Go to "Info" tab
5. Expand "URL Types" section
6. Click "+" to add a new URL type
7. Configure as follows:
   - **URL Schemes**: `com.googleusercontent.apps.YOUR_CLIENT_ID`
   - **Identifier**: `Google Sign-In`
   - **Icon**: Leave empty
   - **Role**: Editor

### 1.2 Add Custom Info.plist Keys
In the same "Info" tab, add these custom keys:

#### Google Client ID
- **Key**: `GIDClientID`
- **Type**: String
- **Value**: `YOUR_CLIENT_ID.apps.googleusercontent.com`

#### Privacy Description
- **Key**: `NSUserTrackingUsageDescription`
- **Type**: String
- **Value**: `This app uses Google Sign-In to authenticate users and provide personalized experiences.`

## Step 2: Update AppConfig.swift

1. Open `VendingLocationScore/Config/AppConfig.swift`
2. Replace `YOUR_CLIENT_ID` with your actual Google client ID
3. The format should be: `123456789-abcdefghijklmnop.apps.googleusercontent.com`

## Step 3: Add Google Sign-In Package

1. In Xcode, go to **File** > **Add Package Dependencies**
2. Enter: `https://github.com/google/GoogleSignIn-iOS.git`
3. Select version **7.0.0** or later
4. Add both packages:
   - `GoogleSignIn`
   - `GoogleSignInSwift`

## Step 4: Verify Configuration

After configuration, your project should have:

✅ **URL Types** configured with Google Sign-In scheme
✅ **GIDClientID** key set in project settings
✅ **Google Sign-In packages** added via Swift Package Manager
✅ **AppConfig.swift** updated with your client ID

## Troubleshooting

### Build Error: "Multiple commands produce Info.plist"
- **Solution**: Remove any manually created Info.plist files
- **Ensure**: `GENERATE_INFOPLIST_FILE = YES` in project settings

### Google Sign-In Not Working
- **Check**: URL scheme matches your client ID exactly
- **Verify**: GIDClientID is set correctly
- **Confirm**: Google Sign-In packages are properly linked

### Configuration Validation
The app will show a warning if Google Sign-In is not properly configured. Check:
1. Client ID format in AppConfig.swift
2. URL scheme in project settings
3. Package dependencies are linked

## Example Configuration

### AppConfig.swift
```swift
static let googleClientID = "123456789-abcdefghijklmnop.apps.googleusercontent.com"
```

### URL Scheme
```
com.googleusercontent.apps.123456789
```

### Project Info Settings
- **URL Types**: `com.googleusercontent.apps.123456789`
- **GIDClientID**: `123456789-abcdefghijklmnop.apps.googleusercontent.com`

## Next Steps

1. Follow the Google Cloud Console setup in `GOOGLE_SIGNIN_SETUP.md`
2. Configure your Xcode project as described above
3. Test the authentication flow
4. Customize the UI as needed

## Support

- Check Xcode console for detailed error messages
- Verify all configuration steps are completed
- Test on a physical device for best results
- Ensure network connectivity for authentication
