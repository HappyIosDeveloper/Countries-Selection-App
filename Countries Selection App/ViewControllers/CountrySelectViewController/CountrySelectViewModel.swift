//
//  CountrySelectViewModel.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 3/1/22.
//

import Foundation

class CountrySelectViewModel {
    
    var stopRefresh: ()->()
    var showIndicator: ()->()
    var reloadTableView: ()-> ()
    var showNetworkError: ()->()
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

// MARK: - TableView Functions
extension CountrySelectViewModel {
    
    func getTableCount(isSearchBarTextEmpty: Bool)-> Int {
        return (filteredCountries.isEmpty && isSearchBarTextEmpty) ? countries.count : filteredCountries.count
    }
    
    func getCellCountry(indexPath: IndexPath)-> Country {
        return filteredCountries.isEmpty ? countries[indexPath.row] : filteredCountries[indexPath.row]
    }
    
    func didSelect(at indexPath: IndexPath) {
        if filteredCountries.isEmpty {
            countries[indexPath.row].isSelected?.toggle()
            update(this: countries[indexPath.row], isFilteredList: true)
        } else {
            filteredCountries[indexPath.row].isSelected?.toggle()
            update(this: filteredCountries[indexPath.row], isFilteredList: false)
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
        }
        self.countries = countries
        DispatchQueue.main.async { [self] in
            stopRefresh()
        }
    }
}
