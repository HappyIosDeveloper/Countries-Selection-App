//
//  TableViewCellExtensionHighlightEffects.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 12/30/21.
//

import UIKit

extension ViewController {
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        softVibrate()
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.tag != 123 {
                cell.tag = 123
                UIView.animate(withDuration: 0.4) {
                    cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.97, 0.97, 1.15)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                cell.layer.transform = CATransform3DIdentity
            }) { (_) in
                cell.tag = 0
            }
        }
    }
}
