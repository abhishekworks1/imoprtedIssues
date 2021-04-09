//
//  WatermarkSettingCell.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 07/04/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

enum WatermarkType: Int {
    case fastestEverWatermark = 0
    case applicationIdentifier
}

class WatermarkSettingCell: UITableViewCell {
    
    // MARK: - Outlets declaration
    @IBOutlet weak var hideWatermarkButton: UIButton!
    @IBOutlet weak var lblWatermarkName: UILabel!
    @IBOutlet weak var lblUpgrade: UILabel!
    @IBOutlet weak var imgWatermarkShow: UIImageView!
    @IBOutlet weak var imgWatermarkHide: UIImageView!
    @IBOutlet weak var hideWatermarkView: UIView!
    
    // MARK: - Variables declaration
    var watermarkType: WatermarkType = .fastestEverWatermark {
        didSet {
            if watermarkType == .fastestEverWatermark {
                lblWatermarkName.text = R.string.localizable.fastesteverImage()
                self.setSelection(fastestEverWatermarkSetting: Defaults.shared.fastestEverWatermarkSetting)
            } else if watermarkType == .applicationIdentifier {
                lblWatermarkName.text = R.string.localizable.applicationIdentifier()
                self.setSelection(appIdentifierWatermarkSetting: Defaults.shared.appIdentifierWatermarkSetting)
            }
        }
    }
    
    // MARK: - Life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setup()
    }
    
    // MARK: - Setup methods
    func setup() {
        if Defaults.shared.appMode == .free {
            self.imgWatermarkHide.image = R.image.oval()
            self.hideWatermarkView.backgroundColor = R.color.hideWatermarkBackgroundColor()
            self.lblUpgrade.isHidden = false
        } else {
            self.imgWatermarkHide.image = R.image.radioDeselected()
            self.hideWatermarkView.backgroundColor = .white
            self.lblUpgrade.isHidden = true
        }
    }
    
    func setSelection(fastestEverWatermarkSetting: FastestEverWatermarkSetting) {
        self.imgWatermarkShow.image = R.image.radioDeselected()
        if Defaults.shared.appMode != .free {
            self.imgWatermarkHide.image = R.image.radioDeselected()
        }
        switch fastestEverWatermarkSetting {
        case .show:
            self.imgWatermarkShow.image = R.image.radioSelected()
        case .hide:
            if Defaults.shared.appMode != .free {
                self.imgWatermarkHide.image = R.image.radioSelected()
            } else {
                self.imgWatermarkShow.image = R.image.radioSelected()
            }
        }
    }
    
    func setSelection(appIdentifierWatermarkSetting: AppIdentifierWatermarkSetting) {
        self.imgWatermarkShow.image = R.image.radioDeselected()
        if Defaults.shared.appMode != .free {
            self.imgWatermarkHide.image = R.image.radioDeselected()
        }
        switch appIdentifierWatermarkSetting {
        case .show:
            self.imgWatermarkShow.image = R.image.radioSelected()
        case .hide:
            if Defaults.shared.appMode != .free {
                self.imgWatermarkHide.image = R.image.radioSelected()
            } else {
                self.imgWatermarkShow.image = R.image.radioSelected()
            }
        }
    }
    
    // MARK: - Action methods
    @IBAction func btnWatermarkShowTapped(_ sender: UIButton) {
        if watermarkType == .fastestEverWatermark {
            Defaults.shared.fastestEverWatermarkSetting = .show
            self.setSelection(fastestEverWatermarkSetting: Defaults.shared.fastestEverWatermarkSetting)
        } else if watermarkType == .applicationIdentifier {
            Defaults.shared.appIdentifierWatermarkSetting = .show
            self.setSelection(appIdentifierWatermarkSetting: Defaults.shared.appIdentifierWatermarkSetting)
        }
    }
    
    @IBAction func btnWatermarkHideTapped(_ sender: UIButton) {
        if watermarkType == .fastestEverWatermark {
            Defaults.shared.fastestEverWatermarkSetting = .hide
            self.setSelection(fastestEverWatermarkSetting: Defaults.shared.fastestEverWatermarkSetting)
        } else if watermarkType == .applicationIdentifier {
            Defaults.shared.appIdentifierWatermarkSetting = .hide
            self.setSelection(appIdentifierWatermarkSetting: Defaults.shared.appIdentifierWatermarkSetting)
        }
    }
    
}
