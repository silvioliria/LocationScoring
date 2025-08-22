import SwiftUI
import SwiftData

struct ResidentialMetricsView: View {
    let location: Location
    let onDataChanged: () -> Void
    @Environment(\.modelContext) private var context
    
    @State private var selectedMetric: ResidentialMetricType?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Score Widget
                    CompactResidentialScoreWidget(location: location)
                    
                    // Property Metrics Section
                    MetricsSectionCard(
                        title: "Property Metrics",
                        icon: "building.columns",
                        iconColor: .purple,
                        content: {
                            VStack(spacing: 12) {
                                ResidentialMetricRowView(
                                    title: "Unit Count",
                                    rating: getMetricRating(for: .unitCount),
                                    notes: getMetricNotes(for: .unitCount),
                                    onTap: { selectedMetric = .unitCount }
                                )
                                
                                ResidentialMetricRowView(
                                    title: "Occupancy Rate",
                                    rating: getMetricRating(for: .occupancyRate),
                                    notes: getMetricNotes(for: .occupancyRate),
                                    onTap: { selectedMetric = .occupancyRate }
                                )
                                
                                ResidentialMetricRowView(
                                    title: "Demographics",
                                    rating: getMetricRating(for: .demographics),
                                    notes: getMetricNotes(for: .demographics),
                                    onTap: { selectedMetric = .demographics }
                                )
                            }
                        }
                    )
                    
                    // Service & Access Section
                    MetricsSectionCard(
                        title: "Service & Access",
                        icon: "door.right.hand.open",
                        iconColor: .purple,
                        content: {
                            VStack(spacing: 12) {
                                ResidentialMetricRowView(
                                    title: "Food Service",
                                    rating: getMetricRating(for: .foodService),
                                    notes: getMetricNotes(for: .foodService),
                                    onTap: { selectedMetric = .foodService }
                                )
                                
                                ResidentialMetricRowView(
                                    title: "Vending Restrictions",
                                    rating: getMetricRating(for: .vendingRestrictions),
                                    notes: getMetricNotes(for: .vendingRestrictions),
                                    onTap: { selectedMetric = .vendingRestrictions }
                                )
                                
                                ResidentialMetricRowView(
                                    title: "Hours of Operation",
                                    rating: getMetricRating(for: .hoursOfOperation),
                                    notes: getMetricNotes(for: .hoursOfOperation),
                                    onTap: { selectedMetric = .hoursOfOperation }
                                )
                                
                                ResidentialMetricRowView(
                                    title: "Building Layout",
                                    rating: getMetricRating(for: .buildingLayout),
                                    notes: getMetricNotes(for: .buildingLayout),
                                    onTap: { selectedMetric = .buildingLayout }
                                )
                            }
                        }
                    )
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedMetric) { metricType in
            ModuleMetricDetailView(
                location: location,
                metricType: metricType,
                onDataChanged: onDataChanged
            )
        }
    }
    
    private func getMetricRating(for metric: ResidentialMetricType) -> Int {
        // Get rating from new architecture
        if let residentialMetrics = location.residentialMetrics {
            switch metric {
            case .unitCount: return residentialMetrics.unitCountRating
            case .occupancyRate: return residentialMetrics.occupancyRateRating
            case .demographics: return residentialMetrics.demographicRating
            case .foodService: return residentialMetrics.foodServiceRating
            case .vendingRestrictions: return residentialMetrics.vendingRestrictionsRating
            case .hoursOfOperation: return residentialMetrics.hoursOfOperationRating
            case .buildingLayout: return residentialMetrics.buildingLayoutRating
            }
        }
        return 0
    }
    
    private func getMetricNotes(for metric: ResidentialMetricType) -> String {
        // Get notes from new architecture
        if let residentialMetrics = location.residentialMetrics {
            switch metric {
            case .unitCount: return residentialMetrics.unitCountNotes
            case .occupancyRate: return residentialMetrics.occupancyRateNotes
            case .demographics: return residentialMetrics.demographicNotes
            case .foodService: return residentialMetrics.foodServiceNotes
            case .vendingRestrictions: return residentialMetrics.vendingRestrictionsNotes
            case .hoursOfOperation: return residentialMetrics.hoursOfOperationNotes
            case .buildingLayout: return residentialMetrics.buildingLayoutNotes
            }
        }
        return ""
    }
}

// Simple metric row view to match clean design
struct ResidentialMetricRowView: View {
    let title: String
    let rating: Int
    let notes: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: getIconForMetric(title))
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if rating == 0 {
                        Text("Not Rated")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .foregroundColor(star <= rating ? .yellow : Color(.systemGray4))
                                    .font(.system(size: 12))
                            }
                        }
                    }
                    
                    if !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getIconForMetric(_ title: String) -> String {
        switch title {
        case "Unit Count": return "building.columns"
        case "Occupancy Rate": return "person.3"
        case "Demographics": return "person.2"
        case "Food Service": return "fork.knife"
        case "Vending Restrictions": return "exclamationmark.triangle"
        case "Hours of Operation": return "clock"
        case "Building Layout": return "square.grid.3x3"
        default: return "star"
        }
    }
}

// MARK: - Compact Residential Score Widget
struct CompactResidentialScoreWidget: View {
    let location: Location
    
    private var overallScore: Double {
        location.getResidentialMetrics()?.calculateOverallScore() ?? 0.0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Metrics Score")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if overallScore > 0 {
                        Text("Based on rated metrics")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Rate at least 3 metrics")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                ReusableGaugeView(
                    score: overallScore,
                    maxScore: 5.0,
                    size: .medium,
                    showBackground: true,
                    animate: true
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

struct ResidentialMetricsView_Previews: PreviewProvider {
    static var previews: some View {
        // Temporarily simplified preview without SwiftData
        let locationType = LocationType(type: .residential)
        let location = Location(name: "Sample Residential", address: "123 Home St", comment: "Test residential location", locationType: locationType)
        
        return ResidentialMetricsView(location: location, onDataChanged: {})
    }
}
