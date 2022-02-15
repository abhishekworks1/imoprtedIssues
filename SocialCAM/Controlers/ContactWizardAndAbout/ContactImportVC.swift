//
//  ContactImportVC.swift
//  SocialCAM
//
//  Created by Gaurang Pandya on 26/01/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import SafariServices
import Alamofire
import Contacts
import MessageUI

class ContactImportVC: UIViewController, UITableViewDelegate, UITableViewDataSource, contactCelldelegate , MFMessageComposeViewControllerDelegate , MFMailComposeViewControllerDelegate , UISearchBarDelegate {
    
    

    @IBOutlet weak var line1: UILabel!
    @IBOutlet weak var line2: UILabel!
    @IBOutlet weak var line3: UILabel!

    @IBOutlet weak var lblNum2: UILabel!
    @IBOutlet weak var lblNum3: UILabel!
    @IBOutlet weak var lblNum4: UILabel!

    @IBOutlet weak var page1view: UIView!
    @IBOutlet weak var page2view: UIView!
    @IBOutlet weak var page3view: UIView!
    @IBOutlet weak var page4view: UIView!

    @IBOutlet weak var frwrdarrow1: UIImageView!
    @IBOutlet weak var frwrdarrow2: UIImageView!
    @IBOutlet weak var frwrdarrow3: UIImageView!
    
    @IBOutlet weak var page3NextBtn: UIButton!

    let blueColor1 = UIColor(red: 0/255, green: 125/255, blue: 255/255, alpha: 1.0)
    let grayColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    var pageNo : Int = 1
    var isSelectSMS : Bool = false
    
    var listingResponse : msgTitleList? = nil
    @IBOutlet weak var itemsTableView: UITableView!
    
    
    var selectedTitleRow : Int = 0
    fileprivate static let CELL_IDENTIFIER = "messageTitleCell"

    //share page declaration
    var txtLinkWithCheckOut: String = ""
    var ReferralLink: String = ""
    var greetingMessage: String = ""
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var imgProfileBadge: UIImageView!
    @IBOutlet weak var viewQrCode: UIView!
    @IBOutlet weak var viewprofilePicBadge: UIView!

    @IBOutlet weak var imageQrCode: UIImageView!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var verifiedView: UIView!
    @IBOutlet weak var facebookVerifiedView: UIView!
    @IBOutlet weak var twitterVerifiedView: UIView!
    @IBOutlet weak var snapchatVerifiedView: UIView!
    @IBOutlet weak var youtubeVerifiedView: UIView!
    @IBOutlet weak var btnIncludeProfileImg: UIButton!
    @IBOutlet weak var btnIncludeQrImg: UIButton!
    @IBOutlet weak var lblSinceDate: UILabel!
    @IBOutlet weak var lblDisplayName: UILabel!

    @IBOutlet weak var socialPlatformsVerifiedBadgeView: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var badgebtn1: UIButton!
    @IBOutlet weak var badgebtn2: UIButton!
    @IBOutlet weak var badgebtn3: UIButton!
    
    var isIncludeProfileImg = Defaults.shared.includeProfileImgForShare
    var isIncludeQrImg = Defaults.shared.includeQRImgForShare

    @IBOutlet weak var contactPermitView: UIView!
    @IBOutlet weak var contactTableView: UITableView!
    fileprivate static let CELL_IDENTIFIER_CONTACT = "contactTableViewCell"
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchText:String = ""
    
    var phoneContacts = [PhoneContact]()
    var mailContacts = [PhoneContact]()
    var allphoneContacts = [PhoneContact]()
    var allmailContacts = [PhoneContact]()
    var filter: ContactsFilter = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
        self.setupPage()
        self.fetchTitleMessages()
    }
    // MARK: - UI setup
    func setupUI(){
        frwrdarrow1.setImageColor(color: UIColor(hexString: "007DFF"))
        frwrdarrow2.setImageColor(color: UIColor(hexString: "7D46F5"))
        frwrdarrow3.setImageColor(color: UIColor(hexString: "E48C4C"))

        itemsTableView.register(UINib.init(nibName: ContactImportVC.CELL_IDENTIFIER, bundle: nil), forCellReuseIdentifier: ContactImportVC.CELL_IDENTIFIER)
        
        itemsTableView.allowsSelection = true
        itemsTableView.dataSource = self
        itemsTableView.delegate = self
        
        contactTableView.register(UINib.init(nibName: ContactImportVC.CELL_IDENTIFIER_CONTACT, bundle: nil), forCellReuseIdentifier: ContactImportVC.CELL_IDENTIFIER_CONTACT)
        
        contactTableView.allowsSelection = true
        contactTableView.dataSource = self
        contactTableView.delegate = self
        
        searchBar.delegate = self
        
        
        if let channelId = Defaults.shared.currentUser?.channelId {
            //self.txtLinkWithCheckOut = "\(R.string.localizable.checkOutThisCoolNewAppQuickCam())"
            self.ReferralLink = "\(websiteUrl)/\(channelId)"
            self.lblUserName.text = "@\(channelId)"
        }
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            self.imgProfilePic.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
            self.imgProfilePic.layer.cornerRadius = imgProfilePic.bounds.width / 2
            self.imgProfilePic.contentMode = .scaleAspectFill
        }
        if let qrImageURL = Defaults.shared.currentUser?.qrcode {
            self.imageQrCode.sd_setImage(with: URL.init(string: qrImageURL), placeholderImage: nil)
        }
        self.btnIncludeProfileImg.isSelected = Defaults.shared.includeProfileImgForShare == true
        self.btnIncludeQrImg.isSelected = Defaults.shared.includeQRImgForShare == true
        self.getVerifiedSocialPlatforms()
        //self.instagramView.isHidden = Defaults.shared.includeProfileImgForShare != true
        if let createdDate = Defaults.shared.currentUser?.created {
            let date = CommonFunctions.getDateInSpecificFormat(dateInput: createdDate, dateOutput: R.string.localizable.mmmdYyyy())
            self.lblSinceDate.text = R.string.localizable.sinceJoined(date)
        }
        
        if let displayName =  Defaults.shared.publicDisplayName,
           !displayName.isEmpty {
            self.lblDisplayName.isHidden = false
            self.lblDisplayName.text = displayName
        } else {
            self.lblDisplayName.isHidden = true
        }
        setUpbadges()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
//        if pageNo == 4 {
//            ContactPermission()
//        }
        
    }
    func ContactPermission(){
        
        let loadingView = LoadingView.instanceFromNib()
        loadingView.shouldCancelShow = true
        loadingView.loadingViewShow = true
        loadingView.show(on: view)
        
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts){
            
        case .authorized: //access contacts
            contactPermitView.isHidden = true
            print("here")
            self.loadContacts(filter: self.filter) // Calling loadContacts methods
            loadingView.hide()
        case .denied, .notDetermined: //request permission
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                if granted {
                    //completionHandler(true)
                    DispatchQueue.main.async {
                        self.contactPermitView.isHidden = true
                        self.loadContacts(filter: self.filter) // Calling loadContacts methods
                    }
                    
                } else {
                    self.contactPermitView.isHidden = false
                    DispatchQueue.main.async {
                        self.showSettingsAlert()
                    }
                }
            }
            loadingView.hide()
        default: break
        }
    }
    private func showSettingsAlert() {
        let alert = UIAlertController(title: nil, message: "This app requires access to Contacts to proceed. Go to Settings to grant access.", preferredStyle: .alert)
        if
            let settings = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settings) {
                alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                    //completionHandler(false)
                    UIApplication.shared.open(settings)
                })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            //completionHandler(false)
            self.contactPermitView.isHidden = false
        })
        present(alert, animated: true)
    }
    
    func setupPage(){
        if pageNo == 1 {
            page1view.isHidden = false
            page2view.isHidden = true
            page3view.isHidden = true
            page4view.isHidden = true
            line1.backgroundColor = grayColor
            line2.backgroundColor = grayColor
            line3.backgroundColor = grayColor
            lblNum2.textColor = grayColor
            lblNum3.textColor = grayColor
            lblNum4.textColor = grayColor
            lblNum2.backgroundColor = .white
            lblNum3.backgroundColor = .white
            lblNum4.backgroundColor = .white
        }
        if pageNo == 2{
            page1view.isHidden = true
            page2view.isHidden = false
            page3view.isHidden = true
            page4view.isHidden = true
            line1.backgroundColor = blueColor1
            line2.backgroundColor = grayColor
            line3.backgroundColor = grayColor
            lblNum2.textColor = .white
            lblNum3.textColor = grayColor
            lblNum4.textColor = grayColor
            lblNum2.backgroundColor = blueColor1
            lblNum3.backgroundColor = .white
            lblNum4.backgroundColor = .white
        }
        
        if pageNo == 3{
            page1view.isHidden = true
            page2view.isHidden = true
            page3view.isHidden = false
            page4view.isHidden = true
            line1.backgroundColor = blueColor1
            line2.backgroundColor = blueColor1
            line3.backgroundColor = grayColor
            lblNum2.textColor = .white
            lblNum3.textColor = .white
            lblNum4.textColor = grayColor
            lblNum2.backgroundColor = blueColor1
            lblNum3.backgroundColor = blueColor1
            lblNum4.backgroundColor = .white
            if isSelectSMS {
                page3NextBtn.setTitle("Next", for: .normal)
                page3NextBtn.backgroundColor = blueColor1
                page3NextBtn.setTitleColor(.white, for: .normal)

            }else{
                page3NextBtn.setTitle("Done", for: .normal)
                page3NextBtn.backgroundColor = .white
                page3NextBtn.setTitleColor(blueColor1, for: .normal)
            }
        }
        
        if pageNo == 4{
            page1view.isHidden = true
            page2view.isHidden = true
            page3view.isHidden = true
            page4view.isHidden = false
            line1.backgroundColor = blueColor1
            line2.backgroundColor = blueColor1
            line3.backgroundColor = blueColor1
            lblNum2.textColor = .white
            lblNum3.textColor = .white
            lblNum4.textColor = .white
            lblNum2.backgroundColor = blueColor1
            lblNum3.backgroundColor = blueColor1
            lblNum4.backgroundColor = blueColor1
        }
    }
    func fetchTitleMessages(){
        let path = API.shared.baseUrlV2 + Paths.referralTitle
        let headerWithToken : HTTPHeaders =  ["Content-Type": "application/json",
                                       "userid": Defaults.shared.currentUser?.id ?? "",
                                       "deviceType": "1",
                                       "x-access-token": Defaults.shared.sessionToken ?? ""]
        let request = AF.request(path, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headerWithToken, interceptor: nil)

        request.responseDecodable(of: msgTitleList?.self) {(resposnse) in
            self.listingResponse = resposnse.value as? msgTitleList
            if (self.listingResponse?.list.count ?? 0) > 0{
                self.itemsTableView.reloadData()
            }
        }
    }
    
    func getVerifiedSocialPlatforms() {
        if let socialPlatforms = Defaults.shared.socialPlatforms, socialPlatforms.count > 0 {
            verifiedView.isHidden = false
            for socialPlatform in socialPlatforms {
                if socialPlatform == R.string.localizable.facebook().lowercased() {
                    self.facebookVerifiedView.isHidden = false
                } else if socialPlatform == R.string.localizable.twitter().lowercased() {
                    self.twitterVerifiedView.isHidden = false
                } else if socialPlatform == R.string.localizable.snapchat().lowercased() {
                    self.snapchatVerifiedView.isHidden = false
                } else if socialPlatform == R.string.localizable.youtube().lowercased() {
                    self.youtubeVerifiedView.isHidden = false
                }
            }
            self.imgProfileBadge.image = (socialPlatforms.count == 4) ? R.image.shareScreenRibbonProfileBadge() : R.image.shareScreenProfileBadge()
            self.socialPlatformsVerifiedBadgeView.isHidden = socialPlatforms.count != 4
        } else {
            self.verifiedView.isHidden = true
            self.socialPlatformsVerifiedBadgeView.isHidden = true
        }
    }
    func setUpbadges() {
        let badgearry = Defaults.shared.getbadgesArray()
        view1.isHidden = true
        view2.isHidden = true
        view3.isHidden = true
        //view4.isHidden = true
        
        if  badgearry.count >  0 {
            view1.isHidden = false
            badgebtn1.setImage(UIImage.init(named: badgearry[0]), for: .normal)
        }
        if  badgearry.count >  1 {
            view2.isHidden = false
            badgebtn2.setImage(UIImage.init(named: badgearry[1]), for: .normal)
        }
        if  badgearry.count >  2 {
            view3.isHidden = false
            badgebtn3.setImage(UIImage.init(named: badgearry[2]), for: .normal)
        }
//        if  badgearry.count >  3 {
//            view4.isHidden = false
//            badgebtn4.setImage(UIImage.init(named: badgearry[3]), for: .normal)
//        }
    }
    
    fileprivate func loadContacts(filter: ContactsFilter) {
        phoneContacts.removeAll()
        mailContacts.removeAll()
        
       var allContacts = [PhoneContact]()
        for contact in PhoneContact.getContacts(filter: filter) {
                allContacts.append(PhoneContact(contact: contact))
        }
        allContacts.sort {
            $0.name ?? "" < $1.name ?? ""
        }
        var filterdArray = [PhoneContact]()
        allmailContacts = [PhoneContact]()
        allphoneContacts = [PhoneContact]()
        mailContacts = [PhoneContact]()
        phoneContacts = [PhoneContact]()
        //if self.filter == .mail {
            allmailContacts = allContacts.filter({ $0.email.count > 0 }) // getting all email
            mailContacts = allContacts.filter({ $0.email.count > 0 }) // getting all email
        //} else if self.filter == .message {
            allphoneContacts = allContacts.filter({ $0.phoneNumber.count > 0 })
            phoneContacts = allContacts.filter({ $0.phoneNumber.count > 0 })
        //} else {
            filterdArray = allContacts
        //}
        //phoneContacts.append(contentsOf: filterdArray)
        
        for contact in phoneContacts {
//            print("Name -> \(contact.name)")
//            print("Email -> \(contact.email)")
//            print("Phone Number -> \(contact.phoneNumber)")
        }
//        let arrayCode  = self.phoneNumberWithContryCode()
//        for codes in arrayCode {
//            print(codes)
//        }
        DispatchQueue.main.async {
            
            self.contactTableView.reloadData() // update your tableView having phoneContacts array
        }
    }
            
    // MARK: - tableview Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == itemsTableView{
            return 70
        } else {
            return 75
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {

        if tableView == itemsTableView{
            return 1
        } else{
            return 2
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == itemsTableView{
            return self.listingResponse?.list.count ?? 0
        } else {
            if section == 0 {
                return phoneContacts.count
            }else {
                return mailContacts.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        if tableView == itemsTableView{
            return view
        } else {
            if section == 0{
                if phoneContacts.count>0{
                    let label = cutomHeaderView(title: "Contact Numbers")
                    view.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)
//                    let bottomLine = CALayer()
//                    bottomLine.frame = CGRect(x: 0, y: 34.5, width: self.view.frame.size.width, height: 0.5)
//                    bottomLine.backgroundColor = UIColor.init(hexString: "#D4D4D4").cgColor
//                    view.layer.addSublayer(bottomLine)
                    view.addSubview(label)
                }
            }else if section == 1{
                if mailContacts.count>0{
                    let label = cutomHeaderView(title: "Contact Emails")
                    view.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)
//                    let bottomLine = CALayer()
//                    bottomLine.frame = CGRect(x: 0, y: 34.5, width: self.view.frame.size.width, height: 0.5)
//                    bottomLine.backgroundColor = UIColor.init(hexString: "#D4D4D4").cgColor
//                    view.layer.addSublayer(bottomLine)
                    view.addSubview(label)
                }
            }
            return view
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == itemsTableView{
            let cell:messageTitleCell = self.itemsTableView.dequeueReusableCell(withIdentifier: ContactImportVC.CELL_IDENTIFIER) as! messageTitleCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            let item = self.listingResponse?.list[indexPath.row]
            if item != nil {
                cell.textLbl.text = item?.content ?? ""
            }
            if selectedTitleRow == indexPath.row {
                cell.selectionImageView.image = UIImage.init(named: "radioSelectedBlue")
                txtLinkWithCheckOut = item?.content ?? ""
            }else{
                cell.selectionImageView.image = UIImage.init(named: "radioDeselectedBlue")
            }
            return cell

        } else {
            let cell:contactTableViewCell = self.contactTableView.dequeueReusableCell(withIdentifier: ContactImportVC.CELL_IDENTIFIER_CONTACT) as! contactTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.cellDelegate = self
            if indexPath.section == 0 {
                let contact = phoneContacts[indexPath.row] as PhoneContact
                cell.lblDisplayName.text = contact.name ?? ""
                cell.lblNumberEmail.text = contact.phoneNumber[0]
                if let imagedata =  contact.avatarData {
                    let avtar = UIImage(data:imagedata,scale:1.0)
                    cell.contactImage.image = avtar
                }else {
                    cell.contactImage.image = UIImage.init(named: "User_placeholder")
                }
                cell.phoneContactObj = contact
            }else {
                let contact = mailContacts[indexPath.row] as PhoneContact
                cell.lblDisplayName.text = contact.name ?? ""
                cell.lblNumberEmail.text = contact.email[0]
                if let imagedata =  contact.avatarData {
                    let avtar = UIImage(data:imagedata,scale:1.0)
                    cell.contactImage.image = avtar
                }else {
                    cell.contactImage.image = UIImage.init(named: "User_placeholder")
                }
                cell.phoneContactObj = contact
            }

            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == itemsTableView{
            selectedTitleRow = indexPath.row
            let item = self.listingResponse?.list[indexPath.row]
            if item != nil {
                self.txtLinkWithCheckOut = item?.content ?? ""
            }
            itemsTableView.reloadData()
            if txtLinkWithCheckOut != "" {
                let finalText = "\(greetingMessage) \(txtLinkWithCheckOut)"
                txtLinkWithCheckOut = finalText
                print(txtLinkWithCheckOut)
            }
        } else{
            self.view.endEditing(true)
        }
    }
    
//    MARK: - Creating Alert For User Text Enter
    
    func openAlertTextView() {
        let alert = UIAlertController(title: "Greeting", message: "Please Enter Your Message", preferredStyle: .alert)
       alert.addTextField { customTextFiled in
           customTextFiled.placeholder = "Enter your message"
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [self] okBtn in
            let textFields = alert.textFields
            greetingMessage = (textFields?.first?.text)!
            if greetingMessage != "" {
                print(greetingMessage)
                itemsTableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Searchbar delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            self.searchBar.showsCancelButton = true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //print(searchText)
        guard !searchText.isEmpty  else { phoneContacts = allphoneContacts; mailContacts = allmailContacts; return }

        phoneContacts = allphoneContacts.filter({ Phonecontact -> Bool in
            return (( Phonecontact.name!.lowercased().contains(searchText.lowercased()) ) || ( Phonecontact.phoneNumber[0].contains(searchText.lowercased()) ) )
        })
        
        mailContacts = allmailContacts.filter({ Phonecontact -> Bool in
            return (Phonecontact.name!.lowercased().contains(searchText.lowercased()) || ( Phonecontact.email[0].lowercased().contains(searchText.lowercased()) ))
        })
        contactTableView.reloadData()

    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
        
        phoneContacts = allphoneContacts;
        mailContacts = allmailContacts;
        contactTableView.reloadData()
        
    }
    func searchBarSearchButtonClicked(_ seachBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // MARK: - Button Methods
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func previousClick(_ sender: UIButton) {
        if sender.tag == 1 {
            pageNo = 1
            self.setupPage()
        }else if sender.tag == 2 {
            pageNo = 2
            self.setupPage()
        }else if sender.tag == 3 {
            pageNo = 3
            self.setupPage()
        }
    }
    
    @IBAction func nextClick(_ sender: UIButton) {
        if sender.tag == 1 {
            pageNo = 3
            self.setupPage()
        }
       else if sender.tag == 2 {
           if isSelectSMS {
               pageNo = 4
               self.setupPage()
           }else{
               navigationController?.popViewController(animated: true)
           }
        }else if sender.tag == 3 {
            navigationController?.popViewController(animated: true)
        }
        
    }
    @IBAction func mainOptionsClick(_ sender: UIButton) {
        if sender.tag == 1 {
            isSelectSMS = false
            pageNo = 2
            self.setupPage()
        }else if sender.tag == 2 {
            isSelectSMS = true
            pageNo = 2
            self.setupPage()
        }else if sender.tag == 3 {
            if let token = Defaults.shared.sessionToken {
                let urlString = "\(websiteUrl)/share-wizard?token=\(token)&platformType=ios&redirect_uri=\(redirectUri)"
                print(urlString)
                guard let url = URL(string: urlString) else {
                    return
                }
                presentSafariBrowser(url: url)
            }
        }
    }
    func presentSafariBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    @IBAction func btnInclueProfileImgClicked(_ sender: UIButton) {
        self.isIncludeProfileImg = !isIncludeProfileImg
        self.btnIncludeProfileImg.isSelected = isIncludeProfileImg
        Defaults.shared.includeProfileImgForShare = isIncludeProfileImg
        self.viewprofilePicBadge.isHidden = !isIncludeProfileImg
    }
    @IBAction func btnIncludeQRCodeClicked(_ sender: UIButton) {
        self.isIncludeQrImg = !isIncludeQrImg
        self.btnIncludeQrImg.isSelected = isIncludeQrImg
        Defaults.shared.includeQRImgForShare = isIncludeQrImg
        self.imageQrCode.isHidden = !isIncludeQrImg
        self.viewQrCode.isHidden = !isIncludeQrImg
    }
    
    @IBAction func shareOkButtonClicked(_ sender: UIButton) {
            let urlString = self.txtLinkWithCheckOut
            let channelId = Defaults.shared.currentUser?.channelId ?? ""
            let urlwithString = urlString + "\n" + "\n" + " \(websiteUrl)/\(channelId)"
            UIPasteboard.general.string = urlwithString
            var shareItems: [Any] = [urlwithString]
            //if isIncludeProfileImg {
            let image = self.profileView.toImage()
            shareItems.append(image)
            //}
            let shareVC: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            self.present(shareVC, animated: true, completion: nil)
        //}
    }
    
    
    @IBAction func enableContactClicked(_ sender: UIButton) {
        
        ContactPermission()
    }
    func cutomHeaderView(title:String) -> UILabel {
        let label = UILabel()
        label.frame = CGRect(x: 15,y: 6,width: 200,height: 20)
        label.text = title
        label.textAlignment = .natural
        label.textColor = UIColor(red:0.36, green:0.36, blue:0.36, alpha:1.0)
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }
    
    func didPressButton(_ contact: PhoneContact) {
        
        let urlString = self.txtLinkWithCheckOut
        let channelId = Defaults.shared.currentUser?.channelId ?? ""
        let urlwithString = urlString + "\n" + "\n" + " \(websiteUrl)/\(channelId)"
        //UIPasteboard.general.string = urlwithString
        //var shareItems: [Any] = [urlwithString]

        let imageV = self.profileView.toImage()
       // shareItems.append(image)
        
        var phoneNum = ""
        var email = ""
        if contact.phoneNumber.count > 0 {
            phoneNum = contact.phoneNumber[0]
            
            if !MFMessageComposeViewController.canSendText() {
                    //showAlert("Text services are not available")
                    return
                }

                let textComposer = MFMessageComposeViewController()
                textComposer.messageComposeDelegate = self
                let recipients:[String] = [phoneNum]
                textComposer.body = urlwithString
                textComposer.recipients = recipients

                if MFMessageComposeViewController.canSendAttachments() {
                    let imageData = imageV.jpegData(compressionQuality: 1.0)
                    textComposer.addAttachmentData(imageData!, typeIdentifier: "image/jpg", filename: "photo.jpg")
                }

                present(textComposer, animated: true)
            
        }else {
            if contact.email.count > 0 {
                email = contact.email[0]
                
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients([email])
                    mail.setSubject(urlString)
                    mail.setMessageBody(urlwithString, isHTML: false)
                    
                    let imageData = imageV.jpegData(compressionQuality: 1.0)
                    mail.addAttachmentData(imageData!, mimeType: "image/jpg", fileName: "photo.jpg")
                    present(mail, animated: true)
                    
                    // Show third party email composer if default Mail app is not present
                }
                
            }
        }
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Swift.Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
