import Foundation
import SwiftData

@Model
final class Scorecard: Codable {
    var id: UUID
    
    // Overall scores
    var overallScore: Double
    var generalScore: Double
    var typeSpecificScore: Double
    var financialScore: Double
    
    // Score breakdown
    var generalMetricsScore: Double
    var officeMetricsScore: Double
    var hospitalMetricsScore: Double
    var schoolMetricsScore: Double
    var residentialMetricsScore: Double
    
    // Notes and comments
    var overallNotes: String
    var generalNotes: String
    var typeSpecificNotes: String
    var financialNotes: String
    
    // Timestamps
    var lastUpdated: Date
    var createdAt: Date
    
    init() {
        self.id = UUID()
        self.overallScore = 0.0
        self.generalScore = 0.0
        self.typeSpecificScore = 0.0
        self.financialScore = 0.0
        self.generalMetricsScore = 0.0
        self.officeMetricsScore = 0.0
        self.hospitalMetricsScore = 0.0
        self.schoolMetricsScore = 0.0
        self.residentialMetricsScore = 0.0
        self.overallNotes = ""
        self.generalNotes = ""
        self.typeSpecificNotes = ""
        self.financialNotes = ""
        self.lastUpdated = Date()
        self.createdAt = Date()
    }

    // MARK: - Codable Support

    enum CodingKeys: String, CodingKey {
        case id, overallScore, generalScore, typeSpecificScore, financialScore
        case generalMetricsScore, officeMetricsScore, hospitalMetricsScore, schoolMetricsScore, residentialMetricsScore
        case overallNotes, generalNotes, typeSpecificNotes, financialNotes, lastUpdated, createdAt
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        overallScore = try container.decode(Double.self, forKey: .overallScore)
        generalScore = try container.decode(Double.self, forKey: .generalScore)
        typeSpecificScore = try container.decode(Double.self, forKey: .typeSpecificScore)
        financialScore = try container.decode(Double.self, forKey: .financialScore)
        generalMetricsScore = try container.decode(Double.self, forKey: .generalMetricsScore)
        officeMetricsScore = try container.decode(Double.self, forKey: .officeMetricsScore)
        hospitalMetricsScore = try container.decode(Double.self, forKey: .hospitalMetricsScore)
        schoolMetricsScore = try container.decode(Double.self, forKey: .schoolMetricsScore)
        residentialMetricsScore = try container.decode(Double.self, forKey: .residentialMetricsScore)
        overallNotes = try container.decode(String.self, forKey: .overallNotes)
        generalNotes = try container.decode(String.self, forKey: .generalNotes)
        typeSpecificNotes = try container.decode(String.self, forKey: .typeSpecificNotes)
        financialNotes = try container.decode(String.self, forKey: .financialNotes)
        lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(overallScore, forKey: .overallScore)
        try container.encode(generalScore, forKey: .generalScore)
        try container.encode(typeSpecificScore, forKey: .typeSpecificScore)
        try container.encode(financialScore, forKey: .financialScore)
        try container.encode(generalMetricsScore, forKey: .generalMetricsScore)
        try container.encode(officeMetricsScore, forKey: .officeMetricsScore)
        try container.encode(hospitalMetricsScore, forKey: .hospitalMetricsScore)
        try container.encode(schoolMetricsScore, forKey: .schoolMetricsScore)
        try container.encode(residentialMetricsScore, forKey: .residentialMetricsScore)
        try container.encode(overallNotes, forKey: .overallNotes)
        try container.encode(generalNotes, forKey: .generalNotes)
        try container.encode(typeSpecificNotes, forKey: .typeSpecificNotes)
        try container.encode(financialNotes, forKey: .financialNotes)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encode(createdAt, forKey: .createdAt)
    }
    
    // MARK: - Score Calculation Methods
    
    func calculateOverallScore() -> Double {
        let scores = [generalScore, typeSpecificScore, financialScore]
        let validScores = scores.filter { $0 > 0 }
        guard !validScores.isEmpty else { return 0.0 }
        
        let total = validScores.reduce(0, +)
        overallScore = total / Double(validScores.count)
        lastUpdated = Date()
        return overallScore
    }
    
    func updateGeneralScore(_ score: Double, notes: String = "") {
        self.generalScore = score
        self.generalNotes = notes
        lastUpdated = Date()
        self.overallScore = calculateOverallScore()
    }
    
    func updateTypeSpecificScore(_ score: Double, notes: String = "") {
        self.typeSpecificScore = score
        self.typeSpecificNotes = notes
        lastUpdated = Date()
        self.overallScore = calculateOverallScore()
    }
    
    func updateFinancialScore(_ score: Double, notes: String = "") {
        self.financialScore = score
        self.financialNotes = notes
        lastUpdated = Date()
        self.overallScore = calculateOverallScore()
    }
    
    func updateMetricsScore(for type: LocationTypeEnum, score: Double) {
        switch type {
        case .office:
            officeMetricsScore = score
        case .hospital:
            hospitalMetricsScore = score
        case .school:
            schoolMetricsScore = score
        case .residential:
            residentialMetricsScore = score
        }
        lastUpdated = Date()
    }
    
    // MARK: - Score Rating Methods
    
    func getOverallRating() -> String {
        switch overallScore {
        case 4.5...: return "Excellent"
        case 3.5..<4.5: return "Very Good"
        case 2.5..<3.5: return "Good"
        case 1.5..<2.5: return "Fair"
        case 0.5..<1.5: return "Poor"
        default: return "Not Rated"
        }
    }
    
    func getGeneralRating() -> String {
        switch generalScore {
        case 4.5...: return "Excellent"
        case 3.5..<4.5: return "Very Good"
        case 2.5..<3.5: return "Good"
        case 1.5..<2.5: return "Fair"
        case 0.5..<1.5: return "Poor"
        default: return "Not Rated"
        }
    }
    
    func getTypeSpecificRating() -> String {
        switch typeSpecificScore {
        case 4.5...: return "Excellent"
        case 3.5..<4.5: return "Very Good"
        case 2.5..<3.5: return "Good"
        case 1.5..<2.5: return "Fair"
        case 0.5..<1.5: return "Poor"
        default: return "Not Rated"
        }
    }
    
    func getFinancialRating() -> String {
        switch financialScore {
        case 4.5...: return "Excellent"
        case 3.5..<4.5: return "Very Good"
        case 2.5..<3.5: return "Good"
        case 1.5..<2.5: return "Fair"
        case 0.5..<1.5: return "Poor"
        default: return "Not Rated"
        }
    }
    
    // MARK: - Completion Status
    
    var isComplete: Bool {
        return generalScore > 0 && typeSpecificScore > 0 && financialScore > 0
    }
    
    var completionPercentage: Double {
        let totalScores = 3.0
        let completedScores = [generalScore, typeSpecificScore, financialScore].filter { $0 > 0 }.count
        return Double(completedScores) / totalScores * 100
    }
}
