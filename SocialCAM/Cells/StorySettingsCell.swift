//
//  StorySettingsCell.swift
//  ProManager
//
//  Created by Jasmin Patel on 21/06/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class StorySettingsCell: UITableViewCell {

    @IBOutlet weak var badgesCountLabel: ColorBGLabel!
    @IBOutlet weak var roundedView: RoundedView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var onOffButton: UIButton!
    @IBOutlet weak var settingsName: UILabel!
    @IBOutlet weak var socialImageView: UIImageView?
    @IBOutlet weak var lblPremiumVersionOnly: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imgSettingsIcon: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var imgSubscribeBadge: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        shadowView.dropShadow(color: .lightGray, opacity: 0.5, offSet: CGSize(width: 1, height: 1), radius: 3, scale: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class StorySettingsListCell: UITableViewCell {

    static let identifier = "StorySettingsListCell"
    @IBOutlet weak var badgesCountLabel: ColorBGLabel!
    @IBOutlet weak var roundedView: RoundedView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var onOffButton: UIButton!
    @IBOutlet weak var settingsName: UILabel!
    @IBOutlet weak var socialImageView: UIImageView?
    @IBOutlet weak var lblPremiumVersionOnly: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imgSettingsIcon: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var imgSubscribeBadge: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      //  shadowView.dropShadow(color: .gray, opacity: 1.5, offSet: CGSize(width: 1, height: 1), radius: 3, scale: false)
        
        shadowView.addShadow(cornerRadius: 5.0, borderWidth: 0.0, shadowOpacity: 0.5, shadowRadius: 3.0)
        
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

extension UIView{
    func addShadow(cornerRadius:CGFloat = 0.0 , borderWidth:CGFloat = 0.0 , shadowOpacity:Float = 0.0 , shadowRadius:CGFloat = 0.0){
        // border radius
        self.layer.cornerRadius = cornerRadius

        // border
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = borderWidth

        // drop shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    }
}
