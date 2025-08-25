import SwiftUI

// MARK: - Office Metrics View

struct OfficeMetricsView: View {
    let location: Location
    let onDataChanged: () -> Void
    
    @State private var selectedMetric: OfficeMetricType?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Score Widget
                    CompactOfficeScoreWidget(location: location)
                    
                    // Office Environment Section
                    MetricsSectionCard(
                        title: "Office Environment",
                        icon: "building.2",
                        iconColor: .blue,
                        content: {
                            VStack(spacing: 12) {
                                OfficeMetricRowView(
                                    title: "Common Areas",
                                    rating: getMetricRating(for: .commonAreas),
                                    notes: getMetricNotes(for: .commonAreas),
                                    onTap: { selectedMetric = .commonAreas }
                                )
                                
                                OfficeMetricRowView(
                                    title: "Hours & Access",
                                    rating: getMetricRating(for: .hoursAccess),
                                    notes: getMetricNotes(for: .hoursAccess),
                                    onTap: { selectedMetric = .hoursAccess }
                                )
                                
                                OfficeMetricRowView(
                                    title: "Tenant Amenities",
                                    rating: getMetricRating(for: .tenantAmenities),
                                    notes: getMetricNotes(for: .tenantAmenities),
                                    onTap: { selectedMetric = .tenantAmenities }
                                )
                            }
                        }
                    )
                    
                    // Location & Accessibility Section
                    MetricsSectionCard(
                        title: "Location & Accessibility",
                        icon: "location",
                        iconColor: .blue,
                        content: {
                            VStack(spacing: 12) {
                                OfficeMetricRowView(
                                    title: "Hub Proximity & Transit",
                                    rating: getMetricRating(for: .proximityHubTransit),
                                    notes: getMetricNotes(for: .proximityHubTransit),
                                    onTap: { selectedMetric = .proximityHubTransit }
                                )
                                
                                OfficeMetricRowView(
                                    title: "Branding Restrictions",
                                    rating: getMetricRating(for: .brandingRestrictions),
                                    notes: getMetricNotes(for: .brandingRestrictions),
                                    onTap: { selectedMetric = .brandingRestrictions }
                                )
                                
                                OfficeMetricRowView(
                                    title: "Layout Type",
                                    rating: getMetricRating(for: .layoutType),
                                    notes: getMetricNotes(for: .layoutType),
                                    onTap: { selectedMetric = .layoutType }
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
    
    private func getMetricRating(for metric: OfficeMetricType) -> Int {
        guard let officeMetrics = location.getOfficeMetrics() else { return 0 }
        
        switch metric {
        case .commonAreas: return officeMetrics.commonAreasRating
        case .hoursAccess: return officeMetrics.hoursAccessRating
        case .tenantAmenities: return officeMetrics.tenantAmenitiesRating
        case .proximityHubTransit: return officeMetrics.proximityHubTransitRating
        case .brandingRestrictions: return officeMetrics.brandingRestrictionsRating
        case .layoutType: return officeMetrics.layoutTypeRating
        }
    }
    
    private func getMetricNotes(for metric: OfficeMetricType) -> String {
        guard let officeMetrics = location.getOfficeMetrics() else { return "" }
        
        switch metric {
        case .commonAreas: return officeMetrics.commonAreasNotes
        case .hoursAccess: return officeMetrics.hoursAccessNotes
        case .tenantAmenities: return officeMetrics.tenantAmenitiesNotes
        case .proximityHubTransit: return officeMetrics.proximityHubTransitNotes
        case .brandingRestrictions: return officeMetrics.brandingRestrictionsNotes
        case .layoutType: return officeMetrics.layoutTypeNotes
        }
    }
}

// Simple metric row view to match clean design
struct OfficeMetricRowView: View {
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
        case "Common Areas": return "person.3"
        case "Hours & Access": return "clock"
        case "Tenant Amenities": return "star"
        case "Hub Proximity & Transit": return "location"
        case "Branding Restrictions": return "exclamationmark.triangle"
        case "Layout Type": return "square.grid.3x3"
        default: return "star"
        }
    }
}

// MARK: - Compact Office Score Widget
struct CompactOfficeScoreWidget: View {
    let location: Location
    
    private var overallScore: Double {
        location.getOfficeMetrics()?.calculateOverallScore() ?? 0.0
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

#Preview {
    OfficeMetricsView(
        location: Location(
            name: "Sample Office",
            address: "123 Main St",
            comment: "Sample location",
            locationType: LocationType(type: .office)
        ),
        onDataChanged: {}
    )
}
