import Foundation

@MainActor
class LocalStorageService: ObservableObject, StorageService {
    static let shared = LocalStorageService()
    
    @Published var error: String?
    
    var isAvailable: Bool { true } // Always available
    
    private let userDefaults = UserDefaults.standard
    private let locationsKey = "saved_locations"
    private let userKey = "current_user"
    
    private init() {}
    
    // MARK: - Location Operations
    
    func saveLocation(_ location: Location) async throws -> Location {
        do {
            var locations = try await fetchLocations()
            
            // Check if location already exists (by ID) and update it
            if let existingIndex = locations.firstIndex(where: { $0.id == location.id }) {
                locations[existingIndex] = location
            } else {
                locations.append(location)
            }
            
            // Save to UserDefaults
            let data = try JSONEncoder().encode(locations)
            userDefaults.set(data, forKey: locationsKey)
            
            return location
        } catch {
            self.error = "Failed to save location: \(error.localizedDescription)"
            throw error
        }
    }
    
    func fetchLocations() async throws -> [Location] {
        guard let data = userDefaults.data(forKey: locationsKey) else {
            return []
        }
        
        do {
            let locations = try JSONDecoder().decode([Location].self, from: data)
            return locations.sorted { $0.createdAt > $1.createdAt } // Most recent first
        } catch {
            self.error = "Failed to fetch locations: \(error.localizedDescription)"
            throw error
        }
    }
    
    func deleteLocation(_ location: Location) async throws {
        do {
            var locations = try await fetchLocations()
            locations.removeAll { $0.id == location.id }
            
            let data = try JSONEncoder().encode(locations)
            userDefaults.set(data, forKey: locationsKey)
        } catch {
            self.error = "Failed to delete location: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - User Operations
    
    func saveUser(_ user: User) async throws {
        do {
            let data = try JSONEncoder().encode(user)
            userDefaults.set(data, forKey: userKey)
        } catch {
            self.error = "Failed to save user: \(error.localizedDescription)"
            throw error
        }
    }
    
    func fetchUser() async throws -> User? {
        guard let data = userDefaults.data(forKey: userKey) else {
            return nil
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            self.error = "Failed to fetch user: \(error.localizedDescription)"
            throw error
        }
    }
    
    func clearUser() async throws {
        userDefaults.removeObject(forKey: userKey)
    }
}
