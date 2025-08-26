import SwiftUI
import SwiftData

struct ScorecardView: View {
    let location: Location
    @Environment(\.modelContext) private var context
    
    var body: some View {
        Form {
            Section("Overall Score") {
                VStack(spacing: 16) {
                    // Overall score circle
                    ReusableGaugeView(
                        score: overallScore * 5,
                        maxScore: 5.0,
                        size: .large,
                        showBackground: true,
                        animate: true
                    )
                    .frame(width: 120, height: 120)
                    
                    Text(scoreDescription(overallScore * 5))
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(scoreColor(overallScore * 5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            
            Section("Manual Scoring (1-5)") {
                ScoreDisplayView(title: "Foot Traffic", score: location.generalMetrics?.getRating(for: .footTraffic) ?? 1)
                
                ScoreDisplayView(title: "Demographic Fit", score: location.generalMetrics?.getRating(for: .targetDemographic) ?? 1)
                
                ScoreDisplayView(title: "Competitive Gap", score: location.generalMetrics?.getRating(for: .competition) ?? 1)
                
                ScoreDisplayView(title: "Logistics & Infrastructure", score: location.generalMetrics?.getRating(for: .parkingTransit) ?? 1)
                
                ScoreDisplayView(title: "Financial Terms & ROI", score: location.generalMetrics?.getRating(for: .hostCommission) ?? 1)
            }
            
            Section("Score Breakdown") {
                ScoreRowView(title: "Foot Traffic", score: Double(location.generalMetrics?.getRating(for: .footTraffic) ?? 1))
                ScoreRowView(title: "Demographic Fit", score: Double(location.generalMetrics?.getRating(for: .targetDemographic) ?? 1))
                ScoreRowView(title: "Competitive Gap", score: Double(location.generalMetrics?.getRating(for: .competition) ?? 1))
                ScoreRowView(title: "Logistics", score: Double(location.generalMetrics?.getRating(for: .parkingTransit) ?? 1))
                ScoreRowView(title: location.locationType.displayName, score: getModuleSpecificScore())
                ScoreRowView(title: "Financial Terms", score: Double(location.generalMetrics?.getRating(for: .hostCommission) ?? 1))
            }
            
            Section("Financial Summary") {
                HStack {
                    Text("Net Monthly:")
                    Spacer()
                    Text(location.financials?.netMonthly ?? 0, format: .currency(code: ""))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Financial Score:")
                    Spacer()
                    Text("\(Int((location.financials?.perVendMarginPct ?? 0) * 20))/5")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            Section("Decision") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recommendation:")
                            .font(.headline)
                        Text(decision.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(decisionColor)
                    }
                    Spacer()
                    Image(systemName: decisionIcon)
                        .font(.system(size: 30))
                        .foregroundColor(decisionColor)
                }
                .padding()
                .background(decisionColor.opacity(0.1))
                .cornerRadius(8)
                
                Text(recommendation)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .navigationTitle("Scorecard")
    }
    
    private var overallScore: Double {
        guard let generalMetrics = location.generalMetrics else {
            return 0.0
        }
        
        // Get the module specific score first
        let moduleScore = getModuleSpecificScore()
        
        // Use the proper weighted scoring method for general metrics
        let generalScore = generalMetrics.calculateWeightedOverallScore(moduleSpecificScore: moduleScore)
        
        // Convert from 0-1 scale back to 0-5 scale for consistency
        return generalScore * 5.0
    }
    
    private var decision: LocationDecision {
        let score = overallScore
        
        switch score {
        case 4.0...5.0: return .greenlight
        case 3.0..<4.0: return .watchlist
        default: return .pass
        }
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
    
    private var recommendation: String {
        switch decision {
        case .greenlight:
            return "🌟 Excellent location! This location meets all criteria and is strongly recommended for vending machine placement. High potential for success based on weighted scoring analysis."
        case .watchlist:
            return "⚠️ Moderate potential. This location shows promise but requires careful monitoring. Consider placement with regular performance reviews and be prepared for adjustments."
        case .pass:
            return "❌ Not recommended. This location does not meet the minimum criteria for successful vending machine placement based on the weighted scoring analysis."
        }
    }
    
    private func scoreColor(_ score: Double) -> Color {
        ScoreColorUtility.getScoreColor(score)
    }
    
    private func scoreDescription(_ score: Double) -> String {
        switch score {
        case 4.5...5.0: return "Excellent"
        case 3.5..<4.5: return "Good"
        case 2.5..<3.5: return "Fair"
        case 1.5..<2.5: return "Poor"
        default: return "Very Poor"
        }
    }

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
}

struct ScoreDisplayView: View {
    let title: String
    let score: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                Spacer()
                Text("\(score)/5")
                    .fontWeight(.semibold)
                    .foregroundColor(scoreColor)
            }
            
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= score ? "star.fill" : "star")
                        .foregroundColor(index <= score ? .yellow : .gray)
                        .font(.title3)
                }
            }
        }
    }
    
    private var scoreColor: Color {
        ScoreColorUtility.getScoreColor(Double(score))
    }
}

struct ScoreRowView: View {
    let title: String
    let score: Double
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            HStack(spacing: 4) {
                Text(String(format: "%.1f", score))
                    .fontWeight(.semibold)
                    .foregroundColor(scoreColor)
                
                // Star rating
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= Int(score.rounded()) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    private var scoreColor: Color {
        ScoreColorUtility.getScoreColor(score)
    }
}

struct ScorecardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = try! ModelContainer(for: Location.self, LocationType.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self, MetricDefinition.self, MetricInstance.self, LocationMetrics.self).mainContext
        
        let locationType = LocationType(type: .office)
        let location = Location(name: "Sample Office", address: "123 Main St", comment: "Test location", locationType: locationType)
        
        // Set up the location outside the ViewBuilder
        location.generalMetrics = GeneralMetrics()
        location.financials = Financials()
        location.scorecard = Scorecard()
        
        // Insert into context outside the ViewBuilder
        context.insert(location)
        
        return ScorecardView(location: location)
            .environmentObject(SharedModelContext.shared)
    }
}
