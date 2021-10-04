//
//  GuildlineIconPositionTableViewCell.swift
//  SocialCAM
//
//  Created by Viraj Patel on 10/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

class ColorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

enum Guideline: Int {
    case type = 0
    case thickness
}

class GuildlineIconPositionTableViewCell: UITableViewCell {

    @IBOutlet weak var imgSold: UIImageView!
    @IBOutlet weak var imgDotted: UIImageView!
    @IBOutlet weak var imgDashed: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var iconSettingImage: UIImageView!
    
    @IBOutlet weak var lblSold: UILabel!
    @IBOutlet weak var lblDotted: UILabel!
    @IBOutlet weak var lblDashed: UILabel!
    
    @IBOutlet weak var imgLineSold: UIImageView!
    @IBOutlet weak var imgLineDotted: UIImageView!
    @IBOutlet weak var imgLineDashed: UIImageView!
    
    var guildline: Guideline = .type {
        didSet {
            if guildline == .type {
                lblTitle.text = R.string.localizable.guidelineTypes()
                lblSold.text = R.string.localizable.solidLine()
                lblDotted.text = R.string.localizable.dottedLine()
                lblDashed.text = R.string.localizable.dashedLine()
                imgLineSold.image = R.image.solidLine()
                imgLineDotted.image = R.image.dottedLine()
                imgLineDashed.image = R.image.dashedLine()
                self.setSelection(guidelineTypes: Defaults.shared.cameraGuidelineTypes)
            } else if guildline == .thickness {
                lblTitle.text = R.string.localizable.guidelineThickness()
                lblSold.text = R.string.localizable.small()
                lblDotted.text = R.string.localizable.medium()
                lblDashed.text = R.string.localizable.thick()
                imgLineSold.image = R.image.smallLine()
                imgLineDotted.image = R.image.mediumLine()
                imgLineDashed.image = R.image.thickLine()
                self.setSelection(guidelineThickness: Defaults.shared.cameraGuidelineThickness)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setSelection(guidelineTypes: GuidelineTypes) {
        self.imgSold.image = R.image.radioDeselected()
        self.imgDotted.image = R.image.radioDeselected()
        self.imgDashed.image = R.image.radioDeselected()
        switch guidelineTypes {
        case .solidLine:
            self.imgSold.image = R.image.radioSelected()
        case .dottedLine:
            self.imgDotted.image = R.image.radioSelected()
        case .dashedLine:
            self.imgDashed.image = R.image.radioSelected()
        }
    }
    
    func setSelection(guidelineThickness: GuidelineThickness) {
        self.imgSold.image = R.image.radioDeselected()
        self.imgDotted.image = R.image.radioDeselected()
        self.imgDashed.image = R.image.radioDeselected()
        switch guidelineThickness {
        case .small:
            self.imgSold.image = R.image.radioSelected()
        case .medium:
            self.imgDotted.image = R.image.radioSelected()
        case .thick:
            self.imgDashed.image = R.image.radioSelected()
        }
    }

    @IBAction func btnSoldTapped(_ sender: Any) {
        if guildline == .type {
            Defaults.shared.cameraGuidelineTypes = .solidLine
            self.setSelection(guidelineTypes: Defaults.shared.cameraGuidelineTypes)
        } else if guildline == .thickness {
            Defaults.shared.cameraGuidelineThickness = .small
            self.setSelection(guidelineThickness: Defaults.shared.cameraGuidelineThickness)
        }
    }
    
    @IBAction func btnDottedTapped(_ sender: Any) {
        if guildline == .type {
            Defaults.shared.cameraGuidelineTypes = .dottedLine
            self.setSelection(guidelineTypes: Defaults.shared.cameraGuidelineTypes)
        } else if guildline == .thickness {
            Defaults.shared.cameraGuidelineThickness = .medium
            self.setSelection(guidelineThickness: Defaults.shared.cameraGuidelineThickness)
        }
    }
    
    @IBAction func btnDashedTapped(_ sender: Any) {
        if guildline == .type {
            Defaults.shared.cameraGuidelineTypes = .dashedLine
            self.setSelection(guidelineTypes: Defaults.shared.cameraGuidelineTypes)
        } else if guildline == .thickness {
            Defaults.shared.cameraGuidelineThickness = .thick
            self.setSelection(guidelineThickness: Defaults.shared.cameraGuidelineThickness)
        }
    }
}

