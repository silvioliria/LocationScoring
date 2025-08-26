import SwiftUI
import SwiftData

/// Modern metrics view using the centralized metric system
struct CentralizedMetricsView: View {
    let location: Location
    let onDataChanged: () -> Void
    
    @Environment(\.modelContext) private var context
    @StateObject private var metricService = MetricService.shared
    
    @State private var metricsByCategory: [MetricCategory: [CombinedMetric]] = [:]
    @State private var selectedMetric: CombinedMetric?
    @State private var overallScore: Double = 0.0
    @State private var completionPercentage: Double = 0.0
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Loading metrics...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Overall Score Widget
                            OverallScoreWidget(
                                score: overallScore,
                                completionPercentage: completionPercentage,
                                location: location
                            )
                            
                            // Metrics by Category
                            ForEach(Array(metricsByCategory.keys.sorted(by: { $0.displayName < $1.displayName })), id: \.self) { category in
                                CategorySection(
                                    category: category,
                                    metrics: metricsByCategory[category] ?? [],
                                    onMetricTap: { metric in
                                        selectedMetric = metric
                                    }
                                )
                            }
                            
                            // Bottom spacing
                            Spacer(minLength: 20)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle(location.name)
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadMetrics()
            }
            .task {
                await loadMetrics()
            }
            .sheet(item: $selectedMetric) { metric in
                CentralizedMetricDetailView(
                    location: location,
                    metric: metric,
                    onSave: { rating, notes in
                        Task {
                            await saveMetric(metric: metric, rating: rating, notes: notes)
                        }
                    }
                )
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    @MainActor
    private func loadMetrics() async {
        isLoading = true
        
        do {
            // Get metrics by category
            metricsByCategory = try metricService.getMetricsByCategory(for: location, context: context)
            
            // Calculate scores
            overallScore = try metricService.calculateOverallScore(for: location, context: context)
            completionPercentage = try metricService.getCompletionPercentage(for: location, context: context)
            
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func saveMetric(metric: CombinedMetric, rating: Int, notes: String) async {
        do {
            try metricService.updateMetric(
                for: location,
                metricKey: metric.definition.key,
                rating: rating,
                notes: notes,
                context: context
            )
            
            await loadMetrics()
            onDataChanged()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}

/// Widget showing overall score and completion
struct OverallScoreWidget: View {
    let score: Double
    let completionPercentage: Double
    let location: Location
    
    private var normalizedScore: Double {
        score / 5.0
    }
    
    private var scoreColor: Color {
        switch score {
        case 0: return .gray
        case 0..<2: return .red
        case 2..<3: return .orange
        case 3..<4: return .yellow
        case 4..<5: return .green
        default: return .blue
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                // Score Gauge
                ReusableGaugeView(
                    score: score,
                    maxScore: 5.0,
                    size: .medium,
                    showBackground: true,
                    animate: true
                )
                
                Spacer()
                
                // Score Info
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Overall Score")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if score > 0 {
                        Text(String(format: "%.1f/5.0", score))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(scoreColor)
                    } else {
                        Text("Not rated")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(Int(completionPercentage))% Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            ProgressView(value: completionPercentage, total: 100) {
                HStack {
                    Text("Completion Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(completionPercentage))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            .progressViewStyle(LinearProgressViewStyle(tint: scoreColor))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

/// Section for a category of metrics
struct CategorySection: View {
    let category: MetricCategory
    let metrics: [CombinedMetric]
    let onMetricTap: (CombinedMetric) -> Void
    
    private var categoryScore: Double {
        let ratedMetrics = metrics.filter { $0.isRated }
        guard !ratedMetrics.isEmpty else { return 0.0 }
        
        let totalScore = ratedMetrics.reduce(0.0) { sum, metric in
            sum + Double(metric.rating)
        }
        
        return totalScore / Double(ratedMetrics.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category Header
            CategoryHeader(category: category, score: categoryScore)
            
            // Metrics List
            LazyVStack(spacing: 12) {
                ForEach(metrics) { metric in
                    MetricRowCard(metric: metric) {
                        onMetricTap(metric)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

/// Header for a metric category
struct CategoryHeader: View {
    let category: MetricCategory
    let score: Double
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: category.icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(category.color)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(category.color.opacity(0.1))
                )
            
            // Category Info
            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if score > 0 {
                    Text(String(format: "%.1f/5.0", score))
                        .font(.subheadline)
                        .foregroundColor(category.color)
                } else {
                    Text("Not rated")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Category Score Gauge (Small)
            if score > 0 {
                ReusableGaugeView(
                    score: score,
                    maxScore: 5.0,
                    size: .small,
                    showBackground: false,
                    animate: false
                )
            }
        }
    }
}

/// Row card for individual metrics
struct MetricRowCard: View {
    let metric: CombinedMetric
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Rating Circle
                ZStack {
                    Circle()
                        .fill(metric.isRated ? metric.category.color.opacity(0.1) : Color(.systemGray6))
                        .frame(width: 40, height: 40)
                    
                    if metric.isRated {
                        Text("\(metric.rating)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(metric.category.color)
                    } else {
                        Image(systemName: "questionmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Metric Info
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(metric.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        if metric.isRequired {
                            Text("Required")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.red)
                                )
                        }
                        
                        Spacer()
                    }
                    
                    Text(metric.isRated ? metric.getRatingDescription() : "Tap to rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
                    .stroke(Color(.systemGray5).opacity(0.3), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Detail view for editing a metric
struct CentralizedMetricDetailView: View {
    let location: Location
    let metric: CombinedMetric
    let onSave: (Int, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRating: Int
    @State private var notes: String
    @State private var isSaving = false
    
    init(location: Location, metric: CombinedMetric, onSave: @escaping (Int, String) -> Void) {
        self.location = location
        self.metric = metric
        self.onSave = onSave
        self._selectedRating = State(initialValue: metric.rating)
        self._notes = State(initialValue: metric.notes)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [metric.category.color.opacity(0.1), metric.category.color.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Metric Info Card
                        MetricInfoCard(metric: metric)
                        
                        // Rating Selector
                        RatingSelector(
                            selectedRating: $selectedRating,
                            metric: metric
                        )
                        
                        // Notes Section
                        NotesInputSection(notes: $notes)
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle(metric.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .disabled(isSaving)
                }
            }
        }
    }
    
    private func save() {
        isSaving = true
        onSave(selectedRating, notes)
        dismiss()
    }
}

/// Info card for metric details
struct MetricInfoCard: View {
    let metric: CombinedMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: metric.category.icon)
                    .font(.title2)
                    .foregroundColor(metric.category.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(metric.category.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(metric.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                if metric.isRequired {
                    Text("Required")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.red)
                        )
                }
            }
            
            Text(metric.description)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

/// Rating selector for metrics
struct RatingSelector: View {
    @Binding var selectedRating: Int
    let metric: CombinedMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Select Rating")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(metric.definition.minRating...metric.definition.maxRating, id: \.self) { rating in
                    RatingOptionView(
                        rating: rating,
                        isSelected: rating == selectedRating,
                        metric: metric
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedRating = rating
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

/// Individual rating option
struct RatingOptionView: View {
    let rating: Int
    let isSelected: Bool
    let metric: CombinedMetric
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Rating Number
                ZStack {
                    Circle()
                        .fill(isSelected ? metric.category.color : Color(.systemGray6))
                        .frame(width: 32, height: 32)
                    
                    Text("\(rating)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isSelected ? .white : .secondary)
                }
                
                // Description
                VStack(alignment: .leading, spacing: 2) {
                    Text(metric.definition.getRatingDescription(for: rating))
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .primary : .secondary)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(metric.category.color)
                        .font(.title2)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? metric.category.color.opacity(0.1) : Color.clear)
                    .stroke(isSelected ? metric.category.color.opacity(0.3) : Color(.systemGray5), lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Notes input section
struct NotesInputSection: View {
    @Binding var notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Notes (Optional)")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            TextEditor(text: $notes)
                .frame(minHeight: 100)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct CentralizedMetricsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = try! ModelContainer(for: Location.self, LocationType.self, LocationMetrics.self, MetricDefinition.self, MetricInstance.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self).mainContext
        
        let locationType = LocationType(type: .office)
        let location = Location(name: "Sample Office", address: "123 Main St", comment: "Test office location", locationType: locationType)
        
        context.insert(location)
        
        return CentralizedMetricsView(location: location, onDataChanged: {})
            .environmentObject(SharedModelContext.shared)
    }
}
