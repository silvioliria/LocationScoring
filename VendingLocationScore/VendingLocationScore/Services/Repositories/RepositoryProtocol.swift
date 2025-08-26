import Foundation
import SwiftData

// MARK: - Base Repository Protocol
protocol RepositoryProtocol {
    associatedtype Entity
    
    // MARK: - CRUD Operations
    func create(_ entity: Entity) async throws
    func fetch(id: String) async throws -> Entity?
    func fetchAll() async throws -> [Entity]
    func update(_ entity: Entity) async throws
    func delete(_ entity: Entity) async throws
    func deleteAll() async throws
    
    // MARK: - Query Operations
    func fetch(predicate: Predicate<Entity>) async throws -> [Entity]
    func fetch(predicate: Predicate<Entity>, sortBy: [SortDescriptor<Entity>]) async throws -> [Entity]
    func count(predicate: Predicate<Entity>?) async throws -> Int
    
    // MARK: - Pagination
    func fetch(page: Int, pageSize: Int, predicate: Predicate<Entity>?, sortBy: [SortDescriptor<Entity>]) async throws -> PaginatedResult<Entity>
}

// MARK: - Pagination Result
struct PaginatedResult<T> {
    let items: [T]
    let currentPage: Int
    let pageSize: Int
    let totalCount: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
    
    var totalPages: Int {
        Int(ceil(Double(totalCount) / Double(pageSize)))
    }
}

// MARK: - Repository Error
enum RepositoryError: Error, LocalizedError {
    case entityNotFound
    case invalidEntity
    case saveFailed
    case deleteFailed
    case fetchFailed
    case contextNotAvailable
    case invalidPredicate
    
    var errorDescription: String? {
        switch self {
        case .entityNotFound:
            return "Entity not found"
        case .invalidEntity:
            return "Invalid entity"
        case .saveFailed:
            return "Failed to save entity"
        case .deleteFailed:
            return "Failed to delete entity"
        case .fetchFailed:
            return "Failed to fetch entities"
        case .contextNotAvailable:
            return "Model context not available"
        case .invalidPredicate:
            return "Invalid predicate"
        }
    }
}
