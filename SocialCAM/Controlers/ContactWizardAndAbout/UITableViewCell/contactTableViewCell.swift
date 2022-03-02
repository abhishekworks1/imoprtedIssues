//
//  contactTableViewCell.swift


import UIKit


protocol contactCelldelegate : AnyObject {
    func didPressButton(_ contact: PhoneContact ,mobileContact:ContactResponse?)
}

class contactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var lblNumberEmail: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var inviteBtn: UIButton!

    var cellDelegate: contactCelldelegate?
    var phoneContactObj : PhoneContact?
    var mobileContactObj : ContactResponse?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let view = UIView()
        view.backgroundColor = .white
        
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        cellDelegate?.didPressButton(phoneContactObj ?? PhoneContact(), mobileContact: mobileContactObj)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
   
    
}
