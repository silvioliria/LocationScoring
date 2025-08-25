# 🚀 Design Patterns - Quick Reference

## ⚡ **Before Writing Any Code - CHECK THIS:**

### **🎨 UI Components - ALWAYS USE:**
- **EmptyStateView** - For any empty state
- **ListRowContainer** - For list rows with navigation
- **CommonButtonStyles** - For button appearance
- **CommonTextStyles** - For text appearance
- **ScoreColorUtility** - For score colors
- **CompactScoreGauge** - For score displays

### **🏗️ Architecture - ALWAYS USE:**
- **DataManagementService** - For data access (NOT direct SwiftData)
- **Service layer pattern** - Abstract data operations
- **Component extraction** - Extract reusable patterns to Shared/

---

## 🚫 **NEVER DO:**
- Hardcode colors (use ScoreColorUtility)
- Custom button styling (use CommonButtonStyles)
- Custom text styling (use CommonTextStyles)
- Inline empty states (use EmptyStateView)
- Direct SwiftData access (use DataManagementService)
- Custom spacing values (use standard constants)
- Duplicate UI patterns (extract to shared)

---

## ✅ **ALWAYS DO:**
- Follow established naming conventions
- Use standard spacing (16px horizontal, 4px vertical, 20px sections)
- Use standard fonts (.headline, .subheadline, .caption, etc.)
- Place components in correct directories
- Maintain single responsibility
- Document with MARK comments
- Include preview examples

---

## 📁 **File Organization:**
```
Views/
├── Main Views/           # Primary app screens
├── Shared/              # Reusable components
│   ├── Components/      # Complex reusable components
│   ├── Utilities/       # Utility components
│   └── Styles/          # Style components
└── Components/          # Feature-specific components
```

---

## 🎯 **Standard Layout:**
```swift
VStack(spacing: 20) {           // Standard spacing
    SectionHeaderText("Title")
    
    VStack(spacing: 16) {       // Standard content spacing
        // Content items
    }
    .padding(.horizontal, 16)   // Standard horizontal padding
    
    Spacer(minLength: 24)       // Standard bottom spacing
}
.padding(.horizontal, 16)       // Standard horizontal padding
.padding(.top, 20)              // Standard top padding
```

---

## 🔧 **Standard Constants:**
```swift
// Spacing
private let standardSpacing: CGFloat = 16
private let standardVerticalSpacing: CGFloat = 4
private let standardSectionSpacing: CGFloat = 20

// Padding
private let standardHorizontalPadding: CGFloat = 16
private let standardVerticalPadding: CGFloat = 4
private let standardTopPadding: CGFloat = 20

// Corner Radius
private let standardCornerRadius: CGFloat = 10
private let standardLargeCornerRadius: CGFloat = 16
```

---

## 📋 **Compliance Checklist:**
- [ ] Uses established styling patterns
- [ ] Follows naming conventions
- [ ] Placed in correct directory
- [ ] Uses service layer for data
- [ ] No hardcoded colors/styles
- [ ] No duplicate UI patterns
- [ ] Passes refactoring validation

---

## 🆘 **If Unsure:**
1. **Check this reference** - Look for established patterns
2. **Read full rulebook** - `DESIGN_PATTERNS_AND_ARCHITECTURE_RULES.md`
3. **Follow examples** - Look at existing components
4. **Ask team** - Don't guess, confirm patterns

---

**Remember: "Consistency is more important than individual creativity!"**
