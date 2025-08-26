import Foundation
import SwiftData
import Combine

// MARK: - Lazy Loading Service
class LazyLoadingService<T: PersistentModel, R: RepositoryProtocol>: ObservableObject where R.Entity == T {
    
    // MARK: - Published Properties
    @Published var items: [T] = []
    @Published var isLoading = false
    @Published var hasMoreItems = true
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let repository: R
    private let pageSize: Int
    private var currentPage = 0
    private var currentPredicate: Predicate<T>?
    private var currentSortBy: [SortDescriptor<T>]
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(repository: R, pageSize: Int = 20, sortBy: [SortDescriptor<T>] = []) {
        self.repository = repository
        self.pageSize = pageSize
        self.currentSortBy = sortBy
    }
    
    // MARK: - Public Methods
    
    func refresh() async {
        print("🔄 LazyLoadingService.refresh() called")
        await MainActor.run {
            self.currentPage = 0
            self.items = []
            self.hasMoreItems = true
            self.errorMessage = nil
        }
        
        print("🔄 About to call loadNextPage()")
        await loadNextPage()
        print("🔄 loadNextPage() completed, items count: \(items.count)")
    }
    
    func loadNextPage() async {
        guard !isLoading && hasMoreItems else { return }
        
        print("🔄 loadNextPage: Starting fetch for page \(currentPage)")
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            print("🔄 loadNextPage: Calling repository.fetch with page: \(currentPage), pageSize: \(pageSize)")
            let result = try await repository.fetch(
                page: currentPage,
                pageSize: pageSize,
                predicate: currentPredicate,
                sortBy: currentSortBy
            )
            
            print("🔄 loadNextPage: Repository returned \(result.items.count) items, totalCount: \(result.totalCount)")
            
            await MainActor.run {
                if currentPage == 0 {
                    self.items = result.items
                } else {
                    self.items.append(contentsOf: result.items)
                }
                
                self.hasMoreItems = result.hasNextPage
                self.currentPage = result.currentPage
                self.isLoading = false
            }
            
        } catch {
            print("🔄 loadNextPage: Error occurred: \(error)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func loadMoreIfNeeded(currentItem item: T) async {
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if let itemIndex = items.firstIndex(where: { $0.id == item.id }),
           itemIndex >= thresholdIndex {
            await loadNextPage()
        }
    }
    
    func filter(predicate: Predicate<T>?) async {
        await MainActor.run {
            self.currentPage = 0
            self.items = []
            self.hasMoreItems = true
            self.currentPredicate = predicate
        }
        
        await loadNextPage()
    }
    
    func sort(by sortDescriptors: [SortDescriptor<T>]) async {
        await MainActor.run {
            self.currentPage = 0
            self.items = []
            self.hasMoreItems = true
            self.currentSortBy = sortDescriptors
        }
        
        await loadNextPage()
    }
    
    // MARK: - Search
    func search(query: String) async {
        // This would need to be implemented based on the specific entity type
        // For now, we'll just refresh with the current predicate
        await refresh()
    }
    
    // MARK: - Memory Management
    func clearMemory() {
        // Keep only the current page in memory
        let startIndex = max(0, currentPage * pageSize)
        let endIndex = min(items.count, (currentPage + 1) * pageSize)
        
        if startIndex < endIndex {
            items = Array(items[startIndex..<endIndex])
        }
    }
    
    func optimizeMemory() {
        // Remove items that are far from the current view
        let keepRange = max(0, currentPage - 1)...(currentPage + 1)
        let startIndex = keepRange.lowerBound * pageSize
        let endIndex = min(items.count, keepRange.upperBound * pageSize)
        
        if startIndex < endIndex {
            items = Array(items[startIndex..<endIndex])
        }
    }
}

// MARK: - Lazy Loading Configuration
struct LazyLoadingConfig {
    let pageSize: Int
    let preloadThreshold: Int
    let memoryOptimizationEnabled: Bool
    let maxItemsInMemory: Int
    
    static let `default` = LazyLoadingConfig(
        pageSize: 20,
        preloadThreshold: 5,
        memoryOptimizationEnabled: true,
        maxItemsInMemory: 100
    )
    
    static let aggressive = LazyLoadingConfig(
        pageSize: 10,
        preloadThreshold: 3,
        memoryOptimizationEnabled: true,
        maxItemsInMemory: 50
    )
    
    static let conservative = LazyLoadingConfig(
        pageSize: 50,
        preloadThreshold: 10,
        memoryOptimizationEnabled: false,
        maxItemsInMemory: 200
    )
}

// MARK: - Lazy Loading Delegate
protocol LazyLoadingDelegate: AnyObject {
    func didLoadItems(_ items: [Any])
    func didEncounterError(_ error: Error)
    func loadingStateChanged(_ isLoading: Bool)
}

// MARK: - Memory Monitor
class MemoryMonitor: ObservableObject {
    @Published var memoryUsage: Double = 0.0
    @Published var shouldOptimizeMemory = false
    
    private var timer: Timer?
    private let memoryThreshold: Double = 0.8 // 80% of available memory
    
    init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkMemoryUsage()
        }
    }
    
    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkMemoryUsage() {
        let usage = getMemoryUsage()
        
        DispatchQueue.main.async {
            self.memoryUsage = usage
            self.shouldOptimizeMemory = usage > self.memoryThreshold
        }
    }
    
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMemory = Double(info.resident_size)
            let totalMemory = Double(ProcessInfo.processInfo.physicalMemory)
            return usedMemory / totalMemory
        }
        
        return 0.0
    }
}
