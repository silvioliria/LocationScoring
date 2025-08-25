import SwiftUI

// MARK: - Compact Score Gauge
struct CompactScoreGauge: View {
    let score: Double
    let maxScore: Double
    
    // MARK: - Computed Properties
    private var normalizedScore: Double {
        score / maxScore
    }
    
    private var scoreColor: Color {
        ScoreColorUtility.getScoreColor(score)
    }
    
    // MARK: - Theme Constants
    private let frameSize: CGFloat = 42
    private let strokeWidth: CGFloat = 4
    private let centerFont: Font = .callout
    private let centerFontWeight: Font.Weight = .semibold
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(AppTheme.Colors.borderLight, lineWidth: AppTheme.Components.ScoreGauge.strokeWidth)
                .frame(width: AppTheme.Components.ScoreGauge.size, height: AppTheme.Components.ScoreGauge.size)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: normalizedScore)
                .stroke(scoreColor, style: StrokeStyle(lineWidth: AppTheme.Components.ScoreGauge.strokeWidth, lineCap: .round))
                .frame(width: AppTheme.Components.ScoreGauge.size, height: AppTheme.Components.ScoreGauge.size)
                .rotationEffect(.degrees(-90))
                .animation(AnimationPresets.ScoreGauge.fill, value: normalizedScore)
            
            // Score text
            Text(String(format: "%.1f", score))
                .font(AppTheme.Components.ScoreGauge.fontSize)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .animation(AnimationPresets.ScoreGauge.colorChange, value: score)
        }
        .frame(width: AppTheme.Components.ScoreGauge.size, height: AppTheme.Components.ScoreGauge.size)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        Text("Compact Score Gauge Preview")
            .font(.headline)
        
        HStack(spacing: 20) {
            CompactScoreGauge(score: 0.0, maxScore: 5.0)
            CompactScoreGauge(score: 2.5, maxScore: 5.0)
            CompactScoreGauge(score: 4.8, maxScore: 5.0)
        }
        
        HStack(spacing: 20) {
            CompactScoreGauge(score: 1.2, maxScore: 5.0)
            CompactScoreGauge(score: 3.1, maxScore: 5.0)
            CompactScoreGauge(score: 5.0, maxScore: 5.0)
        }
    }
    .padding()
}
