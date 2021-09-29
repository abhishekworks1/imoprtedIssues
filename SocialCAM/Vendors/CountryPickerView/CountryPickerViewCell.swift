//
//  UserCollectionViewCell.swift
//  YALLayoutTransitioning
//
//  Created by Roman on 23.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

protocol CellInterface {
    static var id: String { get }
    static var cellNib: UINib { get }
}

public struct Country: Equatable {
    public let name: String
    public let code: String
    public let phoneCode: String
    public let isState: Bool
    public func localizedName(_ locale: Locale = Locale.current) -> String? {
        return locale.localizedString(forRegionCode: code)
    }
    public var flag: UIImage {
        if isState {
            return UIImage(named: "\(code.lowercased())") ?? UIImage()
        } else {
            guard let image = UIImage(named: "CountryPickerView.bundle/Images/\(code.uppercased())",
                                      in: Bundle.main, compatibleWith: nil) else {
                return UIImage()
            }
            return image
        }
    }
}

public func ==(lhs: Country, rhs: Country) -> Bool {
    return lhs.code == rhs.code
}
public func !=(lhs: Country, rhs: Country) -> Bool {
    return lhs.code != rhs.code
}

extension CellInterface {
    static var id: String {
        return String(describing: Self.self)
    }
    
    static var cellNib: UINib {
        return UINib(nibName: id, bundle: nil)
    }
    
}

private let avatarListLayoutSize: CGFloat = 80.0

class CountryPickerViewCell: UICollectionViewCell, CellInterface {
    
    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    @IBOutlet fileprivate weak var backgroundGradientView: UIView!
    @IBOutlet fileprivate weak var nameListLabel: UILabel!
    @IBOutlet fileprivate weak var nameGridLabel: UILabel!
    @IBOutlet weak var statisticLabel: UILabel!
    @IBOutlet fileprivate weak var btnSelected: UIButton!
    
    // avatarImageView constraints
    @IBOutlet fileprivate weak var avatarImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var avatarImageViewHeightConstraint: NSLayoutConstraint!
    
    // nameListLabel constraints
    @IBOutlet var nameListLabelLeadingConstraint: NSLayoutConstraint! {
        didSet {
            initialLabelsLeadingConstraintValue = nameListLabelLeadingConstraint.constant
        }
    }
    
    // statisticLabel constraints
    @IBOutlet weak var statisticLabelLeadingConstraint: NSLayoutConstraint!
    
    fileprivate var avatarGridLayoutSize: CGFloat = 0.0
    fileprivate var initialLabelsLeadingConstraintValue: CGFloat = 0.0
    
    @objc open var isSelectedItem: Bool = false
    
    @objc open var selectedItem: Bool = false {
        didSet {
            if !isSelectedItem {
                self.btnSelected?.isHidden = !selectedItem
            }
        }
    }
    
    func bind(_ user: Country) {
        avatarImageView.image = user.flag
        nameListLabel.text = user.name
        nameGridLabel.text = nameListLabel.text
    }
    
    func setupSelectedGridLayoutConstraints(_ transitionProgress: CGFloat, cellWidth: CGFloat) {
        avatarImageViewHeightConstraint.constant = (ceil(
            (cellWidth - avatarListLayoutSize) * transitionProgress + avatarListLayoutSize
        ) - 10)
        avatarImageViewWidthConstraint.constant = ceil(avatarImageViewHeightConstraint.constant)
        avatarImageViewHeightConstraint.constant -= 80
        nameListLabelLeadingConstraint.constant = (-avatarImageViewWidthConstraint.constant * transitionProgress + initialLabelsLeadingConstraintValue) + 40
        backgroundGradientView.alpha = transitionProgress <= 0.5 ? 1 - transitionProgress : transitionProgress
        nameListLabel.alpha = 1 - transitionProgress
        nameGridLabel.alpha = transitionProgress
    }
    
    func setupGridLayoutConstraints(_ transitionProgress: CGFloat, cellWidth: CGFloat) {
        avatarImageViewHeightConstraint.constant = (ceil(
            (cellWidth - avatarListLayoutSize) * transitionProgress + avatarListLayoutSize
        ) - 10)
        avatarImageViewWidthConstraint.constant = ceil(avatarImageViewHeightConstraint.constant)
        nameListLabelLeadingConstraint.constant = -avatarImageViewWidthConstraint.constant * transitionProgress + initialLabelsLeadingConstraintValue
        backgroundGradientView.alpha = transitionProgress <= 0.5 ? 1 - transitionProgress : transitionProgress
        nameListLabel.alpha = 1 - transitionProgress
        nameGridLabel.alpha = transitionProgress
        avatarImageViewHeightConstraint.constant -= 40
    }
    
    func setupListLayoutConstraints(_ transitionProgress: CGFloat, cellWidth: CGFloat) {
        avatarImageViewHeightConstraint.constant = ceil(
            avatarGridLayoutSize - (avatarGridLayoutSize - avatarListLayoutSize) * transitionProgress
        )
        avatarImageViewWidthConstraint.constant = avatarImageViewHeightConstraint.constant 
        nameListLabelLeadingConstraint.constant = avatarImageViewWidthConstraint.constant * transitionProgress + (initialLabelsLeadingConstraintValue - avatarImageViewHeightConstraint.constant)
        backgroundGradientView.alpha = transitionProgress <= 0.5 ? 1 - transitionProgress : transitionProgress
        nameListLabel.alpha = transitionProgress
        nameGridLabel.alpha = 1 - transitionProgress
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? DisplaySwitchLayoutAttributes {
            if attributes.transitionProgress > 0 {
                if attributes.layoutState == .grid {
                    setupGridLayoutConstraints(attributes.transitionProgress,
                                               cellWidth: attributes.nextLayoutCellFrame.width)
                    avatarGridLayoutSize = attributes.nextLayoutCellFrame.width
                } else {
                    setupListLayoutConstraints(attributes.transitionProgress,
                                               cellWidth: attributes.nextLayoutCellFrame.width)
                }
            }
        }
    }
    
}
