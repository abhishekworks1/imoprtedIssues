//
//  UITableViewExtension.swift
//  ProManager
//
//  Created by Harikrishna Daraji on 01/01/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation

extension UITableView {
    
    func scrollToBottom(animated: Bool = false) {
        let sections = self.numberOfSections
        let rows = self.numberOfRows(inSection: sections - 1)
        if (rows > 0) {
            self.scrollToRow(at: IndexPath(row: rows - 1, section: sections - 1), at: .bottom, animated: animated)
        }
    }
    
    func setAndLayoutTableHeaderView(header: UIStackView) {
        if let headerView = self.tableHeaderView {
            let height = header.frame.size.height
            var headerFrame = headerView.frame
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                self.tableHeaderView = headerView
            }
        }
    }
    
}
