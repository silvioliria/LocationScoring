import Foundation
import SwiftData

@Model
final class SchoolMetrics: TypeSpecificMetrics, Codable {
    var id: UUID
    var locationType: LocationTypeEnum
    
    // School-specific metrics
    var studentPopulationRating: Int
    var studentPopulationNotes: String
    var staffSizeRating: Int
    var staffSizeNotes: String
    var foodServiceRating: Int
    var foodServiceNotes: String
    var vendingRestrictionsRating: Int
    var vendingRestrictionsNotes: String
    var hoursOfOperationRating: Int
    var hoursOfOperationNotes: String
    var campusLayoutRating: Int
    var campusLayoutNotes: String
    
    init(locationType: LocationTypeEnum) {
        self.id = UUID()
        self.locationType = locationType
        
        // Initialize all ratings to 0 and notes to empty
        self.studentPopulationRating = 0
        self.studentPopulationNotes = ""
        self.staffSizeRating = 0
        self.staffSizeNotes = ""
        self.foodServiceRating = 0
        self.foodServiceNotes = ""
        self.vendingRestrictionsRating = 0
        self.vendingRestrictionsNotes = ""
        self.hoursOfOperationRating = 0
        self.hoursOfOperationNotes = ""
        self.campusLayoutRating = 0
        self.campusLayoutNotes = ""
    }

    // MARK: - Codable Support

    enum CodingKeys: String, CodingKey {
        case id, locationType, studentPopulationRating, studentPopulationNotes, staffSizeRating, staffSizeNotes
        case foodServiceRating, foodServiceNotes, vendingRestrictionsRating, vendingRestrictionsNotes
        case hoursOfOperationRating, hoursOfOperationNotes, campusLayoutRating, campusLayoutNotes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        locationType = try container.decode(LocationTypeEnum.self, forKey: .locationType)
        studentPopulationRating = try container.decode(Int.self, forKey: .studentPopulationRating)
        studentPopulationNotes = try container.decode(String.self, forKey: .studentPopulationNotes)
        staffSizeRating = try container.decode(Int.self, forKey: .staffSizeRating)
        staffSizeNotes = try container.decode(String.self, forKey: .staffSizeNotes)
        foodServiceRating = try container.decode(Int.self, forKey: .foodServiceRating)
        foodServiceNotes = try container.decode(String.self, forKey: .foodServiceNotes)
        vendingRestrictionsRating = try container.decode(Int.self, forKey: .vendingRestrictionsRating)
        vendingRestrictionsNotes = try container.decode(String.self, forKey: .vendingRestrictionsNotes)
        hoursOfOperationRating = try container.decode(Int.self, forKey: .hoursOfOperationRating)
        hoursOfOperationNotes = try container.decode(String.self, forKey: .hoursOfOperationNotes)
        campusLayoutRating = try container.decode(Int.self, forKey: .campusLayoutRating)
        campusLayoutNotes = try container.decode(String.self, forKey: .campusLayoutNotes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(locationType, forKey: .locationType)
        try container.encode(studentPopulationRating, forKey: .studentPopulationRating)
        try container.encode(studentPopulationNotes, forKey: .studentPopulationNotes)
        try container.encode(staffSizeRating, forKey: .staffSizeRating)
        try container.encode(staffSizeNotes, forKey: .staffSizeNotes)
        try container.encode(foodServiceRating, forKey: .foodServiceRating)
        try container.encode(foodServiceNotes, forKey: .foodServiceNotes)
        try container.encode(vendingRestrictionsRating, forKey: .vendingRestrictionsRating)
        try container.encode(vendingRestrictionsNotes, forKey: .vendingRestrictionsNotes)
        try container.encode(hoursOfOperationRating, forKey: .hoursOfOperationRating)
        try container.encode(hoursOfOperationNotes, forKey: .hoursOfOperationNotes)
        try container.encode(campusLayoutRating, forKey: .campusLayoutRating)
        try container.encode(campusLayoutNotes, forKey: .campusLayoutNotes)
    }
    
    func getMetrics() -> [any MetricBase] {
        return [
            SimpleMetric(id: UUID(), title: "Student Population", metricDescription: "Number of students and their distribution.", rating: studentPopulationRating, notes: studentPopulationNotes),
            SimpleMetric(id: UUID(), title: "Staff Size", metricDescription: "Number of staff members and their distribution.", rating: staffSizeRating, notes: staffSizeNotes),
            SimpleMetric(id: UUID(), title: "Food Service", metricDescription: "Existing food service options and quality.", rating: foodServiceRating, notes: foodServiceNotes),
            SimpleMetric(id: UUID(), title: "Vending Restrictions", metricDescription: "Restrictions on vending machine placement and operation.", rating: vendingRestrictionsRating, notes: vendingRestrictionsNotes),
            SimpleMetric(id: UUID(), title: "Hours of Operation", metricDescription: "School operating hours and access.", rating: hoursOfOperationRating, notes: hoursOfOperationNotes),
            SimpleMetric(id: UUID(), title: "Campus Layout", metricDescription: "Campus layout and building distribution.", rating: campusLayoutRating, notes: campusLayoutNotes)
        ]
    }
    
    func calculateOverallScore() -> Double {
        let ratings = [
            studentPopulationRating,
            staffSizeRating,
            foodServiceRating,
            vendingRestrictionsRating,
            hoursOfOperationRating,
            campusLayoutRating
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
            studentPopulationRating,
            staffSizeRating,
            foodServiceRating,
            vendingRestrictionsRating,
            hoursOfOperationRating,
            campusLayoutRating
        ]
        return ratings.filter { $0 > 0 }.count
    }
    
    func getCompletionPercentage() -> Double {
        let totalMetrics = getMetricCount()
        guard totalMetrics > 0 else { return 0.0 }
        return Double(getRatedMetricCount()) / Double(totalMetrics)
    }
    
    // MARK: - Update Methods
    
    func updateMetric(metricType: SchoolMetricType, rating: Int, notes: String) {
        // Validate rating is within 0-5 range
        let validatedRating = max(0, min(5, rating))
        
        switch metricType {
        case .studentPopulation:
            studentPopulationRating = validatedRating
            studentPopulationNotes = notes
        case .staffSize:
            staffSizeRating = validatedRating
            staffSizeNotes = notes
        case .foodService:
            foodServiceRating = validatedRating
            foodServiceNotes = notes
        case .vendingRestrictions:
            vendingRestrictionsRating = validatedRating
            vendingRestrictionsNotes = notes
        case .hoursOfOperation:
            hoursOfOperationRating = validatedRating
            hoursOfOperationNotes = notes
        case .campusLayout:
            campusLayoutRating = validatedRating
            campusLayoutNotes = notes
        }
    }
    
    func getMetric(metricType: SchoolMetricType) -> (rating: Int, notes: String) {
        switch metricType {
        case .studentPopulation:
            return (studentPopulationRating, studentPopulationNotes)
        case .staffSize:
            return (staffSizeRating, staffSizeNotes)
        case .foodService:
            return (foodServiceRating, foodServiceNotes)
        case .vendingRestrictions:
            return (vendingRestrictionsRating, vendingRestrictionsNotes)
        case .hoursOfOperation:
            return (hoursOfOperationRating, hoursOfOperationNotes)
        case .campusLayout:
            return (campusLayoutRating, campusLayoutNotes)
        }
    }
}
