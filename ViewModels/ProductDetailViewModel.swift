import Foundation

class ProductDetailViewModel {
    // MARK: - Properties
    private(set) var product: Product
    
    // MARK: - Init
    init(product: Product) {
        self.product = product
    }
    
    // MARK: - Computed Properties
    var title: String {
        return product.title
    }
    
    var price: String {
        return "$\(product.price)"
    }
    
    var description: String {
        return product.description
    }
    
    var imageURL: String {
        return product.image
    }
    
    var category: String {
        return product.category.capitalized
    }
}
