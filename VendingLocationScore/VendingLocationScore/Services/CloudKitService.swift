// MARK: - CloudKit Service (Temporarily disabled for Personal Team development)
/*
import Foundation
import CloudKit
import SwiftUI

@MainActor
class CloudKitService: ObservableObject, StorageService {
    static let shared = CloudKitService()

    private let container = CKContainer.default()
    private let database: CKDatabase

    @Published var isSignedInToiCloud = false
    @Published var error: String?

    var isAvailable: Bool { isSignedInToiCloud }

    private init() {
        self.database = container.privateCloudDatabase
        Task {
            await checkiCloudStatus()
        }
    }

    // MARK: - iCloud Status

    private func checkiCloudStatus() async {
        do {
            let status = try await container.accountStatus()
            await MainActor.run {
                self.isSignedInToiCloud = status == .available
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to check iCloud status: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Location Operations

    func saveLocation(_ location: Location) async throws -> Location {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }

        let record = try location.toCKRecord()
        _ = try await database.save(record)

        // Update the location with the saved record ID
        // Note: We'll need to handle this differently since Location.id is UUID
        return location
    }

    func fetchLocations() async throws -> [Location] {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }

        let query = CKQuery(recordType: "Location", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let result = try await database.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }

        return try records.compactMap { record in
            try Location(from: record)
        }
    }

    func deleteLocation(_ location: Location) async throws {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }

        // For now, we'll need to find the record by other means
        // This is a temporary workaround - we'll implement proper ID handling later
        throw CloudKitError.recordNotFound // Temporarily throws error
    }

    // MARK: - User Operations

    func saveUser(_ user: User) async throws {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }

        let record = try user.toCKRecord()
        _ = try await database.save(record)
    }

    func fetchUser() async throws -> User? {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }

        // For now, return nil - implement proper user fetching when needed
        return nil
    }

    func clearUser() async throws {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }

        // Implement user clearing when needed
    }

    // MARK: - Error Handling

    enum CloudKitError: LocalizedError {
        case notSignedIn
        case recordNotFound
        case networkError
        case permissionDenied

        var errorDescription: String? {
            switch self {
            case .notSignedIn:
                return "Please sign in to iCloud to use this app"
            case .recordNotFound:
                return "Record not found"
            case .networkError:
                return "Network error. Please check your connection"
            case .permissionDenied:
                return "Permission denied. Please check your iCloud settings"
            }
        }
    }
}
*/
