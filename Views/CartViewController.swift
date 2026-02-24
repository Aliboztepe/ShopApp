import UIKit

class CartViewController: UIViewController {

    // MARK: - UI Components
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!
    
    // MARK: - Properties
    private let viewModel = CartViewModel()

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
        updateBadge()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "My Cart"
        view.backgroundColor = .systemBackground
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
    }
    
    private func setupBindings() {
        viewModel.onCartUpdated = { [weak self] in
            self?.updateUI()
            self?.updateBadge()
        }
    }
    
    // MARK: - Update UI
    private func updateUI() {
        tableView.reloadData()
        totalLabel.text = "Total: \(viewModel.totalPrice)"
        
        if viewModel.isEmpty {
            tableView.isHidden = true
            showEmptyState()
        } else {
            tableView.isHidden = false
            hideEmptyState()
        }
    }
    
    private func updateBadge() {
        let itemCount = viewModel.itemCount

        if let nav = self.navigationController {
            nav.tabBarItem.badgeValue = itemCount > 0 ? "\(itemCount)" : nil
        } else {
            tabBarItem.badgeValue = itemCount > 0 ? "\(itemCount)" : nil
        }
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel(frame: view.bounds)
        emptyLabel.text = "Sepetiniz Boş"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.tag = 999
        view.addSubview(emptyLabel)
        view.bringSubviewToFront(emptyLabel)
    }
    
    private func hideEmptyState() {
        view.viewWithTag(999)?.removeFromSuperview()
    }
    
    @IBAction func checkoutTapped(_ sender: Any) {
        guard !viewModel.isEmpty else {
            showAlert(title: "Sepet Boş", message: "Sepetinizde ürün bulunmuyor.")
            return
        }
        
        showAlert(title: "Ödeme", message: "Toplam \(viewModel.totalPrice)\n\(viewModel.itemCount) ürün")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as? CartCell else {
            return UITableViewCell()
        }
        
        let cartItem = viewModel.cartItems[indexPath.row]
        
        cell.configure(with: cartItem)
        
        cell.onQuantityChanged = { [weak self] newQuantity in
            self?.viewModel.updateQuantity(at: indexPath.row, newQuantity: newQuantity)
        }

        return cell
    }
}

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.removeItem(at: indexPath.row)
        }
    }
}
