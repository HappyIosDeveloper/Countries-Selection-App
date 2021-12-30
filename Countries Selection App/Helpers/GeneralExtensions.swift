//
//  GeneralExtensions.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 12/30/21.
//

import UIKit

extension UINib {
    
    func instantiate() -> Any? {
        return instantiate(withOwner: nil, options: nil).first
    }
}

public extension Array where Element: Hashable {
    
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}
