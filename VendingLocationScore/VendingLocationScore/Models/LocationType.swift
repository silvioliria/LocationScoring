import Foundation
import SwiftData
// import CloudKit  // Temporarily disabled for Personal Team development

@Model
final class LocationType {
    var type: LocationTypeEnum
    var displayName: String
    
    init(type: LocationTypeEnum, displayName: String? = nil) {
        self.type = type
        self.displayName = displayName ?? type.displayName
    }
}

// MARK: - Location Type Enum
enum LocationTypeEnum: String, CaseIterable, Codable {
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
}
