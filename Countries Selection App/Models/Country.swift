//
//  Country.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 12/30/21.
//

import Foundation

struct Country: Codable, Hashable {
    
    var name: CountryName
    var flag: String?
    var population: Int?
    var isSelected: Bool?
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.name.common == rhs.name.common
    }
}

struct CountryName: Codable, Hashable {
    
    var common: String?
    var official: String?
    
}
