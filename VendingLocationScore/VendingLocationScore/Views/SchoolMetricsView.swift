import SwiftUI
import SwiftData

struct SchoolMetricsView: View {
    let location: Location
    let onDataChanged: () -> Void
    @Environment(\.modelContext) private var context
    @State private var selectedMetric: SchoolMetricType?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Score Widget
                    CompactSchoolScoreWidget(location: location)
                    
                    // Core Metrics Section
                    MetricsSectionCard(
                        title: "Core Metrics",
                        icon: "book.fill",
                        iconColor: .green,
                        content: {
                            VStack(spacing: 12) {
                                SchoolMetricRowView(
                                    title: "Student Population",
                                    rating: getMetricRating(for: .studentPopulation),
                                    notes: getMetricNotes(for: .studentPopulation),
                                    onTap: { selectedMetric = .studentPopulation }
                                )
                                
                                SchoolMetricRowView(
                                    title: "Staff Size",
                                    rating: getMetricRating(for: .staffSize),
                                    notes: getMetricNotes(for: .staffSize),
                                    onTap: { selectedMetric = .staffSize }
                                )
                                
                                SchoolMetricRowView(
                                    title: "Food Service",
                                    rating: getMetricRating(for: .foodService),
                                    notes: getMetricNotes(for: .foodService),
                                    onTap: { selectedMetric = .foodService }
                                )
                            }
                        }
                    )
                    
                    // Additional Metrics Section
                    MetricsSectionCard(
                        title: "Additional Metrics",
                        icon: "plus.circle",
                        iconColor: .green,
                        content: {
                            VStack(spacing: 12) {
                                SchoolMetricRowView(
                                    title: "Vending Restrictions",
                                    rating: getMetricRating(for: .vendingRestrictions),
                                    notes: getMetricNotes(for: .vendingRestrictions),
                                    onTap: { selectedMetric = .vendingRestrictions }
                                )
                                
                                SchoolMetricRowView(
                                    title: "Hours of Operation",
                                    rating: getMetricRating(for: .hoursOfOperation),
                                    notes: getMetricNotes(for: .hoursOfOperation),
                                    onTap: { selectedMetric = .hoursOfOperation }
                                )
                                
                                SchoolMetricRowView(
                                    title: "Campus Layout",
                                    rating: getMetricRating(for: .campusLayout),
                                    notes: getMetricNotes(for: .campusLayout),
                                    onTap: { selectedMetric = .campusLayout }
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
    
    private func getMetricRating(for metric: SchoolMetricType) -> Int {
        if let schoolMetrics = location.schoolMetrics {
            switch metric {
            case .studentPopulation: return schoolMetrics.studentPopulationRating
            case .staffSize: return schoolMetrics.staffSizeRating
            case .foodService: return schoolMetrics.foodServiceRating
            case .vendingRestrictions: return schoolMetrics.vendingRestrictionsRating
            case .hoursOfOperation: return schoolMetrics.hoursOfOperationRating
            case .campusLayout: return schoolMetrics.campusLayoutRating
            }
        }
        return 0
    }
    
    private func getMetricNotes(for metric: SchoolMetricType) -> String {
        if let schoolMetrics = location.schoolMetrics {
            switch metric {
            case .studentPopulation: return schoolMetrics.studentPopulationNotes
            case .staffSize: return schoolMetrics.staffSizeNotes
            case .foodService: return schoolMetrics.foodServiceNotes
            case .vendingRestrictions: return schoolMetrics.vendingRestrictionsNotes
            case .hoursOfOperation: return schoolMetrics.hoursOfOperationNotes
            case .campusLayout: return schoolMetrics.campusLayoutNotes
            }
        }
        return ""
    }
}

// MARK: - Compact School Score Widget
// Simple metric row view to match clean design
struct SchoolMetricRowView: View {
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
        case "Student Population": return "person.3"
        case "Staff Size": return "person.2"
        case "Food Service": return "fork.knife"
        case "Vending Restrictions": return "exclamationmark.triangle"
        case "Hours of Operation": return "clock"
        case "Campus Layout": return "map"
        default: return "star"
        }
    }
}

// MARK: - Compact School Score Widget
struct CompactSchoolScoreWidget: View {
    let location: Location
    
    private var overallScore: Double {
        location.getSchoolMetrics()?.calculateOverallScore() ?? 0.0
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

struct SchoolMetricsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = try! ModelContainer(for: Location.self, LocationType.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self, MetricDefinition.self, MetricInstance.self, LocationMetrics.self).mainContext
        
        let locationType = LocationType(type: .school)
        let location = Location(name: "Sample School", address: "123 Education St", comment: "Test school location", locationType: locationType)
        
        // Set up the location
        let generalMetrics = GeneralMetrics()
        let financials = Financials()
        let scorecard = Scorecard()
        
        location.generalMetrics = generalMetrics
        location.financials = financials
        location.scorecard = scorecard
        
        // Insert into context
        context.insert(location)
        
        return SchoolMetricsView(location: location, onDataChanged: {})
            .environmentObject(SharedModelContext.shared)
    }
}
