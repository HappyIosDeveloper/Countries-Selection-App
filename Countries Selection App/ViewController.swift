//
//  ViewController.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 12/30/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectButton: UIButton!
    @IBAction func selectButtonAction(_ sender: Any) {
        selectBttonAction()
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
extension ViewController {
    
    func setupPage() {
        setupNavigationController()
        setupTableView()
        setupSelectButton()
        getCountries()
    }
    
    func setupNavigationController() {
        navigationItem.title = "Selected Countries"
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "CountryTableViewCell", bundle: nil), forCellReuseIdentifier: "CountryTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    func setupSelectButton() {
        selectButton.backgroundColor = .systemBlue
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.roundUp(.large)
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
extension ViewController {
    
    func selectBttonAction() {
        
    }
}

// MARK: - API Calls
extension ViewController {
    
    func getCountries() {
        WebService.shared.getAllCountries { countries in
            self.countries = countries
        }
    }
}

// MARK: - TableView Functions
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell") as! CountryTableViewCell
        cell.fill(width: countries[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return screenWidth / 5
    }
}
