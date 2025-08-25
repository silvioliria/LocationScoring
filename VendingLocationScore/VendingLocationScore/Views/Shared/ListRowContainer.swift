import SwiftUI

// MARK: - List Row Container
struct ListRowContainer<Content: View>: View {
    let content: Content
    let isNavigationLink: Bool
    let destination: AnyView?
    let onTap: (() -> Void)?
    
    // MARK: - Initializers
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self.isNavigationLink = false
        self.destination = nil
        self.onTap = nil
    }
    
    init(destination: some View, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isNavigationLink = true
        self.destination = AnyView(destination)
        self.onTap = nil
    }
    
    init(onTap: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isNavigationLink = false
        self.destination = nil
        self.onTap = onTap
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if isNavigationLink, let destination = destination {
                NavigationLink(destination: destination) {
                    content
                }
            } else if let onTap = onTap {
                Button(action: onTap) {
                    content
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                content
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(AppTheme.Colors.background)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        List {
            ListRowContainer(destination: Text("Detail View")) {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    VStack(alignment: .leading) {
                        Text("Sample Location")
                            .font(AppTheme.Typography.headline)
                        Text("123 Main St")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    Spacer()
                    CompactScoreGauge(score: 4.2, maxScore: 5.0)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
            
            ListRowContainer(onTap: { print("Row tapped") }) {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Tappable Row")
                        .font(AppTheme.Typography.body)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
        }
        .navigationTitle("List Row Examples")
    }
}
