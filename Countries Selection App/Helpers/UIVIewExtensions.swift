//
//  UIVIewExtensions.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 12/30/21.
//

import UIKit

extension UIView {
    
    func roundUpWithShadow(_ value: CornerRadius, opacity:Float = 0.1) {
        roundUp(value)
        dropShadow(opacity: opacity, corner: value)
    }
    
    func roundUp(_ value: CornerRadius) {
        DispatchQueue.main.async { [weak self] in
            if value != .round {
                self?.layer.cornerRadius = value.rawValue
                self?.layer.cornerCurve = .continuous
            } else {
                self?.layer.cornerRadius = (self?.bounds.height ?? 2) / 2
            }
        }
    }
    
    func dropShadow(opacity:Float = 0.05, corner: CornerRadius) {
        DispatchQueue.main.async { [weak self] in
            self?.layer.masksToBounds = false
            self?.layer.shadowColor = UIColor.black.cgColor
            self?.layer.shadowOpacity = opacity
            self?.layer.shadowOffset = CGSize(width: 5, height: 5)
            if corner == .round {
                self?.layer.shadowRadius = (self?.bounds.height ?? 2) / 8
            } else {
                self?.layer.shadowRadius = corner.rawValue
            }
        }
    }
}

extension UIView {
    
    static var nib: UINib {
        return UINib(nibName: "\(self)", bundle: nil)
    }
    
    static func instantiateFromNib() -> Self? {
        return nib.instantiate() as? Self
    }
}

extension UINib {
    
    func instantiate() -> Any? {
        return instantiate(withOwner: nil, options: nil).first
    }
}
