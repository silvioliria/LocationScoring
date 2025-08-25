import SwiftUI

// MARK: - Score Color Utility
struct ScoreColorUtility {
    /// Returns the appropriate color for a given score value
    /// - Parameter score: The score value (typically 0-5)
    /// - Returns: Color representing the score level
    static func getScoreColor(_ score: Double) -> Color {
        switch score {
        case 0: return .gray
        case 0..<2: return .red
        case 2..<3: return .orange
        case 3..<4: return .yellow
        case 4..<5: return .green
        default: return .blue
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 15) {
            VStack {
                Circle()
                    .fill(ScoreColorUtility.getScoreColor(0))
                    .frame(width: 30, height: 30)
                Text("0")
                    .font(.caption)
            }
            
            VStack {
                Circle()
                    .fill(ScoreColorUtility.getScoreColor(1.5))
                    .frame(width: 30, height: 30)
                Text("1.5")
                    .font(.caption)
            }
            
            VStack {
                Circle()
                    .fill(ScoreColorUtility.getScoreColor(2.5))
                    .frame(width: 30, height: 30)
                Text("2.5")
                    .font(.caption)
            }
            
            VStack {
                Circle()
                    .fill(ScoreColorUtility.getScoreColor(3.5))
                    .frame(width: 30, height: 30)
                Text("3.5")
                    .font(.caption)
            }
            
            VStack {
                Circle()
                    .fill(ScoreColorUtility.getScoreColor(4.5))
                    .frame(width: 30, height: 30)
                Text("4.5")
                    .font(.caption)
            }
            
            VStack {
                Circle()
                    .fill(ScoreColorUtility.getScoreColor(5.0))
                    .frame(width: 30, height: 30)
                Text("5.0")
                    .font(.caption)
            }
        }
        
        Text("Score Color Utility Preview")
            .font(.headline)
    }
    .padding()
}
