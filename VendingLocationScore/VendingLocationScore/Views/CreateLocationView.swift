import SwiftUI
import SwiftData

struct CreateLocationView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onLocationCreated: (Location) -> Void
    let modelContext: ModelContext
    
    // Use computed property to get a fresh data service instance with current context
    private var dataService: any DataManagementService {
        let service = DataManagementServiceFactory.createDataManagementService()
        if let localDataService = service as? LocalDataService {
            localDataService.setContext(modelContext)
        }
        return service
    }
    
    // Step management
    @State private var currentStep = 0
    @State private var canProceedToNext = false
    
    // Form data
    @State private var name = ""
    @State private var address = ""
    @State private var comment = ""
    @State private var selectedLocationType: LocationTypeEnum = .office
    

    
    // UI states
    @State private var isCreating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let totalSteps = 3
    
    init(onLocationCreated: @escaping (Location) -> Void, modelContext: ModelContext) {
        self.onLocationCreated = onLocationCreated
        self.modelContext = modelContext
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                
                // Step content
                stepContent
                
                // Navigation buttons
                navigationButtons
            }
            .navigationTitle("New Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if isCreating {
                    LoadingView()
                }
            }
            .onAppear {
                // Context is now set in the computed property
            }
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        VStack(spacing: 16) {
            HStack {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(step == currentStep ? Color.accentColor : Color.clear, lineWidth: 2)
                                .frame(width: 20, height: 20)
                        )
                    
                    if step < totalSteps - 1 {
                        Rectangle()
                            .fill(step < currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 40)
            
            Text(stepTitle)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(stepDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
    
    // MARK: - Step Content
    
    @ViewBuilder
    private var stepContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch currentStep {
                case 0:
                    basicInfoStep
                case 1:
                    moduleSelectionStep
                case 2:
                    confirmationStep
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 100) // Space for navigation buttons
        }
    }
    
    // MARK: - Step 1: Basic Information
    
    private var basicInfoStep: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Location Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location Name")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter location name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: name) { validateBasicInfo() }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Address")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter full address", text: $address)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: address) { validateBasicInfo() }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Additional Notes (Optional)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Add context or notes", text: $comment, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
            }
        }
    }
    
    // MARK: - Step 2: Module Selection
    
    private var moduleSelectionStep: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Location Type")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Select the type of location to customize the evaluation criteria")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(LocationTypeEnum.allCases, id: \.self) { locationType in
                        ModuleSelectionCard(
                            locationType: locationType,
                            isSelected: selectedLocationType == locationType,
                            onTap: {
                                selectedLocationType = locationType
                                validateModuleSelection()
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Step 3: Confirmation
    
    private var confirmationStep: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Review & Create")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Review your location details before creating")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                locationSummaryCard
            }
        }
    }
    
    private var locationSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Location Name")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(name)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Address")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(address)
                    .font(.subheadline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Type")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(selectedLocationType.displayName)
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
            }
            
            if !comment.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(comment)
                        .font(.subheadline)
                        .italic()
                }
            }
            

        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep -= 1
                            validateCurrentStep()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                if currentStep < totalSteps - 1 {
                    Button("Next") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep += 1
                            validateCurrentStep()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canProceedToNext)
                } else {
                    Button("Create Location") {
                        Task {
                            await createLocation()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canProceedToNext || isCreating)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 8, y: -4)
    }
    
    // MARK: - Computed Properties
    
    private var stepTitle: String {
        switch currentStep {
        case 0: return "Basic Information"
        case 1: return "Location Type"
        case 2: return "Review & Create"
        default: return ""
        }
    }
    
    private var stepDescription: String {
        switch currentStep {
        case 0: return "Enter the basic details about your location"
        case 1: return "Choose the type of location to customize evaluation criteria"
        case 2: return "Review your information before creating the location"
        default: return ""
        }
    }
    
    // MARK: - Validation
    
    private func validateBasicInfo() {
        canProceedToNext = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                           !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func validateModuleSelection() {
        canProceedToNext = true // Module selection is always valid
    }
    
    private func validateCurrentStep() {
        switch currentStep {
        case 0: validateBasicInfo()
        case 1: validateModuleSelection()
        case 2: canProceedToNext = true
        default: break
        }
    }
    
    // MARK: - Location Creation
    
    private func createLocation() async {
        isCreating = true
        
        do {
            print("🔍 Creating location with name: '\(name)', address: '\(address)', type: \(selectedLocationType)")
            print("🔍 ModelContext: \(modelContext)")
            print("🔍 DataService type: \(type(of: dataService))")
            
            // Validate required fields
            guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw NSError(domain: "ValidationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Name and address are required"])
            }
            
            // Use the new LocationManager to create the location
            let savedLocation = try await dataService.createLocation(
                name: name,
                address: address,
                comment: comment.isEmpty ? nil : comment,
                locationType: selectedLocationType
            )
            print("🔍 Location saved successfully!")
            
            // Call the callback to notify parent view
            onLocationCreated(savedLocation)
            
            // Return to the previous view
            dismiss()
        } catch {
            print("🔍 Error creating location: \(error)")
            await MainActor.run {
                errorMessage = "Failed to create location: \(error.localizedDescription)"
                showError = true
            }
        }
        
        await MainActor.run {
            isCreating = false
        }
    }
}

// MARK: - Supporting Views

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

struct ModuleSelectionCard: View {
    let locationType: LocationTypeEnum
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: moduleIcon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .white : moduleColor)
                
                Text(locationType.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(moduleDescription)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? moduleColor : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? moduleColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var moduleIcon: String {
        switch locationType {
        case .office: return "building.2"
        case .hospital: return "cross.case"
        case .school: return "graduationcap"
        case .residential: return "house"
        }
    }
    
    private var moduleColor: Color {
        switch locationType {
        case .office: return .blue
        case .hospital: return .red
        case .school: return .green
        case .residential: return .purple
        }
    }
    
    private var moduleDescription: String {
        switch locationType {
        case .office: return "Corporate buildings, coworking spaces"
        case .hospital: return "Medical facilities, clinics"
        case .school: return "Educational institutions"
        case .residential: return "Apartments, condos, homes"
        }
    }
}



#Preview {
    let context = try! ModelContainer(for: Location.self, LocationType.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self, MetricDefinition.self, MetricInstance.self, LocationMetrics.self).mainContext
    
    CreateLocationView(
        onLocationCreated: { _ in },
        modelContext: context
    )
}
