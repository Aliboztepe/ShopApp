import UIKit

class CartCell: UITableViewCell {
    
    // MARK: - UI Components
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var increaseButton: UIButton!
    
    // MARK: - Properties
    private var cartItem: CartItem?
    var onQuantityChanged: ((Int) -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = UIImage(systemName: "photo")
        onQuantityChanged = nil
    }
    
    // MARK: - Setup
    private func setupUI() {
        productImageView.contentMode = .scaleAspectFit
        productImageView.layer.cornerRadius = 8
        productImageView.clipsToBounds = true
        productImageView.backgroundColor = .systemGray6

        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 2
        
        priceLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        priceLabel.textColor = .secondaryLabel
        
        quantityLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        quantityLabel.textAlignment = .center
        
        totalLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        totalLabel.textColor = .systemGreen
        
        decreaseButton.layer.cornerRadius = 8
        decreaseButton.backgroundColor = .systemGray5
        decreaseButton.setTitleColor(.label, for: .normal)
        decreaseButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        increaseButton.layer.cornerRadius = 8
        increaseButton.backgroundColor = .systemBlue
        increaseButton.setTitleColor(.white, for: .normal)
        increaseButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
    }
    
    // MARK: - Configure
    func configure(with cartItem: CartItem) {
        self.cartItem = cartItem
        
        titleLabel.text = cartItem.product.title
        priceLabel.text = "$\(String(format: "%.2f", cartItem.product.price)) each"
        quantityLabel.text = "\(cartItem.quantity)"
        totalLabel.text = "Total: $\(String(format: "%.2f", cartItem.totalPrice))"
        
        ImageLoader.shared.loadImage(
            from: cartItem.product.image,
            into: productImageView,
            placeholder: UIImage(systemName: "photo")
        )
        
        decreaseButton.isEnabled = cartItem.quantity > 1
        decreaseButton.alpha = cartItem.quantity > 1 ? 1.0 : 0.5
    }
    
    // MARK: - Actions
    
   
    @IBAction func decreaseButtonTapped(_ sender: Any) {
        guard let cartItem = cartItem, cartItem.quantity > 1 else { return }
                
        let newQuantity = cartItem.quantity - 1
        onQuantityChanged?(newQuantity)
    }
    
    @IBAction func increaseButtonTapped(_ sender: UIButton) {
        guard let cartItem = cartItem else { return }
        
        let newQuantity = cartItem.quantity + 1
        onQuantityChanged?(newQuantity)
    }
}
