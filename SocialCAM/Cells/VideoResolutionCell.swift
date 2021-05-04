//
//  VideoResolutionCell.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 02/04/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

class VideoResolutionCell: UITableViewCell {
    
    // MARK: - Outlets declaration
    @IBOutlet weak var highResolutionButton: UIButton!
    @IBOutlet weak var lblUpgrade: UILabel!
    @IBOutlet weak var imgLowResolution: UIImageView!
    @IBOutlet weak var imgHighResolution: UIImageView!
    @IBOutlet weak var highResolutionView: UIView!
    
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
        if isLiteApp {
            self.imgHighResolution.image = R.image.oval()
            self.highResolutionView.backgroundColor = R.color.hideWatermarkBackgroundColor()
            self.lblUpgrade.isHidden = false
        } else {
            self.imgHighResolution.image = R.image.radioDeselected()
            self.highResolutionView.backgroundColor = .white
            self.lblUpgrade.isHidden = true
        }
        self.setSelection(videoResolution: Defaults.shared.videoResolution)
    }
    
    func setSelection(videoResolution: VideoResolution) {
        self.imgLowResolution.image = R.image.radioDeselected()
        if isLiteApp {
            self.imgHighResolution.image = R.image.oval()
        }
        switch videoResolution {
        case .low:
            self.imgLowResolution.image = R.image.radioSelected()
        case .high:
            if isLiteApp {
                self.imgHighResolution.image = R.image.oval()
            } else {
                self.imgLowResolution.image = R.image.radioSelected()
            }
        }
    }
    
    // MARK: - Action methods
    @IBAction func btnLowResolutionTapped(_ sender: UIButton) {
        Defaults.shared.videoResolution = .low
        Defaults.shared.isCameraSettingChanged = true
        self.setSelection(videoResolution: Defaults.shared.videoResolution)
    }
    
    @IBAction func btnHighResolutionTapped(_ sender: UIButton) {
        if isLiteApp {
            return
        }
        Defaults.shared.videoResolution = .high
        Defaults.shared.isCameraSettingChanged = true
        self.setSelection(videoResolution: Defaults.shared.videoResolution)
    }
    
}
