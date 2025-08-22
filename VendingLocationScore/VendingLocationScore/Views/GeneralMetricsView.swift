import SwiftUI
import SwiftData

struct GeneralMetricsView: View {
    let location: Location
    let onDataChanged: () -> Void
    @Environment(\.modelContext) private var context
    @State private var selectedMetric: MetricType?
    
    // Add centralized metric service
    @StateObject private var metricService = MetricService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Score Widget
                    CompactGeneralScoreWidget(location: location)
                    
                    // Foot Traffic & Demographics Section
                    MetricsSectionCard(
                        title: "Foot Traffic & Demographics",
                        icon: "person.3",
                        iconColor: .green,
                        content: {
                            VStack(spacing: 12) {
                                GeneralMetricRowView(
                                    title: "Foot Traffic",
                                    rating: getMetricRating(for: .footTraffic),
                                    notes: getMetricNotes(for: .footTraffic),
                                    metricType: .footTraffic,
                                    onTap: { selectedMetric = .footTraffic },
                                    isComputed: false
                                )
                                
                                GeneralMetricRowView(
                                    title: "Audience Fit",
                                    rating: getMetricRating(for: .targetDemographic),
                                    notes: getMetricNotes(for: .targetDemographic),
                                    metricType: .targetDemographic,
                                    onTap: { selectedMetric = .targetDemographic },
                                    isComputed: false
                                )
                                
                                GeneralMetricRowView(
                                    title: "Competition",
                                    rating: getMetricRating(for: .competition),
                                    notes: getMetricNotes(for: .competition),
                                    metricType: .competition,
                                    onTap: { selectedMetric = .competition },
                                    isComputed: false
                                )
                            }
                        }
                    )
                    
                    // Access & Infrastructure Section
                    MetricsSectionCard(
                        title: "Access & Infrastructure",
                        icon: "car",
                        iconColor: .green,
                        content: {
                            VStack(spacing: 12) {
                                GeneralMetricRowView(
                                    title: "Access",
                                    rating: getMetricRating(for: .parkingTransit),
                                    notes: getMetricNotes(for: .parkingTransit),
                                    metricType: .parkingTransit,
                                    onTap: { selectedMetric = .parkingTransit },
                                    isComputed: false
                                )
                                
                                GeneralMetricRowView(
                                    title: "Security",
                                    rating: getMetricRating(for: .security),
                                    notes: getMetricNotes(for: .security),
                                    metricType: .security,
                                    onTap: { selectedMetric = .security },
                                    isComputed: false
                                )
                                
                                GeneralMetricRowView(
                                    title: "Visibility",
                                    rating: getMetricRating(for: .visibility),
                                    notes: getMetricNotes(for: .visibility),
                                    metricType: .visibility,
                                    onTap: { selectedMetric = .visibility },
                                    isComputed: false
                                )
                            }
                        }
                    )
                    
                    // Amenities & Financial Section
                    MetricsSectionCard(
                        title: "Amenities & Financial",
                        icon: "star",
                        iconColor: .green,
                        content: {
                            VStack(spacing: 12) {
                                GeneralMetricRowView(
                                    title: "Amenities",
                                    rating: getMetricRating(for: .amenities),
                                    notes: getMetricNotes(for: .amenities),
                                    metricType: .amenities,
                                    onTap: { selectedMetric = .amenities },
                                    isComputed: false
                                )
                                
                                GeneralMetricRowView(
                                    title: "Commission",
                                    rating: getMetricRating(for: .hostCommission),
                                    notes: getMetricNotes(for: .hostCommission),
                                    metricType: .hostCommission,
                                    onTap: { selectedMetric = .hostCommission },
                                    isComputed: false
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
            // Use existing MetricDetailView to maintain UI consistency
            MetricDetailView(
                location: location,
                metricType: metricType,
                onDataChanged: onDataChanged
            )
        }
        // Centralized metrics initialization disabled temporarily
    }
    
    // MARK: - Centralized Metric Integration
    
    private func initializeCentralizedMetrics() async {
        do {
            // This will create centralized metrics if they don't exist
            _ = try metricService.getLocationMetrics(for: location, context: context)
            
            // Migrate existing data if this is the first time
            try metricService.migrateLegacyMetrics(for: location, context: context)
        } catch {
            print("Error initializing centralized metrics: \(error)")
        }
    }
    
    // MARK: - Metric Data Retrieval (Using Legacy System)
    
    private func getMetricRating(for metricType: MetricType) -> Int {
        // Use legacy system (centralized system disabled temporarily)
        return location.generalMetrics?.getRating(for: metricType) ?? 0
    }
    
    private func getMetricNotes(for metricType: MetricType) -> String {
        // Use legacy system (centralized system disabled temporarily)
        return location.generalMetrics?.getNotes(for: metricType) ?? ""
    }
    
    private func getMetricKey(for metricType: MetricType) -> String {
        switch metricType {
        case .footTraffic:
            return "general_foot_traffic"
        case .targetDemographic:
            return "general_demographics"
        case .competition:
            return "general_competition"
        case .parkingTransit:
            return "general_accessibility"
        case .security:
            return "general_security"
        case .visibility:
            return "general_visibility"
        case .amenities:
            return "general_amenities"
        case .hostCommission:
            return "general_commission"
        }
    }
}

// MARK: - Supporting Views

// Simple metric row view to match location views design
struct GeneralMetricRowView: View {
    let title: String
    let rating: Int
    let notes: String
    let metricType: MetricType
    let onTap: () -> Void
    let isComputed: Bool
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: getIconForMetric(metricType))
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
    
    private func getIconForMetric(_ metricType: MetricType) -> String {
        switch metricType {
        case .footTraffic: return "person.3"
        case .targetDemographic: return "person.2"
        case .hostCommission: return "dollarsign.circle"
        case .competition: return "building.2"
        case .visibility: return "eye"
        case .security: return "shield"
        case .parkingTransit: return "car"
        case .amenities: return "star"
        }
    }
}

// MARK: - Compact General Score Widget
struct CompactGeneralScoreWidget: View {
    let location: Location
    
    private var overallScore: Double {
        location.calculateOverallScore()
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

struct GeneralMetricsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = try! ModelContainer(for: Location.self, LocationType.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self).mainContext
        
        let locationType = LocationType(type: .office)
        let location = Location(name: "Sample Office", address: "123 Main St", comment: "Test location", locationType: locationType)
        
        // Set up the location
        location.generalMetrics = GeneralMetrics()
        
        // Insert into context
        context.insert(location)
        
        return GeneralMetricsView(location: location, onDataChanged: {})
            .modelContainer(context.container)
    }
}
