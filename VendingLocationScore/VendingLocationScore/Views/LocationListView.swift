import SwiftUI
import SwiftData

struct LocationListView: View {
    @Environment(\.modelContext) private var context
    @State private var lazyLoadingService: LazyLoadingService<Location, LocationRepository>?
    @StateObject private var memoryMonitor = MemoryMonitor()
    @State private var showingCreateLocation = false
    @State private var showingDeleteAlert = false
    @State private var locationToDelete: Location?
    
    init() {
        // Initialize without the service - will be created when context is available
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Content
                if let service = lazyLoadingService {
                    if service.items.isEmpty && !service.isLoading {
                        emptyStateView
                    } else {
                        locationList
                    }
                    
                    // Loading Indicator
                    if service.isLoading {
                        loadingIndicator
                    }
                    
                    // Error View
                    if let errorMessage = service.errorMessage {
                        errorView(message: errorMessage)
                    }
                } else {
                    // Service not initialized yet
                    ProgressView("Initializing...")
                }
            }
            .navigationTitle("Locations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            showingCreateLocation = true
                        }) {
                            Image(systemName: "plus")
                        }
                        
                        Button(action: {
                            Task {
                                await lazyLoadingService?.refresh()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
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
                CreateLocationView(
                    onLocationCreated: { location in
                        // Immediately add the new location and refresh in background
                        print("📍 Location created: \(location.name)")
                        print("📍 About to add item and refresh LazyLoadingService")
                        print("📍 Service exists: \(lazyLoadingService != nil)")
                        
                        // Immediately add the new location to the list for instant feedback
                        lazyLoadingService?.addItem(location)
                        print("📍 Location added to list, items count: \(lazyLoadingService?.items.count ?? 0)")
                    },
                    modelContext: context
                )
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
            .onAppear {
                // Create the service if it doesn't exist
                if lazyLoadingService == nil {
                    createLazyLoadingService()
                }
                
                // Start memory monitoring
                memoryMonitor.startMonitoring()
                
                Task {
                    await lazyLoadingService?.refresh()
                }
            }
            .onDisappear {
                // Stop memory monitoring when view disappears
                memoryMonitor.stopMonitoring()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // Refresh data when app comes to foreground
                Task {
                    await lazyLoadingService?.refresh()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Refresh data when app becomes active
                Task {
                    await lazyLoadingService?.refresh()
                }
            }
            .refreshable {
                await lazyLoadingService?.refresh()
            }
        }
    }
    
    // MARK: - Location List
    private var locationList: some View {
        Group {
            if let service = lazyLoadingService {
                List {
                    ForEach(service.items, id: \.id) { location in
                        NavigationLink(destination: LocationEvaluationView(location: location)) {
                            LocationRowView(location: location)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            // Load more items when approaching the end
                            Task {
                                await service.loadMoreIfNeeded(currentItem: location)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", role: .destructive) {
                                locationToDelete = location
                                showingDeleteAlert = true
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                EmptyView()
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Locations Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create your first location to get started")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create Location") {
                showingCreateLocation = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Loading Indicator
    private var loadingIndicator: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading...")
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.red)
            
            Text("Error")
                .font(.headline)
            
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                Task {
                    await lazyLoadingService?.refresh()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .padding()
    }
    
    // MARK: - Setup Methods
    
    private func createLazyLoadingService() {
        print("🔧 Creating LazyLoadingService...")
        let locationRepository = LocationRepository(context: context)
        print("🔧 LocationRepository created with context: \(context)")
        
        lazyLoadingService = LazyLoadingService<Location, LocationRepository>(
            repository: locationRepository,
            config: .default,
            sortBy: [SortDescriptor(\.name, order: .forward)] // Default sort by name
        )
        print("🔧 LazyLoadingService created: \(lazyLoadingService != nil)")
    }
    
    // MARK: - Data Operations
    
    private func deleteLocation(_ location: Location) async {
        do {
            let locationRepository = LocationRepository(context: context)
            try await locationRepository.delete(location)
            
            // Refresh the data
            await lazyLoadingService?.refresh()
            
        } catch {
            print("❌ Error deleting location: \(error)")
        }
    }
}

// Note: MockRepository is no longer needed as we use LocationRepository from the start

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


