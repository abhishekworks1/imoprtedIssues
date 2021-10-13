
import UIKit

class FlagLayoutGridCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var btnSelected: UIButton!
    
    @objc open var selectedItem: Bool = false {
        didSet {
            self.btnSelected?.isHidden = !selectedItem
        }
    }
    
    func setup(with user: Country) {
        flagImageView.image = user.flag
        nameLabel.text = user.name
    }
}
