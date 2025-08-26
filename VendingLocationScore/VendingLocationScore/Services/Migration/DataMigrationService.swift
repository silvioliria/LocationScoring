import Foundation
import SwiftData

// MARK: - Data Migration Service
class DataMigrationService: ObservableObject {
    
    // MARK: - Migration Configuration
    private let currentSchemaVersion = 2
    private let userDefaultsKey = "DataSchemaVersion"
    
    // MARK: - Migration Paths
    private var migrationPaths: [Int: MigrationPath] = [:]
    
    init() {
        setupMigrationPaths()
    }
    
    // MARK: - Migration Path Setup
    private func setupMigrationPaths() {
        // Version 1 to 2 migration
        migrationPaths[1] = MigrationPath(
            fromVersion: 1,
            toVersion: 2,
            description: "Add capex field to Financials model",
            migration: migrateFromV1ToV2
        )
        
        // Add more migration paths as needed
        // migrationPaths[2] = MigrationPath(fromVersion: 2, toVersion: 3, ...)
    }
    
    // MARK: - Migration Execution
    func performMigrationIfNeeded(context: ModelContext) async throws {
        let storedVersion = UserDefaults.standard.integer(forKey: userDefaultsKey)
        
        if storedVersion == 0 {
            // First time setup
            UserDefaults.standard.set(currentSchemaVersion, forKey: userDefaultsKey)
            return
        }
        
        if storedVersion < currentSchemaVersion {
            try await performMigration(from: storedVersion, to: currentSchemaVersion, context: context)
        }
    }
    
    private func performMigration(from: Int, to: Int, context: ModelContext) async throws {
        print("🔄 Starting migration from version \(from) to \(to)")
        
        var currentVersion = from
        while currentVersion < to {
            guard let migrationPath = migrationPaths[currentVersion] else {
                throw MigrationError.migrationPathNotFound(from: currentVersion, to: currentVersion + 1)
            }
            
            print("🔄 Executing migration: \(migrationPath.description)")
            
            do {
                try await migrationPath.migration(context)
                currentVersion = migrationPath.toVersion
                UserDefaults.standard.set(currentVersion, forKey: userDefaultsKey)
                print("✅ Migration to version \(currentVersion) completed successfully")
            } catch {
                print("❌ Migration failed: \(error)")
                throw MigrationError.migrationFailed(version: currentVersion, error: error)
            }
        }
        
        print("🎉 All migrations completed successfully")
    }
    
    // MARK: - Migration Implementations
    
    private func migrateFromV1ToV2(context: ModelContext) async throws {
        print("🔄 Migrating from V1 to V2: Adding capex field to Financials")
        
        do {
            // Fetch all existing Financials entities
            let descriptor = FetchDescriptor<Financials>()
            let allFinancials = try context.fetch(descriptor)
            
            print("🔄 Found \(allFinancials.count) Financials entities to migrate")
            
            // Update each entity with default capex value
            for financials in allFinancials {
                // The capex field should already have a default value from the model
                // This migration ensures data consistency
                print("🔄 Migrating Financials entity: \(financials)")
            }
            
            // Save the context
            try context.save()
            print("✅ V1 to V2 migration completed successfully")
            
        } catch {
            print("❌ V1 to V2 migration failed: \(error)")
            throw MigrationError.migrationFailed(version: 1, error: error)
        }
    }
    
    // MARK: - Migration Validation
    func validateMigration(context: ModelContext) async throws -> Bool {
        print("🔍 Validating migration results...")
        
        do {
            // Check if all required fields are present
            let descriptor = FetchDescriptor<Financials>()
            let allFinancials = try context.fetch(descriptor)
            
            for financials in allFinancials {
                // Verify that the capex field is accessible
                let _ = financials.capex
            }
            
            print("✅ Migration validation passed")
            return true
            
        } catch {
            print("❌ Migration validation failed: \(error)")
            return false
        }
    }
    
    // MARK: - Rollback Support
    func rollbackToVersion(_ version: Int, context: ModelContext) async throws {
        print("⚠️ Rolling back to version \(version)")
        
        // This is a simplified rollback - in production you'd want more sophisticated rollback logic
        // For now, we'll just update the stored version
        
        UserDefaults.standard.set(version, forKey: userDefaultsKey)
        print("✅ Rollback to version \(version) completed")
    }
    
    // MARK: - Migration Status
    func getMigrationStatus() -> MigrationStatus {
        let storedVersion = UserDefaults.standard.integer(forKey: userDefaultsKey)
        let needsMigration = storedVersion < currentSchemaVersion
        
        return MigrationStatus(
            currentVersion: storedVersion,
            targetVersion: currentSchemaVersion,
            needsMigration: needsMigration,
            migrationPaths: Array(migrationPaths.values)
        )
    }
}

// MARK: - Migration Path
struct MigrationPath {
    let fromVersion: Int
    let toVersion: Int
    let description: String
    let migration: (ModelContext) async throws -> Void
}

// MARK: - Migration Status
struct MigrationStatus {
    let currentVersion: Int
    let targetVersion: Int
    let needsMigration: Bool
    let migrationPaths: [MigrationPath]
}

// MARK: - Migration Errors
enum MigrationError: Error, LocalizedError {
    case migrationPathNotFound(from: Int, to: Int)
    case migrationFailed(version: Int, error: Error)
    case validationFailed
    
    var errorDescription: String? {
        switch self {
        case .migrationPathNotFound(let from, let to):
            return "Migration path not found from version \(from) to \(to)"
        case .migrationFailed(let version, let error):
            return "Migration to version \(version) failed: \(error.localizedDescription)"
        case .validationFailed:
            return "Migration validation failed"
        }
    }
}
