import SwiftUI

struct LocationListView: View {
    @State private var locations: [Location] = []
    @State private var showingCreateLocation = false
    @State private var showingDeleteAlert = false
    @State private var locationToDelete: Location?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @StateObject private var storageService: LocalStorageService
    
    init() {
        self._storageService = StateObject(wrappedValue: LocalStorageService.shared)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading locations...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if locations.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Locations Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Create your first location to get started")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showingCreateLocation = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create Location")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(locations) { location in
                            NavigationLink(destination: LocationEvaluationView(location: location)) {
                                LocationRowView(location: location)
                            }
                        }
                        .onDelete(perform: deleteLocations)
                    }
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
                        Task {
                            await refreshData()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    // Show storage type indicator
                    HStack {
                        Image(systemName: storageService is LocalStorageService ? "iphone" : "icloud")
                            .foregroundColor(storageService is LocalStorageService ? .blue : .green)
                        Text(storageService is LocalStorageService ? "Local" : "iCloud")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingCreateLocation) {
                CreateLocationView(onLocationCreated: { location in
                    Task {
                        await refreshData()
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
            .onAppear {
                Task {
                    await refreshData()
                }
            }
            .refreshable {
                await refreshData()
            }
        }
    }
    
    // MARK: - Data Operations
    
    private func refreshData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            locations = try await storageService.fetchLocations()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func deleteLocations(offsets: IndexSet) {
        for index in offsets {
            locationToDelete = locations[index]
            showingDeleteAlert = true
        }
    }
    
    private func deleteLocation(_ location: Location) async {
        do {
            try await storageService.deleteLocation(location)
            await refreshData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Location Row View
struct LocationRowView: View {
    let location: Location
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(location.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                LocationTypeBadge(locationType: location.locationType)
            }
            
            Text(location.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !location.comment.isEmpty {
                Text(location.comment)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            HStack {
                Text("Created: \(formatDate(location.createdAt))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Type: \(location.locationType.displayName)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
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


