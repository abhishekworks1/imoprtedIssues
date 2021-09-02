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
    @IBOutlet weak var lblPremiumVersionOnly: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
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
