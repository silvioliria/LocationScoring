import SwiftUI
import SwiftData

@main
struct PerkPointLocationEvaluatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Location.self,
            LocationType.self,
            OfficeMetrics.self,
            HospitalMetrics.self,
            SchoolMetrics.self,
            ResidentialMetrics.self,
            GeneralMetrics.self,
            Financials.self,
            Scorecard.self,
            User.self,
            // Centralized metrics system models
            MetricDefinition.self,
            MetricInstance.self,
            LocationMetrics.self
        ])
    }
}
