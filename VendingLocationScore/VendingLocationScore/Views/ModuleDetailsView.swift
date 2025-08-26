import SwiftUI
import SwiftData

struct ModuleDetailsView: View {
    let location: Location
    let onDataChanged: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: horizontalSizeClass == .compact ? 20 : 24) {
                // Module Metrics Display (this includes the header for Office)
                ModuleMetricsSection(location: location, onDataChanged: onDataChanged)
                
                // Module Specific Fields
                ModuleSpecificFields(location: location, onDataChanged: onDataChanged)
                
                // Bottom spacing
                Spacer(minLength: 20)
            }
            .padding(.horizontal, horizontalSizeClass == .compact ? 16 : 24)
            .padding(.top, horizontalSizeClass == .compact ? 16 : 24)
        }
        .navigationTitle("\(location.locationType.displayName) Details")
        .background(Color(.systemGroupedBackground))
        .onTapGesture {
            hideKeyboard()
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 50 {
                        hideKeyboard()
                    }
                }
        )
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ModuleDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = try! ModelContainer(for: Location.self, LocationType.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self, MetricDefinition.self, MetricInstance.self, LocationMetrics.self).mainContext
        
        let locationType = LocationType(type: .residential)
        let location = Location(name: "Sample Residential", address: "123 Home St", comment: "Test residential location", locationType: locationType)
        
        // Set up the location
        location.generalMetrics = GeneralMetrics()
        location.financials = Financials()
        location.scorecard = Scorecard()
        
        // Insert into context
        context.insert(location)
        
        return ModuleDetailsView(location: location, onDataChanged: {})
            .environmentObject(SharedModelContext.shared)
    }
}
