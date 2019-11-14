//
//  CollageViewT801.swift
//  CollageView
//
//  Created by Viraj Patel on 11/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class CollageViewT801: CollageView {
    
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
        let lc04 = NSLayoutConstraint(item: baseLine01, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.25, constant: 0)
        NSLayoutConstraint.activate([ lc01, lc02, lc03, lc04])
        baseLine01.baseLC = lc04
        
        let baseLine02 = BaseLineView()
        baseLine02.id = 2
        baseLine02.moveType = .leftRight
        baseLine02.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine02)
        
        let lc05 = NSLayoutConstraint(item: baseLine02, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc06 = NSLayoutConstraint(item: baseLine02, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc07 = NSLayoutConstraint(item: baseLine02, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0)
        let lc08 = NSLayoutConstraint(item: baseLine02, attribute: .bottom, relatedBy: .equal, toItem: baseLine01, attribute: .bottom, multiplier: 1, constant: 0)
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
        let lc12 = NSLayoutConstraint(item: baseLine03, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.5, constant: 0)
        NSLayoutConstraint.activate([lc09, lc10, lc11, lc12])
        baseLine03.baseLC = lc11
        
        let baseLine04 = BaseLineView()
        baseLine04.id = 4
        baseLine04.moveType = .upDown
        baseLine04.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine04)
        
        let lc13 = NSLayoutConstraint(item: baseLine04, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc14 = NSLayoutConstraint(item: baseLine04, attribute: .top, relatedBy: .equal, toItem: baseLine03, attribute: .bottom, multiplier: 1, constant: 0)
        let lc15 = NSLayoutConstraint(item: baseLine04, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        let lc16 = NSLayoutConstraint(item: baseLine04, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.25, constant: 0)
        NSLayoutConstraint.activate([lc13, lc14, lc15, lc16])
        baseLine04.baseLC = lc16
        
        
        let baseLine05 = BaseLineView()
        baseLine05.id = 5
        baseLine05.moveType = .leftRight
        baseLine05.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine05)
        
        let lc17 = NSLayoutConstraint(item: baseLine05, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc18 = NSLayoutConstraint(item: baseLine05, attribute: .top, relatedBy: .equal, toItem: baseLine04, attribute: .top, multiplier: 1, constant: 0)
        let lc19 = NSLayoutConstraint(item: baseLine05, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0)
        let lc20 = NSLayoutConstraint(item: baseLine05, attribute: .bottom, relatedBy: .equal, toItem: baseLine04, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([lc17, lc18, lc19, lc20])
        baseLine05.baseLC = lc19
        
        let baseLine06 = BaseLineView()
        baseLine06.id = 6
        baseLine06.moveType = .leftRight
        baseLine06.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseLine06)
        
        let lc21 = NSLayoutConstraint(item: baseLine06, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc22 = NSLayoutConstraint(item: baseLine06, attribute: .top, relatedBy: .equal, toItem: baseLine04, attribute: .bottom, multiplier: 1, constant: 0)
        let lc23 = NSLayoutConstraint(item: baseLine06, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0)
        let lc24 = NSLayoutConstraint(item: baseLine06, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc21, lc22, lc23, lc24])
        baseLine06.baseLC = lc23
        
        self.baseLineViews += [baseLine01,baseLine02,baseLine03,baseLine04,baseLine05,baseLine06]
        self.initCells()
    }
    
    private func initCells() {
        
        let cell01 = CollageCell(id: 1)
        cell01.delegate = self
        self.addSubview(cell01)
        let lc01 = NSLayoutConstraint(item: cell01, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc02 = NSLayoutConstraint(item: cell01, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc03 = NSLayoutConstraint(item: cell01, attribute: .right, relatedBy: .equal, toItem: self.baseLineViews[1], attribute: .right, multiplier: 1, constant:0.0)
        let lc04 = NSLayoutConstraint(item: cell01, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0.0)
        NSLayoutConstraint.activate([ lc01, lc02, lc03, lc04])
        
        let cell02 = CollageCell(id: 2)
        cell02.delegate = self
        self.addSubview(cell02)
        let lc05 = NSLayoutConstraint(item: cell02, attribute: .left, relatedBy: .equal, toItem: self.baseLineViews[1], attribute: .right, multiplier: 1, constant: 0)
        let lc06 = NSLayoutConstraint(item: cell02, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let lc07 = NSLayoutConstraint(item: cell02, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let lc08 = NSLayoutConstraint(item: cell02, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc05, lc06, lc07, lc08])
        
        let cell03 = CollageCell(id: 3)
        cell03.delegate = self
        self.addSubview(cell03)
        let lc09 = NSLayoutConstraint(item: cell03, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc10 = NSLayoutConstraint(item: cell03, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0)
        let lc11 = NSLayoutConstraint(item: cell03, attribute: .right, relatedBy: .equal, toItem: self.baseLineViews[2], attribute: .right, multiplier: 1, constant: 0)
        let lc12 = NSLayoutConstraint(item: cell03, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[2], attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc09, lc10, lc11, lc12])
        
        let cell04 = CollageCell(id: 4)
        cell04.delegate = self
        self.addSubview(cell04)
        let lc13 = NSLayoutConstraint(item: cell04, attribute: .left, relatedBy: .equal, toItem: self.baseLineViews[2], attribute: .right, multiplier: 1, constant: 0)
        let lc14 = NSLayoutConstraint(item: cell04, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[0], attribute: .bottom, multiplier: 1, constant: 0)
        let lc15 = NSLayoutConstraint(item: cell04, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let lc16 = NSLayoutConstraint(item: cell04, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[2], attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc13, lc14, lc15, lc16])
        
        let cell05 = CollageCell(id: 5)
        cell05.delegate = self
        self.addSubview(cell05)
        let lc17 = NSLayoutConstraint(item: cell05, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc18 = NSLayoutConstraint(item: cell05, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[3], attribute: .top, multiplier: 1, constant: 0)
        let lc19 = NSLayoutConstraint(item: cell05, attribute: .right, relatedBy: .equal, toItem: self.baseLineViews[4], attribute: .right, multiplier: 1, constant:0.0)
        let lc20 = NSLayoutConstraint(item: cell05, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[3], attribute: .bottom, multiplier: 1, constant: 0.0)
        NSLayoutConstraint.activate([ lc17, lc18, lc19, lc20])
        
        let cell06 = CollageCell(id: 6)
        cell06.delegate = self
        self.addSubview(cell06)
        let lc21 = NSLayoutConstraint(item: cell06, attribute: .left, relatedBy: .equal, toItem: self.baseLineViews[4], attribute: .right, multiplier: 1, constant: 0)
        let lc22 = NSLayoutConstraint(item: cell06, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[3], attribute: .top, multiplier: 1, constant: 0)
        let lc23 = NSLayoutConstraint(item: cell06, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let lc24 = NSLayoutConstraint(item: cell06, attribute: .bottom, relatedBy: .equal, toItem: self.baseLineViews[3], attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc21, lc22, lc23, lc24])
        
        let cell07 = CollageCell(id: 7)
        cell07.delegate = self
        self.addSubview(cell07)
        let lc25 = NSLayoutConstraint(item: cell07, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let lc26 = NSLayoutConstraint(item: cell07, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[4], attribute: .bottom, multiplier: 1, constant: 0)
        let lc27 = NSLayoutConstraint(item: cell07, attribute: .right, relatedBy: .equal, toItem: self.baseLineViews[5], attribute: .right, multiplier: 1, constant: 0)
        let lc28 = NSLayoutConstraint(item: cell07, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc25, lc26, lc27, lc28])
        
        let cell08 = CollageCell(id: 8)
        cell08.delegate = self
        self.addSubview(cell08)
        let lc29 = NSLayoutConstraint(item: cell08, attribute: .left, relatedBy: .equal, toItem: self.baseLineViews[5], attribute: .right, multiplier: 1, constant: 0)
        let lc30 = NSLayoutConstraint(item: cell08, attribute: .top, relatedBy: .equal, toItem: self.baseLineViews[4], attribute: .bottom, multiplier: 1, constant: 0)
        let lc31 = NSLayoutConstraint(item: cell08, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let lc32 = NSLayoutConstraint(item: cell08, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ lc29, lc30, lc31, lc32])
        
        self.marginLeftTopContraints += [lc01,lc02,lc06,lc09]
        self.marginRightBottomContraints += [lc07,lc12,lc15,lc16]
        self.paddingLeftTopContraints += [lc05,lc10,lc13,lc14]
        self.paddingRightBottomContraints += [lc03,lc04,lc08,lc11]
        
        self.marginLeftTopContraints += [lc17,lc25]
        self.marginRightBottomContraints += [lc23,lc28,lc31,lc32]
        self.paddingLeftTopContraints += [lc18,lc21,lc22,lc26,lc29,lc30]
        self.paddingRightBottomContraints += [lc19,lc20,lc24,lc27]
        
        self.collageCells += [cell01,cell02,cell03,cell04,cell05,cell06,cell07,cell08]
        
        // initHandles()
    }
    
    private func initHandles() {
        
        let cell01 = self.collageCells[0]
        var handle01, handle02, handle03 : LineHandleView!
        
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .right, blview: self.baseLineViews[1], cell: cell01)
        handle01.datasource = self
        handle02 = LineHandleView()
        self.addSubview(handle02)
        handle02.initialize(attach: .bottom, blview: self.baseLineViews[0], cell: cell01)
        handle02.datasource = self
        cell01.setHandles(handles: [handle01,handle02])
        
        let cell02 = self.collageCells[1]
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .left, blview: self.baseLineViews[1], cell: cell02)
        handle01.datasource = self
        handle02 = LineHandleView()
        self.addSubview(handle02)
        handle02.initialize(attach: .bottom, blview: self.baseLineViews[0], cell: cell02)
        handle02.datasource = self
        cell02.setHandles(handles: [handle01,handle02])
        
        let cell03 = self.collageCells[2]
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .top, blview: self.baseLineViews[0], cell: cell03)
        handle01.datasource = self
        handle02 = LineHandleView()
        self.addSubview(handle02)
        handle02.initialize(attach: .right, blview: self.baseLineViews[6], cell: cell03)
        handle02.datasource = self
        handle03 = LineHandleView()
        self.addSubview(handle03)
        handle03.initialize(attach: .bottom, blview: self.baseLineViews[2], cell: cell03)
        handle03.datasource = self
        cell03.setHandles(handles: [handle01,handle02,handle03])
        
        let cell04 = self.collageCells[3]
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .left, blview: self.baseLineViews[6], cell: cell04)
        handle01.datasource = self
        handle02 = LineHandleView()
        self.addSubview(handle02)
        handle02.initialize(attach: .top, blview: self.baseLineViews[0], cell: cell04)
        handle02.datasource = self
        handle03 = LineHandleView()
        self.addSubview(handle03)
        handle03.initialize(attach: .bottom, blview: self.baseLineViews[2], cell: cell04)
        handle03.datasource = self
        cell04.setHandles(handles: [handle01,handle02,handle03])
        
        let cell05 = self.collageCells[4]
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .right, blview: self.baseLineViews[4], cell: cell05)
        handle01.datasource = self
        handle02 = LineHandleView()
        self.addSubview(handle02)
        handle02.initialize(attach: .top, blview: self.baseLineViews[2], cell: cell05)
        handle02.datasource = self
        handle03 = LineHandleView()
        self.addSubview(handle03)
        handle03.initialize(attach: .bottom, blview: self.baseLineViews[5], cell: cell05)
        handle03.datasource = self
        cell05.setHandles(handles: [handle01,handle02,handle03])
        
        let cell06 = self.collageCells[5]
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .left, blview: self.baseLineViews[4], cell: cell06)
        handle01.datasource = self
        handle02 = LineHandleView()
        self.addSubview(handle02)
        handle02.initialize(attach: .top, blview: self.baseLineViews[2], cell: cell06)
        handle02.datasource = self
        handle03 = LineHandleView()
        self.addSubview(handle03)
        handle03.initialize(attach: .bottom, blview: self.baseLineViews[5], cell: cell06)
        handle03.datasource = self
        cell06.setHandles(handles: [handle01,handle02,handle03])
        
        let cell07 = self.collageCells[6]
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .right, blview: self.baseLineViews[7], cell: cell07)
        handle01.datasource = self
        handle02 = LineHandleView()
        self.addSubview(handle02)
        handle02.initialize(attach: .top, blview: self.baseLineViews[5], cell: cell07)
        handle02.datasource = self
        cell07.setHandles(handles: [handle01,handle02])
        
        let cell08 = self.collageCells[7]
        handle01 = LineHandleView()
        self.addSubview(handle01)
        handle01.initialize(attach: .left, blview: self.baseLineViews[7], cell: cell08)
        handle01.datasource = self
        handle02 = LineHandleView()
        self.addSubview(handle02)
        handle02.initialize(attach: .top, blview: self.baseLineViews[5], cell: cell08)
        handle02.datasource = self
        cell08.setHandles(handles: [handle01,handle02])
        
    }
}

