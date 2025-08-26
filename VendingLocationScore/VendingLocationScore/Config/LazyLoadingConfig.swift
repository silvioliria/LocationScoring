import Foundation

// MARK: - Lazy Loading Configuration
public struct LazyLoadingConfig {
    public let pageSize: Int
    public let preloadThreshold: Int
    public let memoryOptimizationEnabled: Bool
    public let maxItemsInMemory: Int
    
    public init(
        pageSize: Int,
        preloadThreshold: Int,
        memoryOptimizationEnabled: Bool,
        maxItemsInMemory: Int
    ) {
        self.pageSize = pageSize
        self.preloadThreshold = preloadThreshold
        self.memoryOptimizationEnabled = memoryOptimizationEnabled
        self.maxItemsInMemory = maxItemsInMemory
    }
    
    // MARK: - Preset Configurations
    
    /// Default configuration with balanced performance and memory usage
    public static let `default` = LazyLoadingConfig(
        pageSize: 20,
        preloadThreshold: 5,
        memoryOptimizationEnabled: true,
        maxItemsInMemory: 100
    )
    
    /// Aggressive configuration for memory-constrained devices
    public static let aggressive = LazyLoadingConfig(
        pageSize: 10,
        preloadThreshold: 3,
        memoryOptimizationEnabled: true,
        maxItemsInMemory: 50
    )
    
    /// Conservative configuration for high-performance devices
    public static let conservative = LazyLoadingConfig(
        pageSize: 50,
        preloadThreshold: 10,
        memoryOptimizationEnabled: false,
        maxItemsInMemory: 200
    )
}
