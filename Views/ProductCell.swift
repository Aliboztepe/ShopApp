import UIKit

class ProductCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

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
    }
    
    // MARK: - Setup
    private func setupUI() {
        productImageView.contentMode = .scaleAspectFit
        productImageView.layer.cornerRadius = 8
        productImageView.clipsToBounds = true
        productImageView.backgroundColor = .systemGray6
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        
        priceLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        priceLabel.textColor = .systemGreen
    }
    
    // MARK: - Configure
    func configure(with product: Product) {
        titleLabel.text = product.title
        priceLabel.text = "$\(String(format: "%.2f", product.price))"

        ImageLoader.shared.loadImage(
            from: product.image,
            into: productImageView,
            placeholder: UIImage(systemName: "photo")
        )
    }
}
