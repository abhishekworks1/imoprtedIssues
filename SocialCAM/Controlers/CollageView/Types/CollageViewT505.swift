//
//  CollageViewT505.swift
//  CollageView
//
//  Created by Viraj Patel on 26/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class CollageViewT505: CollageView {
    
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
        let lc04 = NSLayoutConstraint(item: baseLine01, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: (1.0/3.0), constant: 0)
        NSLayoutConstraint.activate([ lc01, lc02, lc03, lc04])
        baseLine01.baseLC = lc04
        
        let baseLine03 = BaseLineView()
        baseLine03.id = 3
        baseLine03.moveType = .leftRight
        baseLine03.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine03)
        
        let lc09 = NSLayoutConstraint(item: baseLine03, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc10 = NSLayoutConstraint(item: baseLine03, attribute: .top, relatedBy: .equal, toItem: baseLine01, attribute: .bottom, multiplier: 1, constant: 0)
        let lc11 = NSLayoutConstraint(item: baseLine03, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0)
        let lc12 = NSLayoutConstraint(item: baseLine03, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.3/3, constant: 0)
        NSLayoutConstraint.activate([ lc09, lc10, lc11, lc12])
        baseLine03.baseLC = lc11
        
        let baseLine04 = BaseLineView()
        baseLine04.id = 4
        baseLine04.moveType = .upDown
        baseLine04.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine04)
        
        let lc13 = NSLayoutConstraint(item: baseLine04, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc14 = NSLayoutConstraint(item: baseLine04, attribute: .top, relatedBy: .equal, toItem: baseLine03, attribute: .bottom, multiplier: 1, constant: 0)
        let lc15 = NSLayoutConstraint(item: baseLine04, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0)
        let lc16 = NSLayoutConstraint(item: baseLine04, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc13, lc14, lc15, lc16])
        baseLine04.baseLC = lc16
        
        let baseLine05 = BaseLineView()
        baseLine05.id = 5
        baseLine05.moveType = .leftRight
        baseLine05.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine05)
        let lc17 = NSLayoutConstraint(item: baseLine05, attribute: .left, relatedBy: .equal, toItem: baseLine04, attribute: .right, multiplier: 1, constant: 0)
        let lc18 = NSLayoutConstraint(item: baseLine05, attribute: .top, relatedBy: .equal, toItem: baseLine03, attribute: .bottom, multiplier: 1, constant: 0)
        let lc19 = NSLayoutConstraint(item: baseLine05, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let lc20 = NSLayoutConstraint(item: baseLine05, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc17, lc18, lc19, lc20])
        baseLine05.baseLC = lc19
        
        let baseLine06 = BaseLineView()
        baseLine06.id = 6
        baseLine06.moveType = .leftRight
        baseLine06.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine06)
        
        let lc21 = NSLayoutConstraint(item: baseLine06, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc22 = NSLayoutConstraint(item: baseLine06, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc23 = NSLayoutConstraint(item: baseLine06, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1/2, constant: 0)
        let lc24 = NSLayoutConstraint(item: baseLine06, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: (1.0/3.0), constant: 0)
        NSLayoutConstraint.activate([ lc21, lc22, lc23, lc24])
        baseLine06.baseLC = lc23
        
        self.baseLineViews += [baseLine01, baseLine03, baseLine04, baseLine05, baseLine06]
        self.initCells()
    }
    
    private func initCells() {
        
        let cell01 = CollageCell(id: 1)
        cell01.delegate = self
        self.addSubview(cell01)
        let lc01 = NSLayoutConstraint(item: cell01, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc02 = NSLayoutConstraint(item: cell01, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc03 = NSLayoutConstraint(item: cell01, attribute: .right, relatedBy: .equal, toItem: self.baseLineViews[4], attribute: .right, multiplier: 1, constant: 0)
        let lc04 = NSLayoutConstraint(item: cell01, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc01, lc02, lc03, lc04])
        
        let cell04 = CollageCell(id: 4)
        cell04.delegate = self
        self.addSubview(cell04)
        let lc011 = NSLayoutConstraint(item: cell04, attribute: .left, relatedBy: .equal, toItem: self.baseLineViews[4], attribute: .right, multiplier: 1, constant: 0)
        let lc021 = NSLayoutConstraint(item: cell04, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc031 = NSLayoutConstraint(item: cell04, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let lc041 = NSLayoutConstraint(item: cell04, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc011, lc021, lc031, lc041])
        
        let cell02 = CollageCell(id: 2)
        cell02.delegate = self
        self.addSubview(cell02)
        let lc05 = NSLayoutConstraint(item: cell02, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc06 = NSLayoutConstraint(item: cell02, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0)
        let lc07 = NSLayoutConstraint(item: cell02, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let lc08 = NSLayoutConstraint(item: cell02, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[2], attribute: .top, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc05, lc06, lc07, lc08])
        
        let cell03 = CollageCell(id: 3)
        cell03.delegate = self
        self.addSubview(cell03)
        let lc09 = NSLayoutConstraint(item: cell03, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc10 = NSLayoutConstraint(item: cell03, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[2], attribute: .top, multiplier: 1, constant: 0)
        let lc11 = NSLayoutConstraint(item: cell03, attribute: .right, relatedBy: .equal, toItem: self.baseLineViews[3], attribute: .left, multiplier: 1, constant: 0)
        let lc12 = NSLayoutConstraint(item: cell03, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc09, lc10, lc11, lc12])
        
        let cell05 = CollageCell(id: 5)
        cell05.delegate = self
        self.addSubview(cell05)
        let lc012 = NSLayoutConstraint(item: cell05, attribute: .left, relatedBy: .equal, toItem: self.baseLineViews[3], attribute: .left, multiplier: 1, constant: 0)
        let lc022 = NSLayoutConstraint(item: cell05, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[2], attribute: .top, multiplier: 1, constant: 0)
        let lc032 = NSLayoutConstraint(item: cell05, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let lc042 = NSLayoutConstraint(item: cell05, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc012, lc022, lc032, lc042])
        
        self.marginLeftTopContraints += [lc01, lc02, lc05, lc09, lc021]
        self.marginRightBottomContraints += [lc03, lc07, lc12, lc031, lc032, lc042]
        self.paddingLeftTopContraints += [lc06, lc10, lc011, lc012, lc022]
        self.paddingRightBottomContraints += [lc04, lc08, lc041]
        self.collageCells += [cell01, cell04, cell02, cell03, cell05]
        
        initHandles()
    }
    
    private func initHandles() {
        
        let cell01 = self.collageCells[0]
        var handle01, handle02, handle03: LineHandleView!
        
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .right, blview: self.baseLineViews[4], cell: cell01)
        handle01.datasource = self
        handle02 = LineHandleView()
        self.addSubview(handle02)
        handle02.initialize(attach: .bottom, blview: self.baseLineViews[0], cell: cell01)
        handle02.datasource = self
        cell01.setHandles(handles: [handle01, handle02])
        
        let cell02 = self.collageCells[1]
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .left, blview: self.baseLineViews[4], cell: cell02)
        handle01.datasource = self
        handle02 = LineHandleView()
        self.addSubview(handle02)
        handle02.initialize(attach: .bottom, blview: self.baseLineViews[0], cell: cell02)
        handle02.datasource = self
        cell02.setHandles(handles: [handle01, handle02])
        
        let cell03 = self.collageCells[2]
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .top, blview: self.baseLineViews[0], cell: cell03)
        handle01.datasource = self
        handle03 = LineHandleView()
        self.addSubview(handle03)
        handle03.initialize(attach: .bottom, blview: self.baseLineViews[2], cell: cell03)
        handle03.datasource = self
        cell03.setHandles(handles: [handle01, handle03])
        
        let cell04 = self.collageCells[3]
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .right, blview: self.baseLineViews[3], cell: cell04)
        handle01.datasource = self
        handle02 = LineHandleView()
        self.addSubview(handle02)
        handle02.initialize(attach: .top, blview: self.baseLineViews[2], cell: cell04)
        handle02.datasource = self
        cell04.setHandles(handles: [handle01, handle02])
        
        let cell05 = self.collageCells[4]
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .top, blview: self.baseLineViews[2], cell: cell05)
        handle01.datasource = self
        handle02 = LineHandleView()
        self.addSubview(handle02)
        handle02.initialize(attach: .left, blview: self.baseLineViews[3], cell: cell05)
        handle02.datasource = self
        cell05.setHandles(handles: [handle01, handle02])
        
    }
}
