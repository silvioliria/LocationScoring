import Foundation
import SwiftData
import Combine

// MARK: - Data Management Service Protocol
@preconcurrency
protocol DataManagementService: ObservableObject {
    var context: ModelContext? { get set }
    
    // MARK: - Location Management
    func createLocation(name: String, address: String, comment: String?, locationType: LocationTypeEnum) async throws -> Location
    func fetchLocations() async throws -> [Location]
    func updateLocation(_ location: Location) async throws
    func deleteLocation(_ location: Location) async throws
    
    // MARK: - Metrics Management
    func saveMetrics(_ metrics: Any) async throws
    func fetchMetrics(for location: Location) async throws -> Any
    
    // MARK: - User operations
    func saveUser(_ user: User) async throws
    func fetchUser() async throws -> User?
    func clearUser() async throws
    
    // MARK: - Sync operations
    func syncData() async throws
    func isDataSynced() async -> Bool
}

// MARK: - Shared ModelContext Access
@MainActor
class SharedModelContext: ObservableObject {
    static let shared = SharedModelContext()
    
    @Published var context: ModelContext?
    
    private init() {}
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    func getContext() -> ModelContext? {
        return context
    }
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
    
    var context: ModelContext?
    private let userDefaults = UserDefaults.standard
    private let userKey = "current_user"
    private let validationService = DataValidationService.shared
    
    private init() {}
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Location Management
    
    func createLocation(name: String, address: String, comment: String?, locationType: LocationTypeEnum) async throws -> Location {
        guard let context = context else {
            throw NSError(domain: "DataServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }
        
        print("🔍 Creating location with name: '\(name)', address: '\(address)', type: \(locationType)")
        
        // Use LocationManager to create the location
        let location = LocationManager.shared.createLocation(name: name, address: address, type: locationType, comment: comment ?? "")
        
        // Validate location before saving
        let validation = validationService.validateLocation(location)
        if validation.hasErrors {
            let errorMessage = "Location validation failed: " + validation.errors.joined(separator: "; ")
            throw NSError(domain: "ValidationError", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        // Log warnings if any
        if validation.hasWarnings {
            print("⚠️ Location validation warnings: \(validation.warnings.joined(separator: "; "))")
        }
        
        do {
            context.insert(location)
            try context.save()
            print("🔍 Location created successfully: \(location.name)")
            return location
        } catch {
            await MainActor.run {
                self.error = "Failed to create location: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    func fetchLocations() async throws -> [Location] {
        guard let context = context else {
            print("🔍 ERROR: ModelContext not set in DataManagementService")
            throw NSError(domain: "DataServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }
        
        print("🔍 ModelContext is set, attempting to fetch locations...")
        
        do {
            let descriptor = FetchDescriptor<Location>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            print("🔍 FetchDescriptor created, about to call context.fetch...")
            let locations = try context.fetch(descriptor)
            print("🔍 Successfully fetched \(locations.count) locations from SwiftData")
            return locations
        } catch {
            print("🔍 ERROR in fetchLocations: \(error)")
            print("🔍 Error type: \(type(of: error))")
            if let nsError = error as NSError? {
                print("🔍 NSError domain: \(nsError.domain), code: \(nsError.code)")
                print("🔍 NSError userInfo: \(nsError.userInfo)")
            }
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
        
        // Validate location before updating
        let validation = validationService.validateLocation(location)
        if validation.hasErrors {
            let errorMessage = "Validation failed: " + validation.errors.joined(separator: "; ")
            throw NSError(domain: "ValidationError", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        // Log warnings if any
        if validation.hasWarnings {
            print("⚠️ Location validation warnings: \(validation.warnings.joined(separator: "; "))")
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
        // Validate user before saving
        let validation = validationService.validateUser(user)
        if validation.hasErrors {
            let errorMessage = "User validation failed: " + validation.errors.joined(separator: "; ")
            throw NSError(domain: "ValidationError", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        // Log warnings if any
        if validation.hasWarnings {
            print("⚠️ User validation warnings: \(validation.warnings.joined(separator: "; "))")
        }
        
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
    
    func saveMetrics(_ metrics: Any) async throws {
        guard let context = context else {
            throw NSError(domain: "DataServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }
        
        // Since GeneralMetrics doesn't conform to MetricBase, we'll handle this differently
        // For now, just save the context without validation
        print("🔍 Saving metrics (type: \(type(of: metrics)))")
        
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
    
    func fetchMetrics(for location: Location) async throws -> Any {
        // This is a simplified implementation - you might want to expand this
        // based on your specific metrics structure
        print("🔍 Fetching metrics for location: \(location.name)")
        
        // For now, return the general metrics if they exist
        if let generalMetrics = location.generalMetrics {
            return generalMetrics
        }
        
        // If no metrics exist, throw an error
        throw NSError(domain: "DataServiceError", code: 4, userInfo: [NSLocalizedDescriptionKey: "No metrics found for location"])
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
