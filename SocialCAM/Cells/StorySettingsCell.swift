//
//  StorySettingsCell.swift
//  ProManager
//
//  Created by Jasmin Patel on 21/06/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class StorySettingsCell: UITableViewCell {

    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var onOffButton: UIButton!
    @IBOutlet weak var settingsName: UILabel!
    @IBOutlet weak var socialImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


class AppOpenSettingsCell: UITableViewCell {

    @IBOutlet var dashBoardView: ScreenSelectionView!
    @IBOutlet var chatView: ScreenSelectionView!
    @IBOutlet var cameraView: ScreenSelectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let x = Defaults.shared.openingScreen.rawValue
        self.setOpenScreen(x: x)
        dashBoardView.selectionHandler = { [unowned self] in
            self.setOpenScreen(x: 1)
            Defaults.shared.openingScreen = .dashboard
        }
        chatView.selectionHandler = { [unowned self] in
            self.setOpenScreen(x: 2)
            Defaults.shared.openingScreen = .chat
        }
        cameraView.selectionHandler = { [unowned self] in
            self.setOpenScreen(x: 0)
            Defaults.shared.openingScreen = .camera
        }
    }
    
    func setOpenScreen(x: Int) {
        switch x {
        case 0:
            self.cameraView.isSelected = true
            self.dashBoardView.isSelected = false
            self.chatView.isSelected = false
        case 1:
            self.cameraView.isSelected = false
            self.dashBoardView.isSelected = true
            self.chatView.isSelected = false
        case 2:
            self.cameraView.isSelected = false
            self.dashBoardView.isSelected = false
            self.chatView.isSelected = true
        default:
            self.cameraView.isSelected = true
            self.dashBoardView.isSelected = false
            self.chatView.isSelected = false
        }
    }
    
}

enum WatermarkType: Int {
    case fastestEverWatermark = 0
    case applicationIdentifier
}

class WatermarkSettingCell: UITableViewCell {
    
    // MARK: - Outlets declaration
    @IBOutlet weak var hideWatermarkButton: UIButton!
    @IBOutlet weak var lblWatermarkName: UILabel!
    @IBOutlet weak var lblUpgrade: UILabel!
    @IBOutlet weak var lblWatermarkSetting: UILabel!
    @IBOutlet weak var imgWatermarkShow: UIImageView!
    @IBOutlet weak var imgWatermarkHide: UIImageView!
    @IBOutlet weak var hideWatermarkView: UIView!
    @IBOutlet weak var watermarkSettingHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var watermarkSettingBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Variables declaration
    var watermarkType: WatermarkType = .fastestEverWatermark {
        didSet {
            if watermarkType == .fastestEverWatermark {
                lblWatermarkName.text = R.string.localizable.fastesteverImage()
                self.setSelection(fastestEverWatermarkSetting: Defaults.shared.fastestEverWatermarkSetting)
                lblWatermarkSetting.isHidden = false
                watermarkSettingHeightConstraint.constant = 19
                watermarkSettingBottomConstraint.constant = 23
            } else if watermarkType == .applicationIdentifier {
                lblWatermarkName.text = R.string.localizable.applicationIdentifier()
                lblWatermarkSetting.isHidden = true
                watermarkSettingHeightConstraint.constant = 0
                watermarkSettingBottomConstraint.constant = 0
                self.setSelection(appIdentifierWatermarkSetting: Defaults.shared.appIdentifierWatermarkSetting)
            }
        }
    }
    var isFreeMode = false
    
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
