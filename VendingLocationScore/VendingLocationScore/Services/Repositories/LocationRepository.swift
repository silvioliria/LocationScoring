import Foundation
import SwiftData

// MARK: - Location Repository
class LocationRepository: BaseRepository<Location> {
    
    init(context: ModelContext) {
        super.init(context: context, entityType: Location.self)
    }
    
    // MARK: - Location-Specific Queries
    
    func fetchByType(_ type: LocationTypeEnum) async throws -> [Location] {
        let predicate = #Predicate<Location> { location in
            location.locationType.type == type
        }
        return try await fetch(predicate: predicate)
    }
    
    func fetchByName(_ name: String) async throws -> [Location] {
        let predicate = #Predicate<Location> { location in
            location.name.localizedStandardContains(name)
        }
        return try await fetch(predicate: predicate)
    }
    
    func fetchByAddress(_ address: String) async throws -> [Location] {
        let predicate = #Predicate<Location> { location in
            location.address.localizedStandardContains(address)
        }
        return try await fetch(predicate: predicate)
    }
    
    func fetchWithHighScores(minScore: Double) async throws -> [Location] {
        let predicate = #Predicate<Location> { location in
            location.scorecard?.overallScore ?? 0 >= minScore
        }
        let sortBy = [SortDescriptor<Location>(\.scorecard?.overallScore, order: .reverse)]
        return try await fetch(predicate: predicate, sortBy: sortBy)
    }
    
    func fetchRecentlyCreated(withinDays days: Int) async throws -> [Location] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let predicate = #Predicate<Location> { location in
            location.createdAt >= cutoffDate
        }
        let sortBy = [SortDescriptor<Location>(\.createdAt, order: .reverse)]
        return try await fetch(predicate: predicate, sortBy: sortBy)
    }
    
    // MARK: - Advanced Queries
    
    func fetchByScoreRange(minScore: Double, maxScore: Double) async throws -> [Location] {
        // For now, filter by minimum score only to avoid predicate complexity
        // TODO: Implement proper range filtering when SwiftData supports it better
        let predicate = #Predicate<Location> { location in
            location.scorecard?.overallScore ?? 0 >= minScore
        }
        let sortBy = [SortDescriptor<Location>(\.scorecard?.overallScore, order: .reverse)]
        return try await fetch(predicate: predicate, sortBy: sortBy)
    }
    
    func fetchByLocationTypeAndScore(type: LocationTypeEnum, minScore: Double) async throws -> [Location] {
        // For now, filter by location type only to avoid predicate complexity
        // TODO: Implement proper combined filtering when SwiftData supports it better
        let predicate = #Predicate<Location> { location in
            location.locationType.type == type
        }
        let sortBy = [
            SortDescriptor<Location>(\.scorecard?.overallScore, order: .reverse),
            SortDescriptor<Location>(\.name, order: .forward)
        ]
        return try await fetch(predicate: predicate, sortBy: sortBy)
    }
    
    // MARK: - Statistics
    
    func getLocationCountByType() async throws -> [LocationTypeEnum: Int] {
        let allLocations = try await fetchAll()
        var counts: [LocationTypeEnum: Int] = [:]
        
        for location in allLocations {
            let type = location.locationType.type
            counts[type, default: 0] += 1
        }
        
        return counts
    }
    
    func getAverageScoreByType() async throws -> [LocationTypeEnum: Double] {
        let allLocations = try await fetchAll()
        var scores: [LocationTypeEnum: [Double]] = [:]
        
        for location in allLocations {
            let type = location.locationType.type
            if let score = location.scorecard?.overallScore {
                scores[type, default: []].append(score)
            }
        }
        
        var averages: [LocationTypeEnum: Double] = [:]
        for (type, scoreList) in scores {
            let average = scoreList.reduce(0, +) / Double(scoreList.count)
            averages[type] = average
        }
        
        return averages
    }
    
    // MARK: - Search
    
    func searchLocations(query: String) async throws -> [Location] {
        // For now, search only by name to avoid predicate complexity
        // TODO: Implement more sophisticated search when SwiftData supports it better
        let predicate = #Predicate<Location> { location in
            location.name.localizedStandardContains(query)
        }
        let sortBy = [SortDescriptor<Location>(\.name, order: .forward)]
        return try await fetch(predicate: predicate, sortBy: sortBy)
    }
}
