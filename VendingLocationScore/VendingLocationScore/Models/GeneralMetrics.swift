import Foundation
import SwiftUI
import SwiftData

@Model
final class GeneralMetrics: Codable {
    var id: UUID
    
    // Core metrics
    var footTrafficDaily: Int
    var targetDemographicFit: String
    var nearbyCompetition: String
    var hostCommissionPct: Double // 0-1 decimal
    
    // Rating scores (1-5) for each rateable item
    var footTrafficRating: Int
    var targetDemographicRating: Int
    var hostCommissionRating: Int
    var competitionRating: Int
    var visibilityRating: Int
    var securityRating: Int
    var parkingTransitRating: Int
    var amenitiesRating: Int
    
    // Consolidated note fields for clarifications
    var footTrafficNotes: String
    var targetDemographicNotes: String
    var competitionNotes: String
    var hostCommissionNotes: String
    var visibilityNotes: String
    var securityNotes: String
    var parkingTransitNotes: String
    var amenitiesNotes: String
    
    // Note: Relationship removed to avoid circular dependency issues
    // var location: Location?
    
    init(
        footTrafficDaily: Int = 0,
        targetDemographicFit: String = "",
        nearbyCompetition: String = "",
        hostCommissionPct: Double = 0.0,
        footTrafficRating: Int = 0, // Changed from 1 to 0 for empty state
        targetDemographicRating: Int = 0, // Changed from 1 to 0 for empty state
        hostCommissionRating: Int = 0, // Changed from 1 to 0 for empty state
        competitionRating: Int = 0, // Changed from 1 to 0 for empty state
        visibilityRating: Int = 0, // Changed from 1 to 0 for empty state
        securityRating: Int = 0, // Changed from 1 to 0 for empty state
        parkingTransitRating: Int = 0, // Changed from 1 to 0 for empty state
        amenitiesRating: Int = 0, // Changed from 1 to 0 for empty state
        footTrafficNotes: String = "",
        targetDemographicNotes: String = "",
        competitionNotes: String = "",
        hostCommissionNotes: String = "",
        visibilityNotes: String = "",
        securityNotes: String = "",
        parkingTransitNotes: String = "",
        amenitiesNotes: String = ""
    ) {
        self.id = UUID()
        self.footTrafficDaily = footTrafficDaily
        self.targetDemographicFit = targetDemographicFit
        self.nearbyCompetition = nearbyCompetition
        self.hostCommissionPct = hostCommissionPct
        self.footTrafficRating = footTrafficRating
        self.targetDemographicRating = targetDemographicRating
        self.hostCommissionRating = hostCommissionRating
        self.competitionRating = competitionRating
        self.visibilityRating = visibilityRating
        self.securityRating = securityRating
        self.parkingTransitRating = parkingTransitRating
        self.amenitiesRating = amenitiesRating
        self.footTrafficNotes = footTrafficNotes
        self.targetDemographicNotes = targetDemographicNotes
        self.competitionNotes = competitionNotes
        self.hostCommissionNotes = hostCommissionNotes
        self.visibilityNotes = visibilityNotes
        self.securityNotes = securityNotes
        self.parkingTransitNotes = parkingTransitNotes
        self.amenitiesNotes = amenitiesNotes
    }

    // MARK: - Codable Support

    enum CodingKeys: String, CodingKey {
        case id, footTrafficDaily, targetDemographicFit, nearbyCompetition, hostCommissionPct
        case footTrafficRating, targetDemographicRating, hostCommissionRating, competitionRating
        case visibilityRating, securityRating, parkingTransitRating, amenitiesRating
        case footTrafficNotes, targetDemographicNotes, competitionNotes, hostCommissionNotes
        case visibilityNotes, securityNotes, parkingTransitNotes, amenitiesNotes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        footTrafficDaily = try container.decode(Int.self, forKey: .footTrafficDaily)
        targetDemographicFit = try container.decode(String.self, forKey: .targetDemographicFit)
        nearbyCompetition = try container.decode(String.self, forKey: .nearbyCompetition)
        hostCommissionPct = try container.decode(Double.self, forKey: .hostCommissionPct)
        footTrafficRating = try container.decode(Int.self, forKey: .footTrafficRating)
        targetDemographicRating = try container.decode(Int.self, forKey: .targetDemographicRating)
        hostCommissionRating = try container.decode(Int.self, forKey: .hostCommissionRating)
        competitionRating = try container.decode(Int.self, forKey: .competitionRating)
        visibilityRating = try container.decode(Int.self, forKey: .visibilityRating)
        securityRating = try container.decode(Int.self, forKey: .securityRating)
        parkingTransitRating = try container.decode(Int.self, forKey: .parkingTransitRating)
        amenitiesRating = try container.decode(Int.self, forKey: .amenitiesRating)
        footTrafficNotes = try container.decode(String.self, forKey: .footTrafficNotes)
        targetDemographicNotes = try container.decode(String.self, forKey: .targetDemographicNotes)
        competitionNotes = try container.decode(String.self, forKey: .competitionNotes)
        hostCommissionNotes = try container.decode(String.self, forKey: .hostCommissionNotes)
        visibilityNotes = try container.decode(String.self, forKey: .visibilityNotes)
        securityNotes = try container.decode(String.self, forKey: .securityNotes)
        parkingTransitNotes = try container.decode(String.self, forKey: .parkingTransitNotes)
        amenitiesNotes = try container.decode(String.self, forKey: .amenitiesNotes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(footTrafficDaily, forKey: .footTrafficDaily)
        try container.encode(targetDemographicFit, forKey: .targetDemographicFit)
        try container.encode(nearbyCompetition, forKey: .nearbyCompetition)
        try container.encode(hostCommissionPct, forKey: .hostCommissionPct)
        try container.encode(footTrafficRating, forKey: .footTrafficRating)
        try container.encode(targetDemographicRating, forKey: .targetDemographicRating)
        try container.encode(hostCommissionRating, forKey: .hostCommissionRating)
        try container.encode(competitionRating, forKey: .competitionRating)
        try container.encode(visibilityRating, forKey: .visibilityRating)
        try container.encode(securityRating, forKey: .securityRating)
        try container.encode(parkingTransitRating, forKey: .parkingTransitRating)
        try container.encode(amenitiesRating, forKey: .amenitiesRating)
        try container.encode(footTrafficNotes, forKey: .footTrafficNotes)
        try container.encode(targetDemographicNotes, forKey: .targetDemographicNotes)
        try container.encode(competitionNotes, forKey: .competitionNotes)
        try container.encode(hostCommissionNotes, forKey: .hostCommissionNotes)
        try container.encode(visibilityNotes, forKey: .visibilityNotes)
        try container.encode(securityNotes, forKey: .securityNotes)
        try container.encode(parkingTransitNotes, forKey: .parkingTransitNotes)
        try container.encode(amenitiesNotes, forKey: .amenitiesNotes)
    }
    
    // Computed foot traffic score based on requirements (updated scale: 1-500)
    var footTrafficScore: Int {
        switch footTrafficDaily {
        case 500...: return 5      // > 500
        case 350..<500: return 4   // 350 to 500
        case 200..<350: return 3   // 200 to 350
        case 100..<200: return 2   // 100 to 200
        case 1..<100: return 1     // < 100
        default: return 0
        }
    }
    
    // MARK: - Overall Score Calculation
    
    func calculateOverallScore() -> Double {
        let ratings = [
            footTrafficRating,
            targetDemographicRating,
            hostCommissionRating,
            competitionRating,
            visibilityRating,
            securityRating,
            parkingTransitRating,
            amenitiesRating
        ]
        
        // Filter out unrated metrics (rating = 0)
        let ratedMetrics = ratings.filter { $0 > 0 }
        
        // Require at least 3 metrics to be rated before calculating a meaningful score
        guard ratedMetrics.count >= 3 else { return 0.0 }
        
        let total = ratedMetrics.reduce(0) { $0 + $1 }
        return Double(total) / Double(ratedMetrics.count)
    }
    
    // MARK: - Computed Objective Scores
    
    /// Computed demographic fit score based on targetDemographicFit string
    var computedDemographicFitScore: Int {
        let lowercased = targetDemographicFit.lowercased()
        if lowercased.contains("excellent") || lowercased.contains("perfect") { return 5 }
        if lowercased.contains("good") || lowercased.contains("strong") { return 4 }
        if lowercased.contains("fair") || lowercased.contains("moderate") { return 3 }
        if lowercased.contains("poor") || lowercased.contains("weak") { return 2 }
        if lowercased.contains("no") || lowercased.contains("bad") { return 1 }
        return 3 // Default to moderate if no clear indicator
    }
    
    /// Computed competition score based on nearbyCompetition string
    var computedCompetitionScore: Int {
        let lowercased = nearbyCompetition.lowercased()
        if lowercased.contains("none") || lowercased.contains("zero") || lowercased.contains("no competition") { return 5 }
        if lowercased.contains("low") || lowercased.contains("minimal") { return 4 }
        if lowercased.contains("moderate") || lowercased.contains("some") { return 3 }
        if lowercased.contains("high") || lowercased.contains("strong") { return 2 }
        if lowercased.contains("very high") || lowercased.contains("intense") { return 1 }
        return 3 // Default to moderate if no clear indicator
    }
    
    /// Computed host commission score based on percentage
    var computedHostCommissionScore: Int {
        let percentage = hostCommissionPct * 100 // Convert from decimal to percentage
        if percentage <= 5 { return 5 }
        if percentage <= 10 { return 4 }
        if percentage <= 15 { return 3 }
        if percentage <= 20 { return 2 }
        return 1 // Above 20%
    }
    
    /// Computed visibility score based on notes (default to moderate if no specific data)
    var computedVisibilityScore: Int {
        let lowercased = visibilityNotes.lowercased()
        if lowercased.contains("excellent") || lowercased.contains("highly visible") || lowercased.contains("prime location") { return 5 }
        if lowercased.contains("good") || lowercased.contains("visible") || lowercased.contains("well positioned") { return 4 }
        if lowercased.contains("moderate") || lowercased.contains("adequate") { return 3 }
        if lowercased.contains("poor") || lowercased.contains("limited visibility") { return 2 }
        if lowercased.contains("very poor") || lowercased.contains("hidden") || lowercased.contains("obscured") { return 1 }
        return 3 // Default to moderate if no clear indicator
    }
    
    /// Computed security score based on notes (default to moderate if no specific data)
    var computedSecurityScore: Int {
        let lowercased = securityNotes.lowercased()
        if lowercased.contains("excellent") || lowercased.contains("very secure") || lowercased.contains("monitored") { return 5 }
        if lowercased.contains("good") || lowercased.contains("secure") || lowercased.contains("safe") { return 4 }
        if lowercased.contains("moderate") || lowercased.contains("adequate") { return 3 }
        if lowercased.contains("poor") || lowercased.contains("concerns") { return 2 }
        if lowercased.contains("very poor") || lowercased.contains("unsafe") || lowercased.contains("high risk") { return 1 }
        return 3 // Default to moderate if no clear indicator
    }
    
    /// Computed parking/transit score based on notes (default to moderate if no specific data)
    var computedParkingTransitScore: Int {
        let lowercased = parkingTransitNotes.lowercased()
        if lowercased.contains("excellent") || lowercased.contains("plenty of parking") || lowercased.contains("easy access") { return 5 }
        if lowercased.contains("good") || lowercased.contains("adequate parking") || lowercased.contains("convenient") { return 4 }
        if lowercased.contains("moderate") || lowercased.contains("some parking") { return 3 }
        if lowercased.contains("poor") || lowercased.contains("limited parking") { return 2 }
        if lowercased.contains("very poor") || lowercased.contains("no parking") || lowercased.contains("difficult access") { return 1 }
        return 3 // Default to moderate if no clear indicator
    }
    
    /// Computed amenities score based on notes (default to moderate if no specific data)
    var computedAmenitiesScore: Int {
        let lowercased = amenitiesNotes.lowercased()
        if lowercased.contains("excellent") || lowercased.contains("many amenities") || lowercased.contains("elevator") { return 5 }
        if lowercased.contains("good") || lowercased.contains("several amenities") { return 4 }
        if lowercased.contains("moderate") || lowercased.contains("some amenities") { return 3 }
        if lowercased.contains("poor") || lowercased.contains("few amenities") { return 2 }
        if lowercased.contains("very poor") || lowercased.contains("no amenities") { return 1 }
        return 3 // Default to moderate if no clear indicator
    }
    
    // Computed overall general metrics score based on computed objective scores
    var overallGeneralScore: Int {
        let computedScores = [
            footTrafficScore,
            computedDemographicFitScore,
            computedHostCommissionScore,
            computedCompetitionScore,
            computedVisibilityScore,
            computedSecurityScore,
            computedParkingTransitScore,
            computedAmenitiesScore
        ]
        
        let total = computedScores.reduce(0, +)
        return total / computedScores.count
    }
    
    // MARK: - Weighted Score Calculation
    
    /// Calculate weighted overall score using MANUAL RATINGS (1-5 stars) instead of computed scores
    func calculateWeightedOverallScore(moduleSpecificScore: Double) -> Double {
        // Core metrics (apply to all locations) — 0.75 total
        // Use MANUAL RATINGS (1-5 stars) that the user sets, not computed scores
        
        // Foot Traffic - 20%
        let footTrafficWeight: Double = 0.20
        // Target Demographic Fit - 10%
        let demographicFitWeight: Double = 0.10
        // Nearby Competition - 10%
        let competitiveGapWeight: Double = 0.10
        // Logistics & Infrastructure (subtotal 15%)
        let visibilityAccessibilityWeight: Double = 0.05
        let parkingTransitWeight: Double = 0.04
        let securityWeight: Double = 0.04
        let adjacentAmenitiesWeight: Double = 0.02
        // Financial Terms & ROI (subtotal 20%)
        let hostCommissionWeight: Double = 0.08
        let paybackVsTargetWeight: Double = 0.06
        let routeClusterFitWeight: Double = 0.04
        let installComplexityWeight: Double = 0.02
        // Module-specific score - 25%
        let moduleSpecificWeight: Double = 0.25
        
        let weightedSum = 
            Double(footTrafficRating) * footTrafficWeight +           // Manual rating
            Double(targetDemographicRating) * demographicFitWeight + // Manual rating
            Double(competitionRating) * competitiveGapWeight +       // Manual rating
            Double(visibilityRating) * visibilityAccessibilityWeight + // Manual rating
            Double(parkingTransitRating) * parkingTransitWeight +    // Manual rating
            Double(securityRating) * securityWeight +                // Manual rating
            Double(amenitiesRating) * adjacentAmenitiesWeight +      // Manual rating
            Double(hostCommissionRating) * hostCommissionWeight +    // Manual rating
            // Note: These metrics need to be added to the GeneralMetrics model
            // For now, using placeholder values of 3 (neutral rating)
            3.0 * paybackVsTargetWeight +                           // Placeholder
            3.0 * routeClusterFitWeight +                           // Placeholder
            3.0 * installComplexityWeight +                         // Placeholder
            moduleSpecificScore * moduleSpecificWeight
        
        let totalWeight = footTrafficWeight + demographicFitWeight + 
                         competitiveGapWeight + visibilityAccessibilityWeight +
                         parkingTransitWeight + securityWeight + adjacentAmenitiesWeight +
                         hostCommissionWeight + paybackVsTargetWeight + routeClusterFitWeight +
                         installComplexityWeight + moduleSpecificWeight
        
        return weightedSum / totalWeight / 5.0 // Normalize to 0-1 scale
    }
    
    /// Calculate weighted overall score using computed scores (matching Scorecard logic) - LEGACY METHOD
    func calculateWeightedOverallScoreComputed(moduleSpecificScore: Double) -> Double {
        // Updated weights: Foot Traffic reduced from 20% to 15%, 5% distributed to other metrics
        let footTrafficWeight: Double = 0.15        // Reduced from 0.20 (20%) to 0.15 (15%)
        let demographicFitWeight: Double = 0.12     // Increased from 0.10 (10%) to 0.12 (12%)
        let competitiveGapWeight: Double = 0.12     // Increased from 0.10 (10%) to 0.12 (12%)
        let logisticsInfrastructureWeight: Double = 0.18  // Increased from 0.15 (15%) to 0.18 (18%)
        let moduleSpecificWeight: Double = 0.25     // Unchanged (25%)
        let financialTermsWeight: Double = 0.18     // Increased from 0.20 (20%) to 0.18 (18%)
        
        let weightedSum = 
            Double(footTrafficScore) * footTrafficWeight +
            Double(computedDemographicFitScore) * demographicFitWeight +
            Double(computedCompetitionScore) * competitiveGapWeight +
            Double(computedParkingTransitScore) * logisticsInfrastructureWeight +
            moduleSpecificScore * moduleSpecificWeight +
            Double(computedHostCommissionScore) * financialTermsWeight
        
        let totalWeight = footTrafficWeight + demographicFitWeight + 
                         competitiveGapWeight + logisticsInfrastructureWeight +
                         moduleSpecificWeight + financialTermsWeight
        
        return weightedSum / totalWeight / 5.0 // Normalize to 0-1 scale
    }
    
    /// Get location decision based on weighted score
    func getLocationDecision(moduleSpecificScore: Double) -> LocationDecision {
        let score = calculateWeightedOverallScore(moduleSpecificScore: moduleSpecificScore)
        
        switch score {
        case 0.75...: return .greenlight
        case 0.60..<0.75: return .watchlist
        default: return .pass
        }
    }
    
    // MARK: - Data Management
    
    /// Updates the rating for a specific metric type
    func updateRating(for metricType: MetricType, rating: Int, notes: String = "") {
        switch metricType {
        case .footTraffic:
            footTrafficRating = max(0, min(5, rating)) // Allow 0 for empty state
            footTrafficNotes = notes
        case .targetDemographic:
            targetDemographicRating = max(0, min(5, rating)) // Allow 0 for empty state
            targetDemographicNotes = notes
        case .hostCommission:
            hostCommissionRating = max(0, min(5, rating)) // Allow 0 for empty state
            hostCommissionNotes = notes
        case .competition:
            competitionRating = max(0, min(5, rating)) // Allow 0 for empty state
            competitionNotes = notes
        case .visibility:
            visibilityRating = max(0, min(5, rating)) // Allow 0 for empty state
            visibilityNotes = notes
        case .security:
            securityRating = max(0, min(5, rating)) // Allow 0 for empty state
            securityNotes = notes
        case .parkingTransit:
            parkingTransitRating = max(0, min(5, rating)) // Allow 0 for empty state
            parkingTransitNotes = notes
        case .amenities:
            amenitiesRating = max(0, min(5, rating)) // Allow 0 for empty state
            amenitiesNotes = notes
        }
    }
    
    /// Gets the rating for a specific metric type (prioritizes manual ratings)
    func getRating(for metricType: MetricType) -> Int {
        switch metricType {
        case .footTraffic: return footTrafficRating
        case .targetDemographic: return targetDemographicRating
        case .hostCommission: return hostCommissionRating
        case .competition: return competitionRating
        case .visibility: return visibilityRating
        case .security: return securityRating
        case .parkingTransit: return parkingTransitRating
        case .amenities: return amenitiesRating
        }
    }
    
    /// Gets the computed score for a specific metric type
    func getComputedScore(for metricType: MetricType) -> Int {
        switch metricType {
        case .footTraffic: return footTrafficScore
        case .targetDemographic: return computedDemographicFitScore
        case .hostCommission: return computedHostCommissionScore
        case .competition: return computedCompetitionScore
        case .visibility: return computedVisibilityScore
        case .security: return computedSecurityScore
        case .parkingTransit: return computedParkingTransitScore
        case .amenities: return computedAmenitiesScore
        }
    }
    
    /// Gets the notes for a specific metric type
    func getNotes(for metricType: MetricType) -> String {
        switch metricType {
        case .footTraffic: return footTrafficNotes
        case .targetDemographic: return targetDemographicNotes
        case .hostCommission: return hostCommissionNotes
        case .competition: return competitionNotes
        case .visibility: return visibilityNotes
        case .security: return securityNotes
        case .parkingTransit: return parkingTransitNotes
        case .amenities: return amenitiesNotes
        }
    }
    
    // MARK: - Data Change Notification
    
    /// Notifies that data has changed and views should refresh
    func notifyDataChanged() {
        // This will trigger SwiftUI to refresh views that depend on this model
        // The @Model macro handles the notification automatically
    }
}
