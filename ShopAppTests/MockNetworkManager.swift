import Foundation

@testable import ShopApp

class MockNetworkManager: NetworkManagerProtocol {
    
    // MARK: - Mock Data
    var mockProducts: [Product] = []
    var shouldReturnError = false
    var errorToReturn: NetworkError = .invalidURL
    
    // MARK: - Tracking
    var fetchProductsCallCount = 0
    
    // MARK: - NetworkManagerProtocol
    func fetchProducts() async throws -> [Product] {
        fetchProductsCallCount += 1
        
        if shouldReturnError {
            throw errorToReturn
        }
        
        return mockProducts
    }
    
    // MARK: - Helper Methods
    func reset() {
        mockProducts = []
        shouldReturnError = false
        errorToReturn = .invalidURL
        fetchProductsCallCount = 0
    }
    
    // MARK: - Mock Product Factory
    static func crateMockProduct(
        id: Int = 1,
        title: String = "Test Product",
        price: Double = 99.99,
        description: String = "Test Description",
        category: String = "Test Category",
        image: String = "https://test.com/image.jpg"
    ) -> Product {
        return Product(id: id, title: title, price: price, description: description, category: category, image: image)
    }
}
