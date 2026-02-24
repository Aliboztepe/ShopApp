import Foundation

// MARK: - Network Manager Protocol
protocol NetworkManagerProtocol {
    func fetchProducts() async throws -> [Product]
}

// MARK: - Default Implementation
extension NetworkManagerProtocol {
}
