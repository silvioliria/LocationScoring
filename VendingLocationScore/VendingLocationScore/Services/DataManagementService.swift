import Foundation
import SwiftData
import Combine

// MARK: - Data Management Service Protocol
@preconcurrency
protocol DataManagementService: ObservableObject {
    var isAvailable: Bool { get }
    var error: String? { get set }
    
    // Location operations
    func createLocation(_ location: Location) async throws
    func fetchLocations() async throws -> [Location]
    func updateLocation(_ location: Location) async throws
    func deleteLocation(_ location: Location) async throws
    
    // User operations
    func saveUser(_ user: User) async throws
    func fetchUser() async throws -> User?
    func clearUser() async throws
    
    // Metrics operations
    func saveMetrics(_ metrics: any MetricBase) async throws
    func fetchMetrics(for locationId: UUID) async throws -> [any MetricBase]
    
    // Sync operations
    func syncData() async throws
    func isDataSynced() async -> Bool
}

// MARK: - Data Management Service Factory
@MainActor
class DataManagementServiceFactory {
    static func createDataManagementService() -> any DataManagementService {
        // For now, use local storage
        // When ready for CloudKit, change this to:
        // return CloudKitDataService.shared.isSignedInToiCloud ? CloudKitDataService.shared : LocalDataService.shared
        return LocalDataService.shared
    }
}

// MARK: - Local Data Service Implementation
@MainActor
class LocalDataService: ObservableObject, @preconcurrency DataManagementService {
    static let shared = LocalDataService()
    
    @Published var error: String?
    
    var isAvailable: Bool { true } // Always available locally
    
    private var context: ModelContext?
    private let userDefaults = UserDefaults.standard
    private let userKey = "current_user"
    
    private init() {}
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Location Operations
    
    func createLocation(_ location: Location) async throws {
        guard let context = context else {
            throw NSError(domain: "DataServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }
        
        do {
            context.insert(location)
            try context.save()
            print("🔍 Location created successfully: \(location.name)")
        } catch {
            await MainActor.run {
                self.error = "Failed to create location: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    func fetchLocations() async throws -> [Location] {
        guard let context = context else {
            throw NSError(domain: "DataServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }
        
        do {
            let descriptor = FetchDescriptor<Location>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            let locations = try context.fetch(descriptor)
            print("🔍 Fetched \(locations.count) locations")
            return locations
        } catch {
            await MainActor.run {
                self.error = "Failed to fetch locations: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    func updateLocation(_ location: Location) async throws {
        guard let context = context else {
            throw NSError(domain: "DataServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }
        
        do {
            try context.save()
            print("🔍 Location updated successfully: \(location.name)")
        } catch {
            await MainActor.run {
                self.error = "Failed to update location: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    func deleteLocation(_ location: Location) async throws {
        guard let context = context else {
            throw NSError(domain: "DataServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }
        
        do {
            context.delete(location)
            try context.save()
            print("🔍 Location deleted successfully: \(location.name)")
        } catch {
            await MainActor.run {
                self.error = "Failed to delete location: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - User Operations
    
    func saveUser(_ user: User) async throws {
        do {
            let data = try JSONEncoder().encode(user)
            userDefaults.set(data, forKey: userKey)
            print("🔍 User saved successfully: \(user.name)")
        } catch {
            await MainActor.run {
                self.error = "Failed to save user: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    func fetchUser() async throws -> User? {
        guard let data = userDefaults.data(forKey: userKey) else {
            return nil
        }
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            print("🔍 User fetched successfully: \(user.name)")
            return user
        } catch {
            await MainActor.run {
                self.error = "Failed to fetch user: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    func clearUser() async throws {
        userDefaults.removeObject(forKey: userKey)
        print("🔍 User cleared successfully")
    }
    
    // MARK: - Metrics Operations
    
    func saveMetrics(_ metrics: any MetricBase) async throws {
        guard let context = context else {
            throw NSError(domain: "DataServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }
        
        do {
            try context.save()
            print("🔍 Metrics saved successfully")
        } catch {
            await MainActor.run {
                self.error = "Failed to save metrics: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    func fetchMetrics(for locationId: UUID) async throws -> [any MetricBase] {
        // This is a simplified implementation - you might want to expand this
        // based on your specific metrics structure
        print("🔍 Fetching metrics for location: \(locationId)")
        return []
    }
    
    // MARK: - Sync Operations
    
    func syncData() async throws {
        // Local storage doesn't need syncing
        print("🔍 Local data sync completed (no-op)")
    }
    
    func isDataSynced() async -> Bool {
        // Local storage is always "synced"
        return true
    }
}

// MARK: - CloudKit Data Service (Future Implementation)
/*
@MainActor
class CloudKitDataService: ObservableObject, @preconcurrency DataManagementService {
    static let shared = CloudKitDataService()
    
    @Published var error: String?
    
    var isAvailable: Bool {
        // Check if user is signed into iCloud
        return CKContainer.default().accountStatus() == .available
    }
    
    // Implement all the protocol methods using CloudKit
    // This will be implemented when you're ready to add CloudKit support
}
*/
