import SwiftUI

// MARK: - App Theme System
struct AppTheme {
    
    // MARK: - Color Palette
    struct Colors {
        // Primary Colors
        static let primary = Color.blue
        static let primaryLight = Color.blue.opacity(0.8)
        static let primaryDark = Color.blue.opacity(1.2)
        
        // Secondary Colors
        static let secondary = Color.gray
        static let secondaryLight = Color.gray.opacity(0.6)
        static let secondaryDark = Color.gray.opacity(0.8)
        
        // Semantic Colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
        
        // Background Colors
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        static let groupedBackground = Color(.systemGroupedBackground)
        
        // Text Colors
        static let primaryText = Color.black
        static let secondaryText = Color.gray
        static let tertiaryText = Color.gray.opacity(0.7)
        static let placeholderText = Color.gray.opacity(0.5)
        
        // Border Colors
        static let border = Color(.separator)
        static let borderLight = Color(.separator).opacity(0.5)
        
        // Score Colors (using ScoreColorUtility logic)
        static let scoreExcellent = Color.green
        static let scoreGood = Color.blue
        static let scoreAverage = Color.yellow
        static let scorePoor = Color.orange
        static let scoreVeryPoor = Color.red
        static let scoreNone = Color.gray
    }
    
    // MARK: - Typography
    struct Typography {
        // Font Sizes
        static let largeTitle: Font = .largeTitle
        static let title1: Font = .title
        static let title2: Font = .title2
        static let title3: Font = .title3
        static let headline: Font = .headline
        static let body: Font = .body
        static let callout: Font = .callout
        static let subheadline: Font = .subheadline
        static let footnote: Font = .footnote
        static let caption: Font = .caption
        static let caption2: Font = .caption2
        
        // Font Weights
        static let regular: Font.Weight = .regular
        static let medium: Font.Weight = .medium
        static let semibold: Font.Weight = .semibold
        static let bold: Font.Weight = .bold
        static let heavy: Font.Weight = .heavy
        
        // Line Heights
        static let tight: CGFloat = 1.0
        static let normal: CGFloat = 1.2
        static let relaxed: CGFloat = 1.5
        static let loose: CGFloat = 1.8
    }
    
    // MARK: - Spacing
    struct Spacing {
        // Base Spacing Unit
        static let base: CGFloat = 4
        
        // Spacing Scale
        static let xs: CGFloat = base * 1      // 4
        static let sm: CGFloat = base * 2      // 8
        static let md: CGFloat = base * 4      // 16
        static let lg: CGFloat = base * 6      // 24
        static let xl: CGFloat = base * 8      // 32
        static let xxl: CGFloat = base * 12    // 48
        
        // Specific Spacing
        static let sectionSpacing: CGFloat = lg      // 24
        static let contentSpacing: CGFloat = md      // 16
        static let itemSpacing: CGFloat = sm         // 8
        static let tightSpacing: CGFloat = xs        // 4
        
        // Padding
        static let horizontalPadding: CGFloat = md   // 16
        static let verticalPadding: CGFloat = sm     // 8
        static let topPadding: CGFloat = lg          // 24
        static let bottomPadding: CGFloat = xl       // 32
    }
    
    // MARK: - Layout
    struct Layout {
        // Corner Radius
        static let small: CGFloat = 6
        static let medium: CGFloat = 10
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
        
        // Border Width
        static let thin: CGFloat = 0.5
        static let normal: CGFloat = 1
        static let thick: CGFloat = 2
        
        // Shadow
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Double = 0.1
        static let shadowOffset = CGSize(width: 0, height: 2)
        
        // Content Width
        static let maxContentWidth: CGFloat = 600
        static let maxListWidth: CGFloat = 500
    }
    
    // MARK: - Animation
    struct Animation {
        // Duration
        static let fast: Double = 0.2
        static let normal: Double = 0.3
        static let slow: Double = 0.5
        
        // Easing
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: normal)
        static let easeOut = SwiftUI.Animation.easeOut(duration: normal)
        static let easeIn = SwiftUI.Animation.easeIn(duration: normal)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
        
        // Stagger
        static let staggerDelay: Double = 0.1
    }
    
    // MARK: - Component Specific
    struct Components {
        // Button
        struct Button {
            static let height: CGFloat = 44
            static let cornerRadius: CGFloat = Layout.medium
            static let padding = EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        }
        
        // Card
        struct Card {
            static let cornerRadius: CGFloat = Layout.medium
            static let padding = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            static let shadowRadius: CGFloat = Layout.shadowRadius
            static let shadowOpacity: Double = Layout.shadowOpacity
        }
        
        // Input Field
        struct InputField {
            static let height: CGFloat = 44
            static let cornerRadius: CGFloat = Layout.small
            static let borderWidth: CGFloat = Layout.normal
        }
        
        // List Row
        struct ListRow {
            static let minHeight: CGFloat = 60
            static let padding = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
        }
        
        // Score Gauge
        struct ScoreGauge {
            static let size: CGFloat = 42
            static let strokeWidth: CGFloat = 4
            static let fontSize: Font = Typography.callout
        }
    }
}

// MARK: - Theme Extensions
extension Color {
    /// App theme colors
    static let appPrimary = AppTheme.Colors.primary
    static let appSecondary = AppTheme.Colors.secondary
    static let appSuccess = AppTheme.Colors.success
    static let appWarning = AppTheme.Colors.warning
    static let appError = AppTheme.Colors.error
    static let appInfo = AppTheme.Colors.info
    
    /// App background colors
    static let appBackground = AppTheme.Colors.background
    static let appSecondaryBackground = AppTheme.Colors.secondaryBackground
    static let appTertiaryBackground = AppTheme.Colors.tertiaryBackground
    static let appGroupedBackground = AppTheme.Colors.groupedBackground
    
    /// App text colors
    static let appPrimaryText = AppTheme.Colors.primaryText
    static let appSecondaryText = AppTheme.Colors.secondaryText
    static let appTertiaryText = AppTheme.Colors.tertiaryText
    static let appPlaceholderText = AppTheme.Colors.placeholderText
    
    /// App border colors
    static let appBorder = AppTheme.Colors.border
    static let appBorderLight = AppTheme.Colors.borderLight
}

extension Font {
    /// App theme fonts
    static let appLargeTitle = AppTheme.Typography.largeTitle
    static let appTitle1 = AppTheme.Typography.title1
    static let appTitle2 = AppTheme.Typography.title2
    static let appTitle3 = AppTheme.Typography.title3
    static let appHeadline = AppTheme.Typography.headline
    static let appBody = AppTheme.Typography.body
    static let appCallout = AppTheme.Typography.callout
    static let appSubheadline = AppTheme.Typography.subheadline
    static let appFootnote = AppTheme.Typography.footnote
    static let appCaption = AppTheme.Typography.caption
    static let appCaption2 = AppTheme.Typography.caption2
}

extension CGFloat {
    /// App theme spacing
    static let appSpacingXS = AppTheme.Spacing.xs
    static let appSpacingSM = AppTheme.Spacing.sm
    static let appSpacingMD = AppTheme.Spacing.md
    static let appSpacingLG = AppTheme.Spacing.lg
    static let appSpacingXL = AppTheme.Spacing.xl
    static let appSpacingXXL = AppTheme.Spacing.xxl
    
    /// App theme layout
    static let appCornerRadiusSmall = AppTheme.Layout.small
    static let appCornerRadiusMedium = AppTheme.Layout.medium
    static let appCornerRadiusLarge = AppTheme.Layout.large
    static let appCornerRadiusExtraLarge = AppTheme.Layout.extraLarge
}

extension SwiftUI.Animation {
    /// App theme animations
    static let appFast = SwiftUI.Animation.easeInOut(duration: AppTheme.Animation.fast)
    static let appNormal = AppTheme.Animation.easeInOut
    static let appSlow = SwiftUI.Animation.easeInOut(duration: AppTheme.Animation.slow)
    static let appSpring = AppTheme.Animation.spring
}

// MARK: - Theme Utilities
struct ThemeUtilities {
    
    /// Get score color based on score value
    static func scoreColor(for score: Double, maxScore: Double = 5.0) -> Color {
        let percentage = score / maxScore
        
        switch percentage {
        case 0.8...1.0:
            return AppTheme.Colors.scoreExcellent
        case 0.6..<0.8:
            return AppTheme.Colors.scoreGood
        case 0.4..<0.6:
            return AppTheme.Colors.scoreAverage
        case 0.2..<0.4:
            return AppTheme.Colors.scorePoor
        case 0.0..<0.2:
            return AppTheme.Colors.scoreVeryPoor
        default:
            return AppTheme.Colors.scoreNone
        }
    }
    
    /// Get background color for current color scheme
    static func backgroundColor(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .light:
            return AppTheme.Colors.background
        case .dark:
            return AppTheme.Colors.secondaryBackground
        @unknown default:
            return AppTheme.Colors.background
        }
    }
    
    /// Get text color for current color scheme
    static func textColor(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .light:
            return AppTheme.Colors.primaryText
        case .dark:
            return AppTheme.Colors.primaryText
        @unknown default:
            return AppTheme.Colors.primaryText
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: AppTheme.Spacing.lg) {
        // Color palette preview
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Color Palette")
                .font(AppTheme.Typography.headline)
            
            HStack(spacing: AppTheme.Spacing.md) {
                Circle()
                    .fill(AppTheme.Colors.primary)
                    .frame(width: 40, height: 40)
                Circle()
                    .fill(AppTheme.Colors.success)
                    .frame(width: 40, height: 40)
                Circle()
                    .fill(AppTheme.Colors.warning)
                    .frame(width: 40, height: 40)
                Circle()
                    .fill(AppTheme.Colors.error)
                    .frame(width: 40, height: 40)
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.Layout.medium)
        
        // Typography preview
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Typography")
                .font(AppTheme.Typography.headline)
            
            Text("Large Title")
                .font(AppTheme.Typography.largeTitle)
            Text("Title")
                .font(AppTheme.Typography.title1)
            Text("Headline")
                .font(AppTheme.Typography.headline)
            Text("Body Text")
                .font(AppTheme.Typography.body)
            Text("Caption")
                .font(AppTheme.Typography.caption)
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.Layout.medium)
        
        // Spacing preview
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Spacing")
                .font(AppTheme.Typography.headline)
            
            HStack(spacing: AppTheme.Spacing.xs) {
                Text("XS")
                    .padding(AppTheme.Spacing.xs)
                    .background(AppTheme.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(AppTheme.Layout.small)
                
                Text("SM")
                    .padding(AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(AppTheme.Layout.small)
                
                Text("MD")
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(AppTheme.Layout.small)
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.Layout.medium)
    }
    .padding()
}
