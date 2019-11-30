//
//  CollageViewT303.swift
//  CollageView
//
//  Created by Viraj Patel on 11/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class CollageViewT303: CollageView {
    
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
        let lc04 = NSLayoutConstraint(item: baseLine01, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([lc01, lc02, lc03, lc04])
        baseLine01.baseLC = lc03
        
        self.baseLineViews += [baseLine01]
        self.initCells()
        
    }
    
    private func initCells() {
        
        let cell01 = CollageCell(id: 1)
        cell01.delegate = self
        self.addSubview(cell01)
        let lc01 = NSLayoutConstraint(item: cell01, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc02 = NSLayoutConstraint(item: cell01, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc03 = NSLayoutConstraint(item: cell01, attribute: .right, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .right, multiplier: 1, constant: 0)
        let lc04 = NSLayoutConstraint(item: cell01, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc01, lc02, lc03, lc04])
        
        let cell02 = CollageCell(id: 2)
        cell02.delegate = self
        self.addSubview(cell02)
        let lc05 = NSLayoutConstraint(item: cell02, attribute: .left, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .right, multiplier: 1, constant: 0)
        let lc06 = NSLayoutConstraint(item: cell02, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc07 = NSLayoutConstraint(item: cell02, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let lc08 = NSLayoutConstraint(item: cell02, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc05, lc06, lc07, lc08])
        
        let cell03 = CollageCell(id: 3)
        cell03.delegate = self
        self.addSubview(cell03)
        
        let lc09 = NSLayoutConstraint(item: cell03, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let lc10 = NSLayoutConstraint(item: cell03, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let lc11 = NSLayoutConstraint(item: cell03, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.39, constant: 0)
        let lc12 = NSLayoutConstraint(item: cell03, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.39, constant: 0)
        NSLayoutConstraint.activate([ lc09, lc10, lc11, lc12])
        
        self.marginLeftTopContraints += [lc01, lc02, lc06]
        self.marginRightBottomContraints += [lc04, lc07, lc08]
        self.paddingLeftTopContraints += [lc05]
        self.paddingRightBottomContraints += [lc03]
        self.collageCells += [cell01, cell02, cell03]
        
        self.collageCells[2].transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/4))
        self.collageCells[2].photoView.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/4))
        self.collageCells[2].photoView.transform = self.collageCells[2].photoView.transform.scaledBy(x: 1.4, y: 1.4)
  
        initHandles()
    }
    
    private func initHandles() {
        
        let cell01 = self.collageCells[0]
        var handle01: LineHandleView!
        
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .right, blview: self.baseLineViews[0], cell: cell01)
        handle01.datasource = self
        cell01.setHandles(handles: [handle01])
        
        let cell02 = self.collageCells[1]
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .left, blview: self.baseLineViews[0], cell: cell02)
        handle01.datasource = self
        
        cell02.setHandles(handles: [handle01])
        
    }
}
