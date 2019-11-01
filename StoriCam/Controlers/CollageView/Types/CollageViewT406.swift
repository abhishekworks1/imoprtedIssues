//
//  CollageViewT406.swift
//  CollageView
//
//  Created by Viraj Patel on 12/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class CollageViewT406: CollageView {
    
    override func initBaseLines() {
        
        // initialize baseline
        let baseLine01 = BaseLineView()
        baseLine01.id = 1
        baseLine01.moveType = .upDown
        baseLine01.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine01)
        
        let lc01 = NSLayoutConstraint(item: baseLine01, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc02 = NSLayoutConstraint(item: baseLine01, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc03 = NSLayoutConstraint(item: baseLine01, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let lc04 = NSLayoutConstraint(item: baseLine01, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: (1.5/3.0), constant: 0)
        NSLayoutConstraint.activate([ lc01, lc02, lc03, lc04])
        baseLine01.baseLC = lc04
        
        self.baseLineViews += [baseLine01]
        self.initCells()
        
    }
    
    private func initCells() {
        
        let cell01 = CollageCell(id: 1)
        cell01.delegate = self
        self.addSubview(cell01)
        let lc01 = NSLayoutConstraint(item: cell01, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc02 = NSLayoutConstraint(item: cell01, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc03 = NSLayoutConstraint(item: cell01, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant:0)
        let lc04 = NSLayoutConstraint(item: cell01, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc01, lc02, lc03, lc04])
        
        let cell02 = CollageCell(id: 2)
        cell02.delegate = self
        self.addSubview(cell02)
        let lc05 = NSLayoutConstraint(item: cell02, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc06 = NSLayoutConstraint(item: cell02, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0)
        let lc07 = NSLayoutConstraint(item: cell02, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant:0)
        let lc08 = NSLayoutConstraint(item: cell02, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc05, lc06, lc07, lc08])
        
        let cell03 = CollageCell(id: 3)
        cell03.delegate = self
        self.addSubview(cell03)
        let lc09 = NSLayoutConstraint(item: cell03, attribute: .centerX, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .centerX, multiplier: 1, constant: 0)
        let lc10 = NSLayoutConstraint(item: cell03, attribute: .centerY, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .centerY, multiplier: 1, constant: 0)
        let lc11 = NSLayoutConstraint(item: cell03, attribute: .width, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .height, multiplier: 0.7, constant:0)
        let lc12 = NSLayoutConstraint(item: cell03, attribute: .height, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .height, multiplier: 0.7, constant: 0)
        NSLayoutConstraint.activate([ lc09, lc10, lc11, lc12])
        
        let cell04 = CollageCell(id: 4)
        cell04.delegate = self
        self.addSubview(cell04)
        let lc13 = NSLayoutConstraint(item: cell04, attribute: .centerX, relatedBy: .equal, toItem: cell02, attribute: .centerX, multiplier: 1, constant: 0)
        let lc14 = NSLayoutConstraint(item: cell04, attribute: .centerY, relatedBy: .equal, toItem: cell02, attribute: .centerY, multiplier: 1, constant: 0)
        let lc15 = NSLayoutConstraint(item: cell04, attribute: .width, relatedBy: .equal, toItem: cell02, attribute: .height, multiplier: 0.7, constant:0)
        let lc16 = NSLayoutConstraint(item: cell04, attribute: .height, relatedBy: .equal, toItem: cell02, attribute: .height, multiplier: 0.7, constant: 0)
        NSLayoutConstraint.activate([ lc13, lc14, lc15, lc16])
        
        self.marginLeftTopContraints += [lc01,lc02,lc05]
        self.marginRightBottomContraints += [lc03,lc07,lc08]
        self.paddingLeftTopContraints += [lc06]
        self.paddingRightBottomContraints += [lc04]
        self.collageCells += [cell01,cell02,cell03,cell04]
        
    }
    
}
