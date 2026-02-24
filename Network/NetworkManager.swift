import Foundation

// MARK: - Network Manager
class NetworkManager: NetworkManagerProtocol {
    
    // MARK: - Singleton (convenience)
    static let shared = NetworkManager()

    // MARK: - Init (public for DI)
    init() {}
    
    func fetchProducts() async throws -> [Product] {
        guard let url = URL(string: APIEndpoint.products) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            if let httpResponse = response as? HTTPURLResponse {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
            throw NetworkError.unknown
        }
        
        do {
            let products = try JSONDecoder().decode([Product].self, from: data)

            return products
        } catch {
            throw NetworkError.decodingError
        }
    }
}
