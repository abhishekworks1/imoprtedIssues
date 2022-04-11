//
//  messageTitleCell.swift
//
//

import UIKit

class messageTitleCell: UITableViewCell {
    
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
            detailsLabel.text = ""
            detailsLabel.isHidden = true
            selectedButton.setImage(UIImage(named: "radioDeselectedBlue"), for: .normal)
        } else {
            detailsLabel.isHidden = false
            detailsLabel.text = "jh sjkahfkjdsh kjsahf kjas kjlfaskjdf hajkls fkjals hfakjlsd fhkjalsfh klajsdh fkjlsa d"
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
