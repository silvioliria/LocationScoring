import SwiftUI

// Module-specific fields coordinator (Temporarily disabled - using dedicated views instead)
struct ModuleSpecificFields: View {
    let location: Location
    let onDataChanged: () -> Void
    
    var body: some View {
        // All location types now use dedicated views instead of these specific fields
        EmptyView()
    }
}
