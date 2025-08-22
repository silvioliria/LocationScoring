import Foundation
import SwiftData

@Model
final class ResidentialMetrics: TypeSpecificMetrics, Codable {
    var id: UUID
    var locationType: LocationTypeEnum
    
    // Residential-specific metrics
    var unitCountRating: Int
    var unitCountNotes: String
    var occupancyRateRating: Int
    var occupancyRateNotes: String
    var demographicRating: Int
    var demographicNotes: String
    var foodServiceRating: Int
    var foodServiceNotes: String
    var vendingRestrictionsRating: Int
    var vendingRestrictionsNotes: String
    var hoursOfOperationRating: Int
    var hoursOfOperationNotes: String
    var buildingLayoutRating: Int
    var buildingLayoutNotes: String
    
    init(locationType: LocationTypeEnum) {
        self.id = UUID()
        self.locationType = locationType
        
        // Initialize all ratings to 0 and notes to empty
        self.unitCountRating = 0
        self.unitCountNotes = ""
        self.occupancyRateRating = 0
        self.occupancyRateNotes = ""
        self.demographicRating = 0
        self.demographicNotes = ""
        self.foodServiceRating = 0
        self.foodServiceNotes = ""
        self.vendingRestrictionsRating = 0
        self.vendingRestrictionsNotes = ""
        self.hoursOfOperationRating = 0
        self.hoursOfOperationNotes = ""
        self.buildingLayoutRating = 0
        self.buildingLayoutNotes = ""
    }

    // MARK: - Codable Support

    enum CodingKeys: String, CodingKey {
        case id, locationType, unitCountRating, unitCountNotes, occupancyRateRating, occupancyRateNotes
        case demographicRating, demographicNotes, foodServiceRating, foodServiceNotes
        case vendingRestrictionsRating, vendingRestrictionsNotes, hoursOfOperationRating, hoursOfOperationNotes
        case buildingLayoutRating, buildingLayoutNotes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        locationType = try container.decode(LocationTypeEnum.self, forKey: .locationType)
        unitCountRating = try container.decode(Int.self, forKey: .unitCountRating)
        unitCountNotes = try container.decode(String.self, forKey: .unitCountNotes)
        occupancyRateRating = try container.decode(Int.self, forKey: .occupancyRateRating)
        occupancyRateNotes = try container.decode(String.self, forKey: .occupancyRateNotes)
        demographicRating = try container.decode(Int.self, forKey: .demographicRating)
        demographicNotes = try container.decode(String.self, forKey: .demographicNotes)
        foodServiceRating = try container.decode(Int.self, forKey: .foodServiceRating)
        foodServiceNotes = try container.decode(String.self, forKey: .foodServiceNotes)
        vendingRestrictionsRating = try container.decode(Int.self, forKey: .vendingRestrictionsRating)
        vendingRestrictionsNotes = try container.decode(String.self, forKey: .vendingRestrictionsNotes)
        hoursOfOperationRating = try container.decode(Int.self, forKey: .hoursOfOperationRating)
        hoursOfOperationNotes = try container.decode(String.self, forKey: .hoursOfOperationNotes)
        buildingLayoutRating = try container.decode(Int.self, forKey: .buildingLayoutRating)
        buildingLayoutNotes = try container.decode(String.self, forKey: .buildingLayoutNotes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(locationType, forKey: .locationType)
        try container.encode(unitCountRating, forKey: .unitCountRating)
        try container.encode(unitCountNotes, forKey: .unitCountNotes)
        try container.encode(occupancyRateRating, forKey: .occupancyRateRating)
        try container.encode(occupancyRateNotes, forKey: .occupancyRateNotes)
        try container.encode(demographicRating, forKey: .demographicRating)
        try container.encode(demographicNotes, forKey: .demographicNotes)
        try container.encode(foodServiceRating, forKey: .foodServiceRating)
        try container.encode(foodServiceNotes, forKey: .foodServiceNotes)
        try container.encode(vendingRestrictionsRating, forKey: .vendingRestrictionsRating)
        try container.encode(vendingRestrictionsNotes, forKey: .vendingRestrictionsNotes)
        try container.encode(hoursOfOperationRating, forKey: .hoursOfOperationRating)
        try container.encode(hoursOfOperationNotes, forKey: .hoursOfOperationNotes)
        try container.encode(buildingLayoutRating, forKey: .buildingLayoutRating)
        try container.encode(buildingLayoutNotes, forKey: .buildingLayoutNotes)
    }
    
    func getMetrics() -> [any MetricBase] {
        return [
            SimpleMetric(id: UUID(), title: "Unit Count", metricDescription: "Number of residential units in the building.", rating: unitCountRating, notes: unitCountNotes),
            SimpleMetric(id: UUID(), title: "Occupancy Rate", metricDescription: "Current occupancy rate and tenant stability.", rating: occupancyRateRating, notes: occupancyRateNotes),
            SimpleMetric(id: UUID(), title: "Demographics", metricDescription: "Tenant demographics and preferences.", rating: demographicRating, notes: demographicNotes),
            SimpleMetric(id: UUID(), title: "Food Service", metricDescription: "Existing food service options and quality.", rating: foodServiceRating, notes: foodServiceNotes),
            SimpleMetric(id: UUID(), title: "Vending Restrictions", metricDescription: "Restrictions on vending machine placement and operation.", rating: vendingRestrictionsRating, notes: vendingRestrictionsNotes),
            SimpleMetric(id: UUID(), title: "Hours of Operation", metricDescription: "Building access hours and flexibility.", rating: hoursOfOperationRating, notes: hoursOfOperationNotes),
            SimpleMetric(id: UUID(), title: "Building Layout", metricDescription: "Building layout and common area distribution.", rating: buildingLayoutRating, notes: buildingLayoutNotes)
        ]
    }
    
    func calculateOverallScore() -> Double {
        let ratings = [
            unitCountRating,
            occupancyRateRating,
            demographicRating,
            foodServiceRating,
            vendingRestrictionsRating,
            hoursOfOperationRating,
            buildingLayoutRating
        ]
        
        let validRatings = ratings.filter { $0 > 0 }
        
        // Require at least 3 metrics to be rated before calculating a meaningful score
        guard validRatings.count >= 3 else { return 0.0 }
        
        let totalScore = validRatings.reduce(0, +)
        return Double(totalScore) / Double(validRatings.count)
    }
    
    func getMetricCount() -> Int {
        return 7
    }
    
    func getRatedMetricCount() -> Int {
        let ratings = [
            unitCountRating,
            occupancyRateRating,
            demographicRating,
            foodServiceRating,
            vendingRestrictionsRating,
            hoursOfOperationRating,
            buildingLayoutRating
        ]
        return ratings.filter { $0 > 0 }.count
    }
    
    func getCompletionPercentage() -> Double {
        let totalMetrics = getMetricCount()
        guard totalMetrics > 0 else { return 0.0 }
        return Double(getRatedMetricCount()) / Double(totalMetrics)
    }
    
    // MARK: - Update Methods
    
    func updateMetric(metricType: ResidentialMetricType, rating: Int, notes: String) {
        switch metricType {
        case .unitCount:
            unitCountRating = rating
            unitCountNotes = notes
        case .occupancyRate:
            occupancyRateRating = rating
            occupancyRateNotes = notes
        case .demographics:
            demographicRating = rating
            demographicNotes = notes
        case .foodService:
            foodServiceRating = rating
            foodServiceNotes = notes
        case .vendingRestrictions:
            vendingRestrictionsRating = rating
            vendingRestrictionsNotes = notes
        case .hoursOfOperation:
            hoursOfOperationRating = rating
            hoursOfOperationNotes = notes
        case .buildingLayout:
            buildingLayoutRating = rating
            buildingLayoutNotes = notes
        }
    }
    
    func getMetric(metricType: ResidentialMetricType) -> (rating: Int, notes: String) {
        switch metricType {
        case .unitCount:
            return (unitCountRating, unitCountNotes)
        case .occupancyRate:
            return (occupancyRateRating, occupancyRateNotes)
        case .demographics:
            return (demographicRating, demographicNotes)
        case .foodService:
            return (foodServiceRating, foodServiceNotes)
        case .vendingRestrictions:
            return (vendingRestrictionsRating, vendingRestrictionsNotes)
        case .hoursOfOperation:
            return (hoursOfOperationRating, hoursOfOperationNotes)
        case .buildingLayout:
            return (buildingLayoutRating, buildingLayoutNotes)
        }
    }
}
