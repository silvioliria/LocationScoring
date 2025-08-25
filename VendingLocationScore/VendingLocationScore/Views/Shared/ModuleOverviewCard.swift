import SwiftUI

struct ModuleOverviewCard: View {
    let location: Location
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Module Icon
                ZStack {
                    Circle()
                        .fill(moduleColor.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: moduleIcon)
                        .font(.title2)
                        .foregroundColor(moduleColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.locationType.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Module Type")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Module Score
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", getModuleSpecificScore()))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(scoreColor)
                    
                    Text("/ 5.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private var moduleColor: Color {
        switch location.locationType.type {
        case .office: return .blue
        case .hospital: return .red
        case .school: return .green
        case .residential: return .purple
        }
    }
    
    private var moduleIcon: String {
        switch location.locationType.type {
        case .office: return "building.2"
        case .hospital: return "cross.case"
        case .school: return "graduationcap"
        case .residential: return "house"
        }
    }
    
    private var scoreColor: Color {
        let score = getModuleSpecificScore()
        return ScoreColorUtility.getScoreColor(score)
    }
    
    private func getModuleSpecificScore() -> Double {
        switch location.locationType.type {
        case .office:
            guard let metrics = location.officeMetrics else { return 0.0 }
            let ratings = [
                metrics.commonAreasRating,
                metrics.hoursAccessRating,
                metrics.tenantAmenitiesRating,
                metrics.proximityHubTransitRating,
                metrics.brandingRestrictionsRating,
                metrics.layoutTypeRating
            ]
            let ratedMetrics = ratings.filter { $0 > 0 }
            return ratedMetrics.isEmpty ? 0.0 : Double(ratedMetrics.reduce(0, +)) / Double(ratedMetrics.count)
            
        case .hospital:
            guard let metrics = location.hospitalMetrics else { return 0.0 }
            let ratings = [
                metrics.patientVolumeRating,
                metrics.staffSizeRating,
                metrics.visitorTrafficRating,
                metrics.foodServiceRating,
                metrics.vendingRestrictionsRating,
                metrics.hoursOfOperationRating
            ]
            let ratedMetrics = ratings.filter { $0 > 0 }
            return ratedMetrics.isEmpty ? 0.0 : Double(ratedMetrics.reduce(0, +)) / Double(ratedMetrics.count)
            
        case .school:
            guard let metrics = location.schoolMetrics else { return 0.0 }
            let ratings = [
                metrics.studentPopulationRating,
                metrics.staffSizeRating,
                metrics.foodServiceRating,
                metrics.vendingRestrictionsRating,
                metrics.hoursOfOperationRating,
                metrics.campusLayoutRating
            ]
            let ratedMetrics = ratings.filter { $0 > 0 }
            return ratedMetrics.isEmpty ? 0.0 : Double(ratedMetrics.reduce(0, +)) / Double(ratedMetrics.count)
            
        case .residential:
            guard let metrics = location.residentialMetrics else { return 0.0 }
            let ratings = [
                metrics.unitCountRating,
                metrics.occupancyRateRating,
                metrics.demographicRating,
                metrics.foodServiceRating,
                metrics.vendingRestrictionsRating,
                metrics.hoursOfOperationRating,
                metrics.buildingLayoutRating
            ]
            let ratedMetrics = ratings.filter { $0 > 0 }
            return ratedMetrics.isEmpty ? 0.0 : Double(ratedMetrics.reduce(0, +)) / Double(ratedMetrics.count)
        }
    }
}
