//
//  messageTitleCell.swift
//
//

import UIKit
import IQKeyboardManagerSwift

class messageTitleCell: UITableViewCell {
    
    @IBOutlet weak var emailSubTextView: IQTextView!
    @IBOutlet weak var emailTextView: IQTextView!
    @IBOutlet weak var messageTextView: IQTextView!
    @IBOutlet weak var ownEmailView: UIView!
    @IBOutlet weak var ownMessageView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet  var textLbl: UILabel!
    @IBOutlet  var detailsLabel: UILabel!
    
    var handleRatioButtonAction: ((_ isSelected: Bool) -> Void)?
    var isSelectedRadio: Bool = false
    var shareType:ShareType = ShareType.textShare
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ownMessageView.isHidden = true
        ownEmailView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setSeletedState(state: Bool, details: String, indexPath: IndexPath) {
        isSelectedRadio = state
        if !state {
            detailView.isHidden = true
            detailsLabel.text = ""
            //detailsLabel.isHidden = true
            selectedButton.setImage(UIImage(named: "radioDeselectedBlue"), for: .normal)
        } else {
            if details.isEmpty {
                detailView.isHidden = true
                //detailsLabel.isHidden = false
                detailsLabel.text = details
                selectedButton.setImage(UIImage(named: "radioSelectedBlue"), for: .normal)
                if indexPath == IndexPath(row: 0, section: 0) {
                    self.ownMessageView.isHidden = false
                    self.ownEmailView.isHidden = true
                } else {
                    self.ownMessageView.isHidden = true
                    self.ownEmailView.isHidden = true
                }
            } else {
                //detailsLabel.isHidden = false
                detailsLabel.text = details
                selectedButton.setImage(UIImage(named: "radioSelectedBlue"), for: .normal)
                if indexPath == IndexPath(row: 0, section: 0) {
                    detailView.isHidden = true
                    self.ownMessageView.isHidden = true
                    self.ownEmailView.isHidden = false
                } else {
                    detailView.isHidden = false
                    self.ownMessageView.isHidden = true
                    self.ownEmailView.isHidden = true
                }
                
            }
        }
    }
    
    func setText(text: String) {
        textLbl.text = text
    }
    @IBAction func selectedButtonAction(_ sender: Any) {
        isSelectedRadio.toggle()
        handleRatioButtonAction?(isSelectedRadio)
    }
    
}
