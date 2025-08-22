# Debug Mode Guide

## Current Status: 🔧 Debug Mode Enabled

Google Sign-In is currently **disabled** for development purposes. This allows you to:
- ✅ **Build and run the app** without Google Sign-In dependencies
- ✅ **Test the app structure** and UI components
- ✅ **Develop other features** while authentication is set up
- ✅ **Use debug login** to simulate user authentication

## How Debug Mode Works

### **Debug Login Button**
- Shows a green "Debug Login" button instead of Google Sign-In
- Creates a test user: "Debug User" (debug@perkpoint.com)
- Simulates the full authentication flow
- Allows you to test the authenticated app experience

### **Configuration**
Debug mode is controlled in `Config/AppConfig.swift`:
```swift
// Feature Flags
static let enableGoogleSignIn = false  // Disabled for development
static let isDebugMode = true
```

## When You're Ready for Google Sign-In

### **Step 1: Enable Google Sign-In**
In `Config/AppConfig.swift`, change:
```swift
static let enableGoogleSignIn = true  // Enable Google Sign-In
```

### **Step 2: Add Google Sign-In Packages**
1. In Xcode: **File** > **Add Package Dependencies**
2. URL: `https://github.com/google/GoogleSignIn-iOS.git`
3. Add both: `GoogleSignIn` and `GoogleSignInSwift`

### **Step 3: Configure Google Cloud Console**
Follow `GOOGLE_SIGNIN_SETUP.md` for:
- OAuth 2.0 credentials
- Client ID configuration
- Project settings

### **Step 4: Update AppConfig.swift**
Replace `YOUR_CLIENT_ID` with your actual Google client ID.

## Benefits of Debug Mode

1. **No Dependencies** - App builds without external packages
2. **Fast Development** - No authentication setup required
3. **Full Testing** - Can test all app features with debug user
4. **Easy Switch** - Simple flag change to enable production auth

## Testing the App

### **Debug Login Flow**
1. Launch app → See login screen with debug button
2. Tap "Debug Login" → Loading indicator appears
3. After 1 second → Automatically logged in
4. Access main app → User profile shows "Debug User"

### **User Profile**
- **Name**: Debug User
- **Email**: debug@perkpoint.com
- **Phone**: +1-555-0123
- **Profile**: Accessible from navigation bar

### **Sign Out**
- Tap profile button → Profile view opens
- Tap "Sign Out" → Returns to login screen

## Switching Between Modes

### **Debug → Production**
```swift
// In AppConfig.swift
static let enableGoogleSignIn = true
static let isDebugMode = false
```

### **Production → Debug**
```swift
// In AppConfig.swift
static let enableGoogleSignIn = false
static let isDebugMode = true
```

## Troubleshooting

### **Build Errors**
- Ensure `enableGoogleSignIn = false` in debug mode
- Remove any Google Sign-In import statements
- Clean build folder if needed

### **Debug Login Not Working**
- Check `isDebugMode = true`
- Verify AuthenticationService is properly injected
- Check console for error messages

### **UI Issues**
- Debug mode shows different UI elements
- Green debug button instead of Google Sign-In
- Different footer text indicating debug mode

## Next Steps

1. **Continue Development** - Use debug mode for now
2. **Test App Features** - Ensure everything works with debug user
3. **When Ready** - Follow steps above to enable Google Sign-In
4. **Production** - Switch to production authentication

## Support

- Check `AppConfig.swift` for current settings
- Review console logs for debugging information
- Use debug login to test all app functionality
- Follow setup guides when ready for production auth

Debug mode is perfect for development! 🚀
