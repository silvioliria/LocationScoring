import SwiftUI
import SwiftData

struct LocationEvaluationView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let location: Location
    @State private var selectedTab = 0
    @State private var refreshTrigger = UUID() // Triggers view refresh
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                DashboardView(location: location, selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "gauge")
                        Text("Dashboard")
                    }
                    .tag(0)
                    .id(refreshTrigger) // Forces refresh when data changes
                
                GeneralMetricsView(location: location, onDataChanged: refreshData)
                    .tabItem {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Metrics")
                    }
                    .tag(1)
                    .id(refreshTrigger) // Forces refresh when data changes
                
                // Module-specific metrics tab
                moduleMetricsTab
                    .tag(2)
                    .id(refreshTrigger) // Forces refresh when data changes
                
                FinancialsView(location: location, onDataChanged: refreshData)
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Financials")
                    }
                    .tag(3)
                    .id(refreshTrigger) // Forces refresh when data changes
            }
            .navigationTitle(location.name)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                setupTabBarAppearance()
            }
        }
    }
    
    @ViewBuilder
    private var moduleMetricsTab: some View {
        switch location.locationType.type {
        case .office:
            OfficeMetricsView(location: location, onDataChanged: refreshData)
                .tabItem {
                    Image(systemName: location.locationType.type.icon)
                    Text("Office Metrics")
                }
        case .hospital:
            HospitalMetricsView(location: location, onDataChanged: refreshData)
                .tabItem {
                    Image(systemName: location.locationType.type.icon)
                    Text("Hospital Metrics")
                }
        case .school:
            SchoolMetricsView(location: location, onDataChanged: refreshData)
                .tabItem {
                    Image(systemName: location.locationType.type.icon)
                    Text("School Metrics")
                }
        case .residential:
            ResidentialMetricsView(location: location, onDataChanged: refreshData)
                .tabItem {
                    Image(systemName: location.locationType.type.icon)
                    Text("Residential Metrics")
                }
        }
    }
    
    private func refreshData() {
        // Trigger a refresh of all tabs
        refreshTrigger = UUID()
    }
    
    private func saveChanges() {
        location.updatedAt = Date()
        do {
            try context.save()
            // Could add a success indicator here if desired
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // Set the border color (line at top of tab bar)
        appearance.shadowColor = UIColor.separator
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    let context = try! ModelContainer(for: Location.self, LocationType.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self).mainContext
    
    let locationType = LocationType(type: .office)
    let location = Location(name: "Sample Office", address: "123 Main St", comment: "Test location", locationType: locationType)
    
    // Set up the location outside the ViewBuilder
    let generalMetrics = GeneralMetrics()
    let financials = Financials()
    let scorecard = Scorecard()
    
    location.generalMetrics = generalMetrics
    location.financials = financials
    location.scorecard = scorecard
    
    // Insert into context outside the ViewBuilder
    context.insert(location)
    
    return LocationEvaluationView(location: location)
}
