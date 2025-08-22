import SwiftUI

struct ResidentialHeaderView: View {
    let location: Location
    
    var body: some View {
        HStack(spacing: 16) {
            // Module Icon
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "house.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Residential")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Module Type")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Score Display
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.1f", getModuleSpecificScore()))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("/ 5.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
    private func getModuleSpecificScore() -> Double {
        // Calculate score from new architecture
        if let residentialMetrics = location.residentialMetrics {
            return residentialMetrics.calculateOverallScore()
        }
        return 0.0
    }
}

#Preview {
    let locationType = LocationType(type: .residential)
    let location = Location(name: "Sample Residential", address: "123 Home Ave", comment: "Sample", locationType: locationType)
    // Note: moduleDetails is now computed from locationType in the new architecture
    
    ResidentialHeaderView(location: location)
        .padding()
}
