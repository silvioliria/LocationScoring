import SwiftUI

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let buttonTitle: String
    let buttonIcon: String
    let buttonAction: () -> Void
    
    // MARK: - Theme Constants
    private let iconSize: CGFloat = 60
    private let spacing: CGFloat = AppTheme.Spacing.lg
    private let buttonCornerRadius: CGFloat = AppTheme.Layout.medium
    private let buttonPadding: CGFloat = AppTheme.Spacing.md
    
    var body: some View {
        VStack(spacing: spacing) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: iconSize))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .fadeInScale(delay: 0.1)
            
            // Title
            Text(title)
                .font(AppTheme.Typography.title2)
                .fontWeight(AppTheme.Typography.semibold)
                .foregroundColor(AppTheme.Colors.primaryText)
                .slideUp(delay: 0.2)
            
            // Description
            Text(description)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .slideUp(delay: 0.3)
            
            // Action Button
            Button(action: buttonAction) {
                HStack {
                    Image(systemName: buttonIcon)
                    Text(buttonTitle)
                }
                .font(AppTheme.Typography.headline)
                .foregroundColor(.white)
                .padding(buttonPadding)
                .background(AppTheme.Colors.primary)
                .cornerRadius(buttonCornerRadius)
            }
            .slideUp(delay: 0.4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Convenience Initializers
extension EmptyStateView {
    /// Creates an empty state for locations list
    static func locationsEmptyState(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "mappin.and.ellipse",
            title: "No Locations Yet",
            description: "Create your first location to get started",
            buttonTitle: "Create Location",
            buttonIcon: "plus.circle.fill",
            buttonAction: action
        )
    }
    
    /// Creates an empty state for metrics
    static func metricsEmptyState(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "chart.bar.fill",
            title: "No Metrics Available",
            description: "Start adding metrics to evaluate this location",
            buttonTitle: "Add Metrics",
            buttonIcon: "plus.circle.fill",
            buttonAction: action
        )
    }
    
    /// Creates an empty state for search results
    static func searchEmptyState(query: String) -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results Found",
            description: "No locations match '\(query)'",
            buttonTitle: "Clear Search",
            buttonIcon: "xmark.circle.fill",
            buttonAction: {}
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        EmptyStateView.locationsEmptyState {
            print("Create Location tapped")
        }
        
        EmptyStateView.metricsEmptyState {
            print("Add Metrics tapped")
        }
        
        EmptyStateView.searchEmptyState(query: "Office")
    }
    .padding()
}
