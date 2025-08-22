import Foundation
import SwiftData

// Protocol for type-specific metrics
protocol TypeSpecificMetrics: Identifiable {
    var id: UUID { get }
    var locationType: LocationTypeEnum { get }
    func getMetrics() -> [any MetricBase]
    func calculateOverallScore() -> Double
    func getMetricCount() -> Int
    func getRatedMetricCount() -> Int
}

// Base class for type-specific metrics (now @Model)
@Model
class BaseTypeSpecificMetrics: TypeSpecificMetrics, Codable {
    var id: UUID
    var locationType: LocationTypeEnum
    
    init(locationType: LocationTypeEnum) {
        self.id = UUID()
        self.locationType = locationType
    }

    // MARK: - Codable Support

    enum CodingKeys: String, CodingKey {
        case id, locationType
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        locationType = try container.decode(LocationTypeEnum.self, forKey: .locationType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(locationType, forKey: .locationType)
    }
    
    func getMetrics() -> [any MetricBase] {
        return []
    }
    
    func calculateOverallScore() -> Double {
        let metrics = getMetrics()
        guard !metrics.isEmpty else { return 0.0 }
        
        let ratedMetrics = metrics.filter { $0.rating > 0 }
        
        // Require at least 3 metrics to be rated before calculating a meaningful score
        guard ratedMetrics.count >= 3 else { return 0.0 }
        
        let totalScore = ratedMetrics.reduce(0.0) { $0 + Double($1.computedScore) }
        return totalScore / Double(ratedMetrics.count)
    }
    
    func getMetricCount() -> Int {
        return getMetrics().count
    }
    
    func getRatedMetricCount() -> Int {
        return getMetrics().filter { $0.rating > 0 }.count
    }
}
