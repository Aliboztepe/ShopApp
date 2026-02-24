import UIKit

class ProductDetailViewController: UIViewController {
    
    // MARK: - UI Components
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    
    // MARK: - ViewModel
    var viewModel: ProductDetailViewModel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithViewModel()
        updateFavoriteButton()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Product Detail"
        view.backgroundColor = .systemBackground
        
        productImageView.layer.cornerRadius = 12
        productImageView.clipsToBounds = true
        
        descriptionTextView.isEditable = false
        descriptionTextView.font = UIFont.systemFont(ofSize: 14)
        descriptionTextView.textColor = .label
    }
    
    private func configureWithViewModel() {
        guard viewModel != nil else {
            print("ViewModel is nil.")
            return
        }
        
        titleLabel.text = viewModel.title
        priceLabel.text = viewModel.price
        categoryLabel.text = "Category: \(viewModel.category)"
        descriptionTextView.text = viewModel.description
        
        ImageLoader.shared.loadImage(
            from: viewModel.product.image,
            into: productImageView,
            placeholder: UIImage(systemName: "photo")
        )
    }
    
    private func updateFavoriteButton() {
        let isFavorite = FavoritesManager.shared.isFavorite(viewModel.product.id)
        
        if isFavorite {
            addToFavoritesButton.setTitle("Remove from Favorites", for: .normal)
            addToFavoritesButton.backgroundColor = .systemPink
        } else {
            addToFavoritesButton.setTitle("Add to Favorites", for: .normal)
            addToFavoritesButton.backgroundColor = .systemRed
        }
    }
    
    @IBAction func addToCartTapped(_ sender: UIButton) {
        CartManager.shared.addToCart(product: viewModel.product)
        
        animateButton(sender)
        
        showAlert(
            title: "Sepete Eklendi!",
            message: "\(viewModel.title) sepete eklendi.\n\nToplam: \(CartManager.shared.itemCount) ürün"
        )
        
        print("Sepete eklendi: \(viewModel.title)")
        print("Sepetteki toplam ürün: \(CartManager.shared.itemCount)")
        print("Sepet toplamı: $\(CartManager.shared.totalPrice)")
    }
    
    @IBAction func addToFavoritesTapped(_ sender: UIButton) {
        FavoritesManager.shared.toggleFavorite(viewModel.product)
        
        updateFavoriteButton()
        
        animateButton(sender)
        
        let isFavorite = FavoritesManager.shared.isFavorite(viewModel.product.id)
        let title = isFavorite ? "Favorilere eklendi" : "Favorilerden Çıkarıldı"
        let message = isFavorite
            ? "\(viewModel.title) favorilere eklendi."
            : "\(viewModel.title) favorilerden çıkarıldı."
        
        showAlert(title: title, message: message)
        
        
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                button.transform = CGAffineTransform.identity
            })
        }
    }
}
