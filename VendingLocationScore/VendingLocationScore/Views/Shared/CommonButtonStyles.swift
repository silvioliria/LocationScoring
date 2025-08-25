import SwiftUI

// MARK: - Common Button Styles

/// Primary action button style (blue background, white text)
struct PrimaryButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    init(cornerRadius: CGFloat = AppTheme.Layout.medium, padding: CGFloat = AppTheme.Spacing.md) {
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.headline)
            .foregroundColor(.white)
            .padding(padding)
            .background(AppTheme.Colors.primary)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(AnimationPresets.Interactive.buttonPress, value: configuration.isPressed)
    }
}

/// Secondary action button style (outlined, primary text)
struct SecondaryButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    let padding: CGFloat
    let borderWidth: CGFloat
    
    init(cornerRadius: CGFloat = 10, padding: CGFloat = 16, borderWidth: CGFloat = 1) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.borderWidth = borderWidth
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .padding(padding)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.blue, lineWidth: borderWidth)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Destructive action button style (red background, white text)
struct DestructiveButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    init(cornerRadius: CGFloat = AppTheme.Layout.medium, padding: CGFloat = AppTheme.Spacing.md) {
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.headline)
            .foregroundColor(.white)
            .padding(padding)
            .background(AppTheme.Colors.error)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(AnimationPresets.Interactive.buttonPress, value: configuration.isPressed)
    }
}

/// Icon-only button style for toolbars
struct IconButtonStyle: ButtonStyle {
    let foregroundColor: Color
    let size: CGFloat
    
    init(foregroundColor: Color = AppTheme.Colors.primary, size: CGFloat = 24) {
        self.foregroundColor = foregroundColor
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .font(.system(size: size))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(AnimationPresets.Interactive.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - Convenience Button Views

/// Primary action button with consistent styling
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

/// Secondary action button with consistent styling
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

/// Destructive action button with consistent styling
struct DestructiveButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
        }
        .buttonStyle(DestructiveButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        PrimaryButton("Create Location", icon: "plus.circle.fill") {
            print("Primary button tapped")
        }
        
        SecondaryButton("Cancel", icon: "xmark.circle") {
            print("Secondary button tapped")
        }
        
        DestructiveButton("Delete", icon: "trash") {
            print("Destructive button tapped")
        }
        
        Button("Custom Style") {
            print("Custom style button tapped")
        }
        .buttonStyle(PrimaryButtonStyle(cornerRadius: 20, padding: 20))
        
        Button(action: { print("Icon button tapped") }) {
            Image(systemName: "gear")
        }
        .buttonStyle(IconButtonStyle(foregroundColor: .orange, size: 32))
    }
    .padding()
}
