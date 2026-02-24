import Foundation

class CartViewModel {
    
    // MARK: - Properties
    private var cartManager = CartManager.shared
    
    // MARK: - Callbacks
    var onCartUpdated: (() -> Void)?
    
    // MARK: - Computed Properties
    var cartItems: [CartItem] {
        return cartManager.cartItems
    }
    
    var totalPrice: String {
        return "$\(String(format: "%.2f", cartManager.totalPrice))"
    }
    
    var itemCount: Int {
        return cartManager.itemCount
    }
    
    var isEmpty: Bool {
        return cartManager.cartItems.isEmpty
    }
    
    // MARK: - Init
    init() {
        observeCartUpdates()
    }
    
    // MARK: - Observe Cart Updates
    private func observeCartUpdates() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidUpdate),
            name: CartManager.cartDidUpdateNotification,
            object: nil
        )
    }
    
    @objc private func cartDidUpdate() {
        onCartUpdated?()
    }
    
    // MARK: - Actions
    func removeItem(at index: Int) {
        guard index < cartItems.count else { return }
        
        let item = cartItems[index]
        cartManager.removeFromCart(cartItemID: item.id)
    }
    
    func updateQuantity(at index: Int, newQuantity: Int) {
        guard index < cartItems.count else { return }
        
        let item = cartItems[index]
        cartManager.updateQuantity(cartItemID: item.id, newQuantity: newQuantity)
    }
    
    func clearCart() {
        cartManager.clearCart()
    }
    
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
