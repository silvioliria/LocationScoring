import Foundation
import SwiftData

// MARK: - Lazy Loading Error
enum LazyLoadingError: Error, LocalizedError {
    case invalidThresholdIndex
    case repositoryError(Error)
    case invalidConfiguration
    
    var errorDescription: String? {
        switch self {
        case .invalidThresholdIndex:
            return "Invalid threshold index for pagination"
        case .repositoryError(let error):
            return "Repository error: \(error.localizedDescription)"
        case .invalidConfiguration:
            return "Invalid lazy loading configuration"
        }
    }
}

// MARK: - Lazy Loading Service
@MainActor
final class LazyLoadingService<T: PersistentModel, R: RepositoryProtocol>: ObservableObject where R.Entity == T {
    
    // MARK: - Published Properties
    @Published var items: [T] = []
    @Published var isLoading = false
    @Published var hasMoreItems = true
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let repository: R
    private let config: LazyLoadingConfig
    private var currentPage = 0
    private var currentPredicate: Predicate<T>?
    private var currentSortBy: [SortDescriptor<T>]
    private var currentTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(repository: R, config: LazyLoadingConfig = .default, sortBy: [SortDescriptor<T>] = []) {
        self.repository = repository
        self.config = config
        self.currentSortBy = sortBy
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Refreshes the data by resetting pagination and loading the first page
    func refresh() async {
        print("🔄 LazyLoadingService.refresh() called")
        currentPage = 0
        items = []
        hasMoreItems = true
        errorMessage = nil
        
        print("🔄 About to call loadNextPage()")
        await loadNextPage()
        print("🔄 loadNextPage() completed, items count: \(items.count)")
    }
    
    /// Loads the next page of data if available and not currently loading
    func loadNextPage() async {
        guard !isLoading && hasMoreItems else { return }
        
        print("🔄 loadNextPage: Starting fetch for page \(currentPage)")
        isLoading = true
        errorMessage = nil
        
        do {
                    print("🔄 loadNextPage: Calling repository.fetch with page: \(currentPage), pageSize: \(config.pageSize)")
        let result = try await repository.fetch(
            page: currentPage,
            pageSize: config.pageSize,
            predicate: currentPredicate,
            sortBy: currentSortBy
        )
            
            print("🔄 loadNextPage: Repository returned \(result.items.count) items, totalCount: \(result.totalCount)")
            
            if currentPage == 0 {
                items = result.items
            } else {
                items.append(contentsOf: result.items)
            }
            
            hasMoreItems = result.hasNextPage
            currentPage = result.currentPage
            isLoading = false
            
        } catch {
            print("🔄 loadNextPage: Error occurred: \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    /// Loads more data if the current item is near the end of the list
    /// - Parameter item: The current item being displayed
    func loadMoreIfNeeded(currentItem item: T) async {
        // Guard against array index out-of-bounds crash
        guard items.count >= 5 else { return }
        
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if let itemIndex = items.firstIndex(where: { $0.id == item.id }),
           itemIndex >= thresholdIndex {
            await loadNextPage()
        }
    }
    
    /// Filters the data using a predicate and resets pagination
    /// - Parameter predicate: The predicate to filter by
    func filter(predicate: Predicate<T>?) async {
        currentPage = 0
        items = []
        hasMoreItems = true
        currentPredicate = predicate
        
        await loadNextPage()
    }
    
    /// Sorts the data using sort descriptors and resets pagination
    /// - Parameter sortDescriptors: The sort descriptors to apply
    func sort(by sortDescriptors: [SortDescriptor<T>]) async {
        currentPage = 0
        items = []
        hasMoreItems = true
        currentSortBy = sortDescriptors
        
        await loadNextPage()
    }
    
    /// Searches for items matching the query
    /// - Parameter query: The search query string
    func search(query: String) async {
        // This would need to be implemented based on the specific entity type
        // For now, we'll just refresh with the current predicate
        await refresh()
    }
    
    /// Cancels any ongoing operations
    func cancel() {
        currentTask?.cancel()
        currentTask = nil
        isLoading = false
    }
    
    // MARK: - Memory Management
    
    /// Clears memory by keeping only the current page in memory
    func clearMemory() {
        // Keep only the current page in memory
        let startIndex = max(0, currentPage * config.pageSize)
        let endIndex = min(items.count, (currentPage + 1) * config.pageSize)
        
        if startIndex < endIndex {
            items = Array(items[startIndex..<endIndex])
        }
    }
    
    /// Optimizes memory by removing items that are far from the current view
    func optimizeMemory() {
        // Remove items that are far from the current view
        let keepRange = max(0, currentPage - 1)...(currentPage + 1)
        let startIndex = keepRange.lowerBound * config.pageSize
        let endIndex = min(items.count, keepRange.upperBound * config.pageSize)
        
        if startIndex < endIndex {
            items = Array(items[startIndex..<endIndex])
        }
    }
}



// MARK: - Lazy Loading Delegate
protocol LazyLoadingDelegate: AnyObject {
    func didLoadItems(_ items: [Any])
    func didEncounterError(_ error: Error)
    func loadingStateChanged(_ isLoading: Bool)
}

// MARK: - Memory Monitor
@MainActor
final class MemoryMonitor: ObservableObject {
    @Published var memoryUsage: Double = 0.0
    @Published var shouldOptimizeMemory = false
    
    private var timer: Timer?
    private let memoryThreshold: Double = 0.8 // 80% of available memory
    private var isMonitoring = false
    
    init() {
        startMonitoring()
    }
    
    deinit {
        Task { @MainActor in
            stopMonitoring()
        }
    }
    
    /// Starts memory monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkMemoryUsage()
            }
        }
    }
    
    /// Stops memory monitoring
    func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
    }
    
    private func checkMemoryUsage() {
        let usage = getMemoryUsage()
        
        memoryUsage = usage
        shouldOptimizeMemory = usage > memoryThreshold
    }
    
    private func getMemoryUsage() -> Double {
        #if os(iOS) || os(macOS)
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
        #endif
        
        return 0.0
    }
}
