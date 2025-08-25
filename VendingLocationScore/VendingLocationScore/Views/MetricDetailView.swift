import SwiftUI
import SwiftData

struct MetricDetailView: View {
    let location: Location
    let metricType: MetricType
    let onDataChanged: () -> Void
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    // Add centralized metric service
    @StateObject private var metricService = MetricService.shared
    
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
                        DescriptionCard(metricType: metricType)
                        
                        // Creative star-based selector
                        StarSelectorView(
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
            .navigationTitle(metricType.title)
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
    
    private func loadExistingData() {
        // Use legacy system for now (centralized system disabled temporarily)
        guard let generalMetrics = location.generalMetrics else { return }
        selectedRating = generalMetrics.getRating(for: metricType)
        notes = generalMetrics.getNotes(for: metricType)
    }
    
    // MARK: - Helper Functions for Centralized System
    
    private func getMetricKey(for metricType: MetricType) -> String {
        switch metricType {
        case .footTraffic:
            return "general_foot_traffic"
        case .targetDemographic:
            return "general_demographics"
        case .competition:
            return "general_competition"
        case .parkingTransit:
            return "general_accessibility"
        case .security:
            return "general_security"
        case .visibility:
            return "general_visibility"
        case .amenities:
            return "general_amenities"
        case .hostCommission:
            return "general_commission"
        }
    }
    
    private func saveMetric() async {
        isSaving = true
        
        do {
            // Use legacy system (centralized system disabled temporarily)
            // Ensure generalMetrics exists
            if location.generalMetrics == nil {
                location.generalMetrics = GeneralMetrics()
            }
            
            // Update the rating and notes
            location.generalMetrics?.updateRating(
                for: metricType,
                rating: selectedRating,
                notes: notes
            )
            
            // Update timestamp
            location.updatedAt = Date()
            
            // Save to context
            try context.save()
            
            // Notify that data has changed
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
            // Use legacy system (centralized system disabled temporarily)
            // Ensure generalMetrics exists
            if location.generalMetrics == nil {
                location.generalMetrics = GeneralMetrics()
            }
            
            // Update the rating and notes
            location.generalMetrics?.updateRating(
                for: metricType,
                rating: selectedRating,
                notes: notes
            )
            
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
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Supporting Views

struct HeroRatingView: View {
    let rating: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundColor(star <= rating ? .yellow : .gray.opacity(0.3))
                        .font(.system(size: 32, weight: .medium))
                        .scaleEffect(star == rating ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: rating)
                }
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct DescriptionCard: View {
    let metricType: MetricType
    
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
            
            Text(metricType.description)
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
}

struct StarSelectorView: View {
    @Binding var selectedRating: Int
    let metricType: MetricType
    
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
                    StarOptionView(
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

struct StarOptionView: View {
    let star: Int
    let isSelected: Bool
    let metricType: MetricType
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
                    Text(metricType.starDescription(for: star))
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
}

struct NotesSection: View {
    @Binding var notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.green)
                    .font(.title2)
                Text("Additional Notes")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            TextField("Add your thoughts here...", text: $notes, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
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

enum MetricType: CaseIterable, Identifiable {
    case footTraffic
    case targetDemographic
    case hostCommission
    case competition
    case visibility
    case security
    case parkingTransit
    case amenities
    
    var id: String { title }
    
    var title: String {
        switch self {
        case .footTraffic: return "Foot Traffic"
        case .targetDemographic: return "Audience Fit"
        case .hostCommission: return "Commission"
        case .competition: return "Competition"
        case .visibility: return "Visibility"
        case .security: return "Security"
        case .parkingTransit: return "Access"
        case .amenities: return "Amenities"
        }
    }
    
    var description: String {
        switch self {
        case .footTraffic: return "Direct driver of potential transactions and revenue. Higher daily foot traffic increases the likelihood of sales and overall profitability."
        case .targetDemographic: return "Matches users most likely to buy grab-and-go items. Better demographic fit means higher conversion rates and customer retention."
        case .hostCommission: return "Higher commissions compress your operating margin. Lower commission rates improve profitability and reduce payback time."
        case .competition: return "Closer/stronger alternatives reduce capture rate. Less competition means higher market share and better sales potential."
        case .visibility: return "Seen and reachable = impulsive purchases rise. Better visibility increases spontaneous buying decisions and overall sales."
        case .security: return "Reduces theft, vandalism, and chargebacks; protects uptime. Good security ensures reliable operations and protects revenue."
        case .parkingTransit: return "Easier service = lower route time and cost. Better access reduces operational expenses and improves service efficiency."
        case .amenities: return "Elevators/mailrooms/ATMs increase dwell and impulse. Adjacent amenities create natural traffic and buying opportunities."
        }
    }
    
    var pickerOptions: [String] {
        switch self {
        case .targetDemographic:
            return ["Excellent Match", "Good Match", "Fair Match", "Poor Match", "No Match"]
        default:
            return []
        }
    }
    
    func starDescription(for star: Int) -> String {
        switch self {
        case .footTraffic:
            switch star {
            case 1: return "< 100"     // Below minimum threshold
            case 2: return "100-200"   // Minimum viable
            case 3: return "200-350"   // Adequate
            case 4: return "350-500"   // Good
            case 5: return "> 500"     // Excellent
            default: return ""
            }
        case .targetDemographic:
            switch star {
            case 1: return "No Match"
            case 2: return "Poor Match"
            case 3: return "Fair Match"
            case 4: return "Good Match"
            case 5: return "Excellent Match"
            default: return ""
            }
        case .hostCommission:
            switch star {
            case 1: return "Above 20%"
            case 2: return "16-20%"
            case 3: return "11-15%"
            case 4: return "6-10%"
            case 5: return "5% or lower"
            default: return ""
            }
        case .competition:
            switch star {
            case 1: return "High competition"
            case 2: return "Moderate-high competition"
            case 3: return "Moderate competition"
            case 4: return "Low competition"
            case 5: return "Zero competition"
            default: return ""
            }
        default:
            switch star {
            case 1: return "Very Poor"
            case 2: return "Poor"
            case 3: return "Moderate"
            case 4: return "Good"
            case 5: return "Excellent"
            default: return ""
            }
        }
    }
    
    func calculateRating<T>(for value: T) -> Int {
        switch self {
        case .footTraffic:
            if let intValue = value as? Int {
                if intValue > 500 { return 5 }
                if intValue >= 350 { return 4 }
                if intValue >= 200 { return 3 }
                if intValue >= 100 { return 2 }
                if intValue >= 1 { return 1 }  // Below minimum threshold
                return 0
            }
        case .targetDemographic:
            if let stringValue = value as? String {
                switch stringValue {
                case "Excellent Match": return 5
                case "Good Match": return 4
                case "Fair Match": return 3
                case "Poor Match": return 2
                case "No Match": return 1
                default: return 0
                }
            }
        case .hostCommission:
            if let doubleValue = value as? Double {
                if doubleValue <= 5 { return 5 }
                if doubleValue <= 10 { return 4 }
                if doubleValue <= 15 { return 3 }
                if doubleValue <= 20 { return 2 }
                return 1
            }
        default:
            if let stringValue = value as? String {
                let lowercased = stringValue.lowercased()
                if lowercased.contains("excellent") || lowercased.contains("high") || lowercased.contains("plenty") { return 5 }
                if lowercased.contains("good") || lowercased.contains("adequate") { return 4 }
                if lowercased.contains("moderate") { return 3 }
                if lowercased.contains("poor") || lowercased.contains("low") || lowercased.contains("limited") { return 2 }
                if lowercased.contains("very poor") || lowercased.contains("none") || lowercased.contains("hidden") || lowercased.contains("unsafe") { return 1 }
                return 3
            }
        }
        return 1
    }
}

#Preview {
    let locationType = LocationType(type: .office)
    let location = Location(name: "Sample Office", address: "123 Main St", comment: "Test location", locationType: locationType)
    
    // Set up the location
    location.generalMetrics = GeneralMetrics()
    
    return MetricDetailView(location: location, metricType: .footTraffic, onDataChanged: {})
}
