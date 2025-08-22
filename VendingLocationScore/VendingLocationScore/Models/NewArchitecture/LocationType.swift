import Foundation
import SwiftData
// import CloudKit  // Temporarily disabled for Personal Team development

@Model
final class LocationType: Codable {
    var type: LocationTypeEnum
    var displayName: String
    
    init(type: LocationTypeEnum, displayName: String? = nil) {
        self.type = type
        self.displayName = displayName ?? type.displayName
    }
    
    // MARK: - Codable Support
    
    enum CodingKeys: String, CodingKey {
        case type, displayName
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(LocationTypeEnum.self, forKey: .type)
        displayName = try container.decode(String.self, forKey: .displayName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(displayName, forKey: .displayName)
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
