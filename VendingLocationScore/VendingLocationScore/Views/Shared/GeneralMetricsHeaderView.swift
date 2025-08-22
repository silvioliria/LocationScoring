import SwiftUI
import SwiftData

struct GeneralMetricsHeaderView: View {
    let location: Location
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced icon with background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.2), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("General Metrics")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Evaluate location fundamentals")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            Spacer()
            
            // Decorative element
            Image(systemName: "sparkles")
                .foregroundColor(.orange)
                .font(.title3)
                .opacity(0.7)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemGray6).opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}



struct GeneralMetricsHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let context = try! ModelContainer(for: Location.self, LocationType.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self).mainContext
        
        let locationType = LocationType(type: .office)
        let location = Location(name: "Sample Office", address: "123 Main St", comment: "Test location", locationType: locationType)
        
        // Set up the location
        let generalMetrics = GeneralMetrics()
        location.generalMetrics = generalMetrics
        
        // Insert into context
        context.insert(location)
        
        return GeneralMetricsHeaderView(location: location)
            .modelContainer(context.container)
    }
}
