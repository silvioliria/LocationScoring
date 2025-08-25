import Foundation
import SwiftData
// import CloudKit  // Temporarily disabled for Personal Team development

// MARK: - Simplified Location Model (With SwiftData)

@Model
final class Location: @unchecked Sendable {
    var id: UUID
    var name: String
    var address: String
    var comment: String
    var createdAt: Date
    var updatedAt: Date
    
    // Location type
    var locationType: LocationType
    
    // Metrics
    var generalMetrics: GeneralMetrics?
    var financials: Financials?
    var scorecard: Scorecard?
    
    // Type-specific metrics
    var officeMetrics: OfficeMetrics?
    var hospitalMetrics: HospitalMetrics?
    var schoolMetrics: SchoolMetrics?
    var residentialMetrics: ResidentialMetrics?
    
    init(name: String, address: String, comment: String = "", locationType: LocationType) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.comment = comment
        self.locationType = locationType
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Getter Methods for Type-Specific Metrics
    
    func getOfficeMetrics() -> OfficeMetrics? {
        // Initialize office metrics if missing (for existing locations)
        if officeMetrics == nil && locationType.type == .office {
            officeMetrics = OfficeMetrics(locationType: locationType.type)
        }
        return officeMetrics
    }
    
    func getHospitalMetrics() -> HospitalMetrics? {
        // Initialize hospital metrics if missing (for existing locations)
        if hospitalMetrics == nil && locationType.type == .hospital {
            hospitalMetrics = HospitalMetrics(locationType: locationType.type)
        }
        return hospitalMetrics
    }
    
    func getSchoolMetrics() -> SchoolMetrics? {
        // Initialize school metrics if missing (for existing locations)
        if schoolMetrics == nil && locationType.type == .school {
            schoolMetrics = SchoolMetrics(locationType: locationType.type)
        }
        return schoolMetrics
    }
    
    func getResidentialMetrics() -> ResidentialMetrics? {
        // Initialize residential metrics if missing (for existing locations)
        if residentialMetrics == nil && locationType.type == .residential {
            residentialMetrics = ResidentialMetrics(locationType: locationType.type)
        }
        return residentialMetrics
    }
    
    func getGeneralMetrics() -> GeneralMetrics? {
        // Initialize general metrics if missing (for existing locations)
        if generalMetrics == nil {
            generalMetrics = GeneralMetrics()
        }
        return generalMetrics
    }
    
    func getFinancials() -> Financials? {
        // Initialize financials if missing (for existing locations)
        if financials == nil {
            financials = Financials()
        }
        return financials
    }
    
    func getScorecard() -> Scorecard? {
        // Initialize scorecard if missing (for existing locations)
        if scorecard == nil {
            scorecard = Scorecard()
        }
        return scorecard
    }
    
    // MARK: - Score Calculation
    
    func calculateOverallScore() -> Double {
        guard let generalMetrics = generalMetrics else {
            return 0.0
        }
        
        // Get the module specific score first
        let moduleScore: Double
        switch locationType.type {
        case .office:
            moduleScore = officeMetrics?.calculateOverallScore() ?? 0.0
        case .hospital:
            moduleScore = hospitalMetrics?.calculateOverallScore() ?? 0.0
        case .school:
            moduleScore = schoolMetrics?.calculateOverallScore() ?? 0.0
        case .residential:
            moduleScore = residentialMetrics?.calculateOverallScore() ?? 0.0
        }
        
        // Use the proper weighted scoring method for general metrics
        let generalScore = generalMetrics.calculateWeightedOverallScore(moduleSpecificScore: moduleScore)
        
        // Convert from 0-1 scale back to 0-5 scale for consistency
        return generalScore * 5.0
    }
    
    private func calculateGeneralScore() -> Double {
        guard let generalMetrics = generalMetrics else { return 0.0 }
        
        let ratings = [
            generalMetrics.footTrafficRating,
            generalMetrics.targetDemographicRating,
            generalMetrics.competitionRating,
            generalMetrics.visibilityRating,
            generalMetrics.securityRating,
            generalMetrics.parkingTransitRating,
            generalMetrics.amenitiesRating
        ]
        
        let ratedCount = ratings.filter { $0 > 0 }.count
        guard ratedCount > 0 else { return 0.0 }
        
        let total = ratings.reduce(0) { $0 + $1 }
        return Double(total) / Double(ratedCount)
    }
    
    private func calculateTypeSpecificScore() -> Double {
        switch locationType.type {
        case .office:
            guard let officeMetrics = officeMetrics else { return 0.0 }
            let officeRatings = [
                officeMetrics.commonAreasRating,
                officeMetrics.hoursAccessRating,
                officeMetrics.tenantAmenitiesRating,
                officeMetrics.proximityHubTransitRating,
                officeMetrics.brandingRestrictionsRating,
                officeMetrics.layoutTypeRating
            ]
            let ratedCount = officeRatings.filter { $0 > 0 }.count
            guard ratedCount > 0 else { return 0.0 }
            let total = officeRatings.reduce(0) { $0 + $1 }
            return Double(total) / Double(ratedCount)
        case .hospital:
            guard let hospitalMetrics = hospitalMetrics else { return 0.0 }
            return hospitalMetrics.calculateOverallScore()
        case .school:
            guard let schoolMetrics = schoolMetrics else { return 0.0 }
            return schoolMetrics.calculateOverallScore()
        case .residential:
            guard let residentialMetrics = residentialMetrics else { return 0.0 }
            return residentialMetrics.calculateOverallScore()
        }
    }
    
    // MARK: - Validation
    
    func isComplete() -> Bool {
        let generalComplete = isGeneralMetricsComplete()
        let typeSpecificComplete = isTypeSpecificComplete()
        
        return generalComplete && typeSpecificComplete
    }
    
    private func isGeneralMetricsComplete() -> Bool {
        guard let generalMetrics = generalMetrics else { return false }
        
        return generalMetrics.footTrafficRating > 0 &&
               generalMetrics.targetDemographicRating > 0 &&
               generalMetrics.competitionRating > 0 &&
               generalMetrics.visibilityRating > 0 &&
               generalMetrics.securityRating > 0
    }
    
    private func isTypeSpecificComplete() -> Bool {
        switch locationType.type {
        case .office:
            guard let officeMetrics = officeMetrics else { return false }
            return officeMetrics.commonAreasRating > 0 ||
                   officeMetrics.hoursAccessRating > 0 ||
                   officeMetrics.tenantAmenitiesRating > 0 ||
                   officeMetrics.proximityHubTransitRating > 0 ||
                   officeMetrics.brandingRestrictionsRating > 0 ||
                   officeMetrics.layoutTypeRating > 0
        case .hospital:
            guard let hospitalMetrics = hospitalMetrics else { return false }
            return hospitalMetrics.getRatedMetricCount() > 0
        case .school:
            guard let schoolMetrics = schoolMetrics else { return false }
            return schoolMetrics.getRatedMetricCount() > 0
        case .residential:
            guard let residentialMetrics = residentialMetrics else { return false }
            return residentialMetrics.getRatedMetricCount() > 0
        }
    }
}

// MARK: - CloudKit Support (Temporarily disabled for Personal Team development)
/*
extension Location {
    func toCKRecord() throws -> CKRecord {
        let record = CKRecord(recordType: "Location")
        record["id"] = id.uuidString
        record["name"] = name
        record["address"] = address
        record["comment"] = comment
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt

        // Store location type as simple properties instead of reference
        record["locationTypeEnum"] = locationType.type.rawValue
        record["locationTypeDisplayName"] = locationType.displayName

        return record
    }

    convenience init(from record: CKRecord) throws {
        let id = UUID() // Generate new UUID since we can't use record ID
        let name = record["name"] as? String ?? "Unknown Location"
        let address = record["address"] as? String ?? ""
        let comment = record["comment"] as? String ?? ""
        let createdAt = record["createdAt"] as? Date ?? Date()
        let updatedAt = record["updatedAt"] as? Date ?? Date()

        // Reconstruct location type from stored properties
        let typeRawValue = record["locationTypeEnum"] as? String ?? "office"
        let typeDisplayName = record["locationTypeDisplayName"] as? String ?? "Office"
        let locationType = LocationType(type: LocationTypeEnum(rawValue: typeRawValue) ?? .office, displayName: typeDisplayName)

        self.init(name: name, address: address, comment: comment, locationType: locationType)
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
*/

// MARK: - Legacy Location Module Enum (for backward compatibility)
enum LocationModule: String, CaseIterable, Codable {
    case office = "office"
    case hospital = "hospital"
    case school = "school"
    case residential = "residential"

    var displayName: String {
        switch self {
        case .office: return "Office"
        case .hospital: return "Hospital"
        case .school: return "School"
        case .residential: return "Residential"
        }
    }

    var icon: String {
        switch self {
        case .office: return "building.2"
        case .hospital: return "cross.case"
        case .school: return "graduationcap"
        case .residential: return "house"
        }
    }

    var color: String {
        switch self {
        case .office: return "blue"
        case .hospital: return "red"
        case .school: return "green"
        case .residential: return "purple"
        }
    }

    func toLocationTypeEnum() -> LocationTypeEnum {
        switch self {
        case .office: return .office
        case .hospital: return .hospital
        case .school: return .school
        case .residential: return .residential
        }
    }
}
