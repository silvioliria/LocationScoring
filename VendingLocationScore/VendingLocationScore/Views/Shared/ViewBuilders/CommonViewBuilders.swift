import SwiftUI

// MARK: - Common View Builders
struct CommonViewBuilders {
    
    // MARK: - Section Builder
    static func section<Content: View>(
        title: String,
        spacing: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            SectionHeaderText(title)
            content()
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Card Builder
    static func card<Content: View>(
        padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        cornerRadius: CGFloat = 10,
        backgroundColor: Color = Color(.systemBackground),
        shadowRadius: CGFloat = 2,
        shadowOpacity: Double = 0.1,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(
                color: Color.black.opacity(shadowOpacity),
                radius: shadowRadius,
                x: 0,
                y: 1
            )
    }
    
    // MARK: - List Row Builder
    static func listRow<Content: View>(
        destination: AnyView? = nil,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        if let destination = destination {
            ListRowContainer(destination: destination) {
                content()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
            }
        } else if let onTap = onTap {
            ListRowContainer(onTap: onTap) {
                content()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
            }
        } else {
            ListRowContainer {
                content()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Form Field Builder
    static func formField<Content: View>(
        label: String,
        isRequired: Bool = false,
        errorMessage: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if isRequired {
                    Text("*")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            
            content()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Action Button Row Builder
    static func actionButtonRow<Content: View>(
        spacing: CGFloat = 12,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: spacing) {
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Loading State Builder
    static func loadingState(
        message: String = "Loading...",
        showProgress: Bool = true
    ) -> some View {
        VStack(spacing: 16) {
            if showProgress {
                ProgressView()
                    .scaleEffect(1.2)
            }
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error State Builder
    static func errorState(
        title: String = "Something went wrong",
        message: String = "Please try again",
        retryAction: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let retryAction = retryAction {
                PrimaryButton("Try Again", icon: "arrow.clockwise") {
                    retryAction()
                }
            }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State Builder
    static func emptyState(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        buttonIcon: String? = nil,
        buttonAction: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let buttonTitle = buttonTitle,
               let buttonIcon = buttonIcon,
               let buttonAction = buttonAction {
                PrimaryButton(buttonTitle, icon: buttonIcon) {
                    buttonAction()
                }
            }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Metric Display Builder
    static func metricDisplay(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String? = nil,
        color: Color? = nil
    ) -> some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color ?? .blue)
                    .frame(width: 32, height: 32)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Convenience Extensions
extension View {
    /// Wraps the view in a standard section with title
    func section(title: String, spacing: CGFloat = 20) -> some View {
        CommonViewBuilders.section(title: title, spacing: spacing) {
            self
        }
    }
    
    /// Wraps the view in a standard card
    func card(
        padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        cornerRadius: CGFloat = 10,
        backgroundColor: Color = Color(.systemBackground),
        shadowRadius: CGFloat = 2,
        shadowOpacity: Double = 0.1
    ) -> some View {
        CommonViewBuilders.card(
            padding: padding,
            cornerRadius: cornerRadius,
            backgroundColor: backgroundColor,
            shadowRadius: shadowRadius,
            shadowOpacity: shadowOpacity
        ) {
            self
        }
    }
    
    /// Wraps the view in a standard list row
    func listRow(
        destination: AnyView? = nil,
        onTap: (() -> Void)? = nil
    ) -> some View {
        CommonViewBuilders.listRow(
            destination: destination,
            onTap: onTap
        ) {
            self
        }
    }
    
    /// Wraps the view in a standard form field
    func formField(
        label: String,
        isRequired: Bool = false,
        errorMessage: String? = nil
    ) -> some View {
        CommonViewBuilders.formField(
            label: label,
            isRequired: isRequired,
            errorMessage: errorMessage
        ) {
            self
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 24) {
            // Section example
            CommonViewBuilders.section(title: "Section Title") {
                Text("Section content goes here")
                    .foregroundColor(.secondary)
            }
            
            // Card example
            CommonViewBuilders.card {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Card Title")
                        .font(.headline)
                    Text("Card content with some text to demonstrate the card layout.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            // Form field example
            CommonViewBuilders.formField(
                label: "Email Address",
                isRequired: true,
                errorMessage: "Please enter a valid email"
            ) {
                TextField("Enter email", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Metric display example
            CommonViewBuilders.metricDisplay(
                title: "Total Score",
                value: "4.2",
                subtitle: "out of 5.0",
                icon: "star.fill",
                color: .yellow
            )
            
            // Action button row example
            CommonViewBuilders.actionButtonRow {
                SecondaryButton("Cancel") { }
                PrimaryButton("Save") { }
            }
        }
        .padding()
    }
}
