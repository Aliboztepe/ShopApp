import UIKit

class ProductListViewController: UIViewController {
    
    // MARK: - UI Components
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ViewModel
    private let viewModel = ProductListViewModel()
    
    // MARK: - Loading UI Components
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Refresh Control
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Search Control
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Products"

        setupTableView()
        setupBindings()
        setupRefreshControl()
        setupSearchController()
        setupLoadingUI()
        viewModel.fetchProducts()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
    }
    
    private func setupBindings() {
        viewModel.onProductsUpdated = { [weak self] in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
        
        viewModel.onLoadingStateChanged = { [weak self] state in
            self?.handleLoadingState(state)
        }
    }
    
    private func handleLoadingState(_ state: LoadingState) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
            errorView.isHidden = true
            tableView.isHidden = false
            
        case .loading:
            activityIndicator.startAnimating()
            errorView.isHidden = true
            tableView.isHidden = viewModel.products.isEmpty
            
        case .success:
            activityIndicator.stopAnimating()
            errorView.isHidden = true
            tableView.isHidden = false
            refreshControl.endRefreshing()
            
        case .error(let message):
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            
            if viewModel.products.isEmpty {
                errorLabel.text = message
                errorView.isHidden = false
                tableView.isHidden = true
            } else {
                errorView.isHidden = true
                tableView.isHidden = false
                showErrorAlert(message: message)
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.fetchProducts()
        })
        present(alert, animated: true)
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = .systemBlue
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refreshControl.addTarget(self, action: #selector(refreshProducts), for: .valueChanged)
        
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshProducts() {
        viewModel.fetchProducts()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search products..."
        searchController.searchBar.autocapitalizationType = .none
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }
    
    private func setupLoadingUI() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        errorView.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -30),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 40),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -40)
        ])
        
        errorView.addSubview(retryButton)
        NSLayoutConstraint.activate([
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 120),
            retryButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    }

    @objc private func retryButtonTapped() {
        viewModel.fetchProducts()
    }
}

// MARK: - UITableViewDataSource
extension ProductListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isSearching ? viewModel.filteredProducts.count : viewModel.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProductCell",
            for: indexPath
        ) as? ProductCell else {
            return UITableViewCell()
        }
        
        let product = viewModel.isSearching
            ? viewModel.filteredProducts[indexPath.row]
            : viewModel.products[indexPath.row]

        cell.configure(with: product)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ProductListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedProduct = viewModel.isSearching
            ? viewModel.filteredProducts[indexPath.row]
            : viewModel.products[indexPath.row]
        
        navigateToProductDetail(with: selectedProduct)
    }
    
    private func navigateToProductDetail(with product: Product) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let detailVC = storyboard.instantiateViewController(
            withIdentifier: "ProductDetailViewController"
        ) as? ProductDetailViewController else {
            print("ProductDetailViewController oluşturulamadı.")
            return
        }
        
        let detailViewModel = ProductDetailViewModel(product: product)
        detailVC.viewModel = detailViewModel
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension ProductListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        viewModel.filterProducts(with: searchText)
    }
}
