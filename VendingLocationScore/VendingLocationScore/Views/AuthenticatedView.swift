import SwiftUI
import SwiftData

struct AuthenticatedView: View {
	let authService: AuthenticationService
	@EnvironmentObject private var sharedContext: SharedModelContext
	@Environment(\.modelContext) private var modelContext
	
	var body: some View {
		LocationListView()
			.onAppear {
				sharedContext.setContext(modelContext)
			}
	}
}

#Preview {
	let authService = AuthenticationService()
	AuthenticatedView(authService: authService)
		.environmentObject(SharedModelContext.shared)
}
