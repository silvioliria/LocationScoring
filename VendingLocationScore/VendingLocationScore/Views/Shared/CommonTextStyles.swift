import SwiftUI

// MARK: - Common Text Styles

/// Section header text with consistent styling
struct SectionHeaderText: View {
    let text: String
    let color: Color
    
    init(_ text: String, color: Color = AppTheme.Colors.primaryText) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(AppTheme.Typography.headline)
            .fontWeight(AppTheme.Typography.semibold)
            .foregroundColor(color)
    }
}

/// Secondary text with consistent styling
struct SecondaryText: View {
    let text: String
    let color: Color
    
    init(_ text: String, color: Color = AppTheme.Colors.secondaryText) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(AppTheme.Typography.subheadline)
            .foregroundColor(color)
    }
}

/// Caption text with consistent styling
struct CaptionText: View {
    let text: String
    let weight: Font.Weight
    let color: Color
    
    init(_ text: String, weight: Font.Weight = AppTheme.Typography.regular, color: Color = AppTheme.Colors.secondaryText) {
        self.text = text
        self.weight = weight
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(AppTheme.Typography.caption)
            .fontWeight(weight)
            .foregroundColor(color)
    }
}

/// Small text with consistent styling
struct SmallText: View {
    let text: String
    let weight: Font.Weight
    let color: Color
    
    init(_ text: String, weight: Font.Weight = AppTheme.Typography.regular, color: Color = AppTheme.Colors.tertiaryText) {
        self.text = text
        self.weight = weight
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(AppTheme.Typography.caption2)
            .fontWeight(weight)
            .foregroundColor(color)
    }
}

/// Emphasized text with consistent styling
struct EmphasizedText: View {
    let text: String
    let color: Color
    
    init(_ text: String, color: Color = AppTheme.Colors.primaryText) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(AppTheme.Typography.body)
            .fontWeight(AppTheme.Typography.semibold)
            .foregroundColor(color)
    }
}

/// Large title text with consistent styling
struct LargeTitleText: View {
    let text: String
    let color: Color
    
    init(_ text: String, color: Color = AppTheme.Colors.primaryText) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(AppTheme.Typography.largeTitle)
            .fontWeight(AppTheme.Typography.bold)
            .foregroundColor(color)
    }
}

/// Medium title text with consistent styling
struct MediumTitleText: View {
    let text: String
    let color: Color
    
    init(_ text: String, color: Color = AppTheme.Colors.primaryText) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(AppTheme.Typography.title1)
            .fontWeight(AppTheme.Typography.semibold)
            .foregroundColor(color)
    }
}

/// Small title text with consistent styling
struct SmallTitleText: View {
    let text: String
    let color: Color
    
    init(_ text: String, color: Color = AppTheme.Colors.primaryText) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(AppTheme.Typography.title3)
            .fontWeight(AppTheme.Typography.medium)
            .foregroundColor(color)
    }
}

// MARK: - Text Extension Modifiers
extension Text {
    /// Apply section header style
    func sectionHeaderStyle(color: Color = AppTheme.Colors.primaryText) -> some View {
        self
            .font(AppTheme.Typography.headline)
            .fontWeight(AppTheme.Typography.semibold)
            .foregroundColor(color)
    }
    
    /// Apply secondary text style
    func secondaryStyle(color: Color = AppTheme.Colors.secondaryText) -> some View {
        self
            .font(AppTheme.Typography.subheadline)
            .foregroundColor(color)
    }
    
    /// Apply caption style
    func captionStyle(weight: Font.Weight = AppTheme.Typography.regular, color: Color = AppTheme.Colors.secondaryText) -> some View {
        self
            .font(AppTheme.Typography.caption)
            .fontWeight(weight)
            .foregroundColor(color)
    }
    
    /// Apply small text style
    func smallStyle(weight: Font.Weight = AppTheme.Typography.regular, color: Color = AppTheme.Colors.tertiaryText) -> some View {
        self
            .font(AppTheme.Typography.caption2)
            .fontWeight(weight)
            .foregroundColor(color)
    }
    
    /// Apply emphasized style
    func emphasizedStyle(color: Color = AppTheme.Colors.primaryText) -> some View {
        self
            .font(AppTheme.Typography.body)
            .fontWeight(AppTheme.Typography.semibold)
            .foregroundColor(color)
    }
}

// MARK: - Preview
#Preview {
    VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
        LargeTitleText("Large Title")
        MediumTitleText("Medium Title")
        SmallTitleText("Small Title")
        SectionHeaderText("Section Header")
        EmphasizedText("Emphasized Text")
        SecondaryText("Secondary text for descriptions and additional information")
        CaptionText("Caption text with medium weight", weight: .medium)
        SmallText("Small text for fine details", weight: .regular)
        
        Divider()
        
        Text("Custom styled text")
            .sectionHeaderStyle(color: .blue)
        
        Text("Another custom style")
            .secondaryStyle(color: .green)
        
        Text("Caption with custom weight")
            .captionStyle(weight: .bold, color: .orange)
    }
    .padding()
}
