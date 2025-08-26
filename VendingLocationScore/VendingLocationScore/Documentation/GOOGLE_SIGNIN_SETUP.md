# Google Sign-In Setup Guide

## Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- Google Cloud Console account

## Step 1: Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Sign-In API:
   - Go to "APIs & Services" > "Library"
   - Search for "Google Sign-In API"
   - Click "Enable"

## Step 2: Create OAuth 2.0 Credentials

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth 2.0 Client IDs"
3. Select "iOS" as application type
4. Enter your app's bundle identifier
5. Download the `GoogleService-Info.plist` file

## Step 3: Configure Your App

1. **Configure Xcode Project Settings**:
   - Follow the detailed instructions in `PROJECT_CONFIGURATION.md`
   - Add URL schemes and custom Info.plist keys through Xcode interface
   - No manual Info.plist file needed

2. **Update AppConfig.swift**:
   - Replace `YOUR_CLIENT_ID` with your actual client ID from Google Cloud Console
   - The client ID format is: `123456789-abcdefghijklmnop.apps.googleusercontent.com`

3. **Update Bundle Identifier**:
   - In Xcode, go to your project settings
   - Make sure the bundle identifier matches what you configured in Google Cloud Console

## Step 4: Install Dependencies

The project now uses Swift Package Manager for Google Sign-In:

1. In Xcode, go to File > Add Package Dependencies
2. Enter: `https://github.com/google/GoogleSignIn-iOS.git`
3. Select version 7.0.0 or later
4. Add both `GoogleSignIn` and `GoogleSignInSwift` packages

## Step 5: Test the Implementation

1. Build and run your app
2. You should see the login screen with a Google Sign-In button
3. Tap the button to test the authentication flow

## Troubleshooting

### Common Issues:

1. **"Invalid client" error**:
   - Verify your client ID in Info.plist
   - Check that bundle identifier matches Google Cloud Console

2. **"URL scheme not found" error**:
   - Ensure Info.plist has correct URL schemes
   - Check that GoogleService-Info.plist is properly added

3. **Build errors**:
   - Clean build folder (Shift+Cmd+K)
   - Verify all dependencies are properly linked

### Debug Tips:

- Check Xcode console for detailed error messages
- Verify network connectivity (Google Sign-In requires internet)
- Test on a physical device (simulator may have limitations)

## Security Notes

- Never commit your actual client ID to version control
- Use environment variables or configuration files for production
- Regularly rotate your OAuth credentials
- Monitor your Google Cloud Console for unusual activity

## Next Steps

After successful setup:
1. Customize the login UI to match your app's design
2. Implement user profile management
3. Add additional authentication providers if needed
4. Set up proper error handling and user feedback

## Support

- [Google Sign-In iOS Documentation](https://developers.google.com/identity/sign-in/ios)
- [Google Cloud Console Help](https://cloud.google.com/docs)
- [iOS Developer Documentation](https://developer.apple.com/documentation/)
