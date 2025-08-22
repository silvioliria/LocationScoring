import SwiftUI
import SwiftData

struct HospitalMetricsView: View {
    let location: Location
    let onDataChanged: () -> Void
    @Environment(\.modelContext) private var context
    
    @State private var selectedMetric: HospitalMetricType?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Score Widget
                    CompactHospitalScoreWidget(location: location)
                    
                    // Core Metrics Section
                    MetricsSectionCard(
                        title: "Core Metrics",
                        icon: "heart.text.square",
                        iconColor: .red,
                        content: {
                            VStack(spacing: 12) {
                                HospitalMetricRowView(
                                    title: "Patient Volume",
                                    rating: getMetricRating(for: .patientVolume),
                                    notes: getMetricNotes(for: .patientVolume),
                                    onTap: { selectedMetric = .patientVolume }
                                )
                                
                                HospitalMetricRowView(
                                    title: "Staff Size",
                                    rating: getMetricRating(for: .staffSize),
                                    notes: getMetricNotes(for: .staffSize),
                                    onTap: { selectedMetric = .staffSize }
                                )
                                
                                HospitalMetricRowView(
                                    title: "Visitor Traffic",
                                    rating: getMetricRating(for: .visitorTraffic),
                                    notes: getMetricNotes(for: .visitorTraffic),
                                    onTap: { selectedMetric = .visitorTraffic }
                                )
                            }
                        }
                    )
                    
                    // Service Metrics Section
                    MetricsSectionCard(
                        title: "Service Metrics",
                        icon: "stethoscope",
                        iconColor: .red,
                        content: {
                            VStack(spacing: 12) {
                                HospitalMetricRowView(
                                    title: "Food Service",
                                    rating: getMetricRating(for: .foodService),
                                    notes: getMetricNotes(for: .foodService),
                                    onTap: { selectedMetric = .foodService }
                                )
                                
                                HospitalMetricRowView(
                                    title: "Vending Restrictions",
                                    rating: getMetricRating(for: .vendingRestrictions),
                                    notes: getMetricNotes(for: .vendingRestrictions),
                                    onTap: { selectedMetric = .vendingRestrictions }
                                )
                                
                                HospitalMetricRowView(
                                    title: "Hours of Operation",
                                    rating: getMetricRating(for: .hoursOfOperation),
                                    notes: getMetricNotes(for: .hoursOfOperation),
                                    onTap: { selectedMetric = .hoursOfOperation }
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
    
    private func getMetricRating(for metric: HospitalMetricType) -> Int {
        // Get rating from new architecture
        if let hospitalMetrics = location.hospitalMetrics {
            switch metric {
            case .patientVolume: return hospitalMetrics.patientVolumeRating
            case .staffSize: return hospitalMetrics.staffSizeRating
            case .visitorTraffic: return hospitalMetrics.visitorTrafficRating
            case .foodService: return hospitalMetrics.foodServiceRating
            case .vendingRestrictions: return hospitalMetrics.vendingRestrictionsRating
            case .hoursOfOperation: return hospitalMetrics.hoursOfOperationRating
            }
        }
        return 0
    }
    
    private func getMetricNotes(for metric: HospitalMetricType) -> String {
        // Get notes from new architecture
        if let hospitalMetrics = location.hospitalMetrics {
            switch metric {
            case .patientVolume: return hospitalMetrics.patientVolumeNotes
            case .staffSize: return hospitalMetrics.staffSizeNotes
            case .visitorTraffic: return hospitalMetrics.visitorTrafficNotes
            case .foodService: return hospitalMetrics.foodServiceNotes
            case .vendingRestrictions: return hospitalMetrics.vendingRestrictionsNotes
            case .hoursOfOperation: return hospitalMetrics.hoursOfOperationNotes
            }
        }
        return ""
    }
}

// Simple metric row view to match clean design
struct HospitalMetricRowView: View {
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
        case "Patient Volume": return "person.3"
        case "Staff Size": return "stethoscope"
        case "Visitor Traffic": return "person.2"
        case "Food Service": return "fork.knife"
        case "Vending Restrictions": return "exclamationmark.triangle"
        case "Hours of Operation": return "clock"
        default: return "star"
        }
    }
}

// MARK: - Compact Hospital Score Widget
struct CompactHospitalScoreWidget: View {
    let location: Location
    
    private var overallScore: Double {
        location.getHospitalMetrics()?.calculateOverallScore() ?? 0.0
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

struct HospitalMetricsView_Previews: PreviewProvider {
    static var previews: some View {
        // Temporarily simplified preview without SwiftData
        let locationType = LocationType(type: .hospital)
        let location = Location(name: "Sample Hospital", address: "123 Medical St", comment: "Test hospital location", locationType: locationType)
        
        return HospitalMetricsView(location: location, onDataChanged: {})
    }
}
