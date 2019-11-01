//
//  DropdownController.swift
//  ProManager
//
//  Created by Viraj Patel on 03/05/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit


protocol DropdownControllerDelegate: class {
    func dropdownController(_ controller: DropdownController, didSelect album: ImageAlbum)
}

class DropdownController: UIViewController {

    lazy var tableView: UITableView = self.makeTableView()
    lazy var blurView: UIVisualEffectView = self.makeBlurView()

    var animating: Bool = false
    var expanding: Bool = false
    var selectedIndex: Int = 0

    var albums: [ImageAlbum] = [] {
        didSet {
            selectedIndex = 0
        }
    }

    var expandedTopConstraint: NSLayoutConstraint?
    var collapsedTopConstraint: NSLayoutConstraint?

    weak var delegate: DropdownControllerDelegate?

    // MARK: - Initialization

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    // MARK: - Setup

    func setup() {
        view.backgroundColor = ApplicationSettings.appClearColor
        tableView.backgroundColor = ApplicationSettings.appClearColor
        tableView.backgroundView = blurView

        view.addSubview(tableView)
        tableView.register(AlbumCell.self, forCellReuseIdentifier: String(describing: AlbumCell.self))

        tableView.g_pinEdges()
    }

    // MARK: - Logic

    func toggle() {
        guard !animating else { return }

        animating = true
        expanding = !expanding

        if expanding {
            collapsedTopConstraint?.isActive = false
            expandedTopConstraint?.isActive = true
        } else {
            expandedTopConstraint?.isActive = false
            collapsedTopConstraint?.isActive = true
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.superview?.layoutIfNeeded()
        }, completion: { finished in
            self.animating = false
        })
    }

    // MARK: - Controls

    func makeTableView() -> UITableView {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.rowHeight = 84

        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }

    func makeBlurView() -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))

        return view
    }
}

extension DropdownController: UITableViewDataSource, UITableViewDelegate {

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AlbumCell.self), for: indexPath)
        as! AlbumCell

        let album = albums[(indexPath as NSIndexPath).row]
        cell.configure(album)
        cell.backgroundColor = ApplicationSettings.appClearColor

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let album = albums[(indexPath as NSIndexPath).row]
        delegate?.dropdownController(self, didSelect: album)

        selectedIndex = (indexPath as NSIndexPath).row
        tableView.reloadData()
    }
}

class AlbumCell: UITableViewCell {

    lazy var albumImageView: UIImageView = self.makeAlbumImageView()
    lazy var albumTitleLabel: UILabel = self.makeAlbumTitleLabel()
    lazy var itemCountLabel: UILabel = self.makeItemCountLabel()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Config

    func configure(_ album: ImageAlbum) {
        albumTitleLabel.text = album.collection.localizedTitle
        itemCountLabel.text = "\(album.items.count)"

        if let item = album.items.first {
            albumImageView.layoutIfNeeded()
            albumImageView.g_loadImage(item.asset)
        }
    }

    // MARK: - Setup

    func setup() {
        [albumImageView, albumTitleLabel, itemCountLabel].forEach {
            addSubview($0)
        }

        albumImageView.g_pin(on: .left, constant: 12)
        albumImageView.g_pin(on: .top, constant: 5)
        albumImageView.g_pin(on: .bottom, constant: -5)
        albumImageView.g_pin(on: .width, view: albumImageView, on: .height)

        albumTitleLabel.g_pin(on: .left, view: albumImageView, on: .right, constant: 10)
        albumTitleLabel.g_pin(on: .top, constant: 24)
        albumTitleLabel.g_pin(on: .right, constant: -10)

        itemCountLabel.g_pin(on: .left, view: albumImageView, on: .right, constant: 10)
        itemCountLabel.g_pin(on: .top, view: albumTitleLabel, on: .bottom, constant: 6)
    }

    // MARK: - Controls

    private func makeAlbumImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage()

        return imageView
    }

    private func makeAlbumTitleLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 15)

        return label
    }

    private func makeItemCountLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 15)

        return label
    }
}

extension UIImage {
    func upOrientationImage() -> UIImage? {
        switch imageOrientation {
        case .up:
            return self
        default:
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            draw(in: CGRect(origin: .zero, size: size))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        }
    }
}
