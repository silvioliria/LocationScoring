import Foundation
import SwiftData

// MARK: - Base Repository Implementation
class BaseRepository<T: PersistentModel>: RepositoryProtocol {
    typealias Entity = T
    
    private let context: ModelContext
    private let entityType: T.Type
    
    init(context: ModelContext, entityType: T.Type) {
        self.context = context
        self.entityType = entityType
    }
    
    // MARK: - CRUD Operations
    
    func create(_ entity: Entity) async throws {
        guard context.hasChanges else { return }
        
        do {
            context.insert(entity)
            try context.save()
        } catch {
            throw RepositoryError.saveFailed
        }
    }
    
    func fetch(id: String) async throws -> Entity? {
        do {
            // For now, fetch all and filter manually to avoid predicate issues
            let allEntities = try await fetchAll()
            return allEntities.first { entity in
                if let identifiable = entity as? any Identifiable {
                    return identifiable.id as? String == id
                }
                return false
            }
        } catch {
            throw RepositoryError.fetchFailed
        }
    }
    
    func fetchAll() async throws -> [Entity] {
        do {
            let descriptor = FetchDescriptor<Entity>()
            return try context.fetch(descriptor)
        } catch {
            throw RepositoryError.fetchFailed
        }
    }
    
    func update(_ entity: Entity) async throws {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            throw RepositoryError.saveFailed
        }
    }
    
    func delete(_ entity: Entity) async throws {
        do {
            context.delete(entity)
            try context.save()
        } catch {
            throw RepositoryError.deleteFailed
        }
    }
    
    func deleteAll() async throws {
        do {
            try context.delete(model: entityType)
            try context.save()
        } catch {
            throw RepositoryError.deleteFailed
        }
    }
    
    // MARK: - Query Operations
    
    func fetch(predicate: Predicate<Entity>) async throws -> [Entity] {
        do {
            let descriptor = FetchDescriptor<Entity>(predicate: predicate)
            return try context.fetch(descriptor)
        } catch {
            throw RepositoryError.fetchFailed
        }
    }
    
    func fetch(predicate: Predicate<Entity>, sortBy: [SortDescriptor<Entity>]) async throws -> [Entity] {
        do {
            let descriptor = FetchDescriptor<Entity>(predicate: predicate, sortBy: sortBy)
            return try context.fetch(descriptor)
        } catch {
            throw RepositoryError.fetchFailed
        }
    }
    
    func count(predicate: Predicate<Entity>?) async throws -> Int {
        do {
            let descriptor = FetchDescriptor<Entity>(predicate: predicate)
            return try context.fetchCount(descriptor)
        } catch {
            throw RepositoryError.fetchFailed
        }
    }
    
    // MARK: - Pagination
    
    func fetch(page: Int, pageSize: Int, predicate: Predicate<Entity>?, sortBy: [SortDescriptor<Entity>]) async throws -> PaginatedResult<Entity> {
        do {
            let totalCount = try await count(predicate: predicate)
            
            var descriptor = FetchDescriptor<Entity>(
                predicate: predicate,
                sortBy: sortBy
            )
            
            // Calculate offset
            let offset = page * pageSize
            descriptor.fetchOffset = offset
            descriptor.fetchLimit = pageSize
            
            let items = try context.fetch(descriptor)
            
            let hasNextPage = offset + pageSize < totalCount
            let hasPreviousPage = page > 0
            
            return PaginatedResult(
                items: items,
                currentPage: page,
                pageSize: pageSize,
                totalCount: totalCount,
                hasNextPage: hasNextPage,
                hasPreviousPage: hasPreviousPage
            )
        } catch {
            throw RepositoryError.fetchFailed
        }
    }
}
