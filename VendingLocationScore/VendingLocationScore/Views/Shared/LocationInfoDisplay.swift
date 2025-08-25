import SwiftUI

// MARK: - Location Info Display
struct LocationInfoDisplay: View {
    let name: String
    let address: String
    let locationType: LocationType
    let showBadge: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Location name
            Text(name)
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.primaryText)
                .lineLimit(2)
            
            // Address
            Text(address)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .lineLimit(2)
            
            // Location type badge (if enabled)
            if showBadge {
                LocationTypeBadge(locationType: locationType)
            }
        }
        // .fadeInScale(delay: 0.1) // Removed animation that was preventing text rendering
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: AppTheme.Spacing.lg) {
        LocationInfoDisplay(
            name: "Downtown Office Complex",
            address: "123 Main Street, Suite 100, Downtown, CA 90210",
            locationType: LocationType(type: .office),
            showBadge: true
        )
        
        LocationInfoDisplay(
            name: "Shopping Mall Kiosk",
            address: "456 Mall Drive, Shopping Center, CA 90211",
            locationType: LocationType(type: .residential),
            showBadge: false
        )
        
        LocationInfoDisplay(
            name: "Gas Station",
            address: "789 Highway 101, Gas Station, CA 90212",
            locationType: LocationType(type: .hospital),
            showBadge: true
        )
    }
    .padding()
}
