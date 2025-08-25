import Foundation

// MARK: - Local Storage Service (User-only, locations now use SwiftData)
class LocalStorageService: ObservableObject, @preconcurrency StorageService {
    static let shared = LocalStorageService()
    
    @Published var error: String?
    
    var isAvailable: Bool { true } // Always available
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "current_user"
    
    private init() {}
    
    // MARK: - User Operations (Locations now use SwiftData)
    
    func saveUser(_ user: User) async throws {
        do {
            let data = try JSONEncoder().encode(user)
            userDefaults.set(data, forKey: userKey)
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
    }
}
