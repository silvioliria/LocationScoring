import Foundation
import SwiftData

@Model
final class HospitalMetrics: TypeSpecificMetrics, Codable {
    var id: UUID
    var locationType: LocationTypeEnum
    
    // Hospital-specific metrics
    var patientVolumeRating: Int
    var patientVolumeNotes: String
    var staffSizeRating: Int
    var staffSizeNotes: String
    var visitorTrafficRating: Int
    var visitorTrafficNotes: String
    var foodServiceRating: Int
    var foodServiceNotes: String
    var vendingRestrictionsRating: Int
    var vendingRestrictionsNotes: String
    var hoursOfOperationRating: Int
    var hoursOfOperationNotes: String
    
    init(locationType: LocationTypeEnum) {
        self.id = UUID()
        self.locationType = locationType
        
        // Initialize all ratings to 0 and notes to empty
        self.patientVolumeRating = 0
        self.patientVolumeNotes = ""
        self.staffSizeRating = 0
        self.staffSizeNotes = ""
        self.visitorTrafficRating = 0
        self.visitorTrafficNotes = ""
        self.foodServiceRating = 0
        self.foodServiceNotes = ""
        self.vendingRestrictionsRating = 0
        self.vendingRestrictionsNotes = ""
        self.hoursOfOperationRating = 0
        self.hoursOfOperationNotes = ""
    }

    // MARK: - Codable Support

    enum CodingKeys: String, CodingKey {
        case id, locationType, patientVolumeRating, patientVolumeNotes, staffSizeRating, staffSizeNotes
        case visitorTrafficRating, visitorTrafficNotes, foodServiceRating, foodServiceNotes
        case vendingRestrictionsRating, vendingRestrictionsNotes, hoursOfOperationRating, hoursOfOperationNotes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        locationType = try container.decode(LocationTypeEnum.self, forKey: .locationType)
        patientVolumeRating = try container.decode(Int.self, forKey: .patientVolumeRating)
        patientVolumeNotes = try container.decode(String.self, forKey: .patientVolumeNotes)
        staffSizeRating = try container.decode(Int.self, forKey: .staffSizeRating)
        staffSizeNotes = try container.decode(String.self, forKey: .staffSizeNotes)
        visitorTrafficRating = try container.decode(Int.self, forKey: .visitorTrafficRating)
        visitorTrafficNotes = try container.decode(String.self, forKey: .visitorTrafficNotes)
        foodServiceRating = try container.decode(Int.self, forKey: .foodServiceRating)
        foodServiceNotes = try container.decode(String.self, forKey: .foodServiceNotes)
        vendingRestrictionsRating = try container.decode(Int.self, forKey: .vendingRestrictionsRating)
        vendingRestrictionsNotes = try container.decode(String.self, forKey: .vendingRestrictionsNotes)
        hoursOfOperationRating = try container.decode(Int.self, forKey: .hoursOfOperationRating)
        hoursOfOperationNotes = try container.decode(String.self, forKey: .hoursOfOperationNotes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(locationType, forKey: .locationType)
        try container.encode(patientVolumeRating, forKey: .patientVolumeRating)
        try container.encode(patientVolumeNotes, forKey: .patientVolumeNotes)
        try container.encode(staffSizeRating, forKey: .staffSizeRating)
        try container.encode(staffSizeNotes, forKey: .staffSizeNotes)
        try container.encode(visitorTrafficRating, forKey: .visitorTrafficRating)
        try container.encode(visitorTrafficNotes, forKey: .visitorTrafficNotes)
        try container.encode(foodServiceRating, forKey: .foodServiceRating)
        try container.encode(foodServiceNotes, forKey: .foodServiceNotes)
        try container.encode(vendingRestrictionsRating, forKey: .vendingRestrictionsRating)
        try container.encode(vendingRestrictionsNotes, forKey: .vendingRestrictionsNotes)
        try container.encode(hoursOfOperationRating, forKey: .hoursOfOperationRating)
        try container.encode(hoursOfOperationNotes, forKey: .hoursOfOperationNotes)
    }
    
    func getMetrics() -> [any MetricBase] {
        return [
            SimpleMetric(id: UUID(), title: "Patient Volume", metricDescription: "Daily patient volume and flow.", rating: patientVolumeRating, notes: patientVolumeNotes),
            SimpleMetric(id: UUID(), title: "Staff Size", metricDescription: "Number of staff members and their distribution.", rating: staffSizeRating, notes: staffSizeNotes),
            SimpleMetric(id: UUID(), title: "Visitor Traffic", metricDescription: "Visitor flow and patterns.", rating: visitorTrafficRating, notes: visitorTrafficNotes),
            SimpleMetric(id: UUID(), title: "Food Service", metricDescription: "Existing food service options and quality.", rating: foodServiceRating, notes: foodServiceNotes),
            SimpleMetric(id: UUID(), title: "Vending Restrictions", metricDescription: "Restrictions on vending machine placement and operation.", rating: vendingRestrictionsRating, notes: vendingRestrictionsNotes),
            SimpleMetric(id: UUID(), title: "Hours of Operation", metricDescription: "Building and department operating hours.", rating: hoursOfOperationRating, notes: hoursOfOperationNotes)
        ]
    }
    
    func calculateOverallScore() -> Double {
        let ratings = [
            patientVolumeRating,
            staffSizeRating,
            visitorTrafficRating,
            foodServiceRating,
            vendingRestrictionsRating,
            hoursOfOperationRating
        ]
        
        let validRatings = ratings.filter { $0 > 0 }
        
        // Require at least 3 metrics to be rated before calculating a meaningful score
        guard validRatings.count >= 3 else { return 0.0 }
        
        let totalScore = validRatings.reduce(0, +)
        return Double(totalScore) / Double(validRatings.count)
    }
    
    func getMetricCount() -> Int {
        return 6
    }
    
    func getRatedMetricCount() -> Int {
        let ratings = [
            patientVolumeRating,
            staffSizeRating,
            visitorTrafficRating,
            foodServiceRating,
            vendingRestrictionsRating,
            hoursOfOperationRating
        ]
        return ratings.filter { $0 > 0 }.count
    }
    
    func getCompletionPercentage() -> Double {
        let totalMetrics = getMetricCount()
        guard totalMetrics > 0 else { return 0.0 }
        return Double(getRatedMetricCount()) / Double(totalMetrics)
    }
    
    // MARK: - Update Methods
    
    func updateMetric(metricType: HospitalMetricType, rating: Int, notes: String) {
        switch metricType {
        case .patientVolume:
            patientVolumeRating = rating
            patientVolumeNotes = notes
        case .staffSize:
            staffSizeRating = rating
            staffSizeNotes = notes
        case .visitorTraffic:
            visitorTrafficRating = rating
            visitorTrafficNotes = notes
        case .foodService:
            foodServiceRating = rating
            foodServiceNotes = notes
        case .vendingRestrictions:
            vendingRestrictionsRating = rating
            vendingRestrictionsNotes = notes
        case .hoursOfOperation:
            hoursOfOperationRating = rating
            hoursOfOperationNotes = notes
        }
    }
    
    func getMetric(metricType: HospitalMetricType) -> (rating: Int, notes: String) {
        switch metricType {
        case .patientVolume:
            return (patientVolumeRating, patientVolumeNotes)
        case .staffSize:
            return (staffSizeRating, staffSizeNotes)
        case .visitorTraffic:
            return (visitorTrafficRating, visitorTrafficNotes)
        case .foodService:
            return (foodServiceRating, foodServiceNotes)
        case .vendingRestrictions:
            return (vendingRestrictionsRating, vendingRestrictionsNotes)
        case .hoursOfOperation:
            return (hoursOfOperationRating, hoursOfOperationNotes)
        }
    }
}
