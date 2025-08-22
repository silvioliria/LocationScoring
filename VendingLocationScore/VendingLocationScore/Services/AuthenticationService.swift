import Foundation
import UIKit

// Conditional imports for Google Sign-In
#if canImport(GoogleSignIn) && canImport(GoogleSignInSwift)
import GoogleSignIn
import GoogleSignInSwift
#endif

@MainActor
class AuthenticationService: ObservableObject {
	@Published var isAuthenticated = false
	@Published var currentUser: User?
	@Published var isLoading = false
	@Published var errorMessage: String?
	
	private let storageService: any StorageService
	
	init() {
		self.storageService = StorageServiceFactory.createStorageService()
	}
	
	func checkAuthenticationState() {
		#if canImport(GoogleSignIn) && canImport(GoogleSignInSwift)
		// Check if user is already signed in
		if let user = GIDSignIn.sharedInstance.currentUser {
			handleSignInResult(user: user)
		} else {
			// Check local storage for existing user
			Task {
				await fetchLocalUser()
			}
		}
		#else
		// In debug mode, just check local storage
		Task {
			await fetchLocalUser()
		}
		#endif
	}
	
	func signIn() {
		isLoading = true
		errorMessage = nil
		
		// Check if Google Sign-In is enabled
		guard AppConfig.enableGoogleSignIn else {
			errorMessage = "Google Sign-In is disabled in debug mode. Use debug login instead."
			isLoading = false
			return
		}
		
		#if canImport(GoogleSignIn) && canImport(GoogleSignInSwift)
		// Check if Google Sign-In is properly configured
		guard AppConfig.isGoogleSignInConfigured else {
			errorMessage = "Google Sign-In not configured. Please check setup instructions."
			isLoading = false
			return
		}
		
		guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
			errorMessage = "Unable to present sign-in"
			isLoading = false
			return
		}
		
		GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
			DispatchQueue.main.async {
				self?.isLoading = false
				
				if let error = error {
					self?.errorMessage = error.localizedDescription
					return
				}
				
				if let user = result?.user {
					self?.handleSignInResult(user: user)
				}
			}
		}
		#else
		errorMessage = "Google Sign-In packages not available. Use debug login instead."
		isLoading = false
		#endif
	}
	
	func signOut() {
		#if canImport(GoogleSignIn) && canImport(GoogleSignInSwift)
		GIDSignIn.sharedInstance.signOut()
		#endif
		
		isAuthenticated = false
		currentUser = nil
		
		// Clear local user data
		Task {
			await clearLocalUser()
		}
	}
	
	// MARK: - Debug Methods
	
	func simulateDebugLogin() {
		guard AppConfig.isDebugMode else { return }
		
		isLoading = true
		
		// Simulate network delay
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			guard let self = self else { return }
			
			// Create a debug user
			let debugUser = User(
				id: "debug-user-123",
				name: "Debug User",
				email: "debug@perkpoint.com",
				phone: "+1-555-0123"
			)
			
			// Save user and update state
			Task {
				await self.saveUser(debugUser)
				await MainActor.run {
					self.isAuthenticated = true
					self.currentUser = debugUser
					self.isLoading = false
					self.errorMessage = nil
				}
			}
		}
	}
	
	#if canImport(GoogleSignIn) && canImport(GoogleSignInSwift)
	private func handleSignInResult(user: GIDUser) {
		let userProfile = User(
			id: user.userID ?? UUID().uuidString,
			name: user.profile?.name ?? "Unknown User",
			email: user.profile?.email ?? "",
			phone: user.profile?.phoneNumber,
			profileImageURL: user.profile?.imageURL(withDimension: 100)?.absoluteString
		)
		
		// Save or update user in local storage
		Task {
			await saveUser(userProfile)
			
			await MainActor.run {
				// Update current state
				currentUser = userProfile
				isAuthenticated = true
				userProfile.updateLastLogin()
			}
		}
	}
	#endif
	
	private func saveUser(_ user: User) async {
		do {
			try await storageService.saveUser(user)
			await MainActor.run {
				currentUser = user
			}
		} catch {
			await MainActor.run {
				errorMessage = "Failed to save user: \(error.localizedDescription)"
			}
		}
	}
	
	private func fetchLocalUser() async {
		do {
			if let user = try await storageService.fetchUser() {
				await MainActor.run {
					currentUser = user
					isAuthenticated = true
				}
			}
		} catch {
			await MainActor.run {
				errorMessage = "Failed to fetch local user: \(error.localizedDescription)"
			}
		}
	}
	
	private func clearLocalUser() async {
		do {
			try await storageService.clearUser()
		} catch {
			await MainActor.run {
				errorMessage = "Failed to clear local user: \(error.localizedDescription)"
			}
		}
	}
}
