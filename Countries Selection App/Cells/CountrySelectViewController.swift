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
    @IBOutlet weak var doneButton: UIButton!
    @IBAction func doneButtonAction(_ sender: Any) {
        doneButtonAction()
    }
    
    weak var delegate: CountrySelectViewControllerDelegate?
    var filteredCountries: [Country] = [] {
        didSet {
            reloadTableView()
        }
    }
    var countries: [Country] = [] {
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
        setupTableView()
        reloadTableView()
        setupSearchBar()
        setupDoneButton()
        getCountries()
    }
    
    func setupDoneButton() {
        doneButton.backgroundColor = .systemBlue
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.roundUp(.large)
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "CountryTableViewCell", bundle: nil), forCellReuseIdentifier: "CountryTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    func reloadTableView() {
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
            if countries.isEmpty {
                
            } else {
                
            }
        }
    }
}

// MARK: - Actions
extension CountrySelectViewController {
    
    func doneButtonAction() {
        dismiss(animated: true) { [self] in
            let finalCountries = filteredCountries.isEmpty ? countries.filter({$0.isSelected ?? false}) : filteredCountries.filter({$0.isSelected ?? false})
            delegate?.countriesDidUpdate(countries: finalCountries)
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
        return filteredCountries.isEmpty ? countries.count : filteredCountries.count
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
        } else {
            filteredCountries[indexPath.row].isSelected?.toggle()
        }
        DispatchQueue.main.async {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - API Calls
extension CountrySelectViewController {
    
    func getCountries() {
        WebService.shared.getAllCountries { countries in
            var countries = countries
            for i in 0..<countries.count {
                countries[i].isSelected = false
            }
            self.countries = countries
        }
    }
}
