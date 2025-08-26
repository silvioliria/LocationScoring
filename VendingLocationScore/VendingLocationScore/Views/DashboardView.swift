import SwiftUI
import SwiftData

struct DashboardView: View {
    let location: Location
    @Binding var selectedTab: Int
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: horizontalSizeClass == .compact ? 20 : 28) {
                // Location Information Group
                LocationInfoCard(location: location)
                
                // Essential Scores Group
                PerformanceOverviewCard(location: location)
                
                // Scores (formerly Key Metrics)
                ScoresCard(location: location, horizontalSizeClass: horizontalSizeClass)
                
                // Bottom spacing
                Spacer(minLength: 24)
            }
            .padding(.horizontal, horizontalSizeClass == .compact ? 16 : 24)
            .padding(.top, horizontalSizeClass == .compact ? 20 : 28)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Helper Functions

private func formatNetMonthly(_ value: Double) -> String {
    // Round to 2 decimal places for currency display
    let roundedValue = round(value * 100) / 100
    
    // Format as currency with proper rounding
    if roundedValue == 0 {
        return "$0.00"
    } else if roundedValue.truncatingRemainder(dividingBy: 1) == 0 {
        // If it's a whole number, show without decimal places
        return "$\(Int(roundedValue))"
    } else {
        // Show with 2 decimal places for partial amounts
        return String(format: "$%.2f", roundedValue)
    }
}

// MARK: - Location Information Card
struct LocationInfoCard: View {
    let location: Location
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 14) {
                // Address
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Address")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(location.address)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                
                // Comment (if exists)
                if !location.comment.isEmpty {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Comment")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(location.comment)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .italic()
                        }
                        Spacer()
                    }
                }
                
                // Module Type
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Type")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        LocationTypeBadge(locationType: location.locationType)
                    }
                    Spacer()
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Scores Card (formerly Key Metrics)
struct ScoresCard: View {
    let location: Location
    let horizontalSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Scores")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                horizontalSizeClass == .regular ? GridItem(.flexible()) : nil
            ].compactMap { $0 }, spacing: horizontalSizeClass == .compact ? 16 : 20) {
                MetricCard(
                    title: "Foot Traffic",
                    value: "\(location.generalMetrics?.getRating(for: .footTraffic) ?? 1)/5",
                    subtitle: "daily visitors",
                    score: location.generalMetrics?.getRating(for: .footTraffic) ?? 1,
                    color: .blue
                )
                
                MetricCard(
                    title: "Net Profit",
                    value: (location.financials?.netMonthly ?? 0).formatted(.currency(code: "USD")),
                    subtitle: "projected",
                    score: Int((location.financials?.perVendMarginPct ?? 0) * 20), // Convert percentage to 1-5 scale
                    color: .green
                )
                
                MetricCard(
                    title: "Demographic Fit",
                    value: "\(location.generalMetrics?.getRating(for: .targetDemographic) ?? 1)/5",
                    subtitle: "target audience",
                    score: location.generalMetrics?.getRating(for: .targetDemographic) ?? 1,
                    color: .purple
                )
                
                MetricCard(
                    title: "Competition",
                    value: "\(location.generalMetrics?.getRating(for: .competition) ?? 1)/5",
                    subtitle: "market position",
                    score: location.generalMetrics?.getRating(for: .competition) ?? 1,
                    color: .orange
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let score: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and score
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(score)/5")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(getDecisionColor(for: Double(score)))
            }
            
            // Specific metric description (replaces generic description)
            Text(getMetricDescription(for: title, score: score))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            // Subtitle
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(getDecisionColor(for: Double(score)).opacity(0.2), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
    }
    
    private func getMetricDescription(for title: String, score: Int) -> String {
        switch title {
        case "Foot Traffic":
            return getFootTrafficDescription(score: score)
        case "Audience Fit":
            return getTargetDemoFitDescription(score: score)
        case "Competition":
            return getNearbyCompetitionDescription(score: score)
        case "Commission":
            return getHostCommissionDescription(score: score)
        case "Access":
            return getParkingTransitDescription(score: score)
        case "Visibility":
            return getVisibilityAccessibilityDescription(score: score)
        case "Security":
            return getSecurityDescription(score: score)
        case "Amenities":
            return getAdjacentAmenitiesDescription(score: score)
        default:
            return getGenericDescription(score: score)
        }
    }
    
    // General metric descriptions
    private func getFootTrafficDescription(score: Int) -> String {
        switch score {
        case 1: return "< 100"     // Below minimum threshold
        case 2: return "100-200"   // Minimum viable
        case 3: return "200-350"   // Adequate
        case 4: return "350-500"   // Good
        case 5: return "> 500"     // Excellent
        default: return "N/A"
        }
    }
    
    private func getTargetDemoFitDescription(score: Int) -> String {
        switch score {
        case 1: return "Poor fit"
        case 2: return "Mixed, older"
        case 3: return "Neutral mix"
        case 4: return "Good fit"
        case 5: return "Ideal users"
        default: return "N/A"
        }
    }
    
    private func getNearbyCompetitionDescription(score: Int) -> String {
        switch score {
        case 1: return "On-site"
        case 2: return "≤2 min walk"
        case 3: return "3-4 min walk"
        case 4: return "5-6 min walk"
        case 5: return "7+ min walk"
        default: return "N/A"
        }
    }
    
    private func getHostCommissionDescription(score: Int) -> String {
        switch score {
        case 1: return ">20%"
        case 2: return "15-20%"
        case 3: return "10-15%"
        case 4: return "5-10%"
        case 5: return "0-5%"
        default: return "N/A"
        }
    }
    
    private func getParkingTransitDescription(score: Int) -> String {
        switch score {
        case 1: return "No loading"
        case 2: return "Difficult"
        case 3: return "Acceptable"
        case 4: return "Good"
        case 5: return "Dedicated"
        default: return "N/A"
        }
    }
    
    private func getVisibilityAccessibilityDescription(score: Int) -> String {
        switch score {
        case 1: return "Hidden"
        case 2: return "Side corridor"
        case 3: return "Secondary flow"
        case 4: return "Clear sightline"
        case 5: return "Prime spot"
        default: return "N/A"
        }
    }
    
    private func getSecurityDescription(score: Int) -> String {
        switch score {
        case 1: return "No CCTV"
        case 2: return "Limited"
        case 3: return "Part-time"
        case 4: return "CCTV + staff"
        case 5: return "Full security"
        default: return "N/A"
        }
    }
    
    private func getAdjacentAmenitiesDescription(score: Int) -> String {
        switch score {
        case 1: return "None"
        case 2: return "1 booster"
        case 3: return "2 boosters"
        case 4: return "3 boosters"
        case 5: return "4+ boosters"
        default: return "N/A"
        }
    }
    
    private func getGenericDescription(score: Int) -> String {
        switch score {
        case 5: return "Excellent"
        case 4: return "Good"
        case 3: return "Fair"
        case 2: return "Poor"
        case 1: return "Very Poor"
        default: return "N/A"
        }
    }
    
    // Centralized color function - same logic as other views
    private func getDecisionColor(for score: Double) -> Color {
        switch score {
        case 4.0...5.0: return .green
        case 3.0..<4.0: return .orange
        default: return .red
        }
    }
}

// MARK: - Score Breakdown Card
struct ScoreBreakdownCard: View {
    let location: Location
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Score Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ScoreRow(title: "Foot Traffic", score: location.generalMetrics?.footTrafficRating ?? 0, color: .blue, weight: "15%")
                ScoreRow(title: "Audience Fit", score: location.generalMetrics?.getRating(for: .targetDemographic) ?? 0, color: .purple, weight: "12%")
                ScoreRow(title: "Competition", score: location.generalMetrics?.getRating(for: .competition) ?? 0, color: .orange, weight: "12%")
                ScoreRow(title: "Access", score: location.generalMetrics?.getRating(for: .parkingTransit) ?? 0, color: .teal, weight: "18%")
                ScoreRow(title: location.locationType.displayName, score: Int(getModuleSpecificScore()), color: .indigo, weight: "25%")
                ScoreRow(title: "Commission", score: location.generalMetrics?.getRating(for: .hostCommission) ?? 0, color: .green, weight: "18%")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
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

struct ScoreRow: View {
    let title: String
    let score: Int
    let color: Color
    let weight: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 6) {
                if score == 0 {
                    Text("N/A")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(score)/5")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                }
                
                Text("(\(weight))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Star rating
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        if score == 0 {
                            // Show all gray stars for empty state
                            Image(systemName: "star")
                                .foregroundColor(.gray.opacity(0.3))
                                .font(.caption)
                        } else {
                            Image(systemName: star <= score ? "star.fill" : "star")
                                .foregroundColor(star <= score ? color : .gray.opacity(0.3))
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Performance Overview Card (Unified)
struct PerformanceOverviewCard: View {
    let location: Location
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 36) {
                // Compact Gauge
                VStack(spacing: 10) {
                    ReusableGaugeView(
                        score: overallScore,
                        maxScore: 5.0,
                        size: .large,
                        showBackground: true,
                        animate: true
                    )
                }
                
                // Recommendation
                VStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: decisionIcon)
                                .foregroundColor(decisionColor)
                                .font(.title2)
                            Text(recommendationTitle)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(decisionColor)
                        }
                        
                        Text(recommendationDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
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
    
    // MARK: - Helper Methods
    
    private func getModuleSpecificScore() -> Double {
        // Calculate score from new architecture based on location type
        // Note: Each metrics class now requires at least 3 metrics to be rated
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
    
    private var normalizedScore: Double {
        return overallScore / 5.0
    }
    
    // Centralized color function - same logic as LocationListView
    private func getDecisionColor(for score: Double) -> Color {
        switch score {
        case 4.0...5.0: return .green
        case 3.0..<4.0: return .orange
        default: return .red
        }
    }
    
    private var decision: LocationDecision {
        let score = overallScore
        
        // Handle insufficient metrics state (less than 3 rated)
        if score == 0.0 {
            return .pass // Default to pass for insufficient metrics
        }
        
        switch score {
        case 4.0...5.0: return .greenlight
        case 3.0..<4.0: return .watchlist
        default: return .pass
        }
    }
    
    private var decisionColor: Color {
        // Handle insufficient metrics state (less than 3 rated)
        if overallScore == 0.0 {
            return .gray // Neutral color for insufficient metrics state
        }
        
        switch decision {
        case .greenlight: return .green
        case .watchlist: return .orange
        case .pass: return .red
        }
    }
    
    private var decisionIcon: String {
        // Handle insufficient metrics state (less than 3 rated)
        if overallScore == 0.0 {
            return "exclamationmark.triangle" // Warning triangle for insufficient metrics
        }
        
        switch decision {
        case .greenlight: return "checkmark.circle.fill"
        case .watchlist: return "exclamationmark.triangle.fill"
        case .pass: return "xmark.circle.fill"
        }
    }
    
    private var recommendationTitle: String {
        // Handle insufficient metrics state (less than 3 rated)
        if overallScore == 0.0 {
            return "Insufficient Data"
        }
        
        switch decision {
        case .greenlight: return "Proceed"
        case .watchlist: return "Monitor"
        case .pass: return "Reconsider"
        }
    }
    
    private var recommendationDescription: String {
        // Handle insufficient metrics state (less than 3 rated)
        if overallScore == 0.0 {
            return "At least 3 metrics need to be rated before calculating a meaningful score. Continue evaluating key factors."
        }
        
        switch decision {
        case .greenlight: return "Location meets all criteria. Ready for implementation."
        case .watchlist: return "Location has potential but needs improvement in key areas."
        case .pass: return "Location doesn't meet minimum requirements. Consider alternatives."
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = try! ModelContainer(for: Location.self, LocationType.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self, MetricDefinition.self, MetricInstance.self, LocationMetrics.self).mainContext
        
        let locationType = LocationType(type: .office)
        let location = Location(name: "Sample Office", address: "123 Main St", comment: "Test location", locationType: locationType)
        
        // Set up the location
        location.generalMetrics = GeneralMetrics()
        location.financials = Financials()
        location.scorecard = Scorecard()
        
        // Insert into context
        context.insert(location)
        
        return DashboardView(location: location, selectedTab: .constant(0))
            .environmentObject(SharedModelContext.shared)
    }
}
