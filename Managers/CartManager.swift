import Foundation

class CartManager {
    
    // MARK: - Singleton
    static let shared = CartManager()
    private init() {}
    
    // MARK: - Properties
    private(set) var cartItems: [CartItem] = []
    
    // MARK: - Notification Names
    static let cartDidUpdateNotification = Notification.Name("CartDidUpdate")
    
    // MARK: - Computed Properties
    var totalPrice: Double {
        return cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var itemCount: Int {
        return cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    // MARK: - Add to Cart
    func addToCart(product: Product, quantity: Int = 1) {
        if let existingIndex = cartItems.firstIndex(where: { $0.product.id == product.id}) {
            cartItems[existingIndex].quantity += quantity
        } else {
            let newItem = CartItem(product: product, quantity: quantity)
            cartItems.append(newItem)
        }
        
        postCartUpdateNotification()
    }
    
    // MARK: - Remove from Cart
    func removeFromCart(cartItemID: String) {
        cartItems.removeAll { $0.id == cartItemID }
        
        postCartUpdateNotification()
    }
    
    // MARK: - Update Quantity
    func updateQuantity(cartItemID: String, newQuantity: Int) {
        guard newQuantity > 0 else {
            removeFromCart(cartItemID: cartItemID)
            return
        }
        
        if let index = cartItems.firstIndex(where: { $0.id == cartItemID}) {
            cartItems[index].quantity = newQuantity
        }
        
        postCartUpdateNotification()
    }
    
    // MARK: - Clear Cart
    func clearCart() {
        cartItems.removeAll()
        
        postCartUpdateNotification()
    }

    // MARK: - Notification
    private func postCartUpdateNotification() {
        NotificationCenter.default.post(name: CartManager.cartDidUpdateNotification, object: nil)
    }
}
