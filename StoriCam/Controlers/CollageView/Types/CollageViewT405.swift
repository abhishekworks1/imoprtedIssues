//
//  CollageViewT405.swift
//  CollageView
//
//  Created by Viraj Patel on 11/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class CollageViewT405: CollageView {
    
    override func initBaseLines() {
        
        // initialize baseline
        let baseLine01 = BaseLineView()
        baseLine01.id = 1
        baseLine01.moveType = .upDown
        baseLine01.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine01)
        
        let lc01 = NSLayoutConstraint(item: baseLine01, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc02 = NSLayoutConstraint(item: baseLine01, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc03 = NSLayoutConstraint(item: baseLine01, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        let lc04 = NSLayoutConstraint(item: baseLine01, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1/3, constant: 0)
        NSLayoutConstraint.activate([ lc01, lc02, lc03, lc04])
        baseLine01.baseLC = lc04
        
        let baseLine02 = BaseLineView()
        baseLine02.id = 2
        baseLine02.moveType = .leftRight
        baseLine02.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine02)
        
        let lc05 = NSLayoutConstraint(item: baseLine02, attribute: .centerX, relatedBy: .equal, toItem: baseLine01, attribute: .centerX, multiplier: 1, constant: 0)
        let lc06 = NSLayoutConstraint(item: baseLine02, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc07 = NSLayoutConstraint(item: baseLine02, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0)
        let lc08 = NSLayoutConstraint(item: baseLine02, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1/3, constant: 0)
        NSLayoutConstraint.activate([ lc05, lc06, lc07, lc08])
        baseLine02.baseLC = lc07
        
        let baseLine03 = BaseLineView()
        baseLine03.id = 3
        baseLine03.moveType = .leftRight
        baseLine03.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine03)
        
        let lc09 = NSLayoutConstraint(item: baseLine03, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc10 = NSLayoutConstraint(item: baseLine03, attribute: .top, relatedBy: .equal, toItem: baseLine01, attribute: .bottom, multiplier: 1, constant: 0)
        let lc11 = NSLayoutConstraint(item: baseLine03, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0)
        let lc12 = NSLayoutConstraint(item: baseLine03, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1/3, constant: 0)
        NSLayoutConstraint.activate([ lc09, lc10, lc11, lc12])
        baseLine03.baseLC = lc11
        
        let baseLine04 = BaseLineView()
        baseLine04.id = 4
        baseLine04.moveType = .upDown
        baseLine04.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine04)
        
        let lc13 = NSLayoutConstraint(item: baseLine04, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc14 = NSLayoutConstraint(item: baseLine04, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let lc15 = NSLayoutConstraint(item: baseLine04, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        let lc16 = NSLayoutConstraint(item: baseLine04, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1/3, constant: 0)
        NSLayoutConstraint.activate([ lc13, lc14, lc15, lc16])
        baseLine04.baseLC = lc16
        
        self.baseLineViews += [baseLine01,baseLine02,baseLine03,baseLine04]
        self.initCells()
    }
    
    private func initCells() {
        
        let cell01 = CollageCell(id: 1)
        cell01.delegate = self
        self.addSubview(cell01)
        let lc01 = NSLayoutConstraint(item: cell01, attribute: .centerX, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .centerX, multiplier: 1, constant: 0)
        let lc02 = NSLayoutConstraint(item: cell01, attribute: .centerY, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .centerY, multiplier: 1, constant: ((UIScreen.main.bounds.height * 63) / 896))
        let lc03 = NSLayoutConstraint(item: cell01, attribute: .width, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .height, multiplier: 1, constant:0)
        let lc04 = NSLayoutConstraint(item: cell01, attribute: .height, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .height, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([lc01, lc02, lc03, lc04])
        
        let cell03 = CollageCell(id: 2)
        cell03.delegate = self
        self.addSubview(cell03)
        
        let lc09 = NSLayoutConstraint(item: cell03, attribute: .width, relatedBy: .equal, toItem: cell03, attribute: .height, multiplier: 1, constant:0)
        let lc10 = NSLayoutConstraint(item: cell03, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0)
        let lc11 = NSLayoutConstraint(item: cell03, attribute: .right, relatedBy: .equal, toItem: self.baseLineViews[2], attribute: .right, multiplier: 1, constant: ((UIScreen.main.bounds.width * 18) / 414))
        let lc12 = NSLayoutConstraint(item: cell03, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[2], attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc09, lc10, lc11, lc12])
        
        let cell04 = CollageCell(id: 3)
        cell04.delegate = self
        self.addSubview(cell04)
        let lc13 = NSLayoutConstraint(item: cell04, attribute: .left, relatedBy: .equal, toItem: self.baseLineViews[2], attribute: .right, multiplier: 1, constant: ((UIScreen.main.bounds.width * -18) / 414))
        let lc14 = NSLayoutConstraint(item: cell04, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[1], attribute: .bottom, multiplier: 1, constant: 0)
        let lc15 = NSLayoutConstraint(item: cell04, attribute: .width, relatedBy: .equal, toItem: cell01, attribute: .height, multiplier: 1, constant:0)
        let lc16 = NSLayoutConstraint(item: cell04, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[2], attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc13, lc14, lc15, lc16])
        
        let cell05 = CollageCell(id: 4)
        cell05.delegate = self
        self.addSubview(cell05)
        let lc17 = NSLayoutConstraint(item: cell05, attribute: .centerX, relatedBy: .equal, toItem: self.baseLineViews[3], attribute: .centerX, multiplier: 1, constant: 0)
        let lc18 = NSLayoutConstraint(item: cell05, attribute: .centerY, relatedBy: .equal, toItem: self.baseLineViews[3], attribute: .centerY, multiplier: 1, constant: ((UIScreen.main.bounds.height * -63) / 896))
        let lc19 = NSLayoutConstraint(item: cell05, attribute: .width, relatedBy: .equal, toItem: self.baseLineViews[3], attribute: .height, multiplier: 1, constant:0)
        let lc20 = NSLayoutConstraint(item: cell05, attribute: .height, relatedBy: .equal, toItem: self.baseLineViews[3], attribute: .height, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([lc17, lc18, lc19, lc20])
        
        self.marginLeftTopContraints += [lc01,lc02,lc09,lc17]
        self.marginRightBottomContraints += [lc12,lc15,lc16,lc19]
        self.paddingLeftTopContraints += [lc10,lc13,lc14,lc18]
        self.paddingRightBottomContraints += [lc03,lc04,lc11,lc20]
        self.collageCells += [cell01,cell03,cell04,cell05]
    }
    
}
