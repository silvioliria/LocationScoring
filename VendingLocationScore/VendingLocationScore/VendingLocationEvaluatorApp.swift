import SwiftUI
import SwiftData

@main
struct VendingLocationEvaluatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(createModelContainer())
        }
    }
    
    private func createModelContainer() -> ModelContainer {
        // First, try to create a container with the default configuration
        do {
            let schema = Schema([
                Location.self,
                LocationType.self,
                OfficeMetrics.self,
                GeneralMetrics.self,
                Financials.self,
                Scorecard.self,
                User.self,
                MetricDefinition.self,
                MetricInstance.self,
                LocationMetrics.self
            ])
            
            let modelConfiguration = ModelConfiguration(schema: schema)
            
            // Try to create the container
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ ModelContainer created successfully with default configuration")
            return container
            
        } catch {
            print("❌ Failed to create ModelContainer with default configuration: \(error)")
            print("🔄 Attempting to create fresh container...")
            
            // If that fails, try to create a completely fresh container
            do {
                // Clear any existing database files from ALL possible locations
                clearAllDatabaseFiles()
                
                // Create a fresh container with a custom URL to avoid conflicts
                let schema = Schema([
                    Location.self,
                    LocationType.self,
                    OfficeMetrics.self,
                    GeneralMetrics.self,
                    Financials.self,
                    Scorecard.self,
                    User.self,
                    MetricDefinition.self,
                    MetricInstance.self,
                    LocationMetrics.self
                ])
                
                // Create a custom configuration with a fresh database URL
                let customURL = getFreshDatabaseURL()
                let modelConfiguration = ModelConfiguration(schema: schema, url: customURL)
                
                let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                print("✅ Fresh ModelContainer created successfully at: \(customURL)")
                return container
                
            } catch {
                print("❌ Failed to create fresh ModelContainer: \(error)")
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }
    
    private func clearAllDatabaseFiles() {
        print("🔄 Clearing all database files...")
        
        // Clear from Documents directory
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let documentsDBURL = documentsPath.appendingPathComponent("default.store")
            deleteFileIfExists(at: documentsDBURL, description: "Documents directory")
        }
        
        // Clear from Library/Application Support directory (where SwiftData actually stores)
        if let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first {
            let appSupportPath = libraryPath.appendingPathComponent("Application Support")
            let appSupportDBURL = appSupportPath.appendingPathComponent("default.store")
            deleteFileIfExists(at: appSupportDBURL, description: "Application Support directory")
            
            // Also try the full path that appears in the error logs
            let fullPath = libraryPath.appendingPathComponent("Application Support/default.store")
            deleteFileIfExists(at: fullPath, description: "Full Application Support path")
        }
        
        // Clear stored data
        UserDefaults.standard.removeObject(forKey: "DataSchemaVersion")
        UserDefaults.standard.removeObject(forKey: "current_user")
        
        print("🔄 Database cleanup completed")
    }
    
    private func deleteFileIfExists(at url: URL, description: String) {
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
                print("🔄 Deleted database file from \(description): \(url.path)")
            } else {
                print("ℹ️ No database file found in \(description): \(url.path)")
            }
        } catch {
            print("❌ Error deleting database from \(description): \(error)")
        }
    }
    
    private func getFreshDatabaseURL() -> URL {
        // Create a fresh database URL with timestamp to avoid conflicts
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "fresh_database_\(timestamp).store"
        
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsPath.appendingPathComponent(fileName)
        } else {
            // Fallback to temporary directory
            return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        }
    }
}
