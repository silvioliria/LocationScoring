import Foundation

// MARK: - Storage Service Protocol
@preconcurrency
protocol StorageService: ObservableObject {
    var isAvailable: Bool { get }
    var error: String? { get set }
    
    // Location operations
    func saveLocation(_ location: Location) async throws -> Location
    func fetchLocations() async throws -> [Location]
    func deleteLocation(_ location: Location) async throws
    
    // User operations
    func saveUser(_ user: User) async throws
    func fetchUser() async throws -> User?
    func clearUser() async throws
}

// MARK: - Storage Service Factory
@MainActor
class StorageServiceFactory {
    static func createStorageService() -> any StorageService {
        // For now, always use local storage since CloudKit requires paid dev account
        // When ready for CloudKit, change this to:
        // return CloudKitService.shared.isSignedInToiCloud ? CloudKitService.shared : LocalStorageService.shared
        return LocalStorageService.shared
    }
}
