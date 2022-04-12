//
//  messageTitleCell.swift
//
//

import UIKit

class messageTitleCell: UITableViewCell {
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet  var textLbl: UILabel!
    @IBOutlet  var detailsLabel: UILabel!
    
    var handleRatioButtonAction: ((_ isSelected: Bool) -> Void)?
    var isSelectedRadio: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setSeletedState(state: Bool, details: String) {
        isSelectedRadio = state
        if !state {
            detailView.isHidden = true
            detailsLabel.text = ""
            //detailsLabel.isHidden = true
            selectedButton.setImage(UIImage(named: "radioDeselectedBlue"), for: .normal)
        } else {
            detailView.isHidden = false
            //detailsLabel.isHidden = false
            detailsLabel.text = details
            selectedButton.setImage(UIImage(named: "radioSelectedBlue"), for: .normal)
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
