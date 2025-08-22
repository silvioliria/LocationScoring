import SwiftUI
import SwiftData

struct ModuleMetricDetailView: View {
    let location: Location
    let metricType: any ModuleMetricType
    let onDataChanged: () -> Void
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var notes: String = ""
    @State private var selectedRating: Int = 1
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var autoSaveTask: Task<Void, Never>?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Creative gradient background
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Description card
                        ModuleDescriptionCard(metricType: metricType)
                        
                        // Creative star-based selector
                        ModuleStarSelectorView(
                            selectedRating: $selectedRating,
                            metricType: metricType
                        )
                        .onChange(of: selectedRating) { _, newValue in
                            // Cancel previous auto-save task
                            autoSaveTask?.cancel()
                            // Start new auto-save task with delay
                            autoSaveTask = Task {
                                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                                if !Task.isCancelled {
                                    await autoSaveMetric()
                                }
                            }
                        }
                        
                        // Notes section
                        NotesSection(notes: $notes)
                            .onChange(of: notes) { _, newValue in
                                // Cancel previous auto-save task
                                autoSaveTask?.cancel()
                                // Start new auto-save task with delay
                                autoSaveTask = Task {
                                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay for notes
                                    if !Task.isCancelled {
                                        await autoSaveMetric()
                                    }
                                }
                            }
                        
                        // Bottom spacing
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle(getMetricTitle())
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveMetric()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(isSaving)
                }
            }
            .onAppear {
                loadExistingData()
            }
            .onDisappear {
                autoSaveTask?.cancel()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                    .fontWeight(.semibold)
                }
            }
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
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func getMetricTitle() -> String {
        switch metricType {
        case let residentialMetric as ResidentialMetricType:
            return residentialMetric.title
        case let officeMetric as OfficeMetricType:
            return officeMetric.title
        case let hospitalMetric as HospitalMetricType:
            return hospitalMetric.title
        case let schoolMetric as SchoolMetricType:
            return schoolMetric.title
        default:
            return "Metric"
        }
    }
    
    private func loadExistingData() {
        // Load existing data from the specific metric being edited
        switch metricType {
        case let officeMetric as OfficeMetricType:
            if let officeMetrics = location.getOfficeMetrics() {
                let metric = officeMetrics.getMetric(metricType: officeMetric)
                selectedRating = metric.rating
                notes = metric.notes
            }
        case let hospitalMetric as HospitalMetricType:
            if let hospitalMetrics = location.getHospitalMetrics() {
                let metric = hospitalMetrics.getMetric(metricType: hospitalMetric)
                selectedRating = metric.rating
                notes = metric.notes
            }
        case let schoolMetric as SchoolMetricType:
            if let schoolMetrics = location.getSchoolMetrics() {
                let metric = schoolMetrics.getMetric(metricType: schoolMetric)
                selectedRating = metric.rating
                notes = metric.notes
            }
        case let residentialMetric as ResidentialMetricType:
            if let residentialMetrics = location.getResidentialMetrics() {
                let metric = residentialMetrics.getMetric(metricType: residentialMetric)
                selectedRating = metric.rating
                notes = metric.notes
            }
        default:
            selectedRating = 1
            notes = ""
        }
    }
    
    private func saveMetric() async {
        isSaving = true
        
        do {
            // Update the rating and notes in the new architecture
            updateMetricInNewArchitecture(rating: selectedRating, notes: notes)
            
            // Update timestamp
            location.updatedAt = Date()
            
            // Save to context
            try context.save()
            
            // Notify that data has changed (this will refresh parent views)
            // Only call this for manual saves, not auto-saves
            onDataChanged()
            
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to save: \(error.localizedDescription)"
                showError = true
            }
        }
        
        await MainActor.run {
            isSaving = false
        }
    }
    
    private func autoSaveMetric() async {
        await MainActor.run {
            isSaving = true
        }
        
        do {
            // Update the rating and notes in the new architecture
            updateMetricInNewArchitecture(rating: selectedRating, notes: notes)
            
            // Update timestamp
            location.updatedAt = Date()
            
            // Save to context
            try context.save()
            
            // Don't call onDataChanged() here to prevent popup from closing
            // The data is saved to the context, so other views will see the changes
            // when they refresh naturally
            
        } catch {
            await MainActor.run {
                errorMessage = "Failed to auto-save: \(error.localizedDescription)"
                showError = true
            }
        }
        
        await MainActor.run {
            isSaving = false
        }
    }
    
    private func updateMetricInNewArchitecture(rating: Int, notes: String) {
        // Update the specific metric based on its type
        switch metricType {
        case let officeMetric as OfficeMetricType:
            if let officeMetrics = location.getOfficeMetrics() {
                officeMetrics.updateMetric(metricType: officeMetric, rating: rating, notes: notes)
            }
        case let hospitalMetric as HospitalMetricType:
            if let hospitalMetrics = location.getHospitalMetrics() {
                hospitalMetrics.updateMetric(metricType: hospitalMetric, rating: rating, notes: notes)
            }
        case let schoolMetric as SchoolMetricType:
            if let schoolMetrics = location.getSchoolMetrics() {
                schoolMetrics.updateMetric(metricType: schoolMetric, rating: rating, notes: notes)
            }
        case let residentialMetric as ResidentialMetricType:
            if let residentialMetrics = location.getResidentialMetrics() {
                residentialMetrics.updateMetric(metricType: residentialMetric, rating: rating, notes: notes)
            }
        default:
            break
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Supporting Views

struct ModuleDescriptionCard: View {
    let metricType: any ModuleMetricType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("About this metric")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(getMetricDescription())
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    private func getMetricDescription() -> String {
        switch metricType {
        case let residentialMetric as ResidentialMetricType:
            return residentialMetric.description
        case let officeMetric as OfficeMetricType:
            return officeMetric.description
        case let hospitalMetric as HospitalMetricType:
            return hospitalMetric.description
        case let schoolMetric as SchoolMetricType:
            return schoolMetric.description
        default:
            return "This metric helps evaluate the location's suitability for vending operations."
        }
    }
}

struct ModuleStarSelectorView: View {
    @Binding var selectedRating: Int
    let metricType: any ModuleMetricType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("Select Rating")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    ModuleStarOptionView(
                        star: star,
                        isSelected: star == selectedRating,
                        metricType: metricType
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedRating = star
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

struct ModuleStarOptionView: View {
    let star: Int
    let isSelected: Bool
    let metricType: any ModuleMetricType
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Star icon
                Image(systemName: star <= (isSelected ? star : 0) ? "star.fill" : "star")
                    .foregroundColor(isSelected ? .yellow : .gray.opacity(0.4))
                    .font(.system(size: 24, weight: .medium))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? .yellow.opacity(0.2) : .clear)
                    )
                
                // Rating description
                VStack(alignment: .leading, spacing: 4) {
                    Text(getStarDescription(for: star))
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .primary : .secondary)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getStarDescription(for star: Int) -> String {
        switch metricType {
        case let residentialMetric as ResidentialMetricType:
            return residentialMetric.starDescription(for: star)
        case let officeMetric as OfficeMetricType:
            return officeMetric.starDescription(for: star)
        case let hospitalMetric as HospitalMetricType:
            return hospitalMetric.starDescription(for: star)
        case let schoolMetric as SchoolMetricType:
            return schoolMetric.starDescription(for: star)
        default:
            // Return just star number for unknown metric types
            return "\(star) stars"
        }
    }
}



struct ModuleMetricDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = try! ModelContainer(for: Location.self, LocationType.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self).mainContext
        
        let locationType = LocationType(type: .office)
        let location = Location(name: "Sample Office", address: "123 Main St", comment: "Test office location", locationType: locationType)
        
        // Set up the location
        location.generalMetrics = GeneralMetrics()
        location.financials = Financials()
        location.scorecard = Scorecard()
        
        // Insert into context
        context.insert(location)
        
        return ModuleMetricDetailView(location: location, metricType: OfficeMetricType.commonAreas, onDataChanged: {})
            .modelContainer(context.container)
    }
}
