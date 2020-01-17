//
//  BasePopOverMenu.swift
//  ProManager
//
//  Created by Viraj Patel on 14/05/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

extension BasePopOverMenu {
    
    public static func showForSender(sender: UIView, with menuArray: [String], withSelectedName: String? = nil, done: @escaping (NSInteger) -> Void, cancel: @escaping () -> Void) {
        self.sharedMenu.showForSender(sender: sender, or: nil, with: menuArray, menuImageArray: [], withSelectedName: withSelectedName, done: done, cancel: cancel)
    }
    public static func showForSender(sender: UIView, with menuArray: [String], menuImageArray: [UIImage], done: @escaping (NSInteger) -> Void, cancel: @escaping () -> Void) {
        self.sharedMenu.showForSender(sender: sender, or: nil, with: menuArray, menuImageArray: menuImageArray, done: done, cancel: cancel)
    }
    
    public static func showForEvent(event: UIEvent, with menuArray: [String], done: @escaping (NSInteger) -> Void, cancel: @escaping () -> Void) {
        self.sharedMenu.showForSender(sender: event.allTouches?.first?.view!, or: nil, with: menuArray, menuImageArray: [], done: done, cancel: cancel)
    }
    public static func showForEvent(event: UIEvent, with menuArray: [String], menuImageArray: [UIImage], done: @escaping (NSInteger) -> Void, cancel: @escaping () -> Void) {
        self.sharedMenu.showForSender(sender: event.allTouches?.first?.view!, or: nil, with: menuArray, menuImageArray: menuImageArray, done: done, cancel: cancel)
    }
    
    public static func showFromSenderFrame(senderFrame: CGRect, with menuArray: [String], done: @escaping (NSInteger) -> Void, cancel: @escaping () -> Void) {
        self.sharedMenu.showForSender(sender: nil, or: senderFrame, with: menuArray, menuImageArray: [], done: done, cancel: cancel)
    }
    public static func showFromSenderFrame(senderFrame: CGRect, with menuArray: [String], menuImageArray: [UIImage], done: @escaping (NSInteger) -> Void, cancel: @escaping () -> Void) {
        self.sharedMenu.showForSender(sender: nil, or: senderFrame, with: menuArray, menuImageArray: menuImageArray, done: done, cancel: cancel)
    }
    
    public static func dismiss() {
        self.sharedMenu.dismiss()
    }
}

public class BasePopConfiguration: NSObject {
    
    public var menuRowHeight: CGFloat = defaultMenuRowHeight
    public var menuWidth: CGFloat = defaultMenuWidth
    public var showCheckMark: UITableViewCell.AccessoryType = .none
    public var textColor: UIColor = ApplicationSettings.appBlackColor
    public var textFont: UIFont = UIFont.systemFont(ofSize: 14)
    public var borderColor: UIColor = defaultTintColor
    public var borderWidth: CGFloat = defaultBorderWidth
    public var backgoundTintColor: UIColor = defaultTintColor
    public var cornerRadius: CGFloat = defaultCornerRadius
    public var textAlignment: NSTextAlignment = NSTextAlignment.left
    public var ignoreImageOriginalColor: Bool = false
    public var menuSeparatorColor: UIColor = ApplicationSettings.appLightGrayColor
    public var menuSeparatorInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: defaultCellMargin, bottom: 0, right: defaultCellMargin)
    public var cellSelectionStyle: UITableViewCell.SelectionStyle = .none
    public var joinText: String = "FPS"
    
    public static var shared: BasePopConfiguration {
        struct StaticConfig {
            static let instance: BasePopConfiguration = BasePopConfiguration()
        }
        return StaticConfig.instance
    }
    
}

private let defaultMargin: CGFloat = 4
private let defaultCellMargin: CGFloat = 6
private let defaultMenuIconSize: CGFloat = 24
private let defaultMenuCornerRadius: CGFloat = 4
private let defaultMenuArrowWidth: CGFloat = 8
private let defaultMenuArrowHeight: CGFloat = 10
private let defaultAnimationDuration: TimeInterval = 0.2
private let defaultBorderWidth: CGFloat = 0.5
private let defaultCornerRadius: CGFloat = 6
private let defaultMenuRowHeight: CGFloat = 40
private let defaultMenuWidth: CGFloat = 120
private let defaultTintColor: UIColor = ApplicationSettings.appWhiteColor

private let basePopOverMenuTableViewCellIndentifier: String = "BasePopOverMenuTableViewCellIndentifier"

private enum BasePopOverMenuArrowDirection {
    case up
    case down
}

public class BasePopOverMenu: NSObject {
    
    var sender: UIView?
    var senderFrame: CGRect?
    var menuNameArray: [String]!
    var selectedName: String?
    var menuImageArray: [UIImage]!
    var done: ((_ selectedIndex: NSInteger) -> Void)!
    var cancel: (() -> Void)!
    
    fileprivate static var sharedMenu: BasePopOverMenu {
        struct Static {
            static let instance: BasePopOverMenu = BasePopOverMenu()
        }
        return Static.instance
    }
    
    fileprivate lazy var configuration: BasePopConfiguration = {
        return BasePopConfiguration.shared
    }()
    
    fileprivate lazy var backgroundView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = ApplicationSettings.appClearColor
        view.addGestureRecognizer(self.tapGesture)
        return view
    }()
    
    fileprivate lazy var popOverMenu: BasePopOverMenuView = {
        let menu = BasePopOverMenuView(frame: CGRect.zero)
        menu.alpha = 0
        self.backgroundView.addSubview(menu)
        return menu
    }()
    
    fileprivate var isOnScreen: Bool = false {
        didSet {
            if isOnScreen {
                self.addOrientationChangeNotification()
            } else {
                self.removeOrientationChangeNotification()
            }
        }
    }
    
    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onBackgroudViewTapped(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    fileprivate func showForSender(sender: UIView?, or senderFrame: CGRect?, with menuNameArray: [String]!, menuImageArray: [UIImage]?, withSelectedName: String? = nil, done: @escaping (NSInteger) -> Void, cancel: @escaping () -> Void) {
        
        if sender == nil && senderFrame == nil {
            return
        }
        
        if menuNameArray.isEmpty {
            return
        }
        
        self.sender = sender
        self.selectedName = withSelectedName
        self.senderFrame = senderFrame
        self.menuNameArray = menuNameArray
        self.menuImageArray = menuImageArray
        self.done = done
        self.cancel = cancel
        
        UIApplication.shared.keyWindow?.addSubview(self.backgroundView)
        
        self.adjustPostionForPopOverMenu()
    }
    
    fileprivate func adjustPostionForPopOverMenu() {
        self.backgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height)
        
        self.setupPopOverMenu()
        
        self.showIfNeeded()
    }
    
    fileprivate func setupPopOverMenu() {
        popOverMenu.transform = CGAffineTransform(scaleX: 1, y: 1)
        
        self.configurePopMenuFrame()
        
        popOverMenu.showWithAnglePoint(point: menuArrowPoint, frame: popMenuFrame, menuNameArray: menuNameArray, menuImageArray: menuImageArray, with: selectedName, arrowDirection: arrowDirection) { (selectedIndex) in
            self.isOnScreen = false
            self.doneActionWithSelectedIndex(selectedIndex: selectedIndex)
        }
        
        popOverMenu.setAnchorPoint(anchorPoint: self.getAnchorPointForPopMenu())
    }
    
    fileprivate func getAnchorPointForPopMenu() -> CGPoint {
        var anchorPoint = CGPoint(x: menuArrowPoint.x / popMenuFrame.size.width, y: 0)
        if arrowDirection == .down {
            anchorPoint = CGPoint(x: menuArrowPoint.x / popMenuFrame.size.width, y: 1)
        }
        return anchorPoint
    }
    
    fileprivate var senderRect: CGRect = CGRect.zero
    fileprivate var popMenuOriginX: CGFloat = 0
    fileprivate var popMenuFrame: CGRect = CGRect.zero
    fileprivate var menuArrowPoint: CGPoint = CGPoint.zero
    fileprivate var arrowDirection: BasePopOverMenuArrowDirection = .up
    fileprivate var popMenuHeight: CGFloat {
        return configuration.menuRowHeight * CGFloat(self.menuNameArray.count) + defaultMenuArrowHeight
    }
    
    fileprivate func configureSenderRect() {
        if self.sender != nil {
            if sender?.superview != nil {
                senderRect = (sender?.superview?.convert((sender?.frame)!, to: backgroundView))!
            } else {
                senderRect = (sender?.frame)!
            }
        } else if senderFrame != nil {
            senderRect = senderFrame!
        }
        senderRect.origin.y = min(UIScreen.height, senderRect.origin.y)
        
        if senderRect.origin.y + senderRect.size.height / 2 < UIScreen.height / 2 {
            arrowDirection = .up
        } else {
            arrowDirection = .down
        }
    }
    
    fileprivate func configurePopMenuOriginX() {
        var senderXCenter: CGPoint = CGPoint(x: senderRect.origin.x + (senderRect.size.width) / 2, y: 0)
        let menuCenterX: CGFloat = configuration.menuWidth / 2 + defaultMargin
        var menuX: CGFloat = 0
        if (senderXCenter.x + menuCenterX > UIScreen.width) {
            senderXCenter.x = min(senderXCenter.x - (UIScreen.width - configuration.menuWidth - defaultMargin), configuration.menuWidth - defaultMenuArrowWidth - defaultMargin)
            menuX = UIScreen.width - configuration.menuWidth - defaultMargin
        } else if (senderXCenter.x - menuCenterX < 0) {
            senderXCenter.x = max(defaultMenuCornerRadius + defaultMenuArrowWidth, senderXCenter.x - defaultMargin)
            menuX = defaultMargin
        } else {
            senderXCenter.x = configuration.menuWidth / 2
            menuX = senderRect.origin.x + (senderRect.size.width) / 2 - configuration.menuWidth / 2
        }
        popMenuOriginX = menuX
    }
    
    fileprivate func configurePopMenuFrame() {
        self.configureSenderRect()
        self.configureMenuArrowPoint()
        self.configurePopMenuOriginX()
        
        if (arrowDirection == .up) {
            popMenuFrame = CGRect(x: popMenuOriginX, y: (senderRect.origin.y + senderRect.size.height), width: configuration.menuWidth, height: popMenuHeight)
            if (popMenuFrame.origin.y + popMenuFrame.size.height > UIScreen.height) {
                popMenuFrame = CGRect(x: popMenuOriginX, y: (senderRect.origin.y + senderRect.size.height), width: configuration.menuWidth, height: UIScreen.height - popMenuFrame.origin.y - defaultMargin)
            }
        } else {
            popMenuFrame = CGRect(x: popMenuOriginX, y: (senderRect.origin.y - popMenuHeight), width: configuration.menuWidth, height: popMenuHeight)
            if (popMenuFrame.origin.y < 0) {
                popMenuFrame = CGRect(x: popMenuOriginX, y: defaultMargin, width: configuration.menuWidth, height: senderRect.origin.y - defaultMargin)
            }
        }
    }
    
    fileprivate func configureMenuArrowPoint() {
        var point: CGPoint = CGPoint(x: senderRect.origin.x + (senderRect.size.width) / 2, y: 0)
        let menuCenterX: CGFloat = configuration.menuWidth / 2 + defaultMargin
        if senderRect.origin.y + senderRect.size.height / 2 < UIScreen.height / 2 {
            point.y = 0
        } else {
            point.y = popMenuHeight
        }
        if (point.x + menuCenterX > UIScreen.width) {
            point.x = min(point.x - (UIScreen.width - configuration.menuWidth - defaultMargin), configuration.menuWidth - defaultMenuArrowWidth - defaultMargin)
        } else if (point.x - menuCenterX < 0) {
            point.x = max(defaultMenuCornerRadius + defaultMenuArrowWidth, point.x - defaultMargin)
        } else {
            point.x = configuration.menuWidth / 2
        }
        menuArrowPoint = point
    }
    
    @objc fileprivate func onBackgroudViewTapped(gesture: UIGestureRecognizer) {
        self.dismiss()
    }
    
    fileprivate func showIfNeeded() {
        if self.isOnScreen == false {
            self.isOnScreen = true
            popOverMenu.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: defaultAnimationDuration, animations: {
                self.popOverMenu.alpha = 1
                self.popOverMenu.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }
    
    fileprivate func dismiss() {
        self.isOnScreen = false
        self.doneActionWithSelectedIndex(selectedIndex: -1)
    }
    
    fileprivate func doneActionWithSelectedIndex(selectedIndex: NSInteger) {
        UIView.animate(withDuration: defaultAnimationDuration,
                       animations: {
                        self.popOverMenu.alpha = 0
                        self.popOverMenu.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { isFinished in
            if isFinished {
                self.backgroundView.removeFromSuperview()
                if selectedIndex < 0 {
                    if (self.cancel != nil) {
                        self.cancel()
                    }
                } else {
                    if (self.done != nil) {
                        self.done(selectedIndex)
                    }
                }
                
            }
        })
    }
    
}
extension UIControl {
    
    // solution found at: http://stackoverflow.com/a/5666430/6310268
    
    fileprivate func setAnchorPoint(anchorPoint: CGPoint) {
        var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x, y: self.bounds.size.height * self.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)
        
        var position = self.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        self.layer.position = position
        self.layer.anchorPoint = anchorPoint
    }
    
}

extension BasePopOverMenu {
    
    fileprivate func addOrientationChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onChangeStatusBarOrientationNotification(notification:)),
                                               name: UIApplication.didChangeStatusBarOrientationNotification,
                                               object: nil)
        
    }
    
    fileprivate func removeOrientationChangeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func onChangeStatusBarOrientationNotification(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.adjustPostionForPopOverMenu()
        })
    }
    
}

extension BasePopOverMenu: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: backgroundView)
        let touchClass: String = NSStringFromClass((touch.view?.classForCoder)!) as String
        if touchClass == "UITableViewCellContentView" {
            return false
        } else if CGRect(x: 0, y: 0, width: configuration.menuWidth, height: configuration.menuRowHeight).contains(touchPoint) {
            // when showed at the navgation-bar-button-item, there is a chance of not respond around the top arrow, so :
            self.doneActionWithSelectedIndex(selectedIndex: 0)
            return false
        }
        return true
    }
    
}

private class BasePopOverMenuView: UIControl {
    
    fileprivate var menuNameArray: [String]!
    fileprivate var selectedName: String?
    fileprivate var menuImageArray: [UIImage]?
    fileprivate var arrowDirection: BasePopOverMenuArrowDirection = .up
    fileprivate var done: ((NSInteger) -> Void)!
    
    fileprivate lazy var configuration: BasePopConfiguration = {
        return BasePopConfiguration.shared
    }()
    
    lazy var menuTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.backgroundColor = BasePopConfiguration.shared.backgoundTintColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = BasePopConfiguration.shared.menuSeparatorColor
        tableView.layer.cornerRadius = BasePopConfiguration.shared.cornerRadius
        tableView.clipsToBounds = true
        tableView.layer.masksToBounds = true
        layer.backgroundColor = ApplicationSettings.appClearColor.cgColor
        layer.shadowColor = ApplicationSettings.appBlackColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 4.0
        return tableView
    }()
    
    fileprivate func showWithAnglePoint(point: CGPoint, frame: CGRect, menuNameArray: [String]!, menuImageArray: [UIImage]!, with selectedName: String? = nil, arrowDirection: BasePopOverMenuArrowDirection, done: @escaping ((NSInteger) -> Void)) {
        
        self.frame = frame
        self.menuNameArray = menuNameArray
        self.selectedName = selectedName
        self.menuImageArray = menuImageArray
        self.arrowDirection = arrowDirection
        self.done = done
        self.repositionMenuTableView()
        self.drawBackgroundLayerWithArrowPoint(arrowPoint: point)
    }
    
    fileprivate func repositionMenuTableView() {
        var menuRect: CGRect = CGRect(x: 0, y: defaultMenuArrowHeight, width: self.frame.size.width, height: self.frame.size.height - defaultMenuArrowHeight)
        if (arrowDirection == .down) {
            menuRect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - defaultMenuArrowHeight)
        }
        self.menuTableView.frame = menuRect
        self.menuTableView.reloadData()
        if menuTableView.frame.height < configuration.menuRowHeight * CGFloat(menuNameArray.count) {
            self.menuTableView.isScrollEnabled = true
        } else {
            self.menuTableView.isScrollEnabled = false
        }
        self.addSubview(self.menuTableView)
    }
    
    fileprivate lazy var backgroundLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        return layer
    }()
    
    fileprivate func drawBackgroundLayerWithArrowPoint(arrowPoint: CGPoint) {
        if self.backgroundLayer.superlayer != nil {
            self.backgroundLayer.removeFromSuperlayer()
        }
        
        backgroundLayer.path = self.getBackgroundPath(arrowPoint: arrowPoint).cgPath
        backgroundLayer.fillColor = configuration.backgoundTintColor.cgColor
        backgroundLayer.strokeColor = configuration.borderColor.cgColor
        backgroundLayer.lineWidth = configuration.borderWidth
        self.layer.insertSublayer(backgroundLayer, at: 0)
    }
    
    func getBackgroundPath(arrowPoint: CGPoint) -> UIBezierPath {
        let radius: CGFloat = configuration.cornerRadius / 2
        
        let path: UIBezierPath = UIBezierPath()
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        if (arrowDirection == .up) {
            path.move(to: CGPoint(x: arrowPoint.x - defaultMenuArrowWidth, y: defaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: arrowPoint.x, y: 0))
            path.addLine(to: CGPoint(x: arrowPoint.x + defaultMenuArrowWidth, y: defaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: self.bounds.size.width - radius, y: defaultMenuArrowHeight))
            path.addArc(withCenter: CGPoint(x: self.bounds.size.width - radius, y: defaultMenuArrowHeight + radius),
                        radius: radius,
                        startAngle: .pi / 2 * 3,
                        endAngle: 0,
                        clockwise: true)
            path.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height - radius))
            path.addArc(withCenter: CGPoint(x: self.bounds.size.width - radius, y: self.bounds.size.height - radius),
                        radius: radius,
                        startAngle: 0,
                        endAngle: .pi / 2,
                        clockwise: true)
            path.addLine(to: CGPoint(x: radius, y: self.bounds.size.height))
            path.addArc(withCenter: CGPoint(x: radius, y: self.bounds.size.height - radius),
                        radius: radius,
                        startAngle: .pi / 2,
                        endAngle: .pi,
                        clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: defaultMenuArrowHeight + radius))
            path.addArc(withCenter: CGPoint(x: radius, y: defaultMenuArrowHeight + radius),
                        radius: radius,
                        startAngle: .pi,
                        endAngle: .pi / 2 * 3,
                        clockwise: true)
            path.close()
        } else {
            path.move(to: CGPoint(x: arrowPoint.x - defaultMenuArrowWidth, y: self.bounds.size.height - defaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: arrowPoint.x, y: self.bounds.size.height))
            path.addLine(to: CGPoint(x: arrowPoint.x + defaultMenuArrowWidth, y: self.bounds.size.height - defaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: self.bounds.size.width - radius, y: self.bounds.size.height - defaultMenuArrowHeight))
            path.addArc(withCenter: CGPoint(x: self.bounds.size.width - radius, y: self.bounds.size.height - defaultMenuArrowHeight - radius),
                        radius: radius,
                        startAngle: .pi / 2,
                        endAngle: 0,
                        clockwise: false)
            path.addLine(to: CGPoint(x: self.bounds.size.width, y: radius))
            path.addArc(withCenter: CGPoint(x: self.bounds.size.width - radius, y: radius),
                        radius: radius,
                        startAngle: 0,
                        endAngle: .pi / 2 * 3,
                        clockwise: false)
            path.addLine(to: CGPoint(x: radius, y: 0))
            path.addArc(withCenter: CGPoint(x: radius, y: radius),
                        radius: radius,
                        startAngle: .pi / 2 * 3,
                        endAngle: .pi,
                        clockwise: false)
            path.addLine(to: CGPoint(x: 0, y: self.bounds.size.height - defaultMenuArrowHeight - radius))
            path.addArc(withCenter: CGPoint(x: radius, y: self.bounds.size.height - defaultMenuArrowHeight - radius),
                        radius: radius,
                        startAngle: .pi,
                        endAngle: .pi / 2,
                        clockwise: false)
            path.close()
        }
        return path
    }
    
}

extension BasePopOverMenuView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return configuration.menuRowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (self.done != nil) {
            self.done(indexPath.row)
        }
    }
    
}

extension BasePopOverMenuView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BasePopOverMenuCell = BasePopOverMenuCell(style: .default, reuseIdentifier: basePopOverMenuTableViewCellIndentifier)
        var imageName: UIImage?
        if menuImageArray != nil {
            if (menuImageArray?.count)! >= indexPath.row + 1 {
                imageName = (menuImageArray?[indexPath.row])!
            }
        }
        cell.setupCellWith(menuName: menuNameArray[indexPath.row], menuImage: imageName)
        
        if (indexPath.row == menuNameArray.count - 1) {
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.bounds.size.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = configuration.menuSeparatorInset
        }
        cell.selectionStyle = configuration.cellSelectionStyle
        
        
        if let selectedItem = selectedName, menuNameArray[indexPath.row] == selectedItem {
            cell.backgroundColor = ApplicationSettings.appLightGrayColor
            cell.accessoryType = configuration.showCheckMark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
}

class BasePopOverMenuCell: UITableViewCell {
    
    fileprivate lazy var configuration: BasePopConfiguration = {
        return BasePopConfiguration.shared
    }()
    
    fileprivate lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        self.contentView.addSubview(label)
        return label
    }()
    
    fileprivate func setupCellWith(menuName: String, menuImage: UIImage?) {
        self.backgroundColor = BasePopConfiguration.shared.backgoundTintColor
        if menuImage != nil {
            if var iconImage: UIImage = menuImage {
                if configuration.ignoreImageOriginalColor {
                    iconImage = iconImage.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                }
                iconImageView.tintColor = configuration.textColor
                iconImageView.frame = CGRect(x: defaultCellMargin, y: (configuration.menuRowHeight - defaultMenuIconSize) / 2, width: defaultMenuIconSize, height: defaultMenuIconSize)
                iconImageView.image = iconImage
                nameLabel.frame = CGRect(x: defaultCellMargin * 2 + defaultMenuIconSize, y: (configuration.menuRowHeight - defaultMenuIconSize) / 2, width: (configuration.menuWidth - defaultMenuIconSize - defaultCellMargin * 3), height: defaultMenuIconSize)
            } else {
                nameLabel.frame = CGRect(x: defaultCellMargin, y: 0, width: configuration.menuWidth - defaultCellMargin * 2, height: configuration.menuRowHeight)
            }
        } else {
            nameLabel.frame = CGRect(x: defaultCellMargin, y: 0, width: configuration.menuWidth - defaultCellMargin * 2, height: configuration.menuRowHeight)
        }
        nameLabel.font = configuration.textFont
        nameLabel.textColor = configuration.textColor
        nameLabel.textAlignment = configuration.textAlignment
        nameLabel.text = configuration.showCheckMark == .none ? menuName : "\(menuName) \(BasePopConfiguration.shared.joinText)"
    }
}
