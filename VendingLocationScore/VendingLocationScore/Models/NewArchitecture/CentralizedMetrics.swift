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
class MetricInstance: Identifiable, Codable {
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
    
    // MARK: - Codable Support
    
    enum CodingKeys: String, CodingKey {
        case id, metricDefinitionKey, rating, notes, isComputed, computedValue, ratedAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        metricDefinitionKey = try container.decode(String.self, forKey: .metricDefinitionKey)
        rating = try container.decode(Int.self, forKey: .rating)
        notes = try container.decode(String.self, forKey: .notes)
        isComputed = try container.decode(Bool.self, forKey: .isComputed)
        computedValue = try container.decodeIfPresent(Double.self, forKey: .computedValue)
        ratedAt = try container.decodeIfPresent(Date.self, forKey: .ratedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(metricDefinitionKey, forKey: .metricDefinitionKey)
        try container.encode(rating, forKey: .rating)
        try container.encode(notes, forKey: .notes)
        try container.encode(isComputed, forKey: .isComputed)
        try container.encodeIfPresent(computedValue, forKey: .computedValue)
        try container.encodeIfPresent(ratedAt, forKey: .ratedAt)
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
class LocationMetrics: Identifiable, Codable {
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
    
    // MARK: - Codable Support
    
    enum CodingKeys: String, CodingKey {
        case id, locationId, locationType, metricInstances, lastUpdated
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        locationId = try container.decode(UUID.self, forKey: .locationId)
        locationType = try container.decode(LocationTypeEnum.self, forKey: .locationType)
        metricInstances = try container.decode([MetricInstance].self, forKey: .metricInstances)
        lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(locationId, forKey: .locationId)
        try container.encode(locationType, forKey: .locationType)
        try container.encode(metricInstances, forKey: .metricInstances)
        try container.encode(lastUpdated, forKey: .lastUpdated)
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
        // Foot Traffic - applies to all locations
        registerMetric(MetricDefinition(
            key: "general_foot_traffic",
            title: "Foot Traffic",
            description: "Daily foot traffic volume. Higher traffic increases sales potential.",
            category: .footTraffic,
            weight: 0.15,
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
            key: "general_demographics",
            title: "Target Demographics",
            description: "Alignment with target customer demographic profile.",
            category: .demographics,
            weight: 0.12,
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
            key: "general_competition",
            title: "Competition",
            description: "Proximity and strength of competing food/beverage options.",
            category: .competition,
            weight: 0.12,
            isRequired: true,
            ratingDescriptions: [
                1: "High competition",
                2: "Moderate-high competition",
                3: "Moderate competition",
                4: "Low competition", 
                5: "Zero competition"
            ]
        ))
        
        // Accessibility - applies to all locations
        registerMetric(MetricDefinition(
            key: "general_accessibility",
            title: "Parking & Transit",
            description: "Ease of access for service vehicles and logistics.",
            category: .accessibility,
            weight: 0.18,
            ratingDescriptions: [
                1: "No loading access",
                2: "Difficult access",
                3: "Acceptable access",
                4: "Good access",
                5: "Dedicated loading zone"
            ]
        ))
        
        // Security - applies to all locations
        registerMetric(MetricDefinition(
            key: "general_security",
            title: "Security",
            description: "Security measures and theft prevention capabilities.",
            category: .security,
            weight: 0.10,
            ratingDescriptions: [
                1: "No CCTV or security",
                2: "Limited security",
                3: "Part-time monitoring",
                4: "CCTV + staff presence",
                5: "Full security system"
            ]
        ))
        
        // Visibility - applies to all locations  
        registerMetric(MetricDefinition(
            key: "general_visibility",
            title: "Visibility & Location",
            description: "Visibility and accessibility of potential vending locations.",
            category: .layout,
            weight: 0.10,
            ratingDescriptions: [
                1: "Hidden location",
                2: "Side corridor",
                3: "Secondary traffic flow",
                4: "Clear sightline",
                5: "Prime high-traffic spot"
            ]
        ))
        
        // Amenities - applies to all locations
        registerMetric(MetricDefinition(
            key: "general_amenities",
            title: "Adjacent Amenities",
            description: "Nearby amenities that drive foot traffic (elevators, mailrooms, ATMs).",
            category: .amenities,
            weight: 0.08,
            ratingDescriptions: [
                1: "No amenities",
                2: "1 traffic booster",
                3: "2 traffic boosters",
                4: "3 traffic boosters",
                5: "4+ traffic boosters"
            ]
        ))
        
        // Host Commission - applies to all locations
        registerMetric(MetricDefinition(
            key: "general_commission",
            title: "Host Commission",
            description: "Commission percentage charged by location host.",
            category: .financial,
            weight: 0.18,
            isRequired: true,
            ratingDescriptions: [
                1: "Above 20%",
                2: "16-20%",
                3: "11-15%", 
                4: "6-10%",
                5: "5% or lower"
            ]
        ))
    }
    
    private func setupOfficeMetrics() {
        registerMetric(MetricDefinition(
            key: "office_common_areas",
            title: "Common Areas",
            description: "Availability and quality of common areas like break rooms and lounges.",
            category: .amenities,
            applicableLocations: [.office],
            ratingDescriptions: [
                1: "None",
                2: "Small kitchenette only",
                3: "Lounge or shared break area",
                4: "Lounge + café nook",
                5: "Lounge + cafeteria / multiple hubs"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "office_hours_access",
            title: "Hours & Access",
            description: "Building access hours and flexibility for vending operations.",
            category: .operations,
            applicableLocations: [.office],
            ratingDescriptions: [
                1: "9-5 only, strict access",
                2: "9-7, limited evenings",
                3: "Extended weekdays",
                4: "Weekdays + some weekends",
                5: "24/7 with tenant badge"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "office_tenant_amenities",
            title: "Tenant Food Amenities",
            description: "Existing food and beverage options for tenants.",
            category: .competition,
            applicableLocations: [.office],
            ratingDescriptions: [
                1: "Full cafeteria / subsidized food",
                2: "Multiple food vendors",
                3: "Limited café / snack cart",
                4: "Coffee only",
                5: "None"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "office_transit_hub",
            title: "Hub Proximity & Transit",
            description: "Proximity to transportation hubs and transit options.",
            category: .accessibility,
            applicableLocations: [.office],
            ratingDescriptions: [
                1: "Remote from hubs, poor transit",
                2: "Edge of hub / infrequent transit", 
                3: "Near hub or decent transit",
                4: "In hub + good transit",
                5: "Prime hub + major transit interchange"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "office_branding_restrictions",
            title: "Branding Restrictions",
            description: "Restrictions on signage and branding for vending machines.",
            category: .restrictions,
            applicableLocations: [.office],
            ratingDescriptions: [
                1: "Severe (no signage, approvals slow)",
                2: "Heavy (strict size/colour limits)",
                3: "Moderate (some constraints)",
                4: "Light (basic guidelines)",
                5: "Minimal/none"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "office_layout_type",
            title: "Layout Type",
            description: "Building layout and tenant density characteristics.",
            category: .layout,
            applicableLocations: [.office],
            ratingDescriptions: [
                1: "Single-tenant, low density",
                2: "Single-tenant, medium density",
                3: "Multi-tenant (2-3)",
                4: "Multi-tenant (4-6)",
                5: "Multi-tenant (7+ diverse tenants)"
            ]
        ))
    }
    
    private func setupHospitalMetrics() {
        registerMetric(MetricDefinition(
            key: "hospital_patient_volume",
            title: "Patient Volume", 
            description: "Daily patient volume and flow patterns.",
            category: .footTraffic,
            applicableLocations: [.hospital],
            ratingDescriptions: [
                1: "<100 patients/day",
                2: "100-300 patients/day",
                3: "300-500 patients/day",
                4: "500-800 patients/day",
                5: "800+ patients/day"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "hospital_staff_size",
            title: "Staff Size",
            description: "Number of staff members and their distribution.",
            category: .demographics,
            applicableLocations: [.hospital],
            ratingDescriptions: [
                1: "<50 staff",
                2: "50-100 staff",
                3: "100-200 staff",
                4: "200-400 staff",
                5: "400+ staff"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "hospital_visitor_traffic",
            title: "Visitor Traffic",
            description: "Visitor flow patterns and volume.",
            category: .footTraffic,
            applicableLocations: [.hospital],
            ratingDescriptions: [
                1: "Minimal visitors",
                2: "Low visitor traffic",
                3: "Moderate visitor traffic",
                4: "High visitor traffic",
                5: "Very high visitor traffic"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "hospital_food_service",
            title: "Food Service",
            description: "Existing food service options and competition level.",
            category: .competition,
            applicableLocations: [.hospital],
            ratingDescriptions: [
                1: "Full-service cafeteria",
                2: "Multiple food options",
                3: "Limited food options",
                4: "Basic vending only",
                5: "No food service"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "hospital_vending_restrictions",
            title: "Vending Restrictions",
            description: "Healthcare-specific restrictions on vending operations.",
            category: .restrictions,
            applicableLocations: [.hospital],
            ratingDescriptions: [
                1: "Many restrictions",
                2: "Several restrictions",
                3: "Some restrictions",
                4: "Few restrictions",
                5: "No restrictions"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "hospital_hours_operation",
            title: "Hours of Operation",
            description: "Facility operating hours and accessibility.",
            category: .operations,
            applicableLocations: [.hospital],
            ratingDescriptions: [
                1: "Limited hours",
                2: "Standard business hours",
                3: "Extended hours",
                4: "Long hours",
                5: "24/7 operation"
            ]
        ))
    }
    
    private func setupSchoolMetrics() {
        registerMetric(MetricDefinition(
            key: "school_student_population",
            title: "Student Population",
            description: "Number of students and enrollment patterns.",
            category: .demographics,
            applicableLocations: [.school],
            ratingDescriptions: [
                1: "<500 students",
                2: "500-999 students",
                3: "1,000-1,999 students",
                4: "2,000-4,999 students",
                5: "5,000+ students"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "school_staff_size",
            title: "Staff Size",
            description: "Number of faculty and staff members.",
            category: .demographics,
            applicableLocations: [.school],
            ratingDescriptions: [
                1: "<50 staff",
                2: "50-99 staff",
                3: "100-199 staff",
                4: "200-399 staff",
                5: "400+ staff"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "school_food_service",
            title: "Food Service",
            description: "Existing cafeteria and food service competition.",
            category: .competition,
            applicableLocations: [.school],
            ratingDescriptions: [
                1: "Full-service cafeteria",
                2: "Multiple food options",
                3: "Limited food options",
                4: "Basic vending only",
                5: "No food service"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "school_vending_restrictions",
            title: "Vending Restrictions",
            description: "Educational institution restrictions on vending.",
            category: .restrictions,
            applicableLocations: [.school],
            ratingDescriptions: [
                1: "Many restrictions",
                2: "Several restrictions",
                3: "Some restrictions",
                4: "Few restrictions",
                5: "No restrictions"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "school_hours_operation",
            title: "Hours of Operation",
            description: "School operating hours and access patterns.",
            category: .operations,
            applicableLocations: [.school],
            ratingDescriptions: [
                1: "Limited hours",
                2: "Standard school hours",
                3: "Extended hours",
                4: "Long hours",
                5: "24/7 access"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "school_campus_layout",
            title: "Campus Layout",
            description: "Campus layout and building distribution for optimal placement.",
            category: .layout,
            applicableLocations: [.school],
            ratingDescriptions: [
                1: "Poor layout",
                2: "Fair layout",
                3: "Good layout",
                4: "Very good layout",
                5: "Excellent layout"
            ]
        ))
    }
    
    private func setupResidentialMetrics() {
        registerMetric(MetricDefinition(
            key: "residential_unit_count",
            title: "Unit Count",
            description: "Number of residential units in the building.",
            category: .demographics,
            applicableLocations: [.residential],
            ratingDescriptions: [
                1: "<100 units",
                2: "100-149 units",
                3: "150-249 units",
                4: "250-349 units",
                5: "350+ units"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "residential_occupancy_rate",
            title: "Occupancy Rate",
            description: "Current occupancy rate and tenant stability.",
            category: .demographics,
            applicableLocations: [.residential],
            ratingDescriptions: [
                1: "<80%",
                2: "80-89%",
                3: "90-94%",
                4: "95-97%",
                5: "98-100%"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "residential_demographics",
            title: "Resident Demographics",
            description: "Demographic profile and purchasing patterns of residents.",
            category: .demographics,
            applicableLocations: [.residential],
            ratingDescriptions: [
                1: "Limited appeal",
                2: "Some appeal",
                3: "Moderate appeal",
                4: "High appeal", 
                5: "Very high appeal"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "residential_food_service",
            title: "Food Service",
            description: "Existing food service options in the building.",
            category: .competition,
            applicableLocations: [.residential],
            ratingDescriptions: [
                1: "Full-service options",
                2: "Multiple alternatives",
                3: "Limited alternatives",
                4: "Basic options only",
                5: "No food service"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "residential_vending_restrictions",
            title: "Vending Restrictions",
            description: "Building management restrictions on vending operations.",
            category: .restrictions,
            applicableLocations: [.residential],
            ratingDescriptions: [
                1: "Many restrictions",
                2: "Several restrictions",
                3: "Some restrictions",
                4: "Few restrictions",
                5: "No restrictions"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "residential_hours_operation",
            title: "Hours of Operation",
            description: "Building access hours and resident activity patterns.",
            category: .operations,
            applicableLocations: [.residential],
            ratingDescriptions: [
                1: "Limited hours",
                2: "Standard hours",
                3: "Extended hours",
                4: "Long hours",
                5: "24/7 access"
            ]
        ))
        
        registerMetric(MetricDefinition(
            key: "residential_building_layout",
            title: "Building Layout",
            description: "Building layout and common area distribution.",
            category: .layout,
            applicableLocations: [.residential],
            ratingDescriptions: [
                1: "Poor layout",
                2: "Fair layout",
                3: "Good layout",
                4: "Very good layout",
                5: "Excellent layout"
            ]
        ))
    }
}

// MARK: - Helper Extensions

// Note: LocationTypeEnum already conforms to CaseIterable in LocationType.swift
