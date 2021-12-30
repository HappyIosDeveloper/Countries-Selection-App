//
//  Country.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 12/30/21.
//

import Foundation

struct Country: Codable {
    
    var name: CountryName
    var population: Int?
    var isSelected: Bool?
}

struct CountryName: Codable {
    
    var common: String?
    var official: String?
}
