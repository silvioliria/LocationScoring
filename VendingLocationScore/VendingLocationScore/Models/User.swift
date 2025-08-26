import Foundation
import SwiftData
// import CloudKit  // Temporarily disabled for Personal Team development

@Model
final class User: Codable {
    var id: String
    var name: String
    var email: String
    var phone: String?
    var profileImageURL: String?
    var isAuthenticated: Bool
    var lastLoginDate: Date
    var createdAt: Date
    
    init(id: String, name: String, email: String, phone: String? = nil, profileImageURL: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.profileImageURL = profileImageURL
        self.isAuthenticated = true
        self.lastLoginDate = Date()
        self.createdAt = Date()
    }
    
    func updateLastLogin() {
        self.lastLoginDate = Date()
    }
    
    // MARK: - Codable Support
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, profileImageURL, isAuthenticated, lastLoginDate, createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
        isAuthenticated = try container.decode(Bool.self, forKey: .isAuthenticated)
        lastLoginDate = try container.decode(Date.self, forKey: .lastLoginDate)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(profileImageURL, forKey: .profileImageURL)
        try container.encode(isAuthenticated, forKey: .isAuthenticated)
        try container.encode(lastLoginDate, forKey: .lastLoginDate)
        try container.encode(createdAt, forKey: .createdAt)
    }
}

// MARK: - CloudKit Support (Temporarily disabled for Personal Team development)
/*
extension User {
    func toCKRecord() throws -> CKRecord {
        let record = CKRecord(recordType: "User")
        record["id"] = id
        record["name"] = name
        record["email"] = email
        record["phone"] = phone
        record["profileImageURL"] = profileImageURL
        record["isAuthenticated"] = isAuthenticated
        record["lastLoginDate"] = lastLoginDate
        record["createdAt"] = createdAt
        return record
    }
    
    convenience init(from record: CKRecord) throws {
        let id = record["id"] as? String ?? UUID().uuidString
        let name = record["name"] as? String ?? "Unknown User"
        let email = record["email"] as? String ?? ""
        let phone = record["phone"] as? String
        let profileImageURL = record["profileImageURL"] as? String
        let isAuthenticated = record["isAuthenticated"] as? Bool ?? false
        let lastLoginDate = record["lastLoginDate"] as? Date ?? Date()
        let createdAt = record["createdAt"] as? Date ?? Date()
        
        self.init(id: id, name: name, email: email, phone: phone, profileImageURL: profileImageURL)
        self.isAuthenticated = isAuthenticated
        self.lastLoginDate = lastLoginDate
        self.createdAt = createdAt
    }
}
*/
