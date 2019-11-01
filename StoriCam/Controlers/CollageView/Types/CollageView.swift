//
//  CollageView.swift
//  CollageView
//
//  Created by Viraj Patel on 11/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

protocol CollageViewDelegate : class {
    func didSelectCell(cellId : Int)
    func didSelectBlankCell(cellId : Int)
}

enum CollageViewDirection : Int {
    case none
    case left
    case right
    case top
    case bottom
    
    var string : String {
        switch self {
        case .left : return "left"
        case .right : return "right"
        case .top : return "top"
        case .bottom: return "bottom"
        default: return "none"
        }
    }
}


enum CollageViewType : Int {
    case t101
    case t201
    case t202
    case t301
    case t302
    case t303
    case t401
    case t402
    case t403
    case t801
    case t802
    case t501
    case t502
    case t601
    case t602
    case t404
    case t405
    case t304
    case t406
    case t503
    case t504
    case t305
    case t306
    case t407
    case t505
    case t307
    case t408
    case t506
    case t203
    case t204
    case t205
    case t206
    case t207
    case t208
    case t209
    case t308
    case t309
    case t310
    case t311
    case t312
    case t313
    var getInstance : CollageView {
        switch self {
        case .t101 : return CollageViewT101()
        case .t201 : return CollageViewT201()
        case .t202 : return CollageViewT202()
        case .t301 : return CollageViewT301()
        case .t302 : return CollageViewT302()
        case .t303 : return CollageViewT303()
        case .t401 : return CollageViewT401()
        case .t402 : return CollageViewT402()
        case .t403 : return CollageViewT403()
        case .t801 : return CollageViewT801()
        case .t802 : return CollageViewT802()
        case .t501 : return CollageViewT501()
        case .t502 : return CollageViewT502()
        case .t601 : return CollageViewT601()
        case .t602 : return CollageViewT602()
        case .t404 : return CollageViewT404()
        case .t405 : return CollageViewT405()
        case .t304 : return CollageViewT304()
        case .t406 : return CollageViewT406()
        case .t503 : return CollageViewT503()
        case .t504 : return CollageViewT504()
        case .t305 : return CollageViewT305()
        case .t306 : return CollageViewT306()
        case .t407 : return CollageViewT407()
        case .t505 : return CollageViewT505()
        case .t307 : return CollageViewT307()
        case .t408 : return CollageViewT408()
        case .t506 : return CollageViewT506()
        case .t203 : return CollageViewT203()
        case .t204 : return CollageViewT204()
        case .t205 : return CollageViewT205()
        case .t206 : return CollageViewT206()
        case .t207 : return CollageViewT207()
        case .t208 : return CollageViewT208()
        case .t209 : return CollageViewT209()
        case .t308 : return CollageViewT308()
        case .t309 : return CollageViewT309()
        case .t310 : return CollageViewT310()
        case .t311 : return CollageViewT311()
        case .t312 : return CollageViewT312()
        case .t313 : return CollageViewT313()
        }
    }
}


open class CollageView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    var baseLineViews : [BaseLineView] = []
    var collageCells : [CollageCell] = []
    var marginLeftTopContraints : [NSLayoutConstraint] = []
    var marginRightBottomContraints : [NSLayoutConstraint] = []
    var paddingLeftTopContraints : [NSLayoutConstraint] = []
    var paddingRightBottomContraints : [NSLayoutConstraint] = []
    private var setPhoto : Bool = false
    var margin : CGFloat = 0.0
    var padding : CGFloat = 0.0
    weak var delegate: CollageViewDelegate?
    var collageType : CollageViewType = .t301
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initBaseLines()
        
        self.backgroundColor = ApplicationSettings.appWhiteColor
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initBaseLines()
        
        self.backgroundColor = ApplicationSettings.appWhiteColor
    }
    
    
    open func initBaseLines() {}
    
    
    func updatePadding(val : CGFloat) {
        
        for lc in self.paddingLeftTopContraints {
            lc.constant = val
        }
        for lc in self.paddingRightBottomContraints {
            lc.constant = -val
        }
        self.padding = val
        self.layoutIfNeeded()
    }
    
    func updateBorder(val : CGFloat) {
        if collageType == .t304 || collageType == .t303 {
            for cell in self.collageCells {
                if cell.id != 3 {
                    self.addBorder(cell: cell, val: val)
                }
            }
        } else {
            for cell in self.collageCells {
                self.addBorder(cell: cell, val: val)
            }
        }
    }
    
    func addBorder(cell: CollageCell, val: CGFloat) {
        cell.layer.borderColor = ApplicationSettings.appWhiteColor.cgColor
        cell.layer.borderWidth = val
    }
    
    func updateMargin(val : CGFloat) {
        
        for lc in self.marginLeftTopContraints {
            lc.constant = val
        }
        for lc in self.marginRightBottomContraints {
            lc.constant = -val
        }
        self.margin = val
        self.layoutIfNeeded()
    }
    
    func setPhotos(photos : [UIImage]) {
        
        guard !setPhoto else { return }
        setPhoto = true
        
        for (i,photo) in photos.enumerated() {
            guard i < self.collageCells.count else { break }
            let cell = self.collageCells[i]
            
            cell.photoView.setPhoto(img: photo)
        }
    }
    
    func cornerRedius(views: [UIView]) {
        for view in views {
            if view.frame.height > view.frame.width
            {
                view.layer.cornerRadius = view.frame.width / 2
            }
            else {
                view.layer.cornerRadius = view.frame.height / 2
            }
            view.layer.masksToBounds = true
            view.clipsToBounds = true
        }
    }
    
    func setViewHaxa(isRoundedHex: Bool? = false, shapeMask: Bool = true) {
        
        for cell in collageCells {
            if isRoundedHex! {
                if cell.id != 4 {
                    let cellItem = cell
                    cellItem.frame = CGRect.init(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.frame.width - 10, height: cell.frame.height - 10)
                    setHaxa(cell: cellItem, shapeMask: shapeMask)
                }
            } else {
                let polyWidth = cell.frame.width - 10
                let polyHeight = cell.frame.height - 10
                cell.layer.masksToBounds = false
                cell.layer.shouldRasterize = true
                cell.isOpaque = true
                if shapeMask {
                    cell.layer.mask = cell.drawRoundedHex(width: polyWidth, height: polyHeight, cornerRadius: 02, sides: 6,shapeMask : shapeMask, type: .hexa)
                } else {
                    cell.layer.addSublayer(cell.drawRoundedHex(width: polyWidth, height: polyHeight, cornerRadius: 02, sides: 6,shapeMask : shapeMask, type: .hexa))
                }
                cell.layer.masksToBounds = false
                cell.layer.shouldRasterize = true
                cell.isOpaque = true
                cell.layer.addSublayer(cell.drawRoundedBorder(width: polyWidth, height: polyHeight, cornerRadius: 02, lineWidth: 6, sides: 6, type: .hexa))
            }
        }
    }
    
    func setHaxa(cell: CollageCell, shapeMask: Bool = true) {
        let polyWidth = cell.frame.width
        let polyHeight = cell.frame.height
        if shapeMask {
            cell.layer.mask  = cell.drawRoundedHex(width: polyWidth, height: polyHeight, cornerRadius: 02, sides: 8,shapeMask : shapeMask,type: .hexa)
        } else {
            cell.layer.addSublayer(cell.drawRoundedHex(width: polyWidth, height: polyHeight, cornerRadius: 02, sides: 8,shapeMask : shapeMask,type: .hexa))
        }
        cell.layer.masksToBounds = false
        cell.layer.shouldRasterize = true
        cell.isOpaque = true
        cell.layer.addSublayer(cell.drawRoundedBorder(width: polyWidth, height: polyHeight, cornerRadius: 02, lineWidth: 6, sides: 8, type: .hexa))
    }
    
    func setHeartView(indexItem: Int) {
        for cell in collageCells {
            if cell.id == indexItem {
                let polyWidth = cell.frame.width
                let polyHeight = cell.frame.height
                cell.layer.mask = cell.drawRoundedHex(width: polyWidth, height: polyHeight, cornerRadius: 02, sides:  6, type: .heart)
                cell.layer.masksToBounds = false
                cell.layer.shouldRasterize = true
                cell.isOpaque = true
                cell.layer.addSublayer(cell.drawRoundedBorder(width: polyWidth, height: polyHeight, cornerRadius: 02, lineWidth: 6, sides: 6,type: .heart))
            }
        }
    }
    
    func setTransferentView(isLargeSize: Bool = false) {
        for cell in collageCells {
            let polyWidth = cell.frame.width
            let polyHeight = cell.frame.height
            if cell.id == 3 {
                cell.layer.addSublayer(cell.drawRoundedHex(width: polyWidth, height: polyHeight, shapeMask : false, type: .star))
                cell.layer.masksToBounds = false
                cell.layer.shouldRasterize = true
                cell.isOpaque = true
            } else if cell.id == 4 {
                cell.layer.addSublayer(cell.drawRoundedHex(width: polyWidth - 10, height: polyHeight - 10, shapeMask : false, type: .heart))
                cell.layer.masksToBounds = false
                cell.layer.shouldRasterize = true
                cell.isOpaque = true
            }
        }
    }
    
}

extension CollageView : CollageCellDelegate {
    
    func didSelectCell(cellId: Int) {
        var isDidSelectedFirst = false
        for cell in self.collageCells {
            
            if cell.id == cellId {
                if cell.photoView.photoImage.image == nil {
                    delegate?.didSelectBlankCell(cellId: cellId)
                    return
                }
            }
            
            if cell.id != cellId {
                cell.isSelected = false
                if !isDidSelectedFirst {
                    delegate?.didSelectCell(cellId: cellId)
                    isDidSelectedFirst = true
                }
            } else {
                cell.isSelected = true
            }
        }
    }
    
}

extension CollageView : LineHandleViewDataSource {
    
    func sizeView() -> CGSize {
        let size = self.frame.size
        return size
    }
    
    func canMove(to: CGPoint, minLen: CGFloat, baseLine: BaseLineView) -> Bool {
        return true
    }
}
