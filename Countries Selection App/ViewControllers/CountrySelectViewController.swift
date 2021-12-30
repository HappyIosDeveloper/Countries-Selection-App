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
    
    weak var delegate: CountrySelectViewControllerDelegate?
    let noDataView: NoDataView = .instantiateFromNib()!
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
        getCountries()
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
        pullControl.addTarget(self, action: #selector(getCountries), for: .valueChanged)
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
    
    func handleBandInternetConnectionMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [self] in
            if countries.isEmpty {
                if let label = self.tableView.backgroundView?.subviews(ofType: UILabel.self).first {
                    label.text = "Bad Interner Connection!"
                }
            }
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
    
    func update(this country: Country, isFilteredList: Bool) {
        if isFilteredList {
            for i in 0..<filteredCountries.count {
                if filteredCountries[i].name.common == country.name.common {
                    filteredCountries[i].isSelected = country.isSelected
                }
            }
        } else {
            for i in 0..<countries.count {
                if countries[i].name.common == country.name.common {
                    countries[i].isSelected = country.isSelected
                }
            }
        }
    }
}

// MARK: - Search Bar Fuctions
extension CountrySelectViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCountries = countries.filter({($0.name.official ?? "").contains(searchText) || ($0.name.common ?? "").contains(searchText)})
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
            update(this: countries[indexPath.row], isFilteredList: true)
        } else {
            filteredCountries[indexPath.row].isSelected?.toggle()
            update(this: filteredCountries[indexPath.row], isFilteredList: false)
        }
        DispatchQueue.main.async {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - API Calls
extension CountrySelectViewController {
    
    @objc func getCountries() {
        DispatchQueue.main.async { [self] in
            tableView.backgroundView = indicator
            handleBandInternetConnectionMessage()
        }
        WebService.shared.getAllCountries { [weak self] countries in
            self?.prepareCountriesForLoad(countries: countries)
        }
    }
    
    func prepareCountriesForLoad(countries: [Country]) {
        var countries = countries
        for i in 0..<countries.count {
            countries[i].isSelected = false
        }
        self.countries = countries
        DispatchQueue.main.async {
            self.pullControl.endRefreshing()
        }
    }
}
