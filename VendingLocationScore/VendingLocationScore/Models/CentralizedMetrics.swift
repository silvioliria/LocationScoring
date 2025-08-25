import Foundation
import SwiftData
import SwiftUI

// MARK: - Centralized Metric System Architecture

/// Core metric categories that apply across all location types
enum MetricCategory: String, CaseIterable, Identifiable {
    case footTraffic = "foot_traffic"
    case demographics = "demographics"
    case competition = "competition"
    case accessibility = "accessibility"
    case security = "security"
    case amenities = "amenities"
    case operations = "operations"
    case financial = "financial"
    case layout = "layout"
    case restrictions = "restrictions"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .footTraffic: return "Foot Traffic"
        case .demographics: return "Demographics"
        case .competition: return "Competition"
        case .accessibility: return "Accessibility" 
        case .security: return "Security"
        case .amenities: return "Amenities"
        case .operations: return "Operations"
        case .financial: return "Financial"
        case .layout: return "Layout"
        case .restrictions: return "Restrictions"
        }
    }
    
    var icon: String {
        switch self {
        case .footTraffic: return "figure.walk"
        case .demographics: return "person.3"
        case .competition: return "building.2"
        case .accessibility: return "car"
        case .security: return "shield"
        case .amenities: return "list.bullet"
        case .operations: return "clock"
        case .financial: return "dollarsign.circle"
        case .layout: return "square.grid.2x2"
        case .restrictions: return "exclamationmark.triangle"
        }
    }
    
    var color: Color {
        switch self {
        case .footTraffic: return .blue
        case .demographics: return .purple
        case .competition: return .orange
        case .accessibility: return .teal
        case .security: return .red
        case .amenities: return .green
        case .operations: return .indigo
        case .financial: return .mint
        case .layout: return .brown
        case .restrictions: return .yellow
        }
    }
}

/// Base metric definition that can be specialized for different location types
@Model
class MetricDefinition: Identifiable, Codable {
    var id: UUID
    var key: String
    var title: String
    var metricDescription: String
    var categoryRawValue: String
    var weight: Double
    var isRequired: Bool
    var applicableLocationsRawValues: [String]
    
    // Rating configuration
    var minRating: Int
    var maxRating: Int
    var ratingDescriptionsRawValues: [String: String]
    
    // Validation rules - stored as JSON string for SwiftData compatibility
    var validationRulesJSON: String?
    
    init(
        key: String,
        title: String,
        description: String,
        category: MetricCategory,
        weight: Double = 1.0,
        isRequired: Bool = false,
        applicableLocations: [LocationTypeEnum] = LocationTypeEnum.allCases,
        minRating: Int = 1,
        maxRating: Int = 5,
        ratingDescriptions: [Int: String] = [:]
    ) {
        self.id = UUID()
        self.key = key
        self.title = title
        self.metricDescription = description
        self.categoryRawValue = category.rawValue
        self.weight = weight
        self.isRequired = isRequired
        self.applicableLocationsRawValues = applicableLocations.map { $0.rawValue }
        self.minRating = minRating
        self.maxRating = maxRating
        self.ratingDescriptionsRawValues = Dictionary(uniqueKeysWithValues: ratingDescriptions.map { (String($0.key), $0.value) })
    }
    
    // MARK: - Codable Support
    
    enum CodingKeys: String, CodingKey {
        case id, key, title, metricDescription, categoryRawValue, weight, isRequired
        case applicableLocationsRawValues, minRating, maxRating, ratingDescriptionsRawValues
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        key = try container.decode(String.self, forKey: .key)
        title = try container.decode(String.self, forKey: .title)
        metricDescription = try container.decode(String.self, forKey: .metricDescription)
        categoryRawValue = try container.decode(String.self, forKey: .categoryRawValue)
        weight = try container.decode(Double.self, forKey: .weight)
        isRequired = try container.decode(Bool.self, forKey: .isRequired)
        applicableLocationsRawValues = try container.decode([String].self, forKey: .applicableLocationsRawValues)
        minRating = try container.decode(Int.self, forKey: .minRating)
        maxRating = try container.decode(Int.self, forKey: .maxRating)
        ratingDescriptionsRawValues = try container.decode([String: String].self, forKey: .ratingDescriptionsRawValues)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(key, forKey: .key)
        try container.encode(title, forKey: .title)
        try container.encode(metricDescription, forKey: .metricDescription)
        try container.encode(categoryRawValue, forKey: .categoryRawValue)
        try container.encode(weight, forKey: .weight)
        try container.encode(isRequired, forKey: .isRequired)
        try container.encode(applicableLocationsRawValues, forKey: .applicableLocationsRawValues)
        try container.encode(minRating, forKey: .minRating)
        try container.encode(maxRating, forKey: .maxRating)
        try container.encode(ratingDescriptionsRawValues, forKey: .ratingDescriptionsRawValues)
    }
    
    // MARK: - Computed Properties for SwiftData Compatibility
    
    var category: MetricCategory {
        return MetricCategory(rawValue: categoryRawValue) ?? .footTraffic
    }
    
    var applicableLocations: [LocationTypeEnum] {
        return applicableLocationsRawValues.compactMap { LocationTypeEnum(rawValue: $0) }
    }
    
    var ratingDescriptions: [Int: String] {
        return Dictionary(uniqueKeysWithValues: ratingDescriptionsRawValues.compactMap { key, value in
            guard let intKey = Int(key) else { return nil }
            return (intKey, value)
        })
    }
    
    var description: String {
        return metricDescription
    }
    
    func isApplicable(for locationType: LocationTypeEnum) -> Bool {
        return applicableLocations.contains(locationType)
    }
    
    func getRatingDescription(for rating: Int) -> String {
        return ratingDescriptions[rating] ?? "Rating \(rating)"
    }
    
    func validateRating(_ rating: Int) -> Bool {
        return rating >= minRating && rating <= maxRating
    }
}

/// Actual metric instance with rating and notes
@Model
class MetricInstance: Identifiable {
    var id: UUID
    var metricDefinitionKey: String
    var rating: Int
    var notes: String
    var isComputed: Bool
    var computedValue: Double?
    var ratedAt: Date?
    
    init(metricDefinitionKey: String, rating: Int = 0, notes: String = "", isComputed: Bool = false) {
        self.id = UUID()
        self.metricDefinitionKey = metricDefinitionKey
        self.rating = rating
        self.notes = notes
        self.isComputed = isComputed
        self.ratedAt = rating > 0 ? Date() : nil
    }
    
    func updateRating(_ newRating: Int, notes newNotes: String = "") {
        self.rating = newRating
        self.notes = newNotes
        self.ratedAt = newRating > 0 ? Date() : nil
    }
    
    var isRated: Bool {
        return rating > 0
    }
}

/// Centralized metrics manager for a location
@Model
class LocationMetrics: Identifiable {
    var id: UUID
    var locationId: UUID
    var locationType: LocationTypeEnum
    var metricInstances: [MetricInstance]
    var lastUpdated: Date
    
    init(locationId: UUID, locationType: LocationTypeEnum) {
        self.id = UUID()
        self.locationId = locationId
        self.locationType = locationType
        self.metricInstances = []
        self.lastUpdated = Date()
    }
    
    // MARK: - Metric Management
    
    func getMetricInstance(for key: String) -> MetricInstance? {
        return metricInstances.first { $0.metricDefinitionKey == key }
    }
    
    func updateMetric(key: String, rating: Int, notes: String = "") {
        if let existing = getMetricInstance(for: key) {
            existing.updateRating(rating, notes: notes)
        } else {
            let newInstance = MetricInstance(metricDefinitionKey: key, rating: rating, notes: notes)
            metricInstances.append(newInstance)
        }
        lastUpdated = Date()
    }
    
    func getRating(for key: String) -> Int {
        return getMetricInstance(for: key)?.rating ?? 0
    }
    
    func getNotes(for key: String) -> String {
        return getMetricInstance(for: key)?.notes ?? ""
    }
    
    func getRatedMetricCount() -> Int {
        return metricInstances.filter { $0.isRated }.count
    }
    
    func getMetricsByCategory(_ category: MetricCategory) -> [MetricInstance] {
        let applicableDefinitions = MetricRegistry.shared.getMetrics(for: locationType, category: category)
        return metricInstances.filter { instance in
            applicableDefinitions.contains { $0.key == instance.metricDefinitionKey }
        }
    }
    
    func calculateCategoryScore(for category: MetricCategory) -> Double {
        let categoryMetrics = getMetricsByCategory(category)
        let ratedMetrics = categoryMetrics.filter { $0.isRated }
        
        guard !ratedMetrics.isEmpty else { return 0.0 }
        
        let totalScore = ratedMetrics.reduce(0.0) { sum, metric in
            sum + Double(metric.rating)
        }
        
        return totalScore / Double(ratedMetrics.count)
    }
    
    func calculateOverallScore(minimumMetrics: Int = 3) -> Double {
        let ratedMetrics = metricInstances.filter { $0.isRated }
        
        guard ratedMetrics.count >= minimumMetrics else { return 0.0 }
        
        let weightedSum = ratedMetrics.reduce(0.0) { sum, metric in
            let definition = MetricRegistry.shared.getMetricDefinition(for: metric.metricDefinitionKey)
            let weight = definition?.weight ?? 1.0
            return sum + (Double(metric.rating) * weight)
        }
        
        let totalWeight = ratedMetrics.reduce(0.0) { sum, metric in
            let definition = MetricRegistry.shared.getMetricDefinition(for: metric.metricDefinitionKey)
            return sum + (definition?.weight ?? 1.0)
        }
        
        return totalWeight > 0 ? weightedSum / totalWeight : 0.0
    }
}

/// Singleton registry for all metric definitions
class MetricRegistry: ObservableObject {
    static let shared = MetricRegistry()
    
    @Published private var metricDefinitions: [MetricDefinition] = []
    
    private init() {
        setupDefaultMetrics()
    }
    
    // MARK: - Metric Definition Management
    
    func registerMetric(_ definition: MetricDefinition) {
        metricDefinitions.append(definition)
    }
    
    func getMetricDefinition(for key: String) -> MetricDefinition? {
        return metricDefinitions.first { $0.key == key }
    }
    
    func getMetrics(for locationType: LocationTypeEnum) -> [MetricDefinition] {
        return metricDefinitions.filter { $0.isApplicable(for: locationType) }
    }
    
    func getMetrics(for locationType: LocationTypeEnum, category: MetricCategory) -> [MetricDefinition] {
        return metricDefinitions.filter { 
            $0.isApplicable(for: locationType) && $0.category == category 
        }
    }
    
    func getRequiredMetrics(for locationType: LocationTypeEnum) -> [MetricDefinition] {
        return getMetrics(for: locationType).filter { $0.isRequired }
    }
    
    func getCategories(for locationType: LocationTypeEnum) -> [MetricCategory] {
        let metrics = getMetrics(for: locationType)
        let categories = Set(metrics.map { $0.category })
        return Array(categories).sorted { $0.displayName < $1.displayName }
    }
    
    // MARK: - Default Metrics Setup
    
    private func setupDefaultMetrics() {
        setupGeneralMetrics()
        setupOfficeMetrics()
        setupHospitalMetrics()
        setupSchoolMetrics()
        setupResidentialMetrics()
    }
    
    private func setupGeneralMetrics() {
        // Core metrics (apply to all locations) — 0.75 total
        
        // Foot Traffic - applies to all locations
        registerMetric(MetricDefinition(
            key: "foot_traffic_daily",
            title: "Foot Traffic (Daily)",
            description: "Daily foot traffic volume. Higher traffic increases sales potential.",
            category: .footTraffic,
            weight: 0.20, // 20% - highest weight
            isRequired: true,
            ratingDescriptions: [
                1: "< 100",
                2: "100-200", 
                3: "200-350",
                4: "350-500",
                5: "> 500"
            ]
        ))
        
        // Target Demographics - applies to all locations
        registerMetric(MetricDefinition(
            key: "target_demo_fit",
            title: "Target Demographic Fit",
            description: "Alignment with target customer demographic profile.",
            category: .demographics,
            weight: 0.10, // 10%
            isRequired: true,
            ratingDescriptions: [
                1: "No Match",
                2: "Poor Match",
                3: "Fair Match", 
                4: "Good Match",
                5: "Excellent Match"
            ]
        ))
        
        // Competition - applies to all locations
        registerMetric(MetricDefinition(
            key: "nearby_competition",
            title: "Nearby Competition",
            description: "Proximity and strength of competing food/beverage options.",
            category: .competition,
            weight: 0.10, // 10%
            isRequired: true,
            ratingDescriptions: [
                1: "High competition",
                2: "Moderate-high competition",
                3: "Moderate competition",
                4: "Low competition", 
                5: "Zero competition"
            ]
        ))
        
        // Logistics & Infrastructure (subtotal 0.15)
        
        // Visibility & Accessibility
        registerMetric(MetricDefinition(
            key: "visibility_accessibility",
            title: "Visibility & Accessibility",
            description: "Visibility and accessibility of potential vending locations.",
            category: .layout,
            weight: 0.05, // 5%
            ratingDescriptions: [
                1: "Hidden location",
                2: "Side corridor",
                3: "Secondary traffic flow",
                4: "Clear sightline",
                5: "Prime high-traffic spot"
            ]
        ))
        
        // Parking & Transit Access
        registerMetric(MetricDefinition(
            key: "parking_transit",
            title: "Parking & Transit Access",
            description: "Ease of access for service vehicles and logistics.",
            category: .accessibility,
            weight: 0.04, // 4%
            ratingDescriptions: [
                1: "No loading access",
                2: "Difficult access",
                3: "Acceptable access",
                4: "Good access",
                5: "Dedicated loading zone"
            ]
        ))
        
        // Security
        registerMetric(MetricDefinition(
            key: "security",
            title: "Security",
            description: "Security measures and theft prevention capabilities.",
            category: .security,
            weight: 0.04, // 4%
            ratingDescriptions: [
                1: "No CCTV or security",
                2: "Limited security",
                3: "Part-time monitoring",
                4: "CCTV + staff presence",
                5: "Full security system"
            ]
        ))
        
        // Adjacent Amenities
        registerMetric(MetricDefinition(
            key: "adjacent_amenities",
            title: "Adjacent Amenities",
            description: "Nearby amenities that drive foot traffic (elevators, mailrooms, ATMs).",
            category: .amenities,
            weight: 0.02, // 2%
            ratingDescriptions: [
                1: "No amenities",
                2: "1 traffic booster",
                3: "2 traffic boosters",
                4: "3 traffic boosters",
                5: "4+ traffic boosters"
            ]
        ))
        
        // Financial Terms & ROI (subtotal 0.20)
        
        // Host Commission % - Note: Commission lives only here to avoid double counting in modules
        registerMetric(MetricDefinition(
            key: "host_commission_pct",
            title: "Host Commission %",
            description: "Commission percentage charged by location host.",
            category: .financial,
            weight: 0.08, // 8%
            isRequired: true,
            ratingDescriptions: [
                1: "Above 20%",
                2: "16-20%",
                3: "11-15%", 
                4: "6-10%",
                5: "5% or lower"
            ]
        ))
        
        // Payback Period vs Target
        registerMetric(MetricDefinition(
            key: "payback_vs_target",
            title: "Payback Period vs Target",
            description: "How quickly the investment pays for itself compared to target.",
            category: .financial,
            weight: 0.06, // 6%
            ratingDescriptions: [
                1: "> 36 months",
                2: "24-36 months",
                3: "18-24 months",
                4: "12-18 months",
                5: "< 12 months"
            ]
        ))
        
        // Route Fit / Clustering
        registerMetric(MetricDefinition(
            key: "route_cluster_fit",
            title: "Route Fit / Clustering",
            description: "How well this location fits into existing service routes.",
            category: .operations,
            weight: 0.04, // 4%
            ratingDescriptions: [
                1: "Requires new route",
                2: "Significant detour",
                3: "Minor detour",
                4: "On existing route",
                5: "Perfect route fit"
            ]
        ))
        
        // Install Complexity / One-time Cost
        registerMetric(MetricDefinition(
            key: "install_complexity",
            title: "Install Complexity / One-time Cost",
            description: "Complexity and cost of initial installation.",
            category: .operations,
            weight: 0.02, // 2%
            ratingDescriptions: [
                1: "Very complex/expensive",
                2: "Complex/expensive",
                3: "Moderate complexity/cost",
                4: "Simple/affordable",
                5: "Very simple/cheap"
            ]
        ))
    }
    
    private func setupOfficeMetrics() {
        // Office — 0.25 total
        
        registerMetric(MetricDefinition(
            key: "off_common_areas",
            title: "Common Areas Available",
            description: "Availability and quality of common areas for vending placement.",
            category: .layout,
            weight: 0.060, // 6.0%
            ratingDescriptions: [
                1: "No common areas",
                2: "Limited common areas",
                3: "Some common areas",
                4: "Good common areas",
                5: "Excellent common areas"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "off_hours_access",
            title: "Hours & Access Control",
            description: "Building access hours and control systems.",
            category: .operations,
            weight: 0.050, // 5.0%
            ratingDescriptions: [
                1: "Very limited hours",
                2: "Limited hours",
                3: "Standard hours",
                4: "Extended hours",
                5: "24/7 access"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "off_tenant_amenities",
            title: "Tenant Amenities Offered",
            description: "Amenities available to office tenants.",
            category: .amenities,
            weight: 0.050, // 5.0%
            ratingDescriptions: [
                1: "No amenities",
                2: "Basic amenities",
                3: "Some amenities",
                4: "Good amenities",
                5: "Excellent amenities"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "off_proximity_hub_transit",
            title: "Proximity to Hub/Transit",
            description: "Proximity to transportation hubs and transit options.",
            category: .accessibility,
            weight: 0.040, // 4.0%
            ratingDescriptions: [
                1: "Far from transit",
                2: "Moderate distance",
                3: "Close to transit",
                4: "Very close to transit",
                5: "At transit hub"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "off_branding_restrictions",
            title: "Branding Restrictions",
            description: "Restrictions on branding and signage.",
            category: .restrictions,
            weight: 0.020, // 2.0%
            ratingDescriptions: [
                1: "Very restrictive",
                2: "Restrictive",
                3: "Moderately restrictive",
                4: "Minimally restrictive",
                5: "No restrictions"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "off_layout_type",
            title: "Layout Type (Single vs. Multi-tenant)",
            description: "Building layout and tenant structure.",
            category: .layout,
            weight: 0.030, // 3.0%
            ratingDescriptions: [
                1: "Poor layout",
                2: "Fair layout",
                3: "Good layout",
                4: "Very good layout",
                5: "Excellent layout"
            ]
        ))
    }
    
    private func setupHospitalMetrics() {
        // Hospital / Healthcare — 0.25 total
        
        registerMetric(MetricDefinition(
            key: "hos_health_safety",
            title: "Health-Safety Compliance",
            description: "Compliance with health and safety regulations.",
            category: .operations,
            weight: 0.070, // 7.0%
            ratingDescriptions: [
                1: "Non-compliant",
                2: "Partially compliant",
                3: "Mostly compliant",
                4: "Fully compliant",
                5: "Exceeds compliance"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "hos_distance_patient_m",
            title: "Distance to Patient Areas (m)",
            description: "Distance from vending location to patient areas.",
            category: .layout,
            weight: 0.050, // 5.0%
            ratingDescriptions: [
                1: "> 200m",
                2: "150-200m",
                3: "100-150m",
                4: "50-100m",
                5: "< 50m"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "hos_vending_zones",
            title: "Designated Vending Zones",
            description: "Availability of designated vending machine zones.",
            category: .layout,
            weight: 0.050, // 5.0%
            ratingDescriptions: [
                1: "No designated zones",
                2: "Limited zones",
                3: "Some zones",
                4: "Good zones",
                5: "Excellent zones"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "hos_fm_coordination",
            title: "Facilities Mgmt Coordination",
            description: "Coordination with facilities management team.",
            category: .operations,
            weight: 0.040, // 4.0%
            ratingDescriptions: [
                1: "No coordination",
                2: "Poor coordination",
                3: "Fair coordination",
                4: "Good coordination",
                5: "Excellent coordination"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "hos_hygiene_extras",
            title: "Hygiene & Sanitation Extras",
            description: "Additional hygiene and sanitation requirements.",
            category: .operations,
            weight: 0.040, // 4.0%
            ratingDescriptions: [
                1: "No requirements",
                2: "Basic requirements",
                3: "Moderate requirements",
                4: "High requirements",
                5: "Very high requirements"
            ]
        ))
    }
    
    private func setupSchoolMetrics() {
        // School / University — 0.25 total
        
        registerMetric(MetricDefinition(
            key: "sch_placement_hotspots",
            title: "Placement in Student Hotspots",
            description: "Placement in high-traffic student areas.",
            category: .layout,
            weight: 0.080, // 8.0%
            ratingDescriptions: [
                1: "Poor placement",
                2: "Fair placement",
                3: "Good placement",
                4: "Very good placement",
                5: "Excellent placement"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "sch_schedule_alignment",
            title: "Schedule Alignment",
            description: "Alignment with student schedules and activity patterns.",
            category: .operations,
            weight: 0.050, // 5.0%
            ratingDescriptions: [
                1: "Poor alignment",
                2: "Fair alignment",
                3: "Good alignment",
                4: "Very good alignment",
                5: "Excellent alignment"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "sch_product_mix",
            title: "Product-Mix Suitability/Compliance",
            description: "Suitability of product mix for school environment and compliance requirements.",
            category: .operations,
            weight: 0.040, // 4.0%
            ratingDescriptions: [
                1: "Poor suitability",
                2: "Fair suitability",
                3: "Good suitability",
                4: "Very good suitability",
                5: "Excellent suitability"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "sch_admin_approval",
            title: "Admin Approval Status",
            description: "Status of administrative approval for vending operations.",
            category: .operations,
            weight: 0.050, // 5.0%
            ratingDescriptions: [
                1: "No approval",
                2: "Pending approval",
                3: "Conditional approval",
                4: "Full approval",
                5: "Expedited approval"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "sch_safety_accessibility",
            title: "Safety & Accessibility",
            description: "Safety measures and accessibility for students.",
            category: .security,
            weight: 0.030, // 3.0%
            ratingDescriptions: [
                1: "Poor safety/accessibility",
                2: "Fair safety/accessibility",
                3: "Good safety/accessibility",
                4: "Very good safety/accessibility",
                5: "Excellent safety/accessibility"
            ]
        ))
    }
    
    private func setupResidentialMetrics() {
        // Residential (apartments/condos/townhomes) — 0.25 total
        
        registerMetric(MetricDefinition(
            key: "res_total_units",
            title: "Total Units",
            description: "Total number of residential units in the building/complex.",
            category: .demographics,
            weight: 0.035, // 3.5%
            ratingDescriptions: [
                1: "< 50 units",
                2: "50-100 units",
                3: "100-200 units",
                4: "200-500 units",
                5: "> 500 units"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "res_occupancy_rate",
            title: "Occupancy Rate",
            description: "Current occupancy rate of the residential complex.",
            category: .demographics,
            weight: 0.020, // 2.0%
            ratingDescriptions: [
                1: "< 60%",
                2: "60-75%",
                3: "75-85%",
                4: "85-95%",
                5: "> 95%"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "res_demo_18_45_pct",
            title: "% Residents 18-45",
            description: "Percentage of residents in the target age demographic.",
            category: .demographics,
            weight: 0.020, // 2.0%
            ratingDescriptions: [
                1: "< 20%",
                2: "20-35%",
                3: "35-50%",
                4: "50-65%",
                5: "> 65%"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "res_avg_lease_months",
            title: "Average Lease Length (Months)",
            description: "Average length of residential leases.",
            category: .operations,
            weight: 0.010, // 1.0%
            ratingDescriptions: [
                1: "< 6 months",
                2: "6-12 months",
                3: "12-18 months",
                4: "18-24 months",
                5: "> 24 months"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "res_amenity_usage_pct",
            title: "Amenity Usage Rate",
            description: "How actively residents use common amenities.",
            category: .amenities,
            weight: 0.020, // 2.0%
            ratingDescriptions: [
                1: "Very low usage",
                2: "Low usage",
                3: "Moderate usage",
                4: "High usage",
                5: "Very high usage"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "res_access_24_7",
            title: "24/7 Common-Area Access",
            description: "Whether common areas are accessible 24/7.",
            category: .operations,
            weight: 0.020, // 2.0%
            ratingDescriptions: [
                1: "No 24/7 access",
                2: "Limited 24/7 access",
                3: "Partial 24/7 access",
                4: "Most areas 24/7",
                5: "Full 24/7 access"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "res_install_visibility",
            title: "Install Visibility",
            description: "Visibility of vending machine installation.",
            category: .layout,
            weight: 0.025, // 2.5%
            ratingDescriptions: [
                1: "Hidden location",
                2: "Poor visibility",
                3: "Moderate visibility",
                4: "Good visibility",
                5: "Excellent visibility"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "res_power_connectivity",
            title: "Power & Connectivity",
            description: "Availability of power and internet connectivity.",
            category: .operations,
            weight: 0.020, // 2.0%
            ratingDescriptions: [
                1: "No power/connectivity",
                2: "Basic power only",
                3: "Power + basic connectivity",
                4: "Power + good connectivity",
                5: "Power + excellent connectivity"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "res_service_path",
            title: "Service/Loading Path",
            description: "Ease of service and loading access.",
            category: .accessibility,
            weight: 0.020, // 2.0%
            ratingDescriptions: [
                1: "No service access",
                2: "Difficult access",
                3: "Challenging access",
                4: "Good access",
                5: "Excellent access"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "res_security_measures",
            title: "Security Measures",
            description: "Security measures in place for the complex.",
            category: .security,
            weight: 0.020, // 2.0%
            ratingDescriptions: [
                1: "No security",
                2: "Basic security",
                3: "Moderate security",
                4: "Good security",
                5: "Excellent security"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "res_on_site_alternatives",
            title: "On-Site Alternatives",
            description: "Presence of competing food/beverage options on-site.",
            category: .competition,
            weight: 0.010, // 1.0%
            ratingDescriptions: [
                1: "Many alternatives",
                2: "Several alternatives",
                3: "Few alternatives",
                4: "Very few alternatives",
                5: "No alternatives"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "res_walk_time_store_min",
            title: "Walk Time to Store (Min)",
            description: "Walking time to nearest convenience store.",
            category: .accessibility,
            weight: 0.020, // 2.0%
            ratingDescriptions: [
                1: "> 15 minutes",
                2: "10-15 minutes",
                3: "5-10 minutes",
                4: "2-5 minutes",
                5: "< 2 minutes"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "res_hoa_rules",
            title: "HOA/Strata Rules",
            description: "Restrictions imposed by HOA or strata council.",
            category: .restrictions,
            weight: 0.005, // 0.5%
            ratingDescriptions: [
                1: "Very restrictive",
                2: "Restrictive",
                3: "Moderately restrictive",
                4: "Minimally restrictive",
                5: "Not restrictive"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "res_events_per_year",
            title: "Resident Events/Year",
            description: "Number of resident events held annually.",
            category: .amenities,
            weight: 0.005, // 0.5%
            ratingDescriptions: [
                1: "0 events",
                2: "1-2 events",
                3: "3-5 events",
                4: "6-10 events",
                5: "> 10 events"
            ]
        ))
    }
}

// MARK: - Helper Extensions

// Note: LocationTypeEnum already conforms to CaseIterable in LocationType.swift
