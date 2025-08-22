import SwiftUI
import SwiftData

struct LoginView: View {
    @ObservedObject var authService: AuthenticationService
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.8),
                        Color.purple.opacity(0.6),
                        Color.blue.opacity(0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // App Logo and Title
                    VStack(spacing: 20) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                        
                        VStack(spacing: 8) {
                            Text("PerkPoint")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Location Evaluator")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    // Description
                    Text("Evaluate and score vending machine locations with precision")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Sign In Section
                    VStack(spacing: 20) {
                        if AppConfig.enableGoogleSignIn {
                            // Google Sign-In is enabled
                            if !AppConfig.isGoogleSignInConfigured {
                                VStack(spacing: 10) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.title)
                                        .foregroundColor(.orange)
                                    
                                    Text("Google Sign-In Not Configured")
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                    
                                    Text("Please follow the setup instructions in GOOGLE_SIGNIN_SETUP.md")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(20)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(15)
                            } else {
                                // Google Sign In Button would go here
                                Text("Google Sign-In Button")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(25)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            }
                        } else {
                            // Google Sign-In is disabled - show debug login
                            VStack(spacing: 15) {
                                Text("🔧 Debug Mode")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Google Sign-In is disabled for development")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    // Simulate successful login for development
                                    authService.simulateDebugLogin()
                                }) {
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                        Text("Debug Login")
                                    }
                                    .foregroundColor(.white)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(25)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                                }
                            }
                            .padding(20)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(15)
                        }
                        
                        // Loading indicator
                        if authService.isLoading {
                            HStack(spacing: 10) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                                Text("Signing in...")
                                    .foregroundColor(.white)
                                    .font(.body)
                            }
                        }
                        
                        // Error message
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Footer
                    VStack(spacing: 8) {
                        if AppConfig.enableGoogleSignIn {
                            Text("Secure authentication powered by Google")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        } else {
                            Text("🔧 Development Mode - Authentication Disabled")
                                .font(.caption)
                                .foregroundColor(.green.opacity(0.8))
                        }
                        
                        Text("Your data stays private and secure")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    let authService = AuthenticationService()
    return LoginView(authService: authService)
}
