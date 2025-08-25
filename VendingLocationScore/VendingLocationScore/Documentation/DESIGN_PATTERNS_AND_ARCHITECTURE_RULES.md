# 🎨 Design Patterns & Architecture Rules

## 🎯 **Core Principle: "Follow Established Patterns"**

> **"Every new feature, component, or change must follow the established design patterns and architecture. Consistency is more important than individual creativity."**

---

## 🏗️ **Architecture Overview**

### **1. Service Layer Architecture**
```
┌─────────────────────────────────────────────────────────────┐
│                    SwiftUI Views                           │
├─────────────────────────────────────────────────────────────┤
│                DataManagementService                       │
│                     (Protocol)                            │
├─────────────────────────────────────────────────────────────┤
│              LocalDataService (SwiftData)                 │
│              CloudKitService (Future)                     │
└─────────────────────────────────────────────────────────────┘
```

### **2. Component Hierarchy**
```
┌─────────────────────────────────────────────────────────────┐
│                    Main Views                              │
│              (LocationListView, etc.)                     │
├─────────────────────────────────────────────────────────────┤
│                Shared Components                           │
│        (EmptyStateView, ListRowContainer, etc.)           │
├─────────────────────────────────────────────────────────────┤
│                Utility Components                          │
│        (ScoreColorUtility, CommonButtonStyles, etc.)      │
├─────────────────────────────────────────────────────────────┤
│                    Models                                  │
│              (Location, GeneralMetrics, etc.)             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎨 **Design Pattern Rules**

### **Rule 1: Component Extraction Pattern**
**When to Extract:**
- ✅ **Extract when**: Same UI pattern appears in 2+ places
- ✅ **Extract when**: Complex logic that could be reused
- ✅ **Extract when**: Styling that should be consistent

**How to Extract:**
```swift
// ✅ CORRECT: Extract to Shared/ directory
struct ReusableComponent: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

// ❌ WRONG: Inline implementation in multiple places
Button(action: action) {
    Text(title)
}
.font(.headline)
.foregroundColor(.white)
.padding(16)
.background(Color.blue)
.cornerRadius(10)
```

### **Rule 2: Styling Consistency Pattern**
**Always Use:**
- **ScoreColorUtility.getScoreColor()** for score colors
- **CommonButtonStyles** for button appearance
- **CommonTextStyles** for text appearance
- **Established spacing values** (16px horizontal, 4px vertical, 20px between sections)

**Never Do:**
```swift
// ❌ WRONG: Hardcoded colors or styles
Text("Score")
    .foregroundColor(.red)  // Use ScoreColorUtility instead
    .font(.system(size: 14)) // Use CommonTextStyles instead

Button("Action") {
    // action
}
.background(Color.blue) // Use CommonButtonStyles instead
```

### **Rule 3: Layout Pattern**
**Standard Layout Structure:**
```swift
var body: some View {
    VStack(spacing: 20) {           // Standard spacing
        // Header section
        SectionHeaderText("Title")
        
        // Content section
        VStack(spacing: 16) {       // Standard content spacing
            // Content items
        }
        .padding(.horizontal, 16)   // Standard horizontal padding
        
        // Bottom spacing
        Spacer(minLength: 24)       // Standard bottom spacing
    }
    .padding(.horizontal, 16)       // Standard horizontal padding
    .padding(.top, 20)              // Standard top padding
}
```

---

## 🧩 **Component Creation Rules**

### **Rule 4: New Component Structure**
**Required Elements:**
```swift
import SwiftUI

// MARK: - Component Name
struct ComponentName: View {
    // MARK: - Properties
    let requiredParameter: String
    let optionalParameter: String?
    
    // MARK: - Constants (if applicable)
    private let standardSpacing: CGFloat = 16
    private let standardCornerRadius: CGFloat = 10
    
    // MARK: - Body
    var body: some View {
        // Implementation
    }
}

// MARK: - Convenience Initializers (if applicable)
extension ComponentName {
    static func standardInstance() -> ComponentName {
        ComponentName(requiredParameter: "Default")
    }
}

// MARK: - Preview
#Preview {
    ComponentName(requiredParameter: "Sample")
        .padding()
}
```

### **Rule 5: Component Naming Convention**
**Naming Rules:**
- **Views**: `DescriptiveNameView` (e.g., `EmptyStateView`, `ListRowContainer`)
- **Utilities**: `DescriptiveNameUtility` (e.g., `ScoreColorUtility`)
- **Styles**: `DescriptiveNameStyle` (e.g., `PrimaryButtonStyle`)
- **Services**: `DescriptiveNameService` (e.g., `DataManagementService`)

**File Organization:**
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

## 🔧 **Data Management Rules**

### **Rule 6: Service Layer Pattern**
**Always Use:**
```swift
// ✅ CORRECT: Use DataManagementService
@State private var dataService = DataManagementServiceFactory.createDataManagementService()

// ❌ WRONG: Direct SwiftData access
@Environment(\.modelContext) private var context
```

**Service Implementation Pattern:**
```swift
protocol DataManagementService {
    func fetchData() async throws -> [Data]
    func saveData(_ data: Data) async throws
    func deleteData(_ data: Data) async throws
}

@MainActor
class LocalDataService: ObservableObject, DataManagementService {
    // Implementation
}
```

### **Rule 7: Model Structure Pattern**
**SwiftData Models:**
```swift
@Model
final class ModelName {
    // MARK: - Properties
    @Attribute(.unique) var id: String
    var name: String
    var createdAt: Date
    
    // MARK: - Relationships
    @Relationship(deleteRule: .cascade) var relatedItems: [RelatedModel]?
    
    // MARK: - Computed Properties
    var displayName: String {
        name.isEmpty ? "Untitled" : name
    }
    
    // MARK: - Methods
    func calculateScore() -> Double {
        // Implementation
    }
}
```

---

## 🎨 **UI Component Rules**

### **Rule 8: Button Implementation Pattern**
**Always Use Established Styles:**
```swift
// ✅ CORRECT: Use CommonButtonStyles
PrimaryButton("Action Title", icon: "plus.circle.fill") {
    // action
}

// ✅ CORRECT: Use button styles
Button("Action") {
    // action
}
.buttonStyle(PrimaryButtonStyle())

// ❌ WRONG: Custom button styling
Button("Action") {
    // action
}
.background(Color.blue)
.foregroundColor(.white)
.padding(16)
.cornerRadius(10)
```

### **Rule 9: Text Implementation Pattern**
**Always Use Established Styles:**
```swift
// ✅ CORRECT: Use CommonTextStyles
SectionHeaderText("Section Title")
SecondaryText("Secondary information")
CaptionText("Caption text", weight: .medium)

// ✅ CORRECT: Use text modifiers
Text("Custom text")
    .sectionHeaderStyle()
    .secondaryStyle()

// ❌ WRONG: Custom text styling
Text("Title")
    .font(.title)
    .fontWeight(.bold)
    .foregroundColor(.primary)
```

### **Rule 10: Empty State Pattern**
**Always Use EmptyStateView:**
```swift
// ✅ CORRECT: Use EmptyStateView
EmptyStateView.locationsEmptyState {
    // action
}

// ❌ WRONG: Custom empty state
VStack(spacing: 20) {
    Image(systemName: "mappin.and.ellipse")
    Text("No Locations")
    Button("Create Location") { }
}
```

---

## 📱 **View Structure Rules**

### **Rule 11: Main View Structure**
**Standard Main View Pattern:**
```swift
struct MainView: View {
    // MARK: - Environment & State
    @Environment(\.modelContext) private var context
    @State private var dataService = DataManagementServiceFactory.createDataManagementService()
    @State private var data: [Model] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if data.isEmpty {
                    EmptyStateView.standardEmptyState {
                        // action
                    }
                } else {
                    List {
                        ForEach(data) { item in
                            ListRowContainer(destination: DetailView(item: item)) {
                                ItemRowView(item: item)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Title")
            .toolbar {
                // Toolbar items
            }
            .onAppear {
                loadData()
            }
        }
    }
    
    // MARK: - Methods
    private func loadData() {
        // Implementation
    }
}
```

### **Rule 12: Row View Pattern**
**Standard Row Structure:**
```swift
struct ItemRowView: View {
    let item: Item
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Left side - Main content
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Right side - Action/Status
            CompactScoreGauge(
                score: item.score,
                maxScore: 5.0
            )
        }
    }
}
```

---

## 🎨 **Styling Constants**

### **Rule 13: Standard Spacing Values**
**Always Use These Values:**
```swift
// Standard spacing constants
private let standardSpacing: CGFloat = 16
private let standardVerticalSpacing: CGFloat = 4
private let standardSectionSpacing: CGFloat = 20
private let standardBottomSpacing: CGFloat = 24

// Standard padding values
private let standardHorizontalPadding: CGFloat = 16
private let standardVerticalPadding: CGFloat = 4
private let standardTopPadding: CGFloat = 20

// Standard corner radius values
private let standardCornerRadius: CGFloat = 10
private let standardLargeCornerRadius: CGFloat = 16
private let standardSmallCornerRadius: CGFloat = 8
```

### **Rule 14: Standard Font Sizes**
**Always Use These Font Sizes:**
```swift
// Standard font sizes
private let standardTitleFont: Font = .title
private let standardTitle2Font: Font = .title2
private let standardTitle3Font: Font = .title3
private let standardHeadlineFont: Font = .headline
private let standardBodyFont: Font = .body
private let standardSubheadlineFont: Font = .subheadline
private let standardCaptionFont: Font = .caption
private let standardCaption2Font: Font = .caption2
```

---

## 🔒 **Refactoring Rules**

### **Rule 15: Refactoring Approval Process**
**Before Any Refactoring:**
1. **Read this rulebook** - Understand established patterns
2. **Run validation script** - `./REFACTORING_VALIDATION_SCRIPT.sh`
3. **Take screenshots** - Document current state
4. **Plan changes** - Document what will change
5. **Follow safeguards** - Use established refactoring process

### **Rule 16: Component Extraction Rules**
**When Extracting Components:**
1. **Maintain visual fidelity** - Must look exactly the same
2. **Preserve functionality** - Must work exactly the same
3. **Follow naming conventions** - Use established patterns
4. **Place in correct directory** - Follow file organization rules
5. **Update existing usage** - Replace all instances consistently

---

## 🚫 **Forbidden Practices**

### **Rule 17: Never Do These**
- ❌ **Hardcode colors** - Always use ScoreColorUtility
- ❌ **Custom button styling** - Always use CommonButtonStyles
- ❌ **Custom text styling** - Always use CommonTextStyles
- ❌ **Inline empty states** - Always use EmptyStateView
- ❌ **Direct SwiftData access** - Always use DataManagementService
- ❌ **Custom spacing values** - Always use standard spacing constants
- ❌ **Custom font sizes** - Always use standard font constants
- ❌ **Duplicate UI patterns** - Always extract to shared components

### **Rule 18: Architecture Violations**
- ❌ **Bypass service layer** - Don't access data directly
- ❌ **Create circular dependencies** - Keep dependencies one-way
- ❌ **Mix concerns** - Keep components focused on single responsibility
- ❌ **Ignore established patterns** - Don't reinvent what already works

---

## ✅ **Compliance Checklist**

### **Before Submitting Any Code:**
- [ ] **Follows established naming conventions**
- [ ] **Uses established styling patterns**
- [ ] **Placed in correct directory structure**
- [ ] **Uses service layer for data access**
- [ ] **Maintains visual and functional fidelity**
- [ ] **Follows component structure patterns**
- [ ] **Uses standard spacing and font values**
- [ ] **No hardcoded colors or styles**
- [ ] **No duplicate UI patterns**
- [ ] **Passes refactoring validation**

---

## 📚 **Reference Examples**

### **Good Examples:**
- `EmptyStateView.swift` - Perfect component extraction
- `ScoreColorUtility.swift` - Perfect utility organization
- `CommonButtonStyles.swift` - Perfect styling system
- `LocationListView.swift` - Perfect main view structure

### **Pattern to Follow:**
- Extract reusable components to `Views/Shared/`
- Use established styling systems
- Follow naming conventions
- Maintain single responsibility
- Document with MARK comments
- Include preview examples

---

## 🔄 **Continuous Improvement**

### **After Each Development Cycle:**
1. **Review patterns** - What worked well? What could be improved?
2. **Update rules** - Refine based on experience
3. **Share knowledge** - Team understanding of patterns
4. **Celebrate consistency** - Acknowledge when patterns are followed

---

## 📞 **Rule Enforcement**

### **If Rules Are Violated:**
1. **Immediate correction** - Fix violations before proceeding
2. **Code review** - Ensure compliance in future
3. **Pattern education** - Share correct patterns with team
4. **Documentation update** - Refine rules if needed

---

*Last Updated: [Current Date]*
*Version: 1.0*
*Status: ACTIVE - Must be followed for all development work*
*Enforcement: MANDATORY - No exceptions without approval*
