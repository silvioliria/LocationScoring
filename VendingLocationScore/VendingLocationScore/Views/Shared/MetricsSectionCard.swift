import SwiftUI

struct MetricsSectionCard<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content
    
    init(title: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Clean section header without background
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    iconColor.opacity(0.2),
                                    iconColor.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Tap to rate each metric")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Content with enhanced spacing
            VStack(spacing: 8) {
                content
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color(.systemGray4).opacity(0.2),
                            lineWidth: 0.5
                        )
                )
        )
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

struct MetricsSectionCard_Previews: PreviewProvider {
    static var previews: some View {
        MetricsSectionCard(
            title: "Foot Traffic & Demographics",
            icon: "person.3.fill",
            iconColor: .green
        ) {
            Text("Sample content for preview")
                .padding()
        }
        .padding()
        .background(Color(.systemGray6))
    }
}
