import Foundation
import SwiftData

@Model
final class Financials: Codable {
    var id: UUID
    
    // Financial metrics
    var revenueProjection: Double
    var costProjection: Double
    var profitMargin: Double
    var paybackPeriod: Int // in months
    var roiPercentage: Double
    
    // Notes
    var revenueNotes: String
    var costNotes: String
    var profitNotes: String
    var paybackNotes: String
    var roiNotes: String
    
    init() {
        self.id = UUID()
        self.revenueProjection = 0.0
        self.costProjection = 0.0
        self.profitMargin = 0.0
        self.paybackPeriod = 0
        self.roiPercentage = 0.0
        self.revenueNotes = ""
        self.costNotes = ""
        self.profitNotes = ""
        self.paybackNotes = ""
        self.roiNotes = ""
    }

    // MARK: - Codable Support

    enum CodingKeys: String, CodingKey {
        case id, revenueProjection, costProjection, profitMargin, paybackPeriod, roiPercentage
        case revenueNotes, costNotes, profitNotes, paybackNotes, roiNotes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        revenueProjection = try container.decode(Double.self, forKey: .revenueProjection)
        costProjection = try container.decode(Double.self, forKey: .costProjection)
        profitMargin = try container.decode(Double.self, forKey: .profitMargin)
        paybackPeriod = try container.decode(Int.self, forKey: .paybackPeriod)
        roiPercentage = try container.decode(Double.self, forKey: .roiPercentage)
        revenueNotes = try container.decode(String.self, forKey: .revenueNotes)
        costNotes = try container.decode(String.self, forKey: .costNotes)
        profitNotes = try container.decode(String.self, forKey: .profitNotes)
        paybackNotes = try container.decode(String.self, forKey: .paybackNotes)
        roiNotes = try container.decode(String.self, forKey: .roiNotes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(revenueProjection, forKey: .revenueProjection)
        try container.encode(costProjection, forKey: .costProjection)
        try container.encode(profitMargin, forKey: .profitMargin)
        try container.encode(paybackPeriod, forKey: .paybackPeriod)
        try container.encode(roiPercentage, forKey: .roiPercentage)
        try container.encode(revenueNotes, forKey: .revenueNotes)
        try container.encode(costNotes, forKey: .costNotes)
        try container.encode(profitNotes, forKey: .profitNotes)
        try container.encode(paybackNotes, forKey: .paybackNotes)
        try container.encode(roiNotes, forKey: .roiNotes)
    }
    
    // MARK: - Computed Properties
    
    var netProfit: Double {
        return revenueProjection - costProjection
    }
    
    var profitMarginPercentage: Double {
        guard revenueProjection > 0 else { return 0.0 }
        return (netProfit / revenueProjection) * 100
    }
    
    // MARK: - Update Methods
    
    func updateRevenueProjection(_ value: Double, notes: String) {
        self.revenueProjection = value
        self.revenueNotes = notes
        recalculateMetrics()
    }
    
    func updateCostProjection(_ value: Double, notes: String) {
        self.costProjection = value
        self.costNotes = notes
        recalculateMetrics()
    }
    
    func updateProfitMargin(_ value: Double, notes: String) {
        self.profitMargin = value
        self.profitNotes = notes
    }
    
    func updatePaybackPeriod(_ value: Int, notes: String) {
        self.paybackPeriod = value
        self.paybackNotes = notes
    }
    
    func updateROI(_ value: Double, notes: String) {
        self.roiPercentage = value
        self.roiNotes = notes
    }
    
    private func recalculateMetrics() {
        // Recalculate profit margin if revenue and cost are available
        if revenueProjection > 0 {
            profitMargin = (netProfit / revenueProjection) * 100
        }
        
        // Recalculate ROI if cost is available
        if costProjection > 0 {
            roiPercentage = (netProfit / costProjection) * 100
        }
    }
}
