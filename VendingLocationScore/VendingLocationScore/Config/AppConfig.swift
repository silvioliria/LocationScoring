import Foundation

struct AppConfig {
    // Google Sign-In Configuration
    static let googleClientID = "YOUR_CLIENT_ID.apps.googleusercontent.com"
    
    // App Configuration
    static let appName = "PerkPoint Location Evaluator"
    static let appVersion = "1.0.0"
    
    // Feature Flags
    static let enableGoogleSignIn = false  // Disabled for development
    static let enableUserProfile = true
    static let enableLocalStorage = true
    
    // Debug Mode
    static let isDebugMode = true
    
    // Validation
    static var isGoogleSignInConfigured: Bool {
        return enableGoogleSignIn && googleClientID != "YOUR_CLIENT_ID.apps.googleusercontent.com"
    }
    
    // Google Sign-In URL Scheme (for Info.plist configuration)
    static var googleURLScheme: String {
        // Extract the client ID from the full client ID
        let components = googleClientID.components(separatedBy: ".")
        if components.count >= 2 {
            return "com.googleusercontent.apps.\(components[0])"
        }
        return "com.googleusercontent.apps.YOUR_CLIENT_ID"
    }
}
