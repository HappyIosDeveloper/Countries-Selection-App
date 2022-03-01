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
    private var filteredCountries: [Country] = [] {
        didSet {
            reloadTableView()
        }
    }
    private var countries: [Country] = [] {
        didSet {
            reloadTableView()
        }
    }
    
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
    
    @objc func bindViewModel() {
        viewModel = CountrySelectViewModel(
            updateCoutries: { [unowned self] countries in
                self.countries = countries
            }, updateFiltredCoutries: { [unowned self] countries in
                self.filteredCountries = filteredCountries
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
        pullControl.addTarget(self, action: #selector(bindViewModel), for: .valueChanged)
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
    
    func reloadTableView() {
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
            if filteredCountries.isEmpty && searchBar.text!.isEmpty {
                if countries.isEmpty {
                    tableView.backgroundView = noDataView
                } else {
                    tableView.backgroundView = nil
                }
            } else {
                if filteredCountries.isEmpty {
                    tableView.backgroundView = noDataView
                } else {
                    tableView.backgroundView = nil
                }
            }
        }
    }
    
    func showNoResultIfReuqied() {
        if countries.isEmpty {
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
            let finalCountries = (filteredCountries + countries).filter({$0.isSelected ?? false}).uniqued()
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
        filteredCountries = countries.filter({($0.name.official ?? "").lowercased().contains(searchText) || ($0.name.common ?? "").lowercased().contains(searchText.lowercased())})
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

// MARK: - TableView Functions
extension CountrySelectViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (filteredCountries.isEmpty && searchBar.text!.isEmpty) ? countries.count : filteredCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell") as! CountryTableViewCell
        cell.fill(width: filteredCountries.isEmpty ? countries[indexPath.row] : filteredCountries[indexPath.row], highlightSelectedCells: true)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return screenWidth / 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filteredCountries.isEmpty {
            countries[indexPath.row].isSelected?.toggle()
            viewModel.update(this: countries[indexPath.row], isFilteredList: true)
        } else {
            filteredCountries[indexPath.row].isSelected?.toggle()
            viewModel.update(this: filteredCountries[indexPath.row], isFilteredList: false)
        }
        DispatchQueue.main.async {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}