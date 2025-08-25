import Foundation
import SwiftData

@Model
final class Financials {
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
