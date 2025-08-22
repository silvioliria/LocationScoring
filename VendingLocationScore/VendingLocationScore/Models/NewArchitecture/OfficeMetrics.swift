import Foundation
import SwiftData

@Model
final class OfficeMetrics: TypeSpecificMetrics, Codable {
    var id: UUID
    var locationType: LocationTypeEnum
    
    // Office-specific metrics - store as simple properties instead of complex objects
    var commonAreasRating: Int
    var commonAreasNotes: String
    var hoursAccessRating: Int
    var hoursAccessNotes: String
    var tenantAmenitiesRating: Int
    var tenantAmenitiesNotes: String
    var proximityHubTransitRating: Int
    var proximityHubTransitNotes: String
    var brandingRestrictionsRating: Int
    var brandingRestrictionsNotes: String
    var layoutTypeRating: Int
    var layoutTypeNotes: String
    
    init(locationType: LocationTypeEnum) {
        self.id = UUID()
        self.locationType = locationType
        
        // Initialize all ratings to 0 and notes to empty
        self.commonAreasRating = 0
        self.commonAreasNotes = ""
        self.hoursAccessRating = 0
        self.hoursAccessNotes = ""
        self.tenantAmenitiesRating = 0
        self.tenantAmenitiesNotes = ""
        self.proximityHubTransitRating = 0
        self.proximityHubTransitNotes = ""
        self.brandingRestrictionsRating = 0
        self.brandingRestrictionsNotes = ""
        self.layoutTypeRating = 0
        self.layoutTypeNotes = ""
    }

    // MARK: - Codable Support

    enum CodingKeys: String, CodingKey {
        case id, locationType, commonAreasRating, commonAreasNotes, hoursAccessRating, hoursAccessNotes
        case tenantAmenitiesRating, tenantAmenitiesNotes, proximityHubTransitRating, proximityHubTransitNotes
        case brandingRestrictionsRating, brandingRestrictionsNotes, layoutTypeRating, layoutTypeNotes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        locationType = try container.decode(LocationTypeEnum.self, forKey: .locationType)
        commonAreasRating = try container.decode(Int.self, forKey: .commonAreasRating)
        commonAreasNotes = try container.decode(String.self, forKey: .commonAreasNotes)
        hoursAccessRating = try container.decode(Int.self, forKey: .hoursAccessRating)
        hoursAccessNotes = try container.decode(String.self, forKey: .hoursAccessNotes)
        tenantAmenitiesRating = try container.decode(Int.self, forKey: .tenantAmenitiesRating)
        tenantAmenitiesNotes = try container.decode(String.self, forKey: .tenantAmenitiesNotes)
        proximityHubTransitRating = try container.decode(Int.self, forKey: .proximityHubTransitRating)
        proximityHubTransitNotes = try container.decode(String.self, forKey: .proximityHubTransitNotes)
        brandingRestrictionsRating = try container.decode(Int.self, forKey: .brandingRestrictionsRating)
        brandingRestrictionsNotes = try container.decode(String.self, forKey: .brandingRestrictionsNotes)
        layoutTypeRating = try container.decode(Int.self, forKey: .layoutTypeRating)
        layoutTypeNotes = try container.decode(String.self, forKey: .layoutTypeNotes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(locationType, forKey: .locationType)
        try container.encode(commonAreasRating, forKey: .commonAreasRating)
        try container.encode(commonAreasNotes, forKey: .commonAreasNotes)
        try container.encode(hoursAccessRating, forKey: .hoursAccessRating)
        try container.encode(hoursAccessNotes, forKey: .hoursAccessNotes)
        try container.encode(tenantAmenitiesRating, forKey: .tenantAmenitiesRating)
        try container.encode(tenantAmenitiesNotes, forKey: .tenantAmenitiesNotes)
        try container.encode(proximityHubTransitRating, forKey: .proximityHubTransitRating)
        try container.encode(proximityHubTransitNotes, forKey: .proximityHubTransitNotes)
        try container.encode(brandingRestrictionsRating, forKey: .brandingRestrictionsRating)
        try container.encode(brandingRestrictionsNotes, forKey: .brandingRestrictionsNotes)
        try container.encode(layoutTypeRating, forKey: .layoutTypeRating)
        try container.encode(layoutTypeNotes, forKey: .layoutTypeNotes)
    }
    
    func getMetrics() -> [any MetricBase] {
        return [
            SimpleMetric(id: UUID(), title: "Common Areas", metricDescription: "Availability and quality of common areas like break rooms, lounges, and cafeterias.", rating: commonAreasRating, notes: commonAreasNotes),
            SimpleMetric(id: UUID(), title: "Hours & Access", metricDescription: "Building access hours and flexibility.", rating: hoursAccessRating, notes: hoursAccessNotes),
            SimpleMetric(id: UUID(), title: "Tenant Amenities", metricDescription: "Existing food and beverage options for tenants.", rating: tenantAmenitiesRating, notes: tenantAmenitiesNotes),
            SimpleMetric(id: UUID(), title: "Hub Proximity & Transit", metricDescription: "Proximity to transportation hubs and transit options.", rating: proximityHubTransitRating, notes: proximityHubTransitNotes),
            SimpleMetric(id: UUID(), title: "Branding Restrictions", metricDescription: "Restrictions on signage and branding.", rating: brandingRestrictionsRating, notes: brandingRestrictionsNotes),
            SimpleMetric(id: UUID(), title: "Layout Type", metricDescription: "Building layout and tenant density.", rating: layoutTypeRating, notes: layoutTypeNotes)
        ]
    }
    
    func calculateOverallScore() -> Double {
        let ratings = [
            commonAreasRating,
            hoursAccessRating,
            tenantAmenitiesRating,
            proximityHubTransitRating,
            brandingRestrictionsRating,
            layoutTypeRating
        ]
        
        let validRatings = ratings.filter { $0 > 0 }
        
        // Require at least 3 metrics to be rated before calculating a meaningful score
        guard validRatings.count >= 3 else { return 0.0 }
        
        let totalScore = validRatings.reduce(0, +)
        return Double(totalScore) / Double(validRatings.count)
    }
    
    func getMetricCount() -> Int {
        return 6 // Fixed number of office metrics
    }
    
    func getRatedMetricCount() -> Int {
        let ratings = [
            commonAreasRating,
            hoursAccessRating,
            tenantAmenitiesRating,
            proximityHubTransitRating,
            brandingRestrictionsRating,
            layoutTypeRating
        ]
        return ratings.filter { $0 > 0 }.count
    }
    
    func getCompletionPercentage() -> Double {
        let totalMetrics = getMetricCount()
        guard totalMetrics > 0 else { return 0.0 }
        return Double(getRatedMetricCount()) / Double(totalMetrics)
    }
    
    // MARK: - Update Methods
    
    func updateMetric(metricType: OfficeMetricType, rating: Int, notes: String) {
        switch metricType {
        case .commonAreas:
            commonAreasRating = rating
            commonAreasNotes = notes
        case .hoursAccess:
            hoursAccessRating = rating
            hoursAccessNotes = notes
        case .tenantAmenities:
            tenantAmenitiesRating = rating
            tenantAmenitiesNotes = notes
        case .proximityHubTransit:
            proximityHubTransitRating = rating
            proximityHubTransitNotes = notes
        case .brandingRestrictions:
            brandingRestrictionsRating = rating
            brandingRestrictionsNotes = notes
        case .layoutType:
            layoutTypeRating = rating
            layoutTypeNotes = notes
        }
    }
    
    func getMetric(metricType: OfficeMetricType) -> (rating: Int, notes: String) {
        switch metricType {
        case .commonAreas:
            return (commonAreasRating, commonAreasNotes)
        case .hoursAccess:
            return (hoursAccessRating, hoursAccessNotes)
        case .tenantAmenities:
            return (tenantAmenitiesRating, tenantAmenitiesNotes)
        case .proximityHubTransit:
            return (proximityHubTransitRating, proximityHubTransitNotes)
        case .brandingRestrictions:
            return (brandingRestrictionsRating, brandingRestrictionsNotes)
        case .layoutType:
            return (layoutTypeRating, layoutTypeNotes)
        }
    }
}

// MARK: - Simple Metric Implementation

/// Simple metric implementation that conforms to MetricBase without inheritance
struct SimpleMetric: MetricBase {
    let id: UUID
    let title: String
    let metricDescription: String
    var rating: Int
    var notes: String
    
    var description: String { metricDescription }
    
    var computedScore: Int { rating }
    
    func updateRating(_ rating: Int, notes: String) {
        // This is a struct, so we can't modify the properties directly
        // The parent class will need to handle updates
    }
    
    func validateRating(_ rating: Int) -> Bool {
        return (0...5).contains(rating)
    }
    
    func getStarDescription(for star: Int) -> String {
        switch star {
        case 1: return "Poor"
        case 2: return "Below Average"
        case 3: return "Average"
        case 4: return "Good"
        case 5: return "Excellent"
        default: return ""
        }
    }
}
