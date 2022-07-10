//
//  ViewControllerViewModel.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 4/15/22.
//

import Foundation

class ViewControllerViewModel {
    
    var reloadTableView: (()->())?
    var countries: [Country] = [] {
        didSet {
            reloadTableView?()
        }
    }
    
    func setup(reloadTableView: @escaping ()->()) {
        self.reloadTableView = reloadTableView
    }
}

extension ViewControllerViewModel: CountrySelectViewControllerDelegate {
    
    func countriesDidUpdate(countries: [Country]) {
        self.countries = countries
    }
}
