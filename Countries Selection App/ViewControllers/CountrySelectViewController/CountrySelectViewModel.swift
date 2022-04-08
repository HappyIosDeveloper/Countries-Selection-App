//
//  CountrySelectViewModel.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 3/1/22.
//

import Foundation
import UIKit

class CountrySelectViewModel {
    
    var stopRefresh: ()->()
    var showIndicator: ()->()
    var reloadTableView: ()-> ()
    var showNetworkError: ()->()
    var countries: [Country] = [] {
        didSet {
            reloadTableView()
        }
    }
    
    init(reloadTableView: @escaping ()->(), showIndicator: @escaping ()->(), showNetworkError: @escaping ()->(), stopRefresh: @escaping ()->()) {
        self.reloadTableView = reloadTableView
        self.showIndicator = showIndicator
        self.showNetworkError = showNetworkError
        self.stopRefresh = stopRefresh
        getCountries()
    }
}

// MARK: - General Actions
extension CountrySelectViewModel {
    
    func search(with text: String) {
        if text.isEmpty {
            for i in 0..<countries.count {
                countries[i].isVisible = true
            }
        } else {
            for i in 0..<countries.count {
                if (countries[i].name.official ?? "").lowercased().contains(text) || (countries[i].name.common ?? "").lowercased().contains(text.lowercased()) {
                    countries[i].isVisible = true
                } else {
                    countries[i].isVisible = false
                }
            }
        }
    }
}

// MARK: - TableView Functions
extension CountrySelectViewModel {
    
    func getTableCount()-> Int {
        return countries.filter({$0.isVisible ?? false}).count
    }
    
    func getCellCountry(indexPath: IndexPath)-> Country {
        return countries.filter({$0.isVisible ?? false})[indexPath.row]
    }
    
    func didSelect(at indexPath: IndexPath) {
        for i in 0..<countries.count {
            if countries[i].name.common == countries.filter({$0.isVisible ?? false})[indexPath.row].name.common {
                countries[i].isSelected?.toggle()
                break
            }
        }
    }
}

// MARK: - API Calls
extension CountrySelectViewModel {
    
    func getCountries() {
        DispatchQueue.main.async { [self] in
            showIndicator()
        }
        WebService.shared.getAllCountries { [weak self] res in
            switch res {
            case .success(let countries):
                self?.prepareCountriesForLoad(countries: countries)
            case .failure:
                self?.showNetworkError()
            }
        }
    }
    
    func prepareCountriesForLoad(countries: [Country]) {
        var countries = countries
        for i in 0..<countries.count {
            countries[i].isSelected = false
            countries[i].isVisible = true
        }
        self.countries = countries
        DispatchQueue.main.async { [self] in
            stopRefresh()
        }
    }
}
