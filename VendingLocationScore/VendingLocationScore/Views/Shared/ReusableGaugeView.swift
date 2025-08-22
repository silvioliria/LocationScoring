import SwiftUI

// MARK: - Reusable Gauge View
struct ReusableGaugeView: View {
    let score: Double
    let maxScore: Double
    let size: GaugeSize
    let showBackground: Bool
    let animate: Bool
    
    // Computed properties
    private var normalizedScore: Double {
        guard score > 0 else { return 0.0 }
        return min(score / maxScore, 1.0)
    }
    
    private var scoreColor: Color {
        switch score {
        case 0: return .gray
        case 0..<2: return .red
        case 2..<3: return .orange
        case 3..<4: return .yellow
        case 4..<5: return .green
        default: return .blue
        }
    }
    
    private var strokeWidth: CGFloat {
        switch size {
        case .small: return 4
        case .medium: return 8
        case .large: return 12
        }
    }
    
    private var frameSize: CGFloat {
        switch size {
        case .small: return 60
        case .medium: return 80
        case .large: return 100
        }
    }
    
    private var centerFont: Font {
        switch size {
        case .small: return .title2
        case .medium: return .title
        case .large: return .title
        }
    }
    
    private var centerFontWeight: Font.Weight {
        switch size {
        case .small: return .bold
        case .medium: return .bold
        case .large: return .bold
        }
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: strokeWidth)
                .frame(width: frameSize, height: frameSize)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: normalizedScore)
                .stroke(
                    score > 0 ? scoreColor : Color.gray.opacity(0.3),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: frameSize, height: frameSize)
                .animation(animate ? .easeInOut(duration: 1.0) : .none, value: normalizedScore)
            
            // Center content
            VStack(spacing: size == .large ? 3 : 2) {
                if score == 0 {
                    Text("N/A")
                        .font(centerFont)
                        .fontWeight(centerFontWeight)
                        .foregroundColor(.secondary)
                } else {
                    Text(String(format: "%.1f", score))
                        .font(centerFont)
                        .fontWeight(centerFontWeight)
                        .foregroundColor(scoreColor)
                }
                
                if size == .large {
                    Text("/ \(String(format: "%.1f", maxScore))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Gauge Size Enum
enum GaugeSize {
    case small    // 60x60, stroke width 4
    case medium   // 80x80, stroke width 8
    case large    // 100x100, stroke width 12
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        HStack(spacing: 20) {
            ReusableGaugeView(score: 0.0, maxScore: 5.0, size: .small, showBackground: true, animate: true)
            ReusableGaugeView(score: 2.5, maxScore: 5.0, size: .small, showBackground: true, animate: true)
            ReusableGaugeView(score: 4.8, maxScore: 5.0, size: .small, showBackground: true, animate: true)
        }
        
        HStack(spacing: 20) {
            ReusableGaugeView(score: 0.0, maxScore: 5.0, size: .medium, showBackground: true, animate: true)
            ReusableGaugeView(score: 2.5, maxScore: 5.0, size: .medium, showBackground: true, animate: true)
            ReusableGaugeView(score: 4.8, maxScore: 5.0, size: .medium, showBackground: true, animate: true)
        }
        
        HStack(spacing: 20) {
            ReusableGaugeView(score: 0.0, maxScore: 5.0, size: .large, showBackground: true, animate: true)
            ReusableGaugeView(score: 2.5, maxScore: 5.0, size: .large, showBackground: true, animate: true)
            ReusableGaugeView(score: 4.8, maxScore: 5.0, size: .large, showBackground: true, animate: true)
        }
    }
    .padding()
}
