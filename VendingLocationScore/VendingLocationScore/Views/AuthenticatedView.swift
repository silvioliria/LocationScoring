import SwiftUI

struct AuthenticatedView: View {
	let authService: AuthenticationService
	
	var body: some View {
		LocationListView()
	}
}

#Preview {
	let authService = AuthenticationService()
	AuthenticatedView(authService: authService)
}
