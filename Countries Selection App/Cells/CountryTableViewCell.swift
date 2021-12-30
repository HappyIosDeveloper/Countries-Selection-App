//
//  CountryTableViewCell.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 12/30/21.
//

import UIKit

class CountryTableViewCell: UITableViewCell {

    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var countryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        parentView.roundUpWithShadow(.large)
    }
    
    func fill(width country: Country) {
        if let flag = country.flag {
            countryNameLabel.text = flag + "  " + (country.name.official ?? "?")
        } else {
            countryNameLabel.text = country.name.official
        }
    }
}
