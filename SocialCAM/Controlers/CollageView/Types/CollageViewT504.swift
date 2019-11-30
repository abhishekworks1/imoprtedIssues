//
//  CollageViewT504.swift
//  CollageView
//
//  Created by Viraj Patel on 26/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation

class CollageViewT504: CollageView {
    
    override func initBaseLines() {
        
        // initialize baseline
        let baseLine01 = BaseLineView()
        baseLine01.id = 1
        baseLine01.moveType = .leftRight
        baseLine01.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine01)
        
        let lc01 = NSLayoutConstraint(item: baseLine01, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc02 = NSLayoutConstraint(item: baseLine01, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc03 = NSLayoutConstraint(item: baseLine01, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: (1.5/3.0), constant: 0)
        let lc04 = NSLayoutConstraint(item: baseLine01, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.5, constant: 0)
        NSLayoutConstraint.activate([lc01, lc02, lc03, lc04])
        baseLine01.baseLC = lc03
        
        let baseLine02 = BaseLineView()
        baseLine02.id = 1
        baseLine02.moveType = .leftRight
        baseLine02.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine02)
        
        let lc05 = NSLayoutConstraint(item: baseLine02, attribute: .left, relatedBy: .equal, toItem: baseLine01, attribute: .right, multiplier: 1, constant: 0)
        let lc06 = NSLayoutConstraint(item: baseLine02, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc07 = NSLayoutConstraint(item: baseLine02, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: (1.5/3.0), constant: 0)
        let lc08 = NSLayoutConstraint(item: baseLine02, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.5, constant: 0)
        NSLayoutConstraint.activate([lc05, lc06, lc07, lc08])
        baseLine02.baseLC = lc07
        
        self.baseLineViews += [baseLine01, baseLine02]
        self.initCells()
        
    }
    
    private func initCells() {
        
        let cell01 = CollageCell(id: 1)
        cell01.delegate = self
        self.addSubview(cell01)
        let lc01 = NSLayoutConstraint(item: cell01, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc02 = NSLayoutConstraint(item: cell01, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc03 = NSLayoutConstraint(item: cell01, attribute: .right, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .right, multiplier: 1, constant: 0)
        let lc04 = NSLayoutConstraint(item: cell01, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc01, lc02, lc03, lc04])
        
        let cell02 = CollageCell(id: 2)
        cell02.delegate = self
        self.addSubview(cell02)
        let lc05 = NSLayoutConstraint(item: cell02, attribute: .left, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .right, multiplier: 1, constant: 0)
        let lc06 = NSLayoutConstraint(item: cell02, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc07 = NSLayoutConstraint(item: cell02, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let lc08 = NSLayoutConstraint(item: cell02, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc05, lc06, lc07, lc08])
        
        let cell04 = CollageCell(id: 4)
        cell04.delegate = self
        self.addSubview(cell04)
        let lc13 = NSLayoutConstraint(item: cell04, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc14 = NSLayoutConstraint(item: cell04, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0)
        let lc15 = NSLayoutConstraint(item: cell04, attribute: .right, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .right, multiplier: 1, constant: 0)
        let lc16 = NSLayoutConstraint(item: cell04, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc13, lc14, lc15, lc16])
        
        let cell05 = CollageCell(id: 5)
        cell05.delegate = self
        self.addSubview(cell05)
        let lc17 = NSLayoutConstraint(item: cell05, attribute: .left, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .right, multiplier: 1, constant: 0)
        let lc18 = NSLayoutConstraint(item: cell05, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0)
        let lc19 = NSLayoutConstraint(item: cell05, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let lc20 = NSLayoutConstraint(item: cell05, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc17, lc18, lc19, lc20])
        
        let cell03 = CollageCell(id: 3)
        cell03.delegate = self
        self.addSubview(cell03)
        
        let lc09 = NSLayoutConstraint(item: cell03, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let lc10 = NSLayoutConstraint(item: cell03, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let lc11 = NSLayoutConstraint(item: cell03, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.39, constant: 0)
        let lc12 = NSLayoutConstraint(item: cell03, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.39, constant: 0)
        NSLayoutConstraint.activate([ lc09, lc10, lc11, lc12])
        
        self.marginLeftTopContraints += [lc01, lc02, lc06, lc13]
        self.marginRightBottomContraints += [lc04, lc07, lc16, lc19, lc20]
        self.paddingLeftTopContraints += [lc05, lc14, lc17, lc18]
        self.paddingRightBottomContraints += [lc08, lc03, lc15]
        self.collageCells += [cell01, cell02, cell04, cell05, cell03]
        
        self.collageCells[4].transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/4))
        self.collageCells[4].photoView.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/4))
        self.collageCells[4].photoView.transform = self.collageCells[4].photoView.transform.scaledBy(x: 1.4, y: 1.4)
        
    }
    
}
