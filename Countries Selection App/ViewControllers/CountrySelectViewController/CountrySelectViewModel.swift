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
    var showNetworkError: ()->()
    var updateCoutries: ([Country])-> ()
    var updateFiltredCoutries: ([Country])-> ()
    private var filteredCountries: [Country] = [] {
        didSet {
            updateFiltredCoutries(filteredCountries)
        }
    }
    private var countries: [Country] = [] {
        didSet {
            updateCoutries(countries)
        }
    }

    init(updateCoutries: @escaping ([Country])->(), updateFiltredCoutries: @escaping ([Country])->(), showIndicator: @escaping ()->(), showNetworkError: @escaping ()->(), stopRefresh: @escaping ()->()) {
        self.updateCoutries = updateCoutries
        self.updateFiltredCoutries = updateFiltredCoutries
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

// MARK: - API Calls
extension CountrySelectViewModel {
    
    @objc func getCountries() {
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
