import Foundation
import SwiftData

// MARK: - Base Metric Protocol

/// Base protocol that all metrics must implement
protocol MetricBase: Identifiable {
    var id: UUID { get }
    var title: String { get }
    var metricDescription: String { get }
    var description: String { get } // Computed property for compatibility
    var rating: Int { get set }
    var notes: String { get set }
    var computedScore: Int { get }
    
    func updateRating(_ rating: Int, notes: String)
    func validateRating(_ rating: Int) -> Bool
    func getStarDescription(for star: Int) -> String
}

// MARK: - Base Metrics Implementation

/// Base class for all metrics with common functionality
@Model
class BaseMetrics: MetricBase {
    var id: UUID
    var title: String
    var metricDescription: String
    var rating: Int
    var notes: String
    
    init(title: String, description: String) {
        self.id = UUID()
        self.title = title
        self.metricDescription = description
        self.rating = 0
        self.notes = ""
    }
    
    var computedScore: Int { rating }
    
    var description: String { metricDescription }
    
    func updateRating(_ rating: Int, notes: String) {
        self.rating = validateRating(rating) ? rating : 0
        self.notes = notes
    }
    
    func validateRating(_ rating: Int) -> Bool {
        return (0...5).contains(rating)
    }
    
    func getStarDescription(for star: Int) -> String {
        // Default implementation - subclasses should override
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

// MARK: - Metric Type Enum

/// Enum for different types of metrics
enum NewMetricType: String, CaseIterable, Identifiable {
    case footTraffic = "foot_traffic"
    case targetDemographic = "target_demographic"
    case hostCommission = "host_commission"
    case competition = "competition"
    case visibility = "visibility"
    case security = "security"
    case parkingTransit = "parking_transit"
    case amenities = "amenities"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .footTraffic: return "Foot Traffic"
        case .targetDemographic: return "Audience Fit"
        case .hostCommission: return "Commission"
        case .competition: return "Competition"
        case .visibility: return "Visibility"
        case .security: return "Security"
        case .parkingTransit: return "Access"
        case .amenities: return "Amenities"
        }
    }
    
    var enumDescription: String {
        switch self {
        case .footTraffic: return "Direct driver of potential transactions and revenue. Higher daily foot traffic increases the likelihood of sales and overall profitability."
        case .targetDemographic: return "Matches users most likely to buy grab-and-go items. Better demographic fit means higher conversion rates and customer retention."
        case .hostCommission: return "Higher commissions compress your operating margin. Lower commission rates improve profitability and reduce payback time."
        case .competition: return "Closer/stronger alternatives reduce capture rate. Less competition means higher market share and better sales potential."
        case .visibility: return "Seen and reachable = impulsive purchases rise. Better visibility increases spontaneous buying decisions and overall sales."
        case .security: return "Reduces theft, vandalism, and chargebacks; protects uptime. Good security ensures reliable operations and protects revenue."
        case .parkingTransit: return "Easier service = lower route time and cost. Better access reduces operational expenses and improves service efficiency."
        case .amenities: return "Elevators/mailrooms/ATMs increase dwell and impulse. Adjacent amenities create natural traffic and buying opportunities."
        }
    }
}
