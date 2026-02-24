import Foundation

class FavoritesViewModel {
    
    // MARK: - Properties
    private var favoritesManager = FavoritesManager.shared
    
    // MARK: - Callbacks
    var onFavoritesUpdated: (() -> Void)?
    
    // MARK: - Computed Properties
    var favorites: [Product] {
        return favoritesManager.favorites
    }
    
    var isEmpty: Bool {
        return favoritesManager.favorites.isEmpty
    }
    
    var favoriteCount: Int {
        return favoritesManager.favorites.count
    }
    
    // MARK: - Init
    init() {
        observeFavoritesUpdates()
    }
    
    // MARK: - Observe Updates
    private func observeFavoritesUpdates() {
        NotificationCenter.default.addObserver(self, selector: #selector(favoritesDidUpdate), name: FavoritesManager.favoritesDidUpdateNotification, object: nil)
    }
    
    @objc private func favoritesDidUpdate() {
        onFavoritesUpdated?()
    }
    
    // MARK: - Actions
    func removeFromFavorites(at index: Int) {
        guard index < favorites.count else { return }
        
        let product = favorites[index]
        favoritesManager.removeFromFavorites(productID: product.id)
    }
    
    func clearAllFavorites() {
        favoritesManager.clearFavorites()
    }
    
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
