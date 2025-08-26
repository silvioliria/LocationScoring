import XCTest
import SwiftData
@testable import VendingLocationScore

final class LazyLoadingServiceTests: XCTestCase {
    
    var mockRepository: MockLocationRepository!
    var lazyLoadingService: LazyLoadingService<Location, MockLocationRepository>!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockLocationRepository()
        lazyLoadingService = LazyLoadingService<Location, MockLocationRepository>(
            repository: mockRepository,
            config: .default
        )
    }
    
    override func tearDown() {
        lazyLoadingService = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Pagination Edge Cases
    
    func testLoadMoreIfNeededWithEmptyItems() async {
        // Test with 0 items (should not crash)
        await lazyLoadingService.loadMoreIfNeeded(currentItem: createMockLocation())
        XCTAssertEqual(lazyLoadingService.items.count, 0)
    }
    
    func testLoadMoreIfNeededWithLessThan5Items() async {
        // Test with 3 items (should not crash)
        let locations = [createMockLocation(), createMockLocation(), createMockLocation()]
        lazyLoadingService.items = locations
        
        await lazyLoadingService.loadMoreIfNeeded(currentItem: locations[0])
        XCTAssertEqual(lazyLoadingService.items.count, 3)
    }
    
    func testLoadMoreIfNeededWithExactly5Items() async {
        // Test with exactly 5 items
        let locations = Array(0..<5).map { _ in createMockLocation() }
        lazyLoadingService.items = locations
        
        await lazyLoadingService.loadMoreIfNeeded(currentItem: locations[0])
        XCTAssertEqual(lazyLoadingService.items.count, 5)
    }
    
    func testLoadMoreIfNeededWithMoreThan5Items() async {
        // Test with more than 5 items
        let locations = Array(0..<10).map { _ in createMockLocation() }
        lazyLoadingService.items = locations
        
        await lazyLoadingService.loadMoreIfNeeded(currentItem: locations[0])
        XCTAssertEqual(lazyLoadingService.items.count, 10)
    }
    
    // MARK: - Memory Management Tests
    
    func testClearMemory() {
        let locations = Array(0..<25).map { _ in createMockLocation() }
        lazyLoadingService.items = locations
        lazyLoadingService.currentPage = 1
        
        lazyLoadingService.clearMemory()
        
        // Should keep only current page items
        XCTAssertEqual(lazyLoadingService.items.count, 20)
    }
    
    func testOptimizeMemory() {
        let locations = Array(0..<60).map { _ in createMockLocation() }
        lazyLoadingService.items = locations
        lazyLoadingService.currentPage = 2
        
        lazyLoadingService.optimizeMemory()
        
        // Should keep items from pages 1, 2, and 3
        XCTAssertEqual(lazyLoadingService.items.count, 60)
    }
    
    // MARK: - Configuration Tests
    
    func testDefaultConfiguration() {
        let service = LazyLoadingService<Location, MockLocationRepository>(
            repository: mockRepository,
            config: .default
        )
        
        XCTAssertEqual(service.items.count, 0)
        XCTAssertFalse(service.isLoading)
        XCTAssertTrue(service.hasMoreItems)
    }
    
    func testAggressiveConfiguration() {
        let service = LazyLoadingService<Location, MockLocationRepository>(
            repository: mockRepository,
            config: .aggressive
        )
        
        XCTAssertEqual(service.items.count, 0)
        XCTAssertFalse(service.isLoading)
        XCTAssertTrue(service.hasMoreItems)
    }
    
    // MARK: - Helper Methods
    
    private func createMockLocation() -> Location {
        let location = Location()
        location.id = UUID()
        location.name = "Test Location"
        location.address = "Test Address"
        return location
    }
}

// MARK: - Mock Repository

class MockLocationRepository: RepositoryProtocol {
    typealias Entity = Location
    
    func create(_ entity: Location) async throws {}
    func fetch(id: String) async throws -> Location? { return nil }
    func fetchAll() async throws -> [Location] { return [] }
    func update(_ entity: Location) async throws {}
    func delete(_ entity: Location) async throws {}
    func deleteAll() async throws {}
    func fetch(predicate: Predicate<Location>) async throws -> [Location] { return [] }
    func fetch(predicate: Predicate<Location>, sortBy: [SortDescriptor<Location>]) async throws -> [Location] { return [] }
    func count(predicate: Predicate<Location>?) async throws -> Int { return 0 }
    
    func fetch(page: Int, pageSize: Int, predicate: Predicate<Location>?, sortBy: [SortDescriptor<Location>]) async throws -> PaginatedResult<Location> {
        return PaginatedResult(
            items: [],
            currentPage: page,
            pageSize: pageSize,
            totalCount: 0,
            hasNextPage: false,
            hasPreviousPage: false
        )
    }
}
