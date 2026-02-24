import XCTest
@testable import ShopApp

final class CartManagerTests: XCTestCase {
    
    // MARK: - Properties
    var cartManager: CartManager!
    var testProduct1: Product!
    var testProduct2: Product!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        cartManager = CartManager.shared
        cartManager.clearCart()
        
        testProduct1 = Product(
            id: 1,
            title: "Iphone 15 Pro",
            price: 999.99,
            description: "Test Iphone",
            category: "electronics",
            image: "https://test.com/iphone.jpg"
        )
        
        testProduct2 = Product(
            id: 2,
            title: "Macbook Pro",
            price: 1999.99,
            description: "Test Macbook",
            category: "electronics",
            image: "https://test.com/macbook.jpg"
        )
    }
    
    override func tearDown() {
        cartManager.clearCart()
        testProduct1 = nil
        testProduct2 = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testAddToCart_NewProduct_AddSuccessfully() {
        XCTAssertTrue(cartManager.cartItems.isEmpty, "Cart Manager Should Empty initially")
        
        cartManager.addToCart(product: testProduct1)
    }
}
