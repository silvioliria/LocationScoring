import SwiftUI

struct ContentView: View {
    @StateObject private var authService: AuthenticationService
    
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
    }
}

#Preview {
    ContentView()
}
