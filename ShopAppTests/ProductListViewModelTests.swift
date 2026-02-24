import XCTest
@testable import ShopApp

final class ProductListViewModelTests: XCTestCase {

    // MARK: - Properties
    var viewModel: ProductListViewModel!
    var mockNetworkManager: MockNetworkManager!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        viewModel = ProductListViewModel(networkManager: mockNetworkManager)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testFetchProducts_Success_ReturnsProducts() {
        
        let expectation = expectation(description: "Fetch products")
        
        let mockProduct1 = MockNetworkManager.crateMockProduct(
            id: 1,
            title: "Iphone 15 Pro",
            price: 999.99
        )
        
        let mockProduct2 = MockNetworkManager.crateMockProduct(
            id: 2,
            title: "Macbook Pro",
            price: 1999.99
        )
        
        mockNetworkManager.mockProducts = [mockProduct1, mockProduct2]

        viewModel.onProductsUpdated = {
            expectation.fulfill()
        }
        
        viewModel.fetchProducts()
        
        waitForExpectations(timeout: 2.0) { _ in
            XCTAssertEqual(self.viewModel.products.count, 2, "Should have 2 products")
            XCTAssertEqual(self.viewModel.products[0].title, "Iphone 15 Pro")
            XCTAssertEqual(self.viewModel.products[1].title, "Macbook Pro")
            XCTAssertEqual(self.viewModel.loadingState, .success, "Loading state should be success")
            XCTAssertFalse(self.viewModel.isSearching, "Should not be searching")
        }
    }
    
    func testFetchProducts_NetworkError_SetsErrorState() {
        let expectation = expectation(description: "Fetch products error")

        mockNetworkManager.shouldReturnError = true
        mockNetworkManager.errorToReturn = .serverError(statusCode: 404)
        
        viewModel.onLoadingStateChanged = { state in
            if case .error = state {
                expectation.fulfill()
            }
        }
        
        viewModel.fetchProducts()
        
        waitForExpectations(timeout: 2.0) { _ in
            XCTAssertTrue(self.viewModel.products.isEmpty, "Products should be empty on error")
            
            switch self.viewModel.loadingState {
            case .error(let string):
                XCTAssertFalse(string.isEmpty, "Error message should not be empty")
            default:
                XCTFail("Loading state should be error")
            }
            
            XCTAssertEqual(self.mockNetworkManager.fetchProductsCallCount, 1, "Should call fetchProducts once")
        }
    }
    
    func testFilterProducts_EmptySearch_ReturnAllProducts() {
        let mockProduct1 = MockNetworkManager.crateMockProduct(
            id: 1,
            title: "Iphone"
        )
        
        let mockProduct2 = MockNetworkManager.crateMockProduct(
            id: 2,
            title: "Macbook"
        )
        
        viewModel.setProductsForTesting([mockProduct1, mockProduct2])
        
        viewModel.filterProducts(with: "")
        
        XCTAssertEqual(viewModel.filteredProducts.count, 2, "Should return all products")
        XCTAssertFalse(viewModel.isSearching, "Should not be searching with empty string")
    }
    
    func testFilterProducts_WithText_FiltersCorrectly() {
        
        let mockProduct1 = MockNetworkManager.crateMockProduct(
            id: 1,
            title: "Iphone 15 Pro"
        )
        let mockProduct2 = MockNetworkManager.crateMockProduct(
            id: 2,
            title: "Macbook Pro"
        )
        let mockProduct3 = MockNetworkManager.crateMockProduct(
            id: 3,
            title: "Iphone 14"
        )
        
        viewModel.setProductsForTesting([mockProduct1, mockProduct2, mockProduct3])
        
        viewModel.filterProducts(with: "iphone")
        
        XCTAssertEqual(viewModel.filteredProducts.count, 2, "Should return 2 iphones")
        XCTAssertTrue(viewModel.isSearching, "Should be in searching mode")
        
        let titles = viewModel.filteredProducts.map { $0.title }
        
        XCTAssertTrue(titles.contains("Iphone 15 Pro"), "Should contain Iphone 15 Pro")
        XCTAssertTrue(titles.contains("Iphone 14"), "Should contain Iphone 14")
        XCTAssertFalse(titles.contains("Macbook Pro"), "Should not contain Macbook Pro")
    }
    
    func testFilterProducts_CaseInsensitive() {
        let mockProduct1 = MockNetworkManager.crateMockProduct(
            id: 1,
            title: "Iphone 15 Pro"
        )
        let mockProduct2 = MockNetworkManager.crateMockProduct(
            id: 2,
            title: "Macbook Pro"
        )
        
        viewModel.setProductsForTesting([mockProduct1, mockProduct2])
        
        viewModel.filterProducts(with: "IPHONE")
        
        XCTAssertEqual(viewModel.filteredProducts.count, 1, "Should find Iphone with uppercase search")
        XCTAssertEqual(viewModel.filteredProducts[0].title, "Iphone 15 Pro")
        
        viewModel.filterProducts(with: "iPhoNe")
        
        XCTAssertEqual(viewModel.filteredProducts.count, 1, "Should find Iphone with mixed case search")
        XCTAssertEqual(viewModel.filteredProducts[0].title, "Iphone 15 Pro")
        
        viewModel.filterProducts(with: "iphone")
        
        XCTAssertEqual(viewModel.filteredProducts.count, 1, "Should find Iphone with lowercase search")
        XCTAssertEqual(viewModel.filteredProducts[0].title, "Iphone 15 Pro")
    }
    
    func testFilterProducts_NoMatch_ReturnsEmpty() {
        let mockProduct1 = MockNetworkManager.crateMockProduct(
            id: 1,
            title: "Iphone 15 Pro"
        )
        let mockProduct2 = MockNetworkManager.crateMockProduct(
            id: 2,
            title: "Macbook Pro"
        )
        
        viewModel.setProductsForTesting([mockProduct1, mockProduct2])
        
        viewModel.filterProducts(with: "xyz")
        
        XCTAssertTrue(viewModel.filteredProducts.isEmpty, "Should return empty array when no match")
        XCTAssertTrue(viewModel.isSearching, "Should still be in searching mode")
        XCTAssertFalse(viewModel.products.isEmpty, "Original products should not be affected")
    }
    
    func testLoadingState_InitialState_IsIdle() {
        XCTAssertEqual(viewModel.loadingState, .idle, "Initial loading state should be idle")
        XCTAssertTrue(viewModel.products.isEmpty, "Products should be empty initially")
        XCTAssertTrue(viewModel.filteredProducts.isEmpty, "Filtered products should be empty initially")
        XCTAssertFalse(viewModel.isSearching, "Should not be searching initially")
    }
    
    func testLoadingState_WhileLoading_IsLoading() {
        let expectation = expectation(description: "Loading State changed")
        
        mockNetworkManager.mockProducts = [
            MockNetworkManager.crateMockProduct(
                id: 1,
                title: "Test"
            )
        ]
        
        var loadingStateChanges: [LoadingState] = []
        
        viewModel.onLoadingStateChanged = { state in
            loadingStateChanges.append(state)
            if case .success = state {
                expectation.fulfill()
            }
        }
        
        viewModel.fetchProducts()
        
        XCTAssertEqual(viewModel.loadingState, .loading, "Should be loading immediately after fetch")
        
        waitForExpectations(timeout: 2.0) { _ in
            XCTAssertEqual(loadingStateChanges.count, 2, "Should have 2 state changes")
            XCTAssertEqual(loadingStateChanges[0], .loading, "First state should be loading")
            XCTAssertEqual(loadingStateChanges[1], .success, "Second state should be success")
        }
    }
    
    func testFetchProducts_UpdatesFilteredProducts() {
        let expectation = expectation(description: "Products Updated")
        
        let mockProduct1 = MockNetworkManager.crateMockProduct(
            id: 1,
            title: "Iphone 15 Pro"
        )
        let mockProduct2 = MockNetworkManager.crateMockProduct(
            id: 2,
            title: "Macbook Pro"
        )
        
        mockNetworkManager.mockProducts = [mockProduct1, mockProduct2]
        
        viewModel.onProductsUpdated = {
            expectation.fulfill()
        }
        
        viewModel.fetchProducts()
        
        waitForExpectations(timeout: 2.0) { _ in
            XCTAssertEqual(self.viewModel.products.count, 2, "Products should be updated")
            XCTAssertEqual(self.viewModel.filteredProducts.count, 2, "Filtered products should also be updated")
            XCTAssertEqual(self.viewModel.products.first?.id, self.viewModel.filteredProducts.first?.id, "Products and Filtered products should same")
        }
    }
}
