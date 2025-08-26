import Foundation
import SwiftData

@Model
final class Financials {
    var id: UUID
    
    // MARK: - Input Metrics (User or Defaulted)
    
    // Traffic and conversion metrics
    var capturePct: Double? // % of passers who buy (module default; editable)
    var days: Int? // open days per month (e.g., 30)
    
    // Transaction metrics
    var avgTicket: Double? // dollars per transaction (format default; editable)
    
    // Cost metrics
    var cogs: Double? // cost of goods per vend
    var variableCosts: Double? // variable ops per vend (fees, spoilage)
    
    // Route metrics
    var routeVisitCost: Double // $/service visit
    var routeVisits: Int // visits per month
    
    // Financial terms
    var commissionPct: Double // host commission (decimal)
    var capex: Double? // installed equipment/fit-out cost (optional, for payback)
    
    // Notes for each metric
    var capturePctNotes: String?
    var daysNotes: String?
    var avgTicketNotes: String?
    var cogsNotes: String?
    var variableCostsNotes: String?
    var routeVisitCostNotes: String?
    var routeVisitsNotes: String?
    var commissionPctNotes: String?
    var capexNotes: String?
    
    init() {
        self.id = UUID()
        
        // Initialize with sensible defaults
        self.capturePct = 0.05 // 5% default capture rate
        self.days = 30 // 30 days per month
        self.avgTicket = 2.50 // $2.50 default ticket
        self.cogs = 0.75 // $0.75 default COGS
        self.variableCosts = 0.25 // $0.25 default variable costs
        self.routeVisitCost = 50.0 // $50 default route visit cost
        self.routeVisits = 4 // 4 visits per month
        self.commissionPct = 0.15 // 15% default commission
        self.capex = 0.0 // No capex by default
        
        // Initialize notes
        self.capturePctNotes = ""
        self.daysNotes = ""
        self.avgTicketNotes = ""
        self.cogsNotes = ""
        self.variableCostsNotes = ""
        self.routeVisitCostNotes = ""
        self.routeVisitsNotes = ""
        self.commissionPctNotes = ""
        self.capexNotes = ""
    }
    
    // MARK: - Derived Metrics (Calculated)
    
    /// Expected transactions per day
    var txDay: Double {
        // This will be calculated using foot_traffic_daily from GeneralMetrics
        // The calculation is: foot_traffic_daily × capture_pct
        return 0.0 // Placeholder - will be calculated in the view
    }
    
    /// Gross revenue per month
    var grossMonthly: Double {
        return (avgTicket ?? 2.50) * txDay * Double(days ?? 30)
    }
    
    /// Product costs per month
    var productCostsMonthly: Double {
        return ((cogs ?? 0.75) + (variableCosts ?? 0.25)) * txDay * Double(days ?? 30)
    }
    
    /// Route costs per month
    var routeCostsMonthly: Double {
        return routeVisitCost * Double(routeVisits)
    }
    
    /// Commission per month
    var commissionMonthly: Double {
        return commissionPct * grossMonthly
    }
    
    /// Net profit per month
    var netMonthly: Double {
        return grossMonthly - productCostsMonthly - routeCostsMonthly - commissionMonthly
    }
    
    /// Per-vend margin percentage (after commission & variable costs)
    var perVendMarginPct: Double {
        guard let avgTicket = avgTicket, avgTicket > 0 else { return 0.0 }
        return (avgTicket * (1 - commissionPct) - ((cogs ?? 0.75) + (variableCosts ?? 0.25))) / avgTicket
    }
    
    /// Break-even transactions per day
    var breakevenTxDay: Double {
        guard let avgTicket = avgTicket else { return 0.0 }
        let denominator = Double(days ?? 30) * (avgTicket * (1 - commissionPct) - ((cogs ?? 0.75) + (variableCosts ?? 0.25)))
        guard denominator > 0 else { return 0.0 }
        return routeCostsMonthly / denominator
    }
    
    /// Payback period in months
    var paybackMonths: Double {
        let net = max(netMonthly, 0.01) // Prevent division by zero
        return (capex ?? 0.0) / net
    }
    
    // MARK: - Legacy Properties (for backward compatibility)
    
    var revenueProjection: Double {
        get { grossMonthly }
        set { /* Read-only derived property */ }
    }
    
    var costProjection: Double {
        get { productCostsMonthly + routeCostsMonthly + commissionMonthly }
        set { /* Read-only derived property */ }
    }
    
    var profitMargin: Double {
        get { perVendMarginPct * 100 }
        set { /* Read-only derived property */ }
    }
    
    var paybackPeriod: Int {
        get { Int(round(paybackMonths)) }
        set { /* Read-only derived property */ }
    }
    
    var roiPercentage: Double {
        get { 
            let totalCosts = (capex ?? 0.0) + (productCostsMonthly + routeCostsMonthly + commissionMonthly)
            guard totalCosts > 0 else { return 0.0 }
            return (netMonthly * 12) / totalCosts * 100
        }
        set { /* Read-only derived property */ }
    }
    
    // Legacy notes (for backward compatibility)
    var revenueNotes: String {
        get { avgTicketNotes ?? "" }
        set { avgTicketNotes = newValue }
    }
    
    var costNotes: String {
        get { cogsNotes ?? "" }
        set { cogsNotes = newValue }
    }
    
    var profitNotes: String {
        get { capturePctNotes ?? "" }
        set { capturePctNotes = newValue }
    }
    
    var paybackNotes: String {
        get { capexNotes ?? "" }
        set { capexNotes = newValue }
    }
    
    var roiNotes: String {
        get { commissionPctNotes ?? "" }
        set { commissionPctNotes = newValue }
    }
    
    // MARK: - Update Methods
    
    func updateCapturePct(_ value: Double, notes: String) {
        self.capturePct = max(0.0, min(1.0, value)) // Ensure 0-100% range
        self.capturePctNotes = notes
    }
    
    func updateDays(_ value: Int, notes: String) {
        self.days = max(1, min(31, value)) // Ensure 1-31 range
        self.daysNotes = notes
    }
    
    func updateAvgTicket(_ value: Double, notes: String) {
        self.avgTicket = max(0.0, value)
        self.avgTicketNotes = notes
    }
    
    func updateCogs(_ value: Double, notes: String) {
        self.cogs = max(0.0, value)
        self.cogsNotes = notes
    }
    
    func updateVariableCosts(_ value: Double, notes: String) {
        self.variableCosts = max(0.0, value)
        self.variableCostsNotes = notes
    }
    
    func updateRouteVisitCost(_ value: Double, notes: String) {
        self.routeVisitCost = max(0.0, value)
        self.routeVisitCostNotes = notes
    }
    
    func updateRouteVisits(_ value: Int, notes: String) {
        self.routeVisits = max(0, value)
        self.routeVisitsNotes = notes
    }
    
    func updateCommissionPct(_ value: Double, notes: String) {
        self.commissionPct = max(0.0, min(1.0, value)) // Ensure 0-100% range
        self.commissionPctNotes = notes
    }
    
    func updateCapex(_ value: Double, notes: String) {
        self.capex = max(0.0, value)
        self.capexNotes = notes
    }
    
    // MARK: - Legacy Update Methods (for backward compatibility)
    
    func updateRevenueProjection(_ value: Double, notes: String) {
        // This is now read-only, but we can update avgTicket as a proxy
        updateAvgTicket(value / (Double(days ?? 30) * (capturePct ?? 0.15)), notes: notes)
    }
    
    func updateCostProjection(_ value: Double, notes: String) {
        // This is now read-only, but we can update cogs as a proxy
        let totalCosts = value
        let routeAndCommission = routeCostsMonthly + commissionMonthly
        let remainingCosts = totalCosts - routeAndCommission
        let costPerVend = remainingCosts / (Double(days ?? 30) * (capturePct ?? 0.15))
        updateCogs(max(0.0, costPerVend - (variableCosts ?? 0.25)), notes: notes)
    }
    
    func updateProfitMargin(_ value: Double, notes: String) {
        // This is now read-only, but we can update capturePct as a proxy
        let targetMargin = value / 100.0
        let avgTicketValue = avgTicket ?? 2.50
        let daysValue = days ?? 30
        let cogsValue = cogs ?? 0.75
        let variableCostsValue = variableCosts ?? 0.25
        let capturePctValue = capturePct ?? 0.15
        
        let newCapturePct = (routeCostsMonthly / Double(daysValue)) / (avgTicketValue * (1 - commissionPct - targetMargin) - (cogsValue + variableCostsValue))
        updateCapturePct(max(0.0, min(1.0, newCapturePct)), notes: notes)
    }
    
    func updatePaybackPeriod(_ value: Int, notes: String) {
        // This is now read-only, but we can update capex as a proxy
        let targetPayback = Double(value)
        let newCapex = netMonthly * targetPayback
        updateCapex(max(0.0, newCapex), notes: notes)
    }
    
    func updateROI(_ value: Double, notes: String) {
        // This is now read-only, but we can update commissionPct as a proxy
        let targetROI = value / 100.0
        let annualNet = netMonthly * 12
        let totalCosts = (capex ?? 0.0) + (productCostsMonthly + routeCostsMonthly + commissionMonthly)
        let newCommissionPct = (grossMonthly - (annualNet / targetROI) - productCostsMonthly - routeCostsMonthly) / grossMonthly
        updateCommissionPct(max(0.0, min(1.0, newCommissionPct)), notes: notes)
    }
}
