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
    case madeWithGif
    case outtroVideo
}

class WatermarkSettingCell: UITableViewCell {
    
    // MARK: - Outlets declaration
    @IBOutlet weak var hideWatermarkButton: UIButton!
    @IBOutlet weak var lblWatermarkName: UILabel!
    @IBOutlet weak var lblUpgrade: UILabel!
    @IBOutlet weak var imgWatermarkShow: UIImageView!
    @IBOutlet weak var imgWatermarkHide: UIImageView!
    @IBOutlet weak var hideWatermarkView: UIView!
    @IBOutlet weak var lblWatermarkTitle: UILabel!
    
    // MARK: - Variables declaration
    var watermarkType: WatermarkType = .fastestEverWatermark {
        didSet {
            if watermarkType == .fastestEverWatermark {
                lblWatermarkName.text = R.string.localizable.fastestevercontest()
                self.hideWatermarkView.backgroundColor = .white
                self.lblWatermarkTitle.textColor = R.color.watermarkTitleColor()
                self.lblUpgrade.isHidden = true
                self.setSelection(fastestEverWatermarkSetting: Defaults.shared.fastestEverWatermarkSetting)
            } else if watermarkType == .applicationIdentifier {
                lblWatermarkName.text = R.string.localizable.madeWith(Constant.Application.displayName)
                self.setSelection(appIdentifierWatermarkSetting: Defaults.shared.appIdentifierWatermarkSetting)
            } else if watermarkType == .madeWithGif {
                lblWatermarkName.text = R.string.localizable.madeWithgif(Constant.Application.displayName)
                self.setSelection(madeWithGifSetting: Defaults.shared.madeWithGifSetting)
            } else if watermarkType == .outtroVideo {
                lblWatermarkName.text = R.string.localizable.outtroVdieo()
                self.setSelection(outtroVideoSetting: Defaults.shared.outtroVideoSetting)
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
            self.lblWatermarkTitle.textColor = R.color.watermarkTitleForFreeUserColor()
            self.hideWatermarkView.backgroundColor = R.color.hideWatermarkBackgroundColor()
            self.lblUpgrade.isHidden = false
        } else {
            self.imgWatermarkHide.image = R.image.radioDeselected()
            self.lblWatermarkTitle.textColor = R.color.watermarkTitleColor()
            self.hideWatermarkView.backgroundColor = .white
            self.lblUpgrade.isHidden = true
        }
    }
    
    func setSelection(fastestEverWatermarkSetting: FastestEverWatermarkSetting) {
        self.imgWatermarkShow.image = R.image.radioDeselected()
        self.imgWatermarkHide.image = R.image.radioDeselected()
        switch fastestEverWatermarkSetting {
        case .show:
            self.imgWatermarkShow.image = R.image.radioSelected()
        case .hide:
            self.imgWatermarkHide.image = R.image.radioSelected()
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
    
    func setSelection(madeWithGifSetting: MadeWithGifSetting) {
        self.imgWatermarkShow.image = R.image.radioDeselected()
        if Defaults.shared.appMode != .free {
            self.imgWatermarkHide.image = R.image.radioDeselected()
        }
        switch madeWithGifSetting {
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
    
    func setSelection(outtroVideoSetting: OuttroVideoSetting) {
        self.imgWatermarkShow.image = R.image.radioDeselected()
        if Defaults.shared.appMode != .free {
            self.imgWatermarkHide.image = R.image.radioDeselected()
        }
        switch outtroVideoSetting {
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
        } else if watermarkType == .madeWithGif {
            Defaults.shared.madeWithGifSetting = .show
            self.setSelection(madeWithGifSetting: Defaults.shared.madeWithGifSetting)
        } else if watermarkType == .outtroVideo {
            Defaults.shared.outtroVideoSetting = .show
            self.setSelection(outtroVideoSetting: Defaults.shared.outtroVideoSetting)
        }
    }
    
    @IBAction func btnWatermarkHideTapped(_ sender: UIButton) {
        if watermarkType == .fastestEverWatermark {
            Defaults.shared.fastestEverWatermarkSetting = .hide
            self.setSelection(fastestEverWatermarkSetting: Defaults.shared.fastestEverWatermarkSetting)
        } else if watermarkType == .applicationIdentifier {
            Defaults.shared.appIdentifierWatermarkSetting = .hide
            self.setSelection(appIdentifierWatermarkSetting: Defaults.shared.appIdentifierWatermarkSetting)
        } else if watermarkType == .madeWithGif {
            Defaults.shared.madeWithGifSetting = .hide
            self.setSelection(madeWithGifSetting: Defaults.shared.madeWithGifSetting)
        } else if watermarkType == .outtroVideo {
            Defaults.shared.outtroVideoSetting = .hide
            self.setSelection(outtroVideoSetting: Defaults.shared.outtroVideoSetting)
        }
    }
    
}
