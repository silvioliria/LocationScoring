import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var authService: AuthenticationService
    @StateObject private var sharedContext = SharedModelContext.shared
    
    init() {
        self._authService = StateObject(wrappedValue: AuthenticationService())
    }
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                AuthenticatedView(authService: authService)
            } else {
                LoginView(authService: authService)
            }
        }
        .onAppear {
            authService.checkAuthenticationState()
        }
        .environmentObject(sharedContext)
    }
}
