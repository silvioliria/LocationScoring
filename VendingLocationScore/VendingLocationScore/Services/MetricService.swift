import Foundation
import SwiftData
import SwiftUI

/// Centralized service for all metric operations
class MetricService: ObservableObject {
    static let shared = MetricService()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Location Metrics Management
    
    /// Initialize metrics for a new location
    func initializeMetrics(for location: Location, context: ModelContext) throws {
        let locationMetrics = LocationMetrics(locationId: location.id, locationType: location.locationType.type)
        
        // Get applicable metrics for this location type
        let applicableMetrics = MetricRegistry.shared.getMetrics(for: location.locationType.type)
        
        // Create instances for all applicable metrics
        for metricDef in applicableMetrics {
            let instance = MetricInstance(metricDefinitionKey: metricDef.key)
            locationMetrics.metricInstances.append(instance)
        }
        
        context.insert(locationMetrics)
        try context.save()
    }
    
    /// Get or create location metrics
    func getLocationMetrics(for location: Location, context: ModelContext) throws -> LocationMetrics {
        // Try to find existing metrics
        let descriptor = FetchDescriptor<LocationMetrics>(
            predicate: #Predicate { $0.locationId == location.id }
        )
        
        if let existingMetrics = try context.fetch(descriptor).first {
            return existingMetrics
        }
        
        // Create new metrics if none exist
        try initializeMetrics(for: location, context: context)
        
        // Fetch the newly created metrics
        if let newMetrics = try context.fetch(descriptor).first {
            return newMetrics
        }
        
        throw MetricServiceError.failedToCreateMetrics
    }
    
    /// Update a specific metric rating
    func updateMetric(
        for location: Location,
        metricKey: String,
        rating: Int,
        notes: String = "",
        context: ModelContext
    ) throws {
        let locationMetrics = try getLocationMetrics(for: location, context: context)
        locationMetrics.updateMetric(key: metricKey, rating: rating, notes: notes)
        try context.save()
    }
    
    /// Get metric instance for a location
    func getMetricInstance(for location: Location, metricKey: String, context: ModelContext) throws -> MetricInstance? {
        let locationMetrics = try getLocationMetrics(for: location, context: context)
        return locationMetrics.getMetricInstance(for: metricKey)
    }
    
    /// Get all metrics for a location grouped by category
    func getMetricsByCategory(for location: Location, context: ModelContext) throws -> [MetricCategory: [CombinedMetric]] {
        let locationMetrics = try getLocationMetrics(for: location, context: context)
        let categories = MetricRegistry.shared.getCategories(for: location.locationType.type)
        
        var result: [MetricCategory: [CombinedMetric]] = [:]
        
        for category in categories {
            let categoryDefinitions = MetricRegistry.shared.getMetrics(for: location.locationType.type, category: category)
            let combinedMetrics = categoryDefinitions.compactMap { definition in
                let instance = locationMetrics.getMetricInstance(for: definition.key)
                return CombinedMetric(definition: definition, instance: instance)
            }
            
            if !combinedMetrics.isEmpty {
                result[category] = combinedMetrics
            }
        }
        
        return result
    }
    
    /// Calculate overall score for a location
    func calculateOverallScore(for location: Location, context: ModelContext) throws -> Double {
        let locationMetrics = try getLocationMetrics(for: location, context: context)
        return locationMetrics.calculateOverallScore()
    }
    
    /// Calculate category score for a location
    func calculateCategoryScore(for location: Location, category: MetricCategory, context: ModelContext) throws -> Double {
        let locationMetrics = try getLocationMetrics(for: location, context: context)
        return locationMetrics.calculateCategoryScore(for: category)
    }
    
    /// Get completion percentage for a location
    func getCompletionPercentage(for location: Location, context: ModelContext) throws -> Double {
        let locationMetrics = try getLocationMetrics(for: location, context: context)
        let totalMetrics = locationMetrics.metricInstances.count
        let ratedMetrics = locationMetrics.getRatedMetricCount()
        
        guard totalMetrics > 0 else { return 0.0 }
        return Double(ratedMetrics) / Double(totalMetrics) * 100.0
    }
    
    /// Get required metrics completion status
    func getRequiredMetricsStatus(for location: Location, context: ModelContext) throws -> (completed: Int, total: Int) {
        let locationMetrics = try getLocationMetrics(for: location, context: context)
        let requiredMetrics = MetricRegistry.shared.getRequiredMetrics(for: location.locationType.type)
        
        let completedRequired = requiredMetrics.filter { definition in
            let instance = locationMetrics.getMetricInstance(for: definition.key)
            return instance?.isRated == true
        }.count
        
        return (completed: completedRequired, total: requiredMetrics.count)
    }
    
    // MARK: - Migration Helpers
    
    /// Migrate existing legacy metrics to new system
    func migrateLegacyMetrics(for location: Location, context: ModelContext) throws {
        // This would handle migration from the old system to the new centralized system
        // Implementation would depend on the specific legacy data structure
        
        guard let generalMetrics = location.generalMetrics else {
            return
        }
        
        let locationMetrics = try getLocationMetrics(for: location, context: context)
        
        // Migrate general metrics
        if generalMetrics.footTrafficRating > 0 {
            locationMetrics.updateMetric(
                key: "general_foot_traffic",
                rating: generalMetrics.footTrafficRating,
                notes: generalMetrics.footTrafficNotes
            )
        }
        
        if generalMetrics.targetDemographicRating > 0 {
            locationMetrics.updateMetric(
                key: "general_demographics",
                rating: generalMetrics.targetDemographicRating,
                notes: generalMetrics.targetDemographicNotes
            )
        }
        
        if generalMetrics.competitionRating > 0 {
            locationMetrics.updateMetric(
                key: "general_competition",
                rating: generalMetrics.competitionRating,
                notes: generalMetrics.competitionNotes
            )
        }
        
        if generalMetrics.parkingTransitRating > 0 {
            locationMetrics.updateMetric(
                key: "general_accessibility",
                rating: generalMetrics.parkingTransitRating,
                notes: generalMetrics.parkingTransitNotes
            )
        }
        
        if generalMetrics.securityRating > 0 {
            locationMetrics.updateMetric(
                key: "general_security",
                rating: generalMetrics.securityRating,
                notes: generalMetrics.securityNotes
            )
        }
        
        if generalMetrics.visibilityRating > 0 {
            locationMetrics.updateMetric(
                key: "general_visibility",
                rating: generalMetrics.visibilityRating,
                notes: generalMetrics.visibilityNotes
            )
        }
        
        if generalMetrics.amenitiesRating > 0 {
            locationMetrics.updateMetric(
                key: "general_amenities",
                rating: generalMetrics.amenitiesRating,
                notes: generalMetrics.amenitiesNotes
            )
        }
        
        if generalMetrics.hostCommissionRating > 0 {
            locationMetrics.updateMetric(
                key: "general_commission",
                rating: generalMetrics.hostCommissionRating,
                notes: generalMetrics.hostCommissionNotes
            )
        }
        
        // Migrate location-specific metrics
        switch location.locationType.type {
        case .office:
            try migrateOfficeMetrics(from: location, to: locationMetrics)
        case .hospital:
            try migrateHospitalMetrics(from: location, to: locationMetrics)
        case .school:
            try migrateSchoolMetrics(from: location, to: locationMetrics)
        case .residential:
            try migrateResidentialMetrics(from: location, to: locationMetrics)
        }
        
        try context.save()
    }
    
    private func migrateOfficeMetrics(from location: Location, to locationMetrics: LocationMetrics) throws {
        guard let officeMetrics = location.officeMetrics else { return }
        
        if officeMetrics.commonAreasRating > 0 {
            locationMetrics.updateMetric(
                key: "office_common_areas",
                rating: officeMetrics.commonAreasRating,
                notes: officeMetrics.commonAreasNotes
            )
        }
        
        if officeMetrics.hoursAccessRating > 0 {
            locationMetrics.updateMetric(
                key: "office_hours_access",
                rating: officeMetrics.hoursAccessRating,
                notes: officeMetrics.hoursAccessNotes
            )
        }
        
        if officeMetrics.tenantAmenitiesRating > 0 {
            locationMetrics.updateMetric(
                key: "office_tenant_amenities",
                rating: officeMetrics.tenantAmenitiesRating,
                notes: officeMetrics.tenantAmenitiesNotes
            )
        }
        
        if officeMetrics.proximityHubTransitRating > 0 {
            locationMetrics.updateMetric(
                key: "office_transit_hub",
                rating: officeMetrics.proximityHubTransitRating,
                notes: officeMetrics.proximityHubTransitNotes
            )
        }
        
        if officeMetrics.brandingRestrictionsRating > 0 {
            locationMetrics.updateMetric(
                key: "office_branding_restrictions",
                rating: officeMetrics.brandingRestrictionsRating,
                notes: officeMetrics.brandingRestrictionsNotes
            )
        }
        
        if officeMetrics.layoutTypeRating > 0 {
            locationMetrics.updateMetric(
                key: "office_layout_type",
                rating: officeMetrics.layoutTypeRating,
                notes: officeMetrics.layoutTypeNotes
            )
        }
    }
    
    private func migrateHospitalMetrics(from location: Location, to locationMetrics: LocationMetrics) throws {
        guard let hospitalMetrics = location.hospitalMetrics else { return }
        
        if hospitalMetrics.patientVolumeRating > 0 {
            locationMetrics.updateMetric(
                key: "hospital_patient_volume",
                rating: hospitalMetrics.patientVolumeRating,
                notes: hospitalMetrics.patientVolumeNotes
            )
        }
        
        if hospitalMetrics.staffSizeRating > 0 {
            locationMetrics.updateMetric(
                key: "hospital_staff_size",
                rating: hospitalMetrics.staffSizeRating,
                notes: hospitalMetrics.staffSizeNotes
            )
        }
        
        if hospitalMetrics.visitorTrafficRating > 0 {
            locationMetrics.updateMetric(
                key: "hospital_visitor_traffic",
                rating: hospitalMetrics.visitorTrafficRating,
                notes: hospitalMetrics.visitorTrafficNotes
            )
        }
        
        if hospitalMetrics.foodServiceRating > 0 {
            locationMetrics.updateMetric(
                key: "hospital_food_service",
                rating: hospitalMetrics.foodServiceRating,
                notes: hospitalMetrics.foodServiceNotes
            )
        }
        
        if hospitalMetrics.vendingRestrictionsRating > 0 {
            locationMetrics.updateMetric(
                key: "hospital_vending_restrictions",
                rating: hospitalMetrics.vendingRestrictionsRating,
                notes: hospitalMetrics.vendingRestrictionsNotes
            )
        }
        
        if hospitalMetrics.hoursOfOperationRating > 0 {
            locationMetrics.updateMetric(
                key: "hospital_hours_operation",
                rating: hospitalMetrics.hoursOfOperationRating,
                notes: hospitalMetrics.hoursOfOperationNotes
            )
        }
    }
    
    private func migrateSchoolMetrics(from location: Location, to locationMetrics: LocationMetrics) throws {
        guard let schoolMetrics = location.schoolMetrics else { return }
        
        if schoolMetrics.studentPopulationRating > 0 {
            locationMetrics.updateMetric(
                key: "school_student_population",
                rating: schoolMetrics.studentPopulationRating,
                notes: schoolMetrics.studentPopulationNotes
            )
        }
        
        if schoolMetrics.staffSizeRating > 0 {
            locationMetrics.updateMetric(
                key: "school_staff_size",
                rating: schoolMetrics.staffSizeRating,
                notes: schoolMetrics.staffSizeNotes
            )
        }
        
        if schoolMetrics.foodServiceRating > 0 {
            locationMetrics.updateMetric(
                key: "school_food_service",
                rating: schoolMetrics.foodServiceRating,
                notes: schoolMetrics.foodServiceNotes
            )
        }
        
        if schoolMetrics.vendingRestrictionsRating > 0 {
            locationMetrics.updateMetric(
                key: "school_vending_restrictions",
                rating: schoolMetrics.vendingRestrictionsRating,
                notes: schoolMetrics.vendingRestrictionsNotes
            )
        }
        
        if schoolMetrics.hoursOfOperationRating > 0 {
            locationMetrics.updateMetric(
                key: "school_hours_operation",
                rating: schoolMetrics.hoursOfOperationRating,
                notes: schoolMetrics.hoursOfOperationNotes
            )
        }
        
        if schoolMetrics.campusLayoutRating > 0 {
            locationMetrics.updateMetric(
                key: "school_campus_layout",
                rating: schoolMetrics.campusLayoutRating,
                notes: schoolMetrics.campusLayoutNotes
            )
        }
    }
    
    private func migrateResidentialMetrics(from location: Location, to locationMetrics: LocationMetrics) throws {
        guard let residentialMetrics = location.residentialMetrics else { return }
        
        if residentialMetrics.unitCountRating > 0 {
            locationMetrics.updateMetric(
                key: "residential_unit_count",
                rating: residentialMetrics.unitCountRating,
                notes: residentialMetrics.unitCountNotes
            )
        }
        
        if residentialMetrics.occupancyRateRating > 0 {
            locationMetrics.updateMetric(
                key: "residential_occupancy_rate",
                rating: residentialMetrics.occupancyRateRating,
                notes: residentialMetrics.occupancyRateNotes
            )
        }
        
        if residentialMetrics.demographicRating > 0 {
            locationMetrics.updateMetric(
                key: "residential_demographics",
                rating: residentialMetrics.demographicRating,
                notes: residentialMetrics.demographicNotes
            )
        }
        
        if residentialMetrics.foodServiceRating > 0 {
            locationMetrics.updateMetric(
                key: "residential_food_service",
                rating: residentialMetrics.foodServiceRating,
                notes: residentialMetrics.foodServiceNotes
            )
        }
        
        if residentialMetrics.vendingRestrictionsRating > 0 {
            locationMetrics.updateMetric(
                key: "residential_vending_restrictions",
                rating: residentialMetrics.vendingRestrictionsRating,
                notes: residentialMetrics.vendingRestrictionsNotes
            )
        }
        
        if residentialMetrics.hoursOfOperationRating > 0 {
            locationMetrics.updateMetric(
                key: "residential_hours_operation",
                rating: residentialMetrics.hoursOfOperationRating,
                notes: residentialMetrics.hoursOfOperationNotes
            )
        }
        
        if residentialMetrics.buildingLayoutRating > 0 {
            locationMetrics.updateMetric(
                key: "residential_building_layout",
                rating: residentialMetrics.buildingLayoutRating,
                notes: residentialMetrics.buildingLayoutNotes
            )
        }
    }
}

// MARK: - Supporting Types

/// Combines metric definition with instance data for display
struct CombinedMetric: Identifiable {
    let id = UUID()
    let definition: MetricDefinition
    let instance: MetricInstance?
    
    var title: String { definition.title }
    var description: String { definition.description }
    var category: MetricCategory { definition.category }
    var weight: Double { definition.weight }
    var isRequired: Bool { definition.isRequired }
    
    var rating: Int { instance?.rating ?? 0 }
    var notes: String { instance?.notes ?? "" }
    var isRated: Bool { instance?.isRated ?? false }
    var ratedAt: Date? { instance?.ratedAt }
    
    func getRatingDescription() -> String {
        guard rating > 0 else { return "Not rated" }
        return definition.getRatingDescription(for: rating)
    }
}

/// Service-specific errors
enum MetricServiceError: Error, LocalizedError {
    case failedToCreateMetrics
    case metricNotFound
    case invalidRating
    case contextNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .failedToCreateMetrics:
            return "Failed to create metrics for location"
        case .metricNotFound:
            return "Metric not found"
        case .invalidRating:
            return "Invalid rating value"
        case .contextNotAvailable:
            return "Database context not available"
        }
    }
}
