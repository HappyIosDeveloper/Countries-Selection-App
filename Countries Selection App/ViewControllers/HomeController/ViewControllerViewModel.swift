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
