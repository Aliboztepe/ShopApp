import Foundation

struct CartItem {
    // MARK: - Properties
    let id: String
    let product: Product
    var quantity: Int
    
    // MARK: - Init
    init(product: Product, quantity: Int = 1) {
        self.id = UUID().uuidString
        self.product = product
        self.quantity = quantity
    }
    
    // MARK: - Computed Properties
    var totalPrice: Double {
        return product.price * Double(quantity)
    }
}
