//
//  SearchDropDown.swift
//  SocialCAM
//
//  Created by Viraj Patel on 15/04/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

let kCellIdentifier = "DropDownCellIdentifier"

typealias DropDownMenuCompletionBlock = (DropDownMenu, DropDownMenuItem?, Int) -> Void

enum DropDownMenuDirection : Int {
    case down
    case up
}

class DropDownMenu: UIView, UITableViewDataSource, UITableViewDelegate {

    ///  Background color of the drop down menu.
    var menuColor: UIColor?
    ///  Text color of the menu items.
    var itemColor: UIColor?
    ///  Font of the menu items.
    var itemFont: UIFont?
    ///  Height of individual menu items.
    var itemHeight: CGFloat = 0.0
    ///  Hide the drop down menu when an item is selected.
    var hidesOnSelection = false
    ///  Show the drop down menu below or above the specified view.
    var dropDownMenuDirection: DropDownMenuDirection = .up
    ///  An array of DropDownMenuItems to show in the drop down menu.
    var menuItems: [DropDownMenuItem]? = []

    var targetView: UIView?
    var menuTableView: UITableView?
    var callback: DropDownMenuCompletionBlock!

    // MARK: - Init methods
    init(view: UIView?, menuItems: [DropDownMenuItem]?) {
        assert(view != nil, "View must not be nil.")
        super.init(frame: CGRect.zero)
        targetView = view
        self.menuItems = menuItems
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Setup
    func setup() {
        setupDefaults()
        setupUI()
        addTable()
    }

    func setupDefaults() {
        menuColor = UIColor.white
        itemColor = UIColor.black
        itemFont = UIFont.systemFont(ofSize: 14.0)
        itemHeight = 40.0
    }        

    func setupUI() {
        clipsToBounds = true
        layer.cornerRadius = 3.0
        self.setShadow(offset: self.frame.size, opacity: 0.5)
        backgroundColor = menuColor
    }

    func addTable() {
        menuTableView = UITableView(frame: CGRect.zero)
        menuTableView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        menuTableView!.separatorStyle = .singleLine
        menuTableView!.backgroundColor = menuColor
        menuTableView!.keyboardDismissMode = .onDrag
        addSubview(menuTableView!)
        menuTableView!.dataSource = self
        menuTableView!.delegate = self
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: kCellIdentifier)
        }
        let item = menuItems?[indexPath.row]
        let hasSubtitle = item?.subtitle?.count != 0 ? true : false
        let hasImage = item?.image != nil ? true : false

        cell?.textLabel?.textColor = itemColor
        cell?.textLabel?.font = itemFont
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.text = item?.title

        if hasSubtitle {
            cell?.detailTextLabel?.text = item?.subtitle
            cell?.detailTextLabel?.textColor = itemColor
        }
        if hasImage {
            cell?.imageView?.image = item?.image
        }

        return cell ?? UITableViewCell()
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hidesOnSelection == true {
            hide()
        }

        if (callback != nil) {
            callback?(self, menuItems?[indexPath.row], indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemHeight
    }

    // MARK: - Property setters
    func setMenuColor(_ menuColor: UIColor?) {
        self.menuColor = menuColor
        backgroundColor = self.menuColor
    }

    func setItemColor(_ itemColor: UIColor?) {
        self.itemColor = itemColor
        reloadTable()
    }

    func setItemFont(_ itemFont: UIFont?) {
        self.itemFont = itemFont
        reloadTable()
    }

    func setItemHeight(_ itemHeight: CGFloat) {
        self.itemHeight = itemHeight
        reloadTable()
    }

    func setMenuItems(_ menuItems: [DropDownMenuItem]?) {
        self.menuItems = menuItems
        reloadTable()
    }

    func reloadTable() {
        menuTableView?.reloadData()
    }

    // MARK: - Show-hide
    func show(withCompletion callback: @escaping DropDownMenuCompletionBlock) {
        self.callback = callback
        self.layoutIfNeeded()
        targetView?.layoutIfNeeded()
        
        let x = targetView!.frame.origin.x
        let width = targetView!.superview!.superview!.frame.size.width
        var height: CGFloat = (itemHeight * CGFloat(menuItems!.count))

        if menuItems!.count > 5 {
            height = itemHeight * 5
        }

        var y: CGFloat = 0.0
        if self.dropDownMenuDirection == .down {
            y = (targetView!.frame.origin.y) + (targetView!.frame.size.height)
        } else {
            y = targetView!.superview!.frame.origin.y - height
        }
 
        frame = CGRect(x: x, y: y + 20, width: width, height: height)
        targetView!.superview!.superview!.addSubview(self)
        targetView!.superview!.superview!.bringSubviewToFront(self)
    }

    func hide() {
        removeFromSuperview()
        if let indexPathForSelectedRow = menuTableView?.indexPathForSelectedRow {
            menuTableView?.deselectRow(at: indexPathForSelectedRow, animated: false)
        }
    }
}

// MARK: - DropDownMenuItem

class DropDownMenuItem: NSObject {
    ///  Main text of the menu item.
    var title: String?
    ///  Accompanying text below the main text. Optional.
    var subtitle: String?
    ///  Accompanying  image on the left of the main text. Optional
    var image: UIImage?

    override init() {
        super.init()
    }

    convenience init?(title: String?) {
        self.init()
        self.title = title
    }

    convenience init?(title: String?, subtitle: String?, image: UIImage?) {
        self.init()
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
}
