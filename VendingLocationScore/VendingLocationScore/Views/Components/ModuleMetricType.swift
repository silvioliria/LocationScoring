import Foundation

// Protocol for all metric types to ensure consistency
protocol ModuleMetricType: CaseIterable, Identifiable {
    var title: String { get }
    var description: String { get }
}

// Extension to provide default implementation for types that don't have title/description
extension ModuleMetricType {
    var displayName: String {
        if let stringConvertible = self as? any RawRepresentable, let rawValue = stringConvertible.rawValue as? String {
            return rawValue.replacingOccurrences(of: "_", with: " ")
                .capitalized
        }
        return String(describing: self)
    }
}
