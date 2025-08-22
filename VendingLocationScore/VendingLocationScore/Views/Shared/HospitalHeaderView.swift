import SwiftUI

struct HospitalHeaderView: View {
    let location: Location
    
    var body: some View {
        HStack(spacing: 16) {
            // Module Icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "cross.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Hospital")
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
        if let hospitalMetrics = location.hospitalMetrics {
            return hospitalMetrics.calculateOverallScore()
        }
        return 0.0
    }
}

#Preview {
    let locationType = LocationType(type: .hospital)
    let location = Location(name: "Sample Hospital", address: "123 Medical Dr", comment: "Sample", locationType: locationType)
    // Note: moduleDetails is now computed from locationType in the new architecture
    
    HospitalHeaderView(location: location)
        .padding()
}
