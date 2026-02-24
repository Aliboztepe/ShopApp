import Foundation

class FavoritesManager {
    
    // MARK: Singleton
    static let shared = FavoritesManager()
    private init() {}
    
    // MARK: UserDefaults Key
    private let favoritesKey = "SavedFavorites"
    
    // MARK: Properties
    private(set) var favorites: [Product] = []
    
    // MARK: - Notification
    static let favoritesDidUpdateNotification = Notification.Name("FavoritesDidUpdate")
    
    // MARK: - Init
    func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decodedFavorites = try? JSONDecoder().decode([Product].self, from: data) {
            self.favorites = decodedFavorites
        }
    }
    
    // MARK: - Add to Favorites
    func addToFavorites(_ product: Product) {
        guard !isFavorite(product.id) else { return }
        
        favorites.append(product)
        saveFavorites()
        postNotification()
    }
    
    // MARK: - Remove Favorites
    func removeFromFavorites(productID: Int) {
        favorites.removeAll { $0.id == productID }
        saveFavorites()
        postNotification()
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(_ product: Product) {
        if isFavorite(product.id) {
            removeFromFavorites(productID: product.id)
        } else {
            addToFavorites(product)
        }
    }
    
    // MARK: - Check Favorite
    func isFavorite(_ productID: Int) -> Bool {
        return favorites.contains { $0.id == productID }
    }
    
    // MARK: - Clear Favorites
    func clearFavorites() {
        favorites.removeAll()
        saveFavorites()
        postNotification()
    }
    
    // MARK: - Save to UserDefaults
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    // MARK: - Post Notification
    private func postNotification() {
        NotificationCenter.default.post(name: FavoritesManager.favoritesDidUpdateNotification, object: nil)
    }
}
