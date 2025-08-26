import Foundation
import SwiftData

// MARK: - Metrics Repository
class MetricsRepository: BaseRepository<GeneralMetrics> {
    
    init(context: ModelContext) {
        super.init(context: context, entityType: GeneralMetrics.self)
    }
    
    // MARK: - Metrics-Specific Queries
    
    func fetchByLocation(_ location: Location) async throws -> GeneralMetrics? {
        return location.generalMetrics
    }
    
    func fetchByScoreRange(minScore: Double, maxScore: Double) async throws -> [GeneralMetrics] {
        // For now, filter by foot traffic rating as a proxy for overall score
        // TODO: Implement proper score calculation when SwiftData supports it better
        let minRating = Int(minScore)
        let predicate = #Predicate<GeneralMetrics> { metrics in
            metrics.footTrafficRating >= minRating
        }
        let sortBy = [SortDescriptor<GeneralMetrics>(\.footTrafficRating, order: .reverse)]
        return try await fetch(predicate: predicate, sortBy: sortBy)
    }
    
    func fetchHighPerformingMetrics(minScore: Double) async throws -> [GeneralMetrics] {
        // For now, filter by foot traffic rating as a proxy for overall score
        let minRating = Int(minScore)
        let predicate = #Predicate<GeneralMetrics> { metrics in
            metrics.footTrafficRating >= minRating
        }
        let sortBy = [SortDescriptor<GeneralMetrics>(\.footTrafficRating, order: .reverse)]
        return try await fetch(predicate: predicate, sortBy: sortBy)
    }
    
    func fetchByFootTrafficRange(min: Int, max: Int) async throws -> [GeneralMetrics] {
        // Simplified predicate to avoid multiple expressions
        let predicate = #Predicate<GeneralMetrics> { metrics in
            metrics.footTrafficDaily >= min
        }
        let sortBy = [SortDescriptor<GeneralMetrics>(\.footTrafficDaily, order: .reverse)]
        return try await fetch(predicate: predicate, sortBy: sortBy)
    }
    
    // MARK: - Financial Metrics
    
    func fetchByRevenueRange(minRevenue: Double, maxRevenue: Double) async throws -> [GeneralMetrics] {
        // This would need to be implemented based on how financial data is linked to general metrics
        // For now, returning empty array as placeholder
        return []
    }
    
    // MARK: - Analytics
    
    func getAverageFootTraffic() async throws -> Double {
        let allMetrics = try await fetchAll()
        let total = allMetrics.reduce(0) { $0 + $1.footTrafficDaily }
        return Double(total) / Double(allMetrics.count)
    }
    
    func getAverageRatingByCategory() async throws -> [String: Double] {
        let allMetrics = try await fetchAll()
        var categoryScores: [String: [Double]] = [:]
        
        for metrics in allMetrics {
            categoryScores["footTraffic", default: []].append(Double(metrics.footTrafficRating))
            categoryScores["targetDemographic", default: []].append(Double(metrics.targetDemographicRating))
            categoryScores["hostCommission", default: []].append(Double(metrics.hostCommissionRating))
            categoryScores["competition", default: []].append(Double(metrics.competitionRating))
            categoryScores["visibility", default: []].append(Double(metrics.visibilityRating))
            categoryScores["security", default: []].append(Double(metrics.securityRating))
            categoryScores["parkingTransit", default: []].append(Double(metrics.parkingTransitRating))
            categoryScores["amenities", default: []].append(Double(metrics.amenitiesRating))
        }
        
        var averages: [String: Double] = [:]
        for (category, scores) in categoryScores {
            let average = scores.reduce(0, +) / Double(scores.count)
            averages[category] = average
        }
        
        return averages
    }
    
    // MARK: - Performance Metrics
    
    func getTopPerformingLocations(limit: Int) async throws -> [GeneralMetrics] {
        let allMetrics = try await fetchAll()
        let sortedMetrics = allMetrics.sorted { 
            $0.calculateOverallScore() > $1.calculateOverallScore() 
        }
        return Array(sortedMetrics.prefix(limit))
    }
    
    func getMetricsByPerformanceTier() async throws -> [String: [GeneralMetrics]] {
        let allMetrics = try await fetchAll()
        var tiers: [String: [GeneralMetrics]] = [
            "excellent": [],
            "good": [],
            "average": [],
            "below_average": []
        ]
        
        for metrics in allMetrics {
            let score = metrics.calculateOverallScore()
            switch score {
            case 4.5...:
                tiers["excellent"]?.append(metrics)
            case 3.5..<4.5:
                tiers["good"]?.append(metrics)
            case 2.5..<3.5:
                tiers["average"]?.append(metrics)
            default:
                tiers["below_average"]?.append(metrics)
            }
        }
        
        return tiers
    }
}

// MARK: - Financial Metrics Repository
class FinancialMetricsRepository: BaseRepository<Financials> {
    
    init(context: ModelContext) {
        super.init(context: context, entityType: Financials.self)
    }
    
    // MARK: - Financial-Specific Queries
    
    func fetchByRevenueRange(minRevenue: Double, maxRevenue: Double) async throws -> [Financials] {
        // For now, return empty array as SwiftData predicates don't handle optionals well
        // TODO: Implement proper filtering when SwiftData supports optional handling better
        return []
    }
    
    func fetchByProfitMargin(minMargin: Double) async throws -> [Financials] {
        // For now, return empty array as SwiftData predicates don't handle optionals well
        // TODO: Implement proper filtering when SwiftData supports optional handling better
        return []
    }
    
    func fetchByROI(minROI: Double) async throws -> [Financials] {
        // For now, return empty array as SwiftData predicates don't handle optionals well
        // TODO: Implement proper filtering when SwiftData supports optional handling better
        return []
    }
    
    // MARK: - Financial Analytics
    
    func getAverageRevenue() async throws -> Double {
        let allFinancials = try await fetchAll()
        let total = allFinancials.reduce(0) { $0 + ($1.avgTicket ?? 0) }
        return total / Double(allFinancials.count)
    }
    
    func getAverageProfitMargin() async throws -> Double {
        let allFinancials = try await fetchAll()
        var totalMargin: Double = 0
        var validCount = 0
        
        for financials in allFinancials {
            if let avgTicket = financials.avgTicket, avgTicket > 0 {
                // For now, use a simplified margin calculation
                let margin = avgTicket * 0.3 // Assume 30% margin as placeholder
                totalMargin += margin
                validCount += 1
            }
        }
        
        return validCount > 0 ? totalMargin / Double(validCount) : 0
    }
    
    func getTopRevenueGenerators(limit: Int) async throws -> [Financials] {
        let allFinancials = try await fetchAll()
        let sorted = allFinancials.sorted { ($0.avgTicket ?? 0) > ($1.avgTicket ?? 0) }
        return Array(sorted.prefix(limit))
    }
}
