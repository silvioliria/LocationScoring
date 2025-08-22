import SwiftUI

// Generic metrics view that works with any metric type (DEPRECATED - using dedicated views now)
/*
struct MetricsSectionView<MetricType: ModuleMetricType>: View {
    let title: String
    let icon: String
    let color: Color
    let location: Location
    let onDataChanged: () -> Void
    let headerContent: (() -> AnyView)?
    @State private var selectedMetric: MetricWrapper?
    
    init(title: String, icon: String, color: Color, location: Location, onDataChanged: @escaping () -> Void, headerContent: (() -> AnyView)? = nil) {
        self.title = title
        self.icon = icon
        self.color = color
        self.location = location
        self.onDataChanged = onDataChanged
        self.headerContent = headerContent
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header if provided
            if let headerContent = headerContent {
                headerContent()
                    .padding(.horizontal)
                    .padding(.top)
            }
            
            Form {
                
                // First section - Core Metrics (like "Foot Traffic & Demographics")
                Section("Core Metrics") {
                    ForEach(Array(MetricType.allCases.prefix(3)), id: \.id) { metric in
                        MetricRowView(
                            title: metric.title,
                            rating: getMetricRating(for: metric),
                            notes: getMetricNotes(for: metric),
                            metricType: .footTraffic, // Use a default metric type
                            onTap: { selectedMetric = MetricWrapper(metricType: metric) },
                            isComputed: false
                        )
                    }
                }
                
                // Second section - Additional Metrics (like "Competition & Environment")
                if MetricType.allCases.count > 3 {
                    Section("Additional Metrics") {
                        ForEach(Array(MetricType.allCases.dropFirst(3)), id: \.id) { metric in
                            MetricRowView(
                                title: metric.title,
                                rating: getMetricRating(for: metric),
                                notes: getMetricNotes(for: metric),
                                metricType: .footTraffic, // Use a default metric type
                                onTap: { selectedMetric = MetricWrapper(metricType: metric) },
                                isComputed: false
                            )
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedMetric) { metricWrapper in
            ModuleMetricDetailView(
                location: location,
                metricType: metricWrapper.metricType,
                onDataChanged: onDataChanged
            )
        }
    }
    

    
    private var hasModuleMetrics: Bool {
        // Check if the location has the appropriate metrics for this module type
        switch MetricType.self {
        case is OfficeMetricType.Type:
            return location.officeMetrics != nil
        case is HospitalMetricType.Type:
            return location.hospitalMetrics != nil
        case is SchoolMetricType.Type:
            return location.schoolMetrics != nil
        case is ResidentialMetricType.Type:
            return location.residentialMetrics != nil
        default:
            return false
        }
    }
    
    private func getMetricRating(for metric: any ModuleMetricType) -> Int {
        // Get the rating from the appropriate metrics object based on the metric type
        switch MetricType.self {
        case is OfficeMetricType.Type:
            if let officeMetrics = location.officeMetrics {
                return getOfficeMetricRating(officeMetrics, for: metric)
            }
        case is HospitalMetricType.Type:
            if let hospitalMetrics = location.hospitalMetrics {
                return getHospitalMetricRating(hospitalMetrics, for: metric)
            }
        case is SchoolMetricType.Type:
            if let schoolMetrics = location.schoolMetrics {
                return getSchoolMetricRating(schoolMetrics, for: metric)
            }
        case is ResidentialMetricType.Type:
            if let residentialMetrics = location.residentialMetrics {
                return getResidentialMetricRating(residentialMetrics, for: metric)
            }
        default:
            break
        }
        return 0
    }
    
    private func getMetricNotes(for metric: any ModuleMetricType) -> String {
        // Get the notes from the appropriate metrics object based on the metric type
        switch MetricType.self {
        case is OfficeMetricType.Type:
            if let officeMetrics = location.officeMetrics {
                return getOfficeMetricNotes(officeMetrics, for: metric)
            }
        case is HospitalMetricType.Type:
            if let hospitalMetrics = location.hospitalMetrics {
                return getHospitalMetricNotes(hospitalMetrics, for: metric)
            }
        case is SchoolMetricType.Type:
            if let schoolMetrics = location.schoolMetrics {
                return getSchoolMetricNotes(schoolMetrics, for: metric)
            }
        case is ResidentialMetricType.Type:
            if let residentialMetrics = location.residentialMetrics {
                return getResidentialMetricNotes(residentialMetrics, for: metric)
            }
        default:
            break
        }
        return ""
    }
    
    // MARK: - Office Metrics Helpers
    
    private func getOfficeMetricRating(_ metrics: OfficeMetrics, for metric: any ModuleMetricType) -> Int {
        guard let officeMetric = metric as? OfficeMetricType else { return 0 }
        
        switch officeMetric {
        case .commonAreas: return metrics.commonAreasRating
        case .hoursAccess: return metrics.hoursAccessRating
        case .tenantAmenities: return metrics.tenantAmenitiesRating
        case .proximityHubTransit: return metrics.proximityHubTransitRating
        case .brandingRestrictions: return metrics.brandingRestrictionsRating
        case .layoutType: return metrics.layoutTypeRating
        }
    }
    
    private func getOfficeMetricNotes(_ metrics: OfficeMetrics, for metric: any ModuleMetricType) -> String {
        guard let officeMetric = metric as? OfficeMetricType else { return "" }
        
        switch officeMetric {
        case .commonAreas: return metrics.commonAreasNotes
        case .hoursAccess: return metrics.hoursAccessNotes
        case .tenantAmenities: return metrics.tenantAmenitiesNotes
        case .proximityHubTransit: return metrics.proximityHubTransitNotes
        case .brandingRestrictions: return metrics.brandingRestrictionsNotes
        case .layoutType: return metrics.layoutTypeNotes
        }
    }
    
    // MARK: - Hospital Metrics Helpers
    
    private func getHospitalMetricRating(_ metrics: HospitalMetrics, for metric: any ModuleMetricType) -> Int {
        guard let hospitalMetric = metric as? HospitalMetricType else { return 0 }
        
        switch hospitalMetric {
        case .patientVolume: return metrics.patientVolumeRating
        case .staffSize: return metrics.staffSizeRating
        case .visitorTraffic: return metrics.visitorTrafficRating
        case .foodService: return metrics.foodServiceRating
        case .vendingRestrictions: return metrics.vendingRestrictionsRating
        case .hoursOfOperation: return metrics.hoursOfOperationRating
        }
    }
    
    private func getHospitalMetricNotes(_ metrics: HospitalMetrics, for metric: any ModuleMetricType) -> String {
        guard let hospitalMetric = metric as? HospitalMetricType else { return "" }
        
        switch hospitalMetric {
        case .patientVolume: return metrics.patientVolumeNotes
        case .staffSize: return metrics.staffSizeNotes
        case .visitorTraffic: return metrics.visitorTrafficNotes
        case .foodService: return metrics.foodServiceNotes
        case .vendingRestrictions: return metrics.vendingRestrictionsNotes
        case .hoursOfOperation: return metrics.hoursOfOperationNotes
        }
    }
    
    // MARK: - School Metrics Helpers
    
    private func getSchoolMetricRating(_ metrics: SchoolMetrics, for metric: any ModuleMetricType) -> Int {
        guard let schoolMetric = metric as? SchoolMetricType else { return 0 }
        
        switch schoolMetric {
        case .studentPopulation: return metrics.studentPopulationRating
        case .staffSize: return metrics.staffSizeRating
        case .foodService: return metrics.foodServiceRating
        case .vendingRestrictions: return metrics.vendingRestrictionsRating
        case .hoursOfOperation: return metrics.hoursOfOperationRating
        case .campusLayout: return metrics.campusLayoutRating
        }
    }
    
    private func getSchoolMetricNotes(_ metrics: SchoolMetrics, for metric: any ModuleMetricType) -> String {
        guard let schoolMetric = metric as? SchoolMetricType else { return "" }
        
        switch schoolMetric {
        case .studentPopulation: return metrics.studentPopulationNotes
        case .staffSize: return metrics.staffSizeNotes
        case .foodService: return metrics.foodServiceNotes
        case .vendingRestrictions: return metrics.vendingRestrictionsNotes
        case .hoursOfOperation: return metrics.hoursOfOperationNotes
        case .campusLayout: return metrics.campusLayoutNotes
        }
    }
    
    // MARK: - Residential Metrics Helpers
    
    private func getResidentialMetricRating(_ metrics: ResidentialMetrics, for metric: any ModuleMetricType) -> Int {
        guard let residentialMetric = metric as? ResidentialMetricType else { return 0 }
        
        switch residentialMetric {
        case .unitCount: return metrics.unitCountRating
        case .occupancyRate: return metrics.occupancyRateRating
        case .demographics: return metrics.demographicRating
        case .foodService: return metrics.foodServiceRating
        case .vendingRestrictions: return metrics.vendingRestrictionsRating
        case .hoursOfOperation: return metrics.hoursOfOperationRating
        case .buildingLayout: return metrics.buildingLayoutRating
        }
    }
    
    private func getResidentialMetricNotes(_ metrics: ResidentialMetrics, for metric: any ModuleMetricType) -> String {
        guard let residentialMetric = metric as? ResidentialMetricType else { return "" }
        
        switch residentialMetric {
        case .unitCount: return metrics.unitCountNotes
        case .occupancyRate: return metrics.occupancyRateNotes
        case .demographics: return metrics.demographicNotes
        case .foodService: return metrics.foodServiceNotes
        case .vendingRestrictions: return metrics.vendingRestrictionsNotes
        case .hoursOfOperation: return metrics.hoursOfOperationNotes
        case .buildingLayout: return metrics.buildingLayoutNotes
        }
    }
}
*/
