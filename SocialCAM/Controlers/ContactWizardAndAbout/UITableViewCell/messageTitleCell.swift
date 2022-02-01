//
//  messageTitleCell.swift
//
//

import UIKit

class messageTitleCell: UITableViewCell {
    
    @IBOutlet  var textLbl: UILabel!
    @IBOutlet  var selectionImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
