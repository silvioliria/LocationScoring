import Foundation
import SwiftUI

enum LocationDecision: String, CaseIterable {
    case greenlight = "greenlight"
    case watchlist = "watchlist"
    case pass = "pass"
    
    var displayName: String {
        switch self {
        case .greenlight: return "Greenlight"
        case .watchlist: return "Watchlist"
        case .pass: return "Pass"
        }
    }
    
    var color: String {
        switch self {
        case .greenlight: return "green"
        case .watchlist: return "yellow"
        case .pass: return "red"
        }
    }
}

// MARK: - Module-Specific Metric Types

// Residential Metrics
enum ResidentialMetricType: String, CaseIterable, Identifiable, ModuleMetricType {
    case unitCount = "res_unit_count"
    case occupancyRate = "res_occupancy_rate"
    case demographics = "res_demographics"
    case foodService = "res_food_service"
    case vendingRestrictions = "res_vending_restrictions"
    case hoursOfOperation = "res_hours_operation"
    case buildingLayout = "res_building_layout"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .unitCount: return "Unit Count"
        case .occupancyRate: return "Occupancy Rate"
        case .demographics: return "Demographics"
        case .foodService: return "Food Service"
        case .vendingRestrictions: return "Vending Restrictions"
        case .hoursOfOperation: return "Hours of Operation"
        case .buildingLayout: return "Building Layout"
        }
    }
    
    var description: String {
        switch self {
        case .unitCount: return "Number of residential units in the building. Higher unit counts generally indicate more potential customers and better economies of scale."
        case .occupancyRate: return "Current occupancy rate and tenant stability. Higher occupancy rates suggest stable tenancy and consistent foot traffic."
        case .demographics: return "Tenant demographics and preferences. Understanding the resident base helps optimize product selection and placement."
        case .foodService: return "Existing food service options and quality. Less competition means better opportunities for vending sales."
        case .vendingRestrictions: return "Restrictions on vending machine placement and operation. Fewer restrictions mean easier installation and operation."
        case .hoursOfOperation: return "Building access hours and flexibility. Longer hours increase revenue potential and customer convenience."
        case .buildingLayout: return "Building layout and common area distribution. Better layouts improve visibility and accessibility for vending machines."
        }
    }
    
    func starDescription(for star: Int) -> String {
        switch self {
        case .unitCount:
            switch star {
            case 1: return "<100 units"
            case 2: return "100-149 units"
            case 3: return "150-249 units"
            case 4: return "250-349 units"
            case 5: return "350+ units"
            default: return ""
            }
        case .occupancyRate:
            switch star {
            case 1: return "<80%"
            case 2: return "80-89%"
            case 3: return "90-94%"
            case 4: return "95-97%"
            case 5: return "98-100%"
            default: return ""
            }
        case .demographics:
            switch star {
            case 1: return "Limited appeal"
            case 2: return "Some appeal"
            case 3: return "Moderate appeal"
            case 4: return "High appeal"
            case 5: return "Very high appeal"
            default: return ""
            }
        case .foodService:
            switch star {
            case 1: return "Full-service options"
            case 2: return "Multiple alternatives"
            case 3: return "Limited alternatives"
            case 4: return "Basic options only"
            case 5: return "No food service"
            default: return ""
            }
        case .vendingRestrictions:
            switch star {
            case 1: return "Many restrictions"
            case 2: return "Several restrictions"
            case 3: return "Some restrictions"
            case 4: return "Few restrictions"
            case 5: return "No restrictions"
            default: return ""
            }
        case .hoursOfOperation:
            switch star {
            case 1: return "Limited hours"
            case 2: return "Standard hours"
            case 3: return "Extended hours"
            case 4: return "Long hours"
            case 5: return "24/7 access"
            default: return ""
            }
        case .buildingLayout:
            switch star {
            case 1: return "Poor layout"
            case 2: return "Fair layout"
            case 3: return "Good layout"
            case 4: return "Very good layout"
            case 5: return "Excellent layout"
            default: return ""
            }
        }
    }
}

// Office Metrics
enum OfficeMetricType: String, CaseIterable, Identifiable, ModuleMetricType {
    case commonAreas = "off_common_areas"
    case hoursAccess = "off_hours_access"
    case tenantAmenities = "off_tenant_amenities"
    case proximityHubTransit = "off_proximity_hub_transit"
    case brandingRestrictions = "off_branding_restrictions"
    case layoutType = "off_layout_type"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .commonAreas: return "Common Areas"
        case .hoursAccess: return "Hours & Access"
        case .tenantAmenities: return "Tenant Amenities"
        case .proximityHubTransit: return "Hub Proximity & Transit"
        case .brandingRestrictions: return "Branding Restrictions"
        case .layoutType: return "Layout Type"
        }
    }
    
    var description: String {
        switch self {
        case .commonAreas: return "Availability and quality of common areas like break rooms, lounges, and cafeterias. More common areas increase foot traffic and vending opportunities."
        case .hoursAccess: return "Building access hours and flexibility. Extended hours provide more opportunities for vending sales."
        case .tenantAmenities: return "Existing food and beverage options for tenants. Fewer alternatives mean less competition for vending sales."
        case .proximityHubTransit: return "Proximity to transportation hubs and transit options. Better accessibility increases potential customer base."
        case .brandingRestrictions: return "Restrictions on signage and branding. Fewer restrictions make installation and operation easier."
        case .layoutType: return "Building layout and tenant density. Multi-tenant buildings typically provide more diverse customer base."
        }
    }
    
    func starDescription(for star: Int) -> String {
        switch self {
        case .commonAreas:
            switch star {
            case 1: return "None"
            case 2: return "Small kitchenette only"
            case 3: return "Lounge or shared break area"
            case 4: return "Lounge + café nook"
            case 5: return "Lounge + cafeteria / multiple hubs"
            default: return ""
            }
        case .hoursAccess:
            switch star {
            case 1: return "9-5 only, strict access"
            case 2: return "9-7, limited evenings"
            case 3: return "Extended weekdays"
            case 4: return "Weekdays + some weekends"
            case 5: return "24/7 with tenant badge"
            default: return ""
            }
        case .tenantAmenities:
            switch star {
            case 1: return "Full cafeteria / subsidized food"
            case 2: return "Multiple food vendors"
            case 3: return "Limited café / snack cart"
            case 4: return "Coffee only"
            case 5: return "None"
            default: return ""
            }
        case .proximityHubTransit:
            switch star {
            case 1: return "Remote from hubs, poor transit"
            case 2: return "Edge of hub / infrequent transit"
            case 3: return "Near hub or decent transit"
            case 4: return "In hub + good transit"
            case 5: return "Prime hub + major transit interchange"
            default: return ""
            }
        case .brandingRestrictions:
            switch star {
            case 1: return "Severe (no signage, approvals slow)"
            case 2: return "Heavy (strict size/colour limits)"
            case 3: return "Moderate (some constraints)"
            case 4: return "Light (basic guidelines)"
            case 5: return "Minimal/none"
            default: return ""
            }
        case .layoutType:
            switch star {
            case 1: return "Single-tenant, low density"
            case 2: return "Single-tenant, medium density"
            case 3: return "Multi-tenant (2-3)"
            case 4: return "Multi-tenant (4-6)"
            case 5: return "Multi-tenant (7+ diverse tenants)"
            default: return ""
            }
        }
    }
}

// Hospital/Healthcare Metrics
enum HospitalMetricType: String, CaseIterable, Identifiable, ModuleMetricType {
    case patientVolume = "hos_patient_volume"
    case staffSize = "hos_staff_size"
    case visitorTraffic = "hos_visitor_traffic"
    case foodService = "hos_food_service"
    case vendingRestrictions = "hos_vending_restrictions"
    case hoursOfOperation = "hos_hours_operation"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .patientVolume: return "Patient Volume"
        case .staffSize: return "Staff Size"
        case .visitorTraffic: return "Visitor Traffic"
        case .foodService: return "Food Service"
        case .vendingRestrictions: return "Vending Restrictions"
        case .hoursOfOperation: return "Hours of Operation"
        }
    }
    
    var description: String {
        switch self {
        case .patientVolume: return "Daily patient volume and flow. Higher volume increases potential customer base."
        case .staffSize: return "Number of staff members and their distribution. More staff means more potential customers."
        case .visitorTraffic: return "Visitor flow and patterns. Regular visitors increase usage opportunities."
        case .foodService: return "Existing food service options and quality. Less competition means better opportunities."
        case .vendingRestrictions: return "Restrictions on vending machine placement and operation. Fewer restrictions mean easier installation."
        case .hoursOfOperation: return "Building and department operating hours. Longer hours increase revenue potential."
        }
    }
    
    func starDescription(for star: Int) -> String {
        switch self {
        case .patientVolume:
            switch star {
            case 1: return "<100 patients/day"
            case 2: return "100-300 patients/day"
            case 3: return "300-500 patients/day"
            case 4: return "500-800 patients/day"
            case 5: return "800+ patients/day"
            default: return ""
            }
        case .staffSize:
            switch star {
            case 1: return "<50 staff"
            case 2: return "50-100 staff"
            case 3: return "100-200 staff"
            case 4: return "200-400 staff"
            case 5: return "400+ staff"
            default: return ""
            }
        case .visitorTraffic:
            switch star {
            case 1: return "Minimal visitors"
            case 2: return "Low visitor traffic"
            case 3: return "Moderate visitor traffic"
            case 4: return "High visitor traffic"
            case 5: return "Very high visitor traffic"
            default: return ""
            }
        case .foodService:
            switch star {
            case 1: return "Full-service cafeteria"
            case 2: return "Multiple food options"
            case 3: return "Limited food options"
            case 4: return "Basic vending only"
            case 5: return "No food service"
            default: return ""
            }
        case .vendingRestrictions:
            switch star {
            case 1: return "Many restrictions"
            case 2: return "Several restrictions"
            case 3: return "Some restrictions"
            case 4: return "Few restrictions"
            case 5: return "No restrictions"
            default: return ""
            }
        case .hoursOfOperation:
            switch star {
            case 1: return "Limited hours"
            case 2: return "Standard business hours"
            case 3: return "Extended hours"
            case 4: return "Long hours"
            case 5: return "24/7 operation"
            default: return ""
            }
        }
    }
}

// School/University Metrics
enum SchoolMetricType: String, CaseIterable, Identifiable, ModuleMetricType {
    case studentPopulation = "sch_student_population"
    case staffSize = "sch_staff_size"
    case foodService = "sch_food_service"
    case vendingRestrictions = "sch_vending_restrictions"
    case hoursOfOperation = "sch_hours_operation"
    case campusLayout = "sch_campus_layout"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .studentPopulation: return "Student Population"
        case .staffSize: return "Staff Size"
        case .foodService: return "Food Service"
        case .vendingRestrictions: return "Vending Restrictions"
        case .hoursOfOperation: return "Hours of Operation"
        case .campusLayout: return "Campus Layout"
        }
    }
    
    var description: String {
        switch self {
        case .studentPopulation: return "Number of students and their distribution. Higher populations increase potential customer base."
        case .staffSize: return "Number of staff members and their distribution. More staff means more potential customers."
        case .foodService: return "Existing food service options and quality. Less competition means better opportunities for vending sales."
        case .vendingRestrictions: return "Restrictions on vending machine placement and operation. Fewer restrictions mean easier installation."
        case .hoursOfOperation: return "School operating hours and access. Longer hours increase revenue potential."
        case .campusLayout: return "Campus layout and building distribution. Better layouts improve visibility and accessibility."
        }
    }
    
    func starDescription(for star: Int) -> String {
        switch self {
        case .studentPopulation:
            switch star {
            case 1: return "<500 students"
            case 2: return "500-999 students"
            case 3: return "1,000-1,999 students"
            case 4: return "2,000-4,999 students"
            case 5: return "5,000+ students"
            default: return ""
            }
        case .staffSize:
            switch star {
            case 1: return "<50 staff"
            case 2: return "50-99 staff"
            case 3: return "100-199 staff"
            case 4: return "200-399 staff"
            case 5: return "400+ staff"
            default: return ""
            }
        case .foodService:
            switch star {
            case 1: return "Full-service cafeteria"
            case 2: return "Multiple food options"
            case 3: return "Limited food options"
            case 4: return "Basic vending only"
            case 5: return "No food service"
            default: return ""
            }
        case .vendingRestrictions:
            switch star {
            case 1: return "Many restrictions"
            case 2: return "Several restrictions"
            case 3: return "Some restrictions"
            case 4: return "Few restrictions"
            case 5: return "No restrictions"
            default: return ""
            }
        case .hoursOfOperation:
            switch star {
            case 1: return "Limited hours"
            case 2: return "Standard school hours"
            case 3: return "Extended hours"
            case 4: return "Long hours"
            case 5: return "24/7 access"
            default: return ""
            }
        case .campusLayout:
            switch star {
            case 1: return "Poor layout"
            case 2: return "Fair layout"
            case 3: return "Good layout"
            case 4: return "Very good layout"
            case 5: return "Excellent layout"
            default: return ""
            }
        }
    }
}

// MARK: - Metric Wrapper for Sheet Presentation

struct MetricWrapper: Identifiable {
    let id = UUID()
    let metricType: any ModuleMetricType
}
