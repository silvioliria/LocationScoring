import SwiftUI

// MARK: - Component Name
struct ComponentName: View {
    // MARK: - Properties
    let requiredParameter: String
    let optionalParameter: String?
    
    // MARK: - Constants (use standard values)
    private let standardSpacing: CGFloat = 16
    private let standardVerticalSpacing: CGFloat = 4
    private let standardSectionSpacing: CGFloat = 20
    private let standardHorizontalPadding: CGFloat = 16
    private let standardTopPadding: CGFloat = 20
    private let standardCornerRadius: CGFloat = 10
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: standardSectionSpacing) {
            // Header section
            SectionHeaderText("Section Title")
            
            // Content section
            VStack(spacing: standardSpacing) {
                // Content items
                Text(requiredParameter)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let optionalParameter = optionalParameter {
                    Text(optionalParameter)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Action button
                PrimaryButton("Action", icon: "plus.circle.fill") {
                    // action
                }
            }
            .padding(.horizontal, standardHorizontalPadding)
            
            // Bottom spacing
            Spacer(minLength: 24)
        }
        .padding(.horizontal, standardHorizontalPadding)
        .padding(.top, standardTopPadding)
    }
}

// MARK: - Convenience Initializers (if applicable)
extension ComponentName {
    /// Creates a standard instance with default values
    static func standardInstance() -> ComponentName {
        ComponentName(
            requiredParameter: "Default Value",
            optionalParameter: nil
        )
    }
    
    /// Creates an instance for a specific use case
    static func specificUseCase() -> ComponentName {
        ComponentName(
            requiredParameter: "Specific Value",
            optionalParameter: "Optional Value"
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        ComponentName(
            requiredParameter: "Sample Required",
            optionalParameter: "Sample Optional"
        )
        
        ComponentName.standardInstance()
        
        ComponentName.specificUseCase()
    }
    .padding()
}
