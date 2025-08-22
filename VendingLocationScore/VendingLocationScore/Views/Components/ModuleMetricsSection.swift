import SwiftUI

// Main metrics section coordinator (Updated to use dedicated views)
struct ModuleMetricsSection: View {
    let location: Location
    let onDataChanged: () -> Void
    
    var body: some View {
        switch location.locationType.type {
        case .residential:
            ResidentialMetricsView(location: location, onDataChanged: onDataChanged)
        case .office:
            OfficeMetricsView(location: location, onDataChanged: onDataChanged)
        case .hospital:
            HospitalMetricsView(location: location, onDataChanged: onDataChanged)
        case .school:
            SchoolMetricsView(location: location, onDataChanged: onDataChanged)
        }
    }
}
