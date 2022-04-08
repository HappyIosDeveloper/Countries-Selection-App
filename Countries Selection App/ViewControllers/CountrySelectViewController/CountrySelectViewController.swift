//
//  CountrySelectViewController.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 12/30/21.
//

import UIKit

protocol CountrySelectViewControllerDelegate: AnyObject {
    func countriesDidUpdate(countries: [Country])
}

class CountrySelectViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!
    @IBAction func doneButtonAction(_ sender: Any) {
        doneButtonAction()
    }
    
    let noDataView: NoDataView = .instantiateFromNib()!
    weak var delegate: CountrySelectViewControllerDelegate?
    private var viewModel: CountrySelectViewModel!
    private var indicator = UIActivityIndicatorView()
    private var pullControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPage()
        bindViewModel()
    }
}

// MARK: - Setup Functions
extension CountrySelectViewController {
    
    func setupPage() {
        setupNavigationController()
        setupTableView()
        reloadTableView()
        setupSearchBar()
        setupDoneButton()
        setupIndicator()
    }
    
    func bindViewModel() {
        viewModel = CountrySelectViewModel(
            reloadTableView: { [unowned self] in
                reloadTableView()
            }, showIndicator: { [unowned self] in
                tableView.backgroundView = indicator
            }, showNetworkError: { [unowned self] in
                showNetworkError()
            }, stopRefresh: { [unowned self] in
                pullControl.endRefreshing()
                showNoResultIfReuqied()
            })
    }
    
    func setupNavigationController() {
        navigationItem.title = "Select Countries"
        let button = UIBarButtonItem(image: UIImage(named: "icons8-Material close"), style: .done, target: self, action: #selector(dismissPage))
        button.tintColor = .darkGray
        navigationItem.rightBarButtonItem = button
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search here..."
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "CountryTableViewCell", bundle: nil), forCellReuseIdentifier: "CountryTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        pullControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullControl.addTarget(self, action: #selector(getData), for: .valueChanged)
        tableView.refreshControl = pullControl
    }
    
    func setupIndicator() {
        indicator.style = .large
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
    }
    
    func setupDoneButton() {
        doneButton.backgroundColor = .systemBlue
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.roundUp(.large)
    }
    
    @objc func getData() {
        viewModel.getCountries()
    }
    
    func reloadTableView() {
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
            if searchBar.text!.isEmpty {
                if viewModel.countries.filter({$0.isVisible ?? false}).isEmpty {
                    tableView.backgroundView = noDataView
                } else {
                    tableView.backgroundView = nil
                }
            }
        }
    }
    
    func showNoResultIfReuqied() {
        if viewModel.countries.isEmpty {
            if let label = self.tableView.backgroundView?.subviews(ofType: UILabel.self).first {
                label.text = "No Result :("
            }
        }
    }
    
    func showNetworkError() {
        if let label = self.tableView.backgroundView?.subviews(ofType: UILabel.self).first {
            label.text = "Network Error :("
        }
    }
}

// MARK: - Actions
extension CountrySelectViewController {
    
    func doneButtonAction() {
        dismiss(animated: true) { [self] in
            for i in 0..<viewModel.countries.count {
                viewModel.countries[i].isVisible = viewModel.countries[i].isSelected
            }
            let finalCountries = viewModel.countries.filter({$0.isSelected ?? false})
            delegate?.countriesDidUpdate(countries: finalCountries)
        }
    }

    @objc func dismissPage() {
        dismiss(animated: true)
    }
}

// MARK: - Search Bar Fuctions
extension CountrySelectViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

// MARK: - TableView Functions
extension CountrySelectViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getTableCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell") as! CountryTableViewCell
        cell.fill(width: viewModel.getCellCountry(indexPath: indexPath), highlightSelectedCells: true)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return screenWidth / 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelect(at: indexPath)
        DispatchQueue.main.async {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
