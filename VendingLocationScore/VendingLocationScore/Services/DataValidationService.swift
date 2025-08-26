import Foundation
import SwiftData

/// Centralized data validation service for ensuring data integrity
@MainActor
class DataValidationService: ObservableObject {
    static let shared = DataValidationService()
    
    private init() {}
    
    // MARK: - Location Validation
    
    /// Validates a location object for completeness and data integrity
    func validateLocation(_ location: Location) -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        // Basic required fields
        if location.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Location name is required")
        }
        
        if location.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Location address is required")
        }
        
        // Metrics validation
        if let generalMetrics = location.generalMetrics {
            let generalValidation = validateGeneralMetrics(generalMetrics)
            errors.append(contentsOf: generalValidation.errors)
            warnings.append(contentsOf: generalValidation.warnings)
        } else {
            warnings.append("General metrics not initialized")
        }
        
        // Type-specific metrics validation
        let typeSpecificValidation = validateTypeSpecificMetrics(for: location)
        errors.append(contentsOf: typeSpecificValidation.errors)
        warnings.append(contentsOf: typeSpecificValidation.warnings)
        
        // Financials validation
        if let financials = location.financials {
            let financialsValidation = validateFinancials(financials)
            errors.append(contentsOf: financialsValidation.errors)
            warnings.append(contentsOf: financialsValidation.warnings)
        } else {
            warnings.append("Financials not initialized")
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    // MARK: - General Metrics Validation
    
    /// Validates general metrics data
    func validateGeneralMetrics(_ metrics: GeneralMetrics) -> ValidationResult {
        var errors: [String] = []
        let warnings: [String] = []
        
        // Validate foot traffic (not optional, so no need for if let)
        if metrics.footTrafficDaily < 0 {
            errors.append("Foot traffic cannot be negative")
        }
        
        // Validate ratings (0-5 scale) - using the actual properties that exist
        let ratings = [
            ("Foot Traffic", metrics.footTrafficRating),
            ("Target Demographic", metrics.targetDemographicRating),
            ("Host Commission", metrics.hostCommissionRating),
            ("Competition", metrics.competitionRating),
            ("Visibility", metrics.visibilityRating),
            ("Security", metrics.securityRating),
            ("Parking/Transit", metrics.parkingTransitRating),
            ("Amenities", metrics.amenitiesRating)
        ]
        
        for (name, rating) in ratings {
            if rating < 0 || rating > 5 {
                errors.append("\(name) rating must be between 0 and 5")
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    // MARK: - Type-Specific Metrics Validation
    
    private func validateTypeSpecificMetrics(for location: Location) -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        switch location.locationType.type {
        case .office:
            if let officeMetrics = location.officeMetrics {
                let validation = validateOfficeMetrics(officeMetrics)
                errors.append(contentsOf: validation.errors)
                warnings.append(contentsOf: validation.warnings)
            } else {
                warnings.append("Office metrics not initialized")
            }
        case .hospital:
            if let hospitalMetrics = location.hospitalMetrics {
                let validation = validateHospitalMetrics(hospitalMetrics)
                errors.append(contentsOf: validation.errors)
                warnings.append(contentsOf: validation.warnings)
            } else {
                warnings.append("Hospital metrics not initialized")
            }
        case .school:
            if let schoolMetrics = location.schoolMetrics {
                let validation = validateSchoolMetrics(schoolMetrics)
                errors.append(contentsOf: validation.errors)
                warnings.append(contentsOf: validation.warnings)
            } else {
                warnings.append("School metrics not initialized")
            }
        case .residential:
            if let residentialMetrics = location.residentialMetrics {
                let validation = validateResidentialMetrics(residentialMetrics)
                errors.append(contentsOf: validation.errors)
                warnings.append(contentsOf: validation.warnings)
            } else {
                warnings.append("Residential metrics not initialized")
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    private func validateOfficeMetrics(_ metrics: OfficeMetrics) -> ValidationResult {
        var errors: [String] = []
        let warnings: [String] = []
        
        let ratings = [
            ("Common Areas", metrics.commonAreasRating),
            ("Hours & Access", metrics.hoursAccessRating),
            ("Tenant Amenities", metrics.tenantAmenitiesRating),
            ("Hub Proximity & Transit", metrics.proximityHubTransitRating),
            ("Branding Restrictions", metrics.brandingRestrictionsRating),
            ("Layout Type", metrics.layoutTypeRating)
        ]
        
        for (name, rating) in ratings {
            if rating > 0 && !(1...5).contains(rating) {
                errors.append("\(name) rating must be between 1 and 5")
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    private func validateHospitalMetrics(_ metrics: HospitalMetrics) -> ValidationResult {
        var errors: [String] = []
        let warnings: [String] = []
        
        let ratings = [
            ("Patient Volume", metrics.patientVolumeRating),
            ("Staff Size", metrics.staffSizeRating),
            ("Visitor Traffic", metrics.visitorTrafficRating),
            ("Food Service", metrics.foodServiceRating),
            ("Vending Restrictions", metrics.vendingRestrictionsRating),
            ("Hours of Operation", metrics.hoursOfOperationRating)
        ]
        
        for (name, rating) in ratings {
            if rating > 0 && !(1...5).contains(rating) {
                errors.append("\(name) rating must be between 1 and 5")
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    private func validateSchoolMetrics(_ metrics: SchoolMetrics) -> ValidationResult {
        var errors: [String] = []
        let warnings: [String] = []
        
        let ratings = [
            ("Student Population", metrics.studentPopulationRating),
            ("Staff Size", metrics.staffSizeRating),
            ("Food Service", metrics.foodServiceRating),
            ("Vending Restrictions", metrics.vendingRestrictionsRating),
            ("Hours of Operation", metrics.hoursOfOperationRating),
            ("Campus Layout", metrics.campusLayoutRating)
        ]
        
        for (name, rating) in ratings {
            if rating > 0 && !(1...5).contains(rating) {
                errors.append("\(name) rating must be between 1 and 5")
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    private func validateResidentialMetrics(_ metrics: ResidentialMetrics) -> ValidationResult {
        var errors: [String] = []
        let warnings: [String] = []
        
        let ratings = [
            ("Unit Count", metrics.unitCountRating),
            ("Occupancy Rate", metrics.occupancyRateRating),
            ("Demographics", metrics.demographicRating),
            ("Food Service", metrics.foodServiceRating),
            ("Vending Restrictions", metrics.vendingRestrictionsRating),
            ("Hours of Operation", metrics.hoursOfOperationRating),
            ("Building Layout", metrics.buildingLayoutRating)
        ]
        
        for (name, rating) in ratings {
            if rating > 0 && !(1...5).contains(rating) {
                errors.append("\(name) rating must be between 1 and 5")
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    // MARK: - Financials Validation
    
    /// Validates financials data
    func validateFinancials(_ financials: Financials) -> ValidationResult {
        var errors: [String] = []
        let warnings: [String] = []
        
        // Validate avgTicket
        if let avgTicket = financials.avgTicket {
            if avgTicket < 0 {
                errors.append("Average ticket cannot be negative")
            }
        }
        
        // Validate capturePct
        if let capturePct = financials.capturePct {
            if capturePct < 0 || capturePct > 1 {
                errors.append("Capture percentage must be between 0 and 1")
            }
        }
        
        // Validate days
        if let days = financials.days {
            if days <= 0 {
                errors.append("Days must be greater than 0")
            }
        }
        
        // Validate cogs
        if let cogs = financials.cogs {
            if cogs < 0 {
                errors.append("Cost of goods cannot be negative")
            }
        }
        
        // Validate variableCosts
        if let variableCosts = financials.variableCosts {
            if variableCosts < 0 {
                errors.append("Variable costs cannot be negative")
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    // MARK: - User Validation
    
    func validateUser(_ user: User) -> ValidationResult {
        var errors: [String] = []
        let warnings: [String] = []
        
        if user.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("User name is required")
        }
        
        if user.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("User email is required")
        } else if !isValidEmail(user.email) {
            errors.append("Invalid email format")
        }
        
        if user.id.isEmpty {
            errors.append("User ID is required")
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    // MARK: - Helper Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Validation Result

struct ValidationResult {
    let isValid: Bool
    let errors: [String]
    let warnings: [String]
    
    var hasErrors: Bool { !errors.isEmpty }
    var hasWarnings: Bool { !warnings.isEmpty }
    
    var summary: String {
        if errors.isEmpty && warnings.isEmpty {
            return "Validation passed"
        } else if errors.isEmpty {
            return "Validation passed with \(warnings.count) warning(s)"
        } else {
            return "Validation failed with \(errors.count) error(s)"
        }
    }
}
