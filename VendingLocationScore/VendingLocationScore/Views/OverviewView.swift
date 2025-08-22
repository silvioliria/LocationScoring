import SwiftUI
import SwiftData

struct OverviewView: View {
    let location: Location
    
    var body: some View {
        Form {
            Section("Location Summary") {
                VStack(alignment: .leading, spacing: 12) {
                    // Site Name & Address
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Site Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(location.name)
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Address")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(location.address)
                            .font(.subheadline)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Module")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        LocationTypeBadge(locationType: location.locationType)
                    }
                }
            }
            
            Section("Key Metrics") {
                // Foot Traffic (raw from General sheet)
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily Foot Traffic")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(location.generalMetrics?.footTrafficDaily ?? 0)")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(location.generalMetrics?.footTrafficScore ?? 0)/5")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                
                // Weighted Score (from Scorecard calculation)
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Weighted Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2f", weightedScore))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(scoreColor)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Scale")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("0.00 - 1.00")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Net Monthly (from Financials)
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Net Monthly")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(location.financials?.netProfit ?? 0, format: .currency(code: ""))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    if let financials = location.financials {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Gross")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(financials.revenueProjection, format: .currency(code: ""))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section("Decision") {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recommendation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            Image(systemName: decisionIcon)
                                .font(.system(size: 24))
                                .foregroundColor(decisionColor)
                            
                            Text(decision.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(decisionColor)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(decisionColor.opacity(0.1))
                .cornerRadius(12)
            }
            
            Section("Last Updated") {
                HStack {
                    Text("Modified")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(location.updatedAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Overview")
    }
    
    // MARK: - Computed Properties
    
    private var weightedScore: Double {
        guard let scorecard = location.scorecard,
              let generalMetrics = location.generalMetrics else {
            return 0.0
        }
        
        // Get module-specific score from new architecture
        let moduleSpecificScore = getModuleSpecificScore()
        
        return calculateWeightedScore(
            footTrafficScore: generalMetrics.footTrafficScore,
            moduleSpecificScore: moduleSpecificScore
        )
    }
    
    private var scoreColor: Color {
        switch weightedScore {
        case 0.75...1.0: return .green
        case 0.60..<0.75: return .orange
        default: return .red
        }
    }
    
    private var netMonthlyColor: Color {
        let netMonthly = location.financials?.netProfit ?? 0
        return netMonthly >= 0 ? .green : .red
    }
    
    private var decision: LocationDecision {
        guard let scorecard = location.scorecard,
              let generalMetrics = location.generalMetrics else {
            return .pass
        }
        
        // Get module-specific score from new architecture
        let moduleSpecificScore = getModuleSpecificScore()
        
        return getDecision(
            footTrafficScore: generalMetrics.footTrafficScore,
            moduleSpecificScore: moduleSpecificScore
        )
    }
    
    private var decisionColor: Color {
        switch decision {
        case .greenlight: return .green
        case .watchlist: return .orange
        case .pass: return .red
        }
    }
    
    private var decisionIcon: String {
        switch decision {
        case .greenlight: return "checkmark.circle.fill"
        case .watchlist: return "exclamationmark.triangle.fill"
        case .pass: return "xmark.circle.fill"
        }
    }
    
    // MARK: - Helper Methods
    
    private func getModuleSpecificScore() -> Double {
        // Calculate score from new architecture based on location type
        switch location.locationType.type {
        case .office:
            if let officeMetrics = location.officeMetrics {
                return officeMetrics.calculateOverallScore()
            }
        case .hospital:
            if let hospitalMetrics = location.hospitalMetrics {
                return hospitalMetrics.calculateOverallScore()
            }
        case .school:
            if let schoolMetrics = location.schoolMetrics {
                return schoolMetrics.calculateOverallScore()
            }
        case .residential:
            if let residentialMetrics = location.residentialMetrics {
                return residentialMetrics.calculateOverallScore()
            }
        }
        return 0.0
    }
    
    private func calculateWeightedScore(footTrafficScore: Int, moduleSpecificScore: Double) -> Double {
        // Convert foot traffic score to 0-1 scale
        let footTrafficNormalized = Double(footTrafficScore) / 5.0
        
        // Convert module-specific score to 0-1 scale (assuming it's already 0-1)
        let moduleNormalized = moduleSpecificScore
        
        // Weighted calculation: 60% foot traffic, 40% module-specific
        let weightedScore = (footTrafficNormalized * 0.6) + (moduleNormalized * 0.4)
        
        return weightedScore
    }
    
    private func getDecision(footTrafficScore: Int, moduleSpecificScore: Double) -> LocationDecision {
        let weightedScore = calculateWeightedScore(footTrafficScore: footTrafficScore, moduleSpecificScore: moduleSpecificScore)
        
        switch weightedScore {
        case 0.75...1.0:
            return .greenlight
        case 0.60..<0.75:
            return .watchlist
        default:
            return .pass
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        let context = try! ModelContainer(for: Location.self, LocationType.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self).mainContext
        
        let locationType = LocationType(type: .office)
        let location = Location(name: "Sample Office", address: "123 Main St", comment: "Test location", locationType: locationType)
        
        // Set up the location
        let generalMetrics = GeneralMetrics()
        generalMetrics.footTrafficDaily = 750
        location.generalMetrics = generalMetrics
        
        let financials = Financials()
        financials.revenueProjection = 2000.0
        financials.costProjection = 500.0
        location.financials = financials
        
        let scorecard = Scorecard()
        location.scorecard = scorecard
        
        // Insert into context
        context.insert(location)
        
        return OverviewView(location: location)
            .modelContainer(context.container)
    }
}
