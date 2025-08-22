import SwiftUI
import SwiftData

struct ModuleMetricsView: View {
    let location: Location
    let onDataChanged: () -> Void
    
    var body: some View {
        ModuleDetailsView(location: location, onDataChanged: onDataChanged)
    }
}

struct ModuleMetricsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = try! ModelContainer(for: Location.self, LocationType.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self).mainContext
        
        let locationType = LocationType(type: .office)
        let location = Location(name: "Sample Office", address: "123 Main St", comment: "Test location", locationType: locationType)
        
        // Set up the location
        let generalMetrics = GeneralMetrics()
        let financials = Financials()
        let scorecard = Scorecard()
        
        location.generalMetrics = generalMetrics
        location.financials = financials
        location.scorecard = scorecard
        
        // Insert into context
        context.insert(location)
        
        return ModuleMetricsView(location: location, onDataChanged: {})
            .modelContainer(context.container)
    }
}
