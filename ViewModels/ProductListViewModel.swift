import Foundation

class ProductListViewModel {
    
    // MARK: - Properties
    private let networkManager: NetworkManagerProtocol
    private(set) var products: [Product] = []
    private(set) var filteredProducts: [Product] = []
    private(set) var isSearching = false
    private(set) var loadingState: LoadingState = .idle
    
    // MARK: - Callbacks
    var onProductsUpdated: (() -> Void)?
    var onLoadingStateChanged: ((LoadingState) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Init (Dependency Injection)
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    func fetchProducts() {
        loadingState = .loading
        onLoadingStateChanged?(.loading)
        
        Task {
            do {
                let fetchedProducts = try await networkManager.fetchProducts()
                
                await MainActor.run {
                    self.products = fetchedProducts
                    self.filteredProducts = products
                    self.loadingState = .success
                    self.onLoadingStateChanged?(.success)
                    self.onProductsUpdated?()
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    let errorMessage = getErrorMessage(for: error)
                    
                    self.loadingState = .error(errorMessage)
                    self.onLoadingStateChanged?(.error(errorMessage))
                }
            } catch {
                await MainActor.run {
                    let errorMessage = getErrorMessage(for: .unknown)

                    self.loadingState = .error(errorMessage)
                    self.onLoadingStateChanged?(.error(errorMessage))
                }
            }
        }
    }
    
    // MARK: - Search
    func filterProducts(with searchText: String) {
        if searchText.isEmpty {
            filteredProducts = products
            isSearching = false
        } else {
            isSearching = true
            filteredProducts = products.filter { product in
                product.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        onProductsUpdated?()
    }
    
    private func getErrorMessage(for error: NetworkError) -> String {
        switch error {
        case .invalidURL:
            return "Invalid URL. Please try again."
        case .noData:
            return "Invalid response from server."
        case .serverError(let statusCode):
            return "Server error (\(statusCode)). Please try again."
        case .decodingError:
            return "Failed to process data. Please try again."
        case .unknown:
            return "Unknown"
        }
    }
    
    // MARK: - Testing Helpers
    #if DEBUG
    func setProductsForTesting(_ products: [Product]) {
        self.products = products
        self.filteredProducts = products
    }
    #endif
}
