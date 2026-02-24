import UIKit

class FavoritesViewController: UIViewController {
    
    // MARK: - UI Components
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ViewModel
    private let viewModel = FavoritesViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Favorites"
        view.backgroundColor = .systemBackground
        
        let clearButton = UIBarButtonItem(
            title: "Clear All",
            style: .plain,
            target: self,
            action: #selector(clearAllTapped)
        )
        navigationItem.rightBarButtonItem = clearButton
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 120
    }
    
    private func setupBindings() {
        viewModel.onFavoritesUpdated = { [weak self] in
            self?.updateUI()
        }
    }
    
    // MARK: - Update UI
    private func updateUI() {
        tableView.reloadData()
        
        if viewModel.isEmpty {
            tableView.isHidden = true
            showEmptyState()
        } else {
            tableView.isHidden = false
            hideEmptyState()
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = !viewModel.isEmpty
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel(frame: view.bounds)
        emptyLabel.text = "\n\nHenüz favori ürün yok\n\nÜrün detayından favorilere ekleyebilirsiniz"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        emptyLabel.tag = 999
        view.addSubview(emptyLabel)
        view.bringSubviewToFront(emptyLabel)
    }
    
    private func hideEmptyState() {
        view.viewWithTag(999)?.removeFromSuperview()
    }
    
    // MARK: - Actions
    @objc private func clearAllTapped() {
        let alert = UIAlertController(
            title: "Tüm Favorileri Temizle",
            message: "Tüm favori ürünleri silmek istediğinize emin misiniz?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Temizle", style: .destructive) { [weak self] _ in
            self?.viewModel.clearAllFavorites()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension FavoritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProductCell",
            for: indexPath
        ) as? ProductCell else {
            return UITableViewCell()
        }
        
        let product = viewModel.favorites[indexPath.row]
        
        cell.configure(with: product)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let product = viewModel.favorites[indexPath.row]
        navigateToProductDetail(with: product)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.removeFromFavorites(at: indexPath.row)
        }
    }
    
    private func navigateToProductDetail(with product: Product) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let detailVC = storyboard.instantiateViewController(
            withIdentifier: "ProductDetailViewController"
        ) as? ProductDetailViewController else {
            return
        }
        
        let detailViewModel = ProductDetailViewModel(product: product)
        detailVC.viewModel = detailViewModel
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
