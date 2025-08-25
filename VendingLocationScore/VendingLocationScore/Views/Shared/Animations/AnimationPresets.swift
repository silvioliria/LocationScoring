import SwiftUI

// MARK: - Animation Presets
struct AnimationPresets {
    
    // MARK: - Entry Animations
    struct Entry {
        /// Fade in with slight scale up
        static let fadeInScale = SwiftUI.Animation.easeOut(duration: 0.3)
        
        /// Slide up from bottom
        static let slideUp = SwiftUI.Animation.spring(
            response: 0.4,
            dampingFraction: 0.8,
            blendDuration: 0
        )
        
        /// Slide in from left
        static let slideInLeft = SwiftUI.Animation.easeOut(duration: 0.3)
        
        /// Slide in from right
        static let slideInRight = SwiftUI.Animation.easeOut(duration: 0.3)
        
        /// Bounce in with spring
        static let bounceIn = SwiftUI.Animation.spring(
            response: 0.5,
            dampingFraction: 0.6,
            blendDuration: 0
        )
        
        /// Staggered entry for lists
        static let staggered = SwiftUI.Animation.easeOut(duration: 0.4)
    }
    
    // MARK: - Exit Animations
    struct Exit {
        /// Fade out with slight scale down
        static let fadeOutScale = SwiftUI.Animation.easeIn(duration: 0.2)
        
        /// Slide down to bottom
        static let slideDown = SwiftUI.Animation.easeIn(duration: 0.2)
        
        /// Slide out to left
        static let slideOutLeft = SwiftUI.Animation.easeIn(duration: 0.2)
        
        /// Slide out to right
        static let slideOutRight = SwiftUI.Animation.easeIn(duration: 0.2)
        
        /// Quick fade out
        static let quickFade = SwiftUI.Animation.easeIn(duration: 0.15)
    }
    
    // MARK: - State Change Animations
    struct StateChange {
        /// Smooth transition for state changes
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        
        /// Quick state change
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        
        /// Slow, deliberate state change
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        
        /// Spring-based state change
        static let spring = SwiftUI.Animation.spring(
            response: 0.4,
            dampingFraction: 0.8,
            blendDuration: 0
        )
    }
    
    // MARK: - Interactive Animations
    struct Interactive {
        /// Button press animation
        static let buttonPress = SwiftUI.Animation.easeInOut(duration: 0.1)
        
        /// Card selection animation
        static let cardSelection = SwiftUI.Animation.spring(
            response: 0.3,
            dampingFraction: 0.7,
            blendDuration: 0
        )
        
        /// List row selection
        static let rowSelection = SwiftUI.Animation.easeInOut(duration: 0.2)
        
        /// Toggle animation
        static let toggle = SwiftUI.Animation.spring(
            response: 0.3,
            dampingFraction: 0.6,
            blendDuration: 0
        )
        
        /// Slider animation
        static let slider = SwiftUI.Animation.easeOut(duration: 0.2)
    }
    
    // MARK: - Loading Animations
    struct Loading {
        /// Spinner rotation
        static let spinner = SwiftUI.Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
        
        /// Pulse animation
        static let pulse = SwiftUI.Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        
        /// Shimmer animation
        static let shimmer = SwiftUI.Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)
        
        /// Bounce loading
        static let bounce = SwiftUI.Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)
    }
    
    // MARK: - Success/Error Animations
    struct Feedback {
        /// Success checkmark animation
        static let success = SwiftUI.Animation.spring(
            response: 0.4,
            dampingFraction: 0.6,
            blendDuration: 0
        )
        
        /// Error shake animation
        static let error = SwiftUI.Animation.easeInOut(duration: 0.1)
        
        /// Warning pulse
        static let warning = SwiftUI.Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
        
        /// Info highlight
        static let info = SwiftUI.Animation.easeInOut(duration: 0.3)
    }
    
    // MARK: - Navigation Animations
    struct Navigation {
        /// Push navigation
        static let push = SwiftUI.Animation.easeInOut(duration: 0.3)
        
        /// Pop navigation
        static let pop = SwiftUI.Animation.easeInOut(duration: 0.25)
        
        /// Modal presentation
        static let modal = SwiftUI.Animation.spring(
            response: 0.4,
            dampingFraction: 0.8,
            blendDuration: 0
        )
        
        /// Sheet presentation
        static let sheet = SwiftUI.Animation.easeOut(duration: 0.3)
    }
    
    // MARK: - List Animations
    struct List {
        /// Row insertion
        static let rowInsert = SwiftUI.Animation.spring(
            response: 0.4,
            dampingFraction: 0.8,
            blendDuration: 0
        )
        
        /// Row deletion
        static let rowDelete = SwiftUI.Animation.easeIn(duration: 0.2)
        
        /// Row move
        static let rowMove = SwiftUI.Animation.easeInOut(duration: 0.3)
        
        /// Staggered list appearance
        static let staggered = SwiftUI.Animation.easeOut(duration: 0.4)
    }
    
    // MARK: - Score Gauge Animations
    struct ScoreGauge {
        /// Score fill animation
        static let fill = SwiftUI.Animation.easeOut(duration: 0.8)
        
        /// Score color transition
        static let colorChange = SwiftUI.Animation.easeInOut(duration: 0.4)
        
        /// Gauge bounce on update
        static let bounce = SwiftUI.Animation.spring(
            response: 0.5,
            dampingFraction: 0.6,
            blendDuration: 0
        )
    }
}

// MARK: - Animation Modifiers
extension View {
    
    // MARK: - Entry Animations
    /// Fade in with scale animation
    func fadeInScale(delay: Double = 0) -> some View {
        self
            .opacity(0)
            .scaleEffect(0.95)
            .animation(
                AnimationPresets.Entry.fadeInScale.delay(delay),
                value: true
            )
            .onAppear {
                withAnimation(AnimationPresets.Entry.fadeInScale.delay(delay)) {
                    // Trigger animation
                }
            }
    }
    
    /// Slide up from bottom animation
    func slideUp(delay: Double = 0) -> some View {
        self
            .offset(y: 50)
            .opacity(0)
            .animation(
                AnimationPresets.Entry.slideUp.delay(delay),
                value: true
            )
            .onAppear {
                withAnimation(AnimationPresets.Entry.slideUp.delay(delay)) {
                    // Trigger animation
                }
            }
    }
    
    /// Staggered entry animation
    func staggeredEntry(index: Int, totalDelay: Double = 0.5) -> some View {
        let delay = Double(index) * (totalDelay / Double(max(1, index)))
        return self
            .opacity(0)
            .offset(y: 20)
            .animation(
                AnimationPresets.Entry.staggered.delay(delay),
                value: true
            )
            .onAppear {
                withAnimation(AnimationPresets.Entry.staggered.delay(delay)) {
                    // Trigger animation
                }
            }
    }
    
    // MARK: - Interactive Animations
    /// Button press animation
    func buttonPress() -> some View {
        self
            .scaleEffect(1.0)
            .animation(AnimationPresets.Interactive.buttonPress, value: true)
    }
    
    /// Card selection animation
    func cardSelection(isSelected: Bool) -> some View {
        self
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: Color.black.opacity(isSelected ? 0.2 : 0.1),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .animation(AnimationPresets.Interactive.cardSelection, value: isSelected)
    }
    
    /// List row selection animation
    func rowSelection(isSelected: Bool) -> some View {
        self
            .background(
                Color.blue.opacity(isSelected ? 0.1 : 0)
                    .animation(AnimationPresets.Interactive.rowSelection, value: isSelected)
            )
    }
    
    // MARK: - Loading Animations
    /// Spinner rotation animation
    func spinnerRotation() -> some View {
        self
            .rotationEffect(.degrees(360))
            .animation(AnimationPresets.Loading.spinner, value: true)
    }
    
    /// Pulse animation
    func pulse() -> some View {
        self
            .scaleEffect(1.0)
            .animation(AnimationPresets.Loading.pulse, value: true)
    }
    
    // MARK: - Feedback Animations
    /// Success animation
    func successAnimation() -> some View {
        self
            .scaleEffect(1.0)
            .animation(AnimationPresets.Feedback.success, value: true)
    }
    
    /// Error shake animation
    func errorShake() -> some View {
        self
            .offset(x: 0)
            .animation(AnimationPresets.Feedback.error, value: true)
    }
    
    // MARK: - Score Gauge Animations
    /// Score gauge fill animation
    func scoreGaugeFill(score: Double, maxScore: Double = 5.0) -> some View {
        self
            .animation(AnimationPresets.ScoreGauge.fill, value: score)
    }
    
    /// Score gauge color transition
    func scoreGaugeColor(score: Double, maxScore: Double = 5.0) -> some View {
        self
            .animation(AnimationPresets.ScoreGauge.colorChange, value: score)
    }
}

// MARK: - Animation Utilities
struct AnimationUtilities {
    
    /// Create staggered animation delays
    static func staggeredDelay(index: Int, baseDelay: Double = 0.1, maxDelay: Double = 1.0) -> Double {
        let delay = Double(index) * baseDelay
        return min(delay, maxDelay)
    }
    
    /// Create spring animation with custom parameters
    static func customSpring(
        response: Double = 0.4,
        dampingFraction: Double = 0.8,
        blendDuration: Double = 0
    ) -> SwiftUI.Animation {
        SwiftUI.Animation.spring(
            response: response,
            dampingFraction: dampingFraction,
            blendDuration: blendDuration
        )
    }
    
    /// Create ease animation with custom duration
    static func customEase(duration: Double = 0.3, curve: Animation.TimingCurve = .easeInOut) -> SwiftUI.Animation {
        switch curve {
        case .easeIn:
            return SwiftUI.Animation.easeIn(duration: duration)
        case .easeOut:
            return SwiftUI.Animation.easeOut(duration: duration)
        case .easeInOut:
            return SwiftUI.Animation.easeInOut(duration: duration)
        }
    }
}

// MARK: - Animation Timing Curves
extension Animation {
    enum TimingCurve {
        case easeIn
        case easeOut
        case easeInOut
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Entry animations
        VStack(alignment: .leading, spacing: 16) {
            Text("Entry Animations")
                .font(.headline)
            
            HStack(spacing: 16) {
                Text("Fade In")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .fadeInScale()
                
                Text("Slide Up")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .slideUp()
            }
        }
        
        // Interactive animations
        VStack(alignment: .leading, spacing: 16) {
            Text("Interactive Animations")
                .font(.headline)
            
            HStack(spacing: 16) {
                Text("Button")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .buttonPress()
                
                Text("Card")
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .cardSelection(isSelected: true)
            }
        }
        
        // Loading animations
        VStack(alignment: .leading, spacing: 16) {
            Text("Loading Animations")
                .font(.headline)
            
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                    .spinnerRotation()
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 20, height: 20)
                    .pulse()
            }
        }
    }
    .padding()
}
