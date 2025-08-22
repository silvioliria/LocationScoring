import Foundation
import SwiftData

// MARK: - Location Manager

/// Manager class for handling location business logic
class LocationManager {
    static let shared = LocationManager()
    
    private init() {}
    
    // MARK: - Data Migration Support
    
    /// Check if this is the first run after data migration
    func isFirstRunAfterMigration(context: ModelContext) -> Bool {
        do {
            let locationDescriptor = FetchDescriptor<Location>()
            let existingLocations = try context.fetch(locationDescriptor)
            return existingLocations.isEmpty
        } catch {
            return true // Assume first run if there's an error
        }
    }
    
    /// Create a welcome location to demonstrate the new architecture
    func createWelcomeLocation(context: ModelContext) -> Location {
        let welcomeLocation = createLocation(
            name: "Welcome to New Architecture",
            address: "Fresh Start Avenue",
            type: .office,
            comment: "This location demonstrates the new object-oriented architecture"
        )
        
        // Add sample office metrics data
        if let officeMetrics = welcomeLocation.officeMetrics {
            officeMetrics.commonAreasRating = 4
            officeMetrics.commonAreasNotes = "Great shared spaces for collaboration"
            officeMetrics.hoursAccessRating = 5
            officeMetrics.hoursAccessNotes = "Modern kitchen and lounge areas"
            officeMetrics.tenantAmenitiesRating = 3
            officeMetrics.tenantAmenitiesNotes = "Limited food options, good for vending"
            officeMetrics.proximityHubTransitRating = 4
            officeMetrics.proximityHubTransitNotes = "Close to transit hub"
            officeMetrics.brandingRestrictionsRating = 4
            officeMetrics.brandingRestrictionsNotes = "Minimal restrictions"
            officeMetrics.layoutTypeRating = 5
            officeMetrics.layoutTypeNotes = "Multi-tenant building with diverse occupants"
        }
        
        // Note: Financials properties are read-only, so we can't set them here
        // They would need to be set through the UI or other means
        _ = welcomeLocation.financials
        
        context.insert(welcomeLocation)
        return welcomeLocation
    }
    
    /// Get all available location types for the new architecture
    func getAvailableLocationTypes() -> [LocationType] {
        return [
            LocationType(type: .office),
            LocationType(type: .hospital),
            LocationType(type: .school),
            LocationType(type: .residential)
        ]
    }
    
    // MARK: - Location Creation
    
    func createLocation(name: String, address: String, type: LocationTypeEnum, comment: String = "") -> Location {
        let locationType = LocationType(type: type)
        let location = Location(name: name, address: address, comment: comment, locationType: locationType)
        
        // Initialize basic metrics
        location.generalMetrics = GeneralMetrics()
        location.financials = Financials()
        location.scorecard = Scorecard()
        
        // Initialize type-specific metrics based on location type
        switch type {
        case .office:
            location.officeMetrics = OfficeMetrics(locationType: type)
        case .hospital:
            location.hospitalMetrics = HospitalMetrics(locationType: type)
        case .school:
            location.schoolMetrics = SchoolMetrics(locationType: type)
        case .residential:
            location.residentialMetrics = ResidentialMetrics(locationType: type)
        }
        
        return location
    }
    
    func createLocationWithQuickSetup(name: String, address: String, type: LocationTypeEnum, comment: String = "", quickSetupData: [String: Any] = [:]) -> Location {
        let location = createLocation(name: name, address: address, type: type, comment: comment)
        
        // Apply quick setup data if available
        if !quickSetupData.isEmpty {
            applyQuickSetupData(to: location, data: quickSetupData)
        }
        
        return location
    }
    
    // MARK: - Quick Setup Data Application
    
    private func applyQuickSetupData(to location: Location, data: [String: Any]) {
        // Apply general metrics
        if let generalData = data["general"] as? [String: Any] {
            applyGeneralMetricsData(location.generalMetrics, data: generalData)
        }
        
        // Apply type-specific metrics
        if let typeData = data["typeSpecific"] as? [String: Any] {
            applyTypeSpecificData(location, data: typeData)
        }
        
        // Apply financial data
        if let financialData = data["financial"] as? [String: Any] {
            applyFinancialData(location.financials, data: financialData)
        }
    }
    
    private func applyGeneralMetricsData(_ metrics: GeneralMetrics?, data: [String: Any]) {
        guard let metrics = metrics else { return }
        
        if let footTraffic = data["footTraffic"] as? Int {
            metrics.footTrafficDaily = footTraffic
        }
        if let demographics = data["demographics"] as? Int {
            metrics.targetDemographicFit = "Demographic fit: \(demographics)"
        }
        if let competition = data["competition"] as? Int {
            metrics.competitionRating = competition
        }
        if let accessibility = data["accessibility"] as? Int {
            metrics.visibilityRating = accessibility
        }
        if let security = data["security"] as? Int {
            metrics.securityRating = security
        }
    }
    
    private func applyTypeSpecificData(_ location: Location, data: [String: Any]) {
        switch location.locationType.type {
        case .office:
            if let officeMetrics = location.officeMetrics {
                applyOfficeMetricsData(officeMetrics, data: data)
            }
        case .hospital:
            if let hospitalMetrics = location.getHospitalMetrics() {
                applyHospitalMetricsData(hospitalMetrics, data: data)
            }
        case .school:
            if let schoolMetrics = location.getSchoolMetrics() {
                applySchoolMetricsData(schoolMetrics, data: data)
            }
        case .residential:
            if let residentialMetrics = location.getResidentialMetrics() {
                applyResidentialMetricsData(residentialMetrics, data: data)
            }
        }
    }
    
    private func applyOfficeMetricsData(_ metrics: OfficeMetrics, data: [String: Any]) {
        // Apply office-specific metrics data
        if let commonAreas = data["commonAreas"] as? Int {
            metrics.commonAreasRating = commonAreas
        }
        if let hoursAccess = data["hoursAccess"] as? Int {
            metrics.hoursAccessRating = hoursAccess
        }
        if let tenantAmenities = data["tenantAmenities"] as? Int {
            metrics.tenantAmenitiesRating = tenantAmenities
        }
        if let proximityHubTransit = data["proximityHubTransit"] as? Int {
            metrics.proximityHubTransitRating = proximityHubTransit
        }
        if let brandingRestrictions = data["brandingRestrictions"] as? Int {
            metrics.brandingRestrictionsRating = brandingRestrictions
        }
        if let layoutType = data["layoutType"] as? Int {
            metrics.layoutTypeRating = layoutType
        }
    }
    
    private func applyHospitalMetricsData(_ metrics: HospitalMetrics, data: [String: Any]) {
        // Placeholder for hospital metrics
    }
    
    private func applySchoolMetricsData(_ metrics: SchoolMetrics, data: [String: Any]) {
        // Placeholder for school metrics
    }
    
    private func applyResidentialMetricsData(_ metrics: ResidentialMetrics, data: [String: Any]) {
        // Placeholder for residential metrics
    }
    
    private func applyFinancialData(_ financials: Financials?, data: [String: Any]) {
        // Note: Financials properties are read-only, so we can't set them here
        // This would need to be handled differently in the actual implementation
    }
    
    // MARK: - Score Calculations
    
    func getLocationScoreBreakdown(_ location: Location) -> LocationScoreBreakdown {
        let generalScore = location.generalMetrics?.calculateOverallScore() ?? 0.0
        let typeSpecificScore = getTypeSpecificScore(location)
        let financialScore = calculateFinancialScore(location.financials)
        
        let totalScore = generalScore + typeSpecificScore + financialScore
        let totalWeight = 3.0
        
        return LocationScoreBreakdown(
            generalScore: generalScore,
            typeSpecificScore: typeSpecificScore,
            financialScore: financialScore,
            overallScore: totalScore / totalWeight
        )
    }
    
    private func calculateFinancialScore(_ financials: Financials?) -> Double {
        guard let financials = financials else { return 0.0 }
        
        // Calculate a simple financial score based on available data
        var score = 0.0
        var factors = 0
        
        if financials.revenueProjection > 0 {
            score += min(financials.revenueProjection / 10000, 5.0) // Cap at 5 points
            factors += 1
        }
        
        if financials.costProjection > 0 {
            score += min((1.0 / financials.costProjection) * 10000, 5.0) // Lower cost = higher score
            factors += 1
        }
        
        if financials.profitMargin > 0 {
            score += min(financials.profitMargin / 20, 5.0) // Cap at 5 points
            factors += 1
        }
        
        if financials.roiPercentage > 0 {
            score += min(financials.roiPercentage / 50, 5.0) // Cap at 5 points
            factors += 1
        }
        
        return factors > 0 ? score / Double(factors) : 0.0
    }
    
    private func getTypeSpecificScore(_ location: Location) -> Double {
        if let officeMetrics = location.getOfficeMetrics() {
            return officeMetrics.calculateOverallScore()
        } else if let hospitalMetrics = location.getHospitalMetrics() {
            return hospitalMetrics.calculateOverallScore()
        } else if let schoolMetrics = location.getSchoolMetrics() {
            return schoolMetrics.calculateOverallScore()
        } else if let residentialMetrics = location.getResidentialMetrics() {
            return residentialMetrics.calculateOverallScore()
        }
        return 0.0
    }
    
    // MARK: - Validation
    
    func validateLocationForCompletion(_ location: Location) -> [String] {
        var warnings: [String] = []
        
        // Check general metrics
        if let generalMetrics = location.generalMetrics {
            let generalComplete = generalMetrics.footTrafficDaily > 0 &&
                                generalMetrics.targetDemographicFit.count > 0 &&
                                generalMetrics.competitionRating > 0 &&
                                generalMetrics.visibilityRating > 0 &&
                                generalMetrics.securityRating > 0
            if !generalComplete {
                warnings.append("General metrics are incomplete")
            }
        }
        
        // Check type-specific metrics
        let typeSpecificComplete = isTypeSpecificComplete(location)
        if !typeSpecificComplete {
            warnings.append("Type-specific metrics are incomplete")
        }
        
        // Check financials
        if let financials = location.financials {
            let financialComplete = financials.revenueProjection > 0 || financials.costProjection > 0
            if !financialComplete {
                warnings.append("Financial information is incomplete")
            }
        }
        
        return warnings
    }
    
    private func isTypeSpecificComplete(_ location: Location) -> Bool {
        if let officeMetrics = location.getOfficeMetrics() {
            return officeMetrics.getRatedMetricCount() >= 1
        } else if let hospitalMetrics = location.getHospitalMetrics() {
            return hospitalMetrics.getRatedMetricCount() >= 1
        } else if let schoolMetrics = location.getSchoolMetrics() {
            return schoolMetrics.getRatedMetricCount() >= 1
        } else if let residentialMetrics = location.getResidentialMetrics() {
            return residentialMetrics.getRatedMetricCount() >= 1
        }
        return false
    }
}

// MARK: - Supporting Types

struct LocationScoreBreakdown {
    let generalScore: Double
    let typeSpecificScore: Double
    let financialScore: Double
    let overallScore: Double
}
