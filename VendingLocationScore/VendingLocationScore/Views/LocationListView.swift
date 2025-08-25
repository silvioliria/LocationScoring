import SwiftUI
import SwiftData

struct LocationListView: View {
    @Environment(\.modelContext) private var context
    @State private var dataService = DataManagementServiceFactory.createDataManagementService()
    @State private var locations: [Location] = []
    @State private var showingCreateLocation = false
    @State private var showingDeleteAlert = false
    @State private var locationToDelete: Location?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading locations...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if locations.isEmpty {
                    EmptyStateView.locationsEmptyState {
                        showingCreateLocation = true
                    }
                } else {
                    List {
                        ForEach(locations) { location in
                            ListRowContainer(destination: LocationEvaluationView(location: location)) {
                                LocationRowView(location: location)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                            }
                        }
                        .onDelete(perform: deleteLocations)
                    }
                    .listStyle(PlainListStyle())
                    .environment(\.defaultMinListRowHeight, 80)
                }
            }
            .navigationTitle("Locations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateLocation = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        refreshData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    // Show storage type indicator
                    HStack {
                        Image(systemName: "iphone")
                            .foregroundColor(.blue)
                        Text("Local")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingCreateLocation) {
                CreateLocationView(onLocationCreated: { location in
                    // Refresh the data after creating a new location
                    print("🔍 Location created callback triggered for: \(location.name)")
                    print("🔍 Location ID: \(location.id)")
                    print("🔍 Location type: \(location.locationType.type)")
                    print("🔍 About to call refreshData()")
                    
                    // Force a refresh and ensure we're on the main thread
                    DispatchQueue.main.async {
                        print("🔍 Calling refreshData() from main thread")
                        refreshData()
                    }
                })
            }
            .alert("Delete Location", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let location = locationToDelete {
                        Task {
                            await deleteLocation(location)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this location? This action cannot be undone.")
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
            .onAppear {
                // Set the context in the data service
                if let localDataService = dataService as? LocalDataService {
                    localDataService.setContext(context)
                }
                refreshData()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // Refresh data when app comes to foreground
                refreshData()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Refresh data when app becomes active
                refreshData()
            }
            .refreshable {
                refreshData()
            }
        }
    }
    
    // MARK: - Data Operations
    
    private func refreshData() {
        print("🔍 Starting data refresh...")
        print("🔍 Current locations count: \(locations.count)")
        
        Task {
            do {
                let fetchedLocations = try await dataService.fetchLocations()
                print("🔍 Raw fetch result count: \(fetchedLocations.count)")
                
                // Print details of each fetched location
                for (index, location) in fetchedLocations.enumerated() {
                    print("🔍 Fetched location \(index): \(location.name) (ID: \(location.id), Type: \(location.locationType.type))")
                }
                
                // Update the state on the main thread
                await MainActor.run {
                    print("🔍 Updating UI with \(fetchedLocations.count) locations")
                    self.locations = fetchedLocations
                    print("🔍 Data refresh completed, locations count: \(self.locations.count)")
                    for location in self.locations {
                        print("🔍 - Location: \(location.name) (ID: \(location.id))")
                    }
                }
            } catch {
                print("🔍 Error fetching locations: \(error)")
                print("🔍 Error details: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func deleteLocations(offsets: IndexSet) {
        for index in offsets {
            locationToDelete = locations[index]
            showingDeleteAlert = true
        }
    }
    
    private func deleteLocation(_ location: Location) async {
        do {
            try await dataService.deleteLocation(location)
            refreshData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Location Row View
struct LocationRowView: View {
    let location: Location
    @State private var currentScore: Double = 0.0
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Left side - Location details (vertically distributed)
            LocationInfoDisplay(
                name: location.name,
                address: location.address,
                locationType: location.locationType,
                showBadge: true
            )
            
            Spacer()
            
            // Right side - Score gauge (vertically centered)
            CompactScoreGauge(
                score: currentScore,
                maxScore: 5.0
            )
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onAppear {
            // Refresh score when row appears
            updateScore()
        }
        .onChange(of: location) { _, newLocation in
            // Update score when location data changes
            updateScore()
        }
    }
    
    private func updateScore() {
        // Calculate and update the current score
        currentScore = location.calculateOverallScore()
    }
}

// MARK: - Location Type Badge
struct LocationTypeBadge: View {
    let locationType: LocationType
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: locationType.type.icon)
                .font(.caption2)
            Text(locationType.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch locationType.type {
        case .office:
            return .blue
        case .hospital:
            return .red
        case .school:
            return .green
        case .residential:
            return .purple
        }
    }
}

#Preview {
    LocationListView()
}


