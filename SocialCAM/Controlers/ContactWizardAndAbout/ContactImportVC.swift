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
import ObjectMapper
import LinkPresentation
import URLEmbeddedView

enum ShareType:Int{
    case textShare = 1
    case qrcode = 2
    case email = 3
    case socialShare = 4
    
}

struct ContactType{
    static let mobile = "mobile"
    static let email = "email"
}
struct ContactStatus{
    static let pending = "pending"
    static let invited = "invited"
    static let recent = "recent"
    static let signedup = "signedup"
    static let subscriber = "subscriber"
    static let optout = "optout"
    static let all = "all"
    static let hidden = "hidden"
    static let opened = "opened"
}
protocol ContactImportDelegate {
    func didFinishEdit(contact:ContactResponse?)
}
class ContactImportVC: UIViewController, UITableViewDelegate, UITableViewDataSource, contactCelldelegate , MFMessageComposeViewControllerDelegate , MFMailComposeViewControllerDelegate , UISearchBarDelegate, UINavigationControllerDelegate,ContactImportDelegate {
    
    var shareType:ShareType = ShareType.textShare
    @IBOutlet weak var line1: UILabel!
    @IBOutlet weak var line2: UILabel!
    @IBOutlet weak var line3: UILabel!
    @IBOutlet weak var line4: UILabel!
    

    @IBOutlet weak var lblNum2: UILabel!
    @IBOutlet weak var lblNum3: UILabel!
    @IBOutlet weak var lblNum4: UILabel!
    @IBOutlet weak var lblNum5: UILabel!
    
    @IBOutlet weak var page0view: UIView!
    @IBOutlet weak var page1view: UIView!
    @IBOutlet weak var page2view: UIView!
    @IBOutlet weak var page3view: UIView!
    @IBOutlet weak var page4view: UIView!

    @IBOutlet weak var frwrdarrow1: UIImageView!
    @IBOutlet weak var frwrdarrow2: UIImageView!
    @IBOutlet weak var frwrdarrow3: UIImageView!
    
    @IBOutlet weak var page3NextBtn: UIButton!
    
    @IBOutlet weak var textShareView: UIView!
    @IBOutlet weak var qrCodeShareView: UIView!
    @IBOutlet weak var manualEmailView: UIView!
    @IBOutlet weak var socialShareView: UIView!
    @IBOutlet weak var businessDashboardView: UIView!
    
    @IBOutlet weak var deleteContactConfirmationView: UIView!
    @IBOutlet weak var deleteContactDoNotShowButton: UIButton!
    @IBOutlet weak var filterOptionView: UIView!
    var loadingStatus = false
    let blueColor1 = UIColor(red: 0/255, green: 125/255, blue: 255/255, alpha: 1.0)
    let grayColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    var pageNo : Int = 1
    var isSelectSMS : Bool = false
    
    var listingResponse : msgTitleList? = nil
    var emailMsgListing : msgTitleList? = nil
    var smsMsgListing : msgTitleList? = nil
   @IBOutlet weak var itemsTableView: UITableView!
    
    @IBOutlet weak var btnDoNotShowAgain: UIButton!
    
    var selectedTitleRow : Int = 0
    fileprivate static let CELL_IDENTIFIER = "messageTitleCell"

    //share page declaration
    var txtDetailForEmail: String = ""
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
    @IBOutlet weak var btnShare: UIButton!
    
    
    @IBOutlet weak var preLunchBadge: UIImageView!
     @IBOutlet weak var foundingMergeBadge: UIImageView!
     @IBOutlet weak var socialBadgeicon: UIImageView!
     @IBOutlet weak var subscriptionBadgeicon: UIImageView!
        
    @IBOutlet weak var preLunchBadge1: UIImageView!
     @IBOutlet weak var foundingMergeBadge1: UIImageView!
     @IBOutlet weak var socialBadgeicon1: UIImageView!
     @IBOutlet weak var subscriptionBadgeicon1: UIImageView!

    
    @IBOutlet weak var textMessageButton: UIButton!
    @IBOutlet weak var textMessageSeperatorView: UIView!
    @IBOutlet weak var textMessageSeperatorViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailSeperatorView: UIView!
    @IBOutlet weak var emailSeperatorViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var segmentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stepViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var inviteAgainpopup: UIView!
    
    @IBOutlet weak var contactSentConfirmPopup: UIView!
    var isIncludeProfileImg = Defaults.shared.includeProfileImgForShare
    var isIncludeQrImg = Defaults.shared.includeQRImgForShare
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var contactPermitView: UIView!
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var emailContactTableView: UITableView!
    
    @IBOutlet weak var previewMainView: UIView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewImageview: UIImageView!
    @IBOutlet weak var lblpreviewText: UILabel!
    @IBOutlet weak var lblpreviewUrl: UILabel!
    @IBOutlet weak var socialSharePopupView: UIView!
    
    fileprivate static let CELL_IDENTIFIER_CONTACT = "contactTableViewCell"
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //for View One
    @IBOutlet weak var lblReferralLink: UILabel!
   
    
    @IBOutlet weak var businessDashboardStackView: UIStackView!
    @IBOutlet weak var businessDashboardButton: UIButton!
    @IBOutlet weak var businessDashbardConfirmPopupView: UIView!
    @IBOutlet weak var btnDoNotShowAgainBusinessConfirmPopup: UIButton!
    
    
    var searchText:String = ""
    var selectedContact:ContactResponse?
    var inviteData:Data?
    var phoneContacts = [PhoneContact]()
    var mailContacts = [PhoneContact]()
    var allphoneContacts = [PhoneContact]()
    var allmailContacts = [PhoneContact]()
    var mobileContacts = [ContactResponse]()
    var emailContacts = [ContactResponse]()
    var allmobileContacts = [ContactResponse]()
    var allmobileContactsForHide = [ContactResponse]()
    var allemailContactsForHide = [ContactResponse]()
    var filter: ContactsFilter = .none
    var selectedFilter:String = ContactStatus.all
    var loadingView: LoadingView? = LoadingView.instanceFromNib()
    var selectedContactType:String = ContactType.mobile
    
    let themeBlueColor = UIColor(hexString:"4F2AD8")
    let logoImage = UIImage(named:"qr_applogo")
    private var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
        self.setupPage()
        self.fetchTitleMessages()
        self.fetchEmailMessages()
      //  self.getContactList()
    }
    // MARK: - UI setup
    func setupUI(){
//        frwrdarrow1.setImageColor(color: UIColor(hexString: "007DFF"))
//        frwrdarrow2.setImageColor(color: UIColor(hexString: "7D46F5"))
//        frwrdarrow3.setImageColor(color: UIColor(hexString: "E48C4C"))

        itemsTableView.register(UINib.init(nibName: ContactImportVC.CELL_IDENTIFIER, bundle: nil), forCellReuseIdentifier: ContactImportVC.CELL_IDENTIFIER)
        
        itemsTableView.allowsSelection = true
        itemsTableView.dataSource = self
        itemsTableView.delegate = self
        
        contactTableView.register(UINib.init(nibName: ContactImportVC.CELL_IDENTIFIER_CONTACT, bundle: nil), forCellReuseIdentifier: ContactImportVC.CELL_IDENTIFIER_CONTACT)
        
        emailContactTableView.register(UINib.init(nibName: ContactImportVC.CELL_IDENTIFIER_CONTACT, bundle: nil), forCellReuseIdentifier: ContactImportVC.CELL_IDENTIFIER_CONTACT)
        
        contactTableView.allowsSelection = true
        contactTableView.dataSource = self
        contactTableView.delegate = self
        
        emailContactTableView.allowsSelection = true
        emailContactTableView.dataSource = self
        emailContactTableView.delegate = self
        
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
//        if let qrImageURL = Defaults.shared.currentUser?.qrcode {
//            self.imageQrCode.sd_setImage(with: URL.init(string: qrImageURL), placeholderImage: nil)
//        }
        if let referralPage = Defaults.shared.currentUser?.referralPage {
            let image =  URL(string: referralPage)?.qrImage(using: themeBlueColor, logo: logoImage)
            self.imageQrCode.image = image?.convert()
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
        
        textMessageButton.setTitleColor(ApplicationSettings.appPrimaryColor, for: .normal)
        textMessageSeperatorView.backgroundColor = ApplicationSettings.appPrimaryColor
        textMessageSeperatorViewHeight.constant = 3.0
        
        emailButton.setTitleColor(UIColor(hexString: "676767"), for: .normal)
        emailSeperatorView.backgroundColor = UIColor(hexString: "676767")
        emailSeperatorViewHeight.constant = 1.0
        selectedContactType = ContactType.mobile
        self.emailContactTableView.isHidden = true
        self.contactTableView.isHidden = false
        
        if let channelId = Defaults.shared.currentUser?.channelId {
            self.lblReferralLink.text = "\(websiteUrl)/\(channelId)"
        }
        
        self.textShareView.dropShadow()
        self.qrCodeShareView.dropShadow()
        self.manualEmailView.dropShadow()
        self.socialShareView.dropShadow()
        self.businessDashboardView.dropShadow()
        
        previewImageview.contentMode = .scaleAspectFit
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon

//        if pageNo == 4 {
//            ContactPermission()
//        }
        

        
        filterOptionView.isHidden = true
      //  let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
      //  self.view.addGestureRecognizer(tap)
      //  self.syncButtonClicked(sender:self.syncButton)
      //  self.textMessageSelected(sender:self.textMessageButton)
        textMessageButton.setTitleColor(ApplicationSettings.appPrimaryColor, for: .normal)
        textMessageSeperatorView.backgroundColor = ApplicationSettings.appPrimaryColor
        textMessageSeperatorViewHeight.constant = 3.0
        
        emailButton.setTitleColor(UIColor(hexString: "676767"), for: .normal)
        emailSeperatorView.backgroundColor = UIColor(hexString: "676767")
        emailSeperatorViewHeight.constant = 1.0
        selectedContactType = ContactType.mobile
        self.emailContactTableView.isHidden = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if pageNo == 4{
            self.getContactList(source: self.selectedContactType,filter:self.selectedFilter)
        }
        setPreviewData()
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if !filterOptionView.isHidden{
            filterOptionView.isHidden = true
        }
    }
    func showLoader(){
            self.loadingView = LoadingView.instanceFromNib()
            self.loadingView?.shouldCancelShow = true
            self.loadingView?.loadingViewShow = true
            self.loadingView?.hideAdView(true)
            self.loadingView?.show(on: self.view)
  
    }
    func hideLoader(){
        DispatchQueue.main.async {
            self.loadingView?.hide()
        }
    }
    func ContactPermission(){
        self.showLoader()
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts){
            
        case .authorized: //access contacts
            contactPermitView.isHidden = true
            print("here")
            //self.loadContacts(filter: self.filter) // Calling loadContacts methods
            self.getContactList()
           // loadingView.hide()
           // self.hideLoader()
        case .denied, .notDetermined: //request permission
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                if granted {
                    //completionHandler(true)
                    DispatchQueue.main.async {
                        self.contactPermitView.isHidden = true
                        self.loadContacts(filter: self.filter) // Calling loadContacts methods
                    }
                    
                } else {
                    self.hideLoader()
                    self.contactPermitView.isHidden = false
                    DispatchQueue.main.async {
                        self.showSettingsAlert()
                    }
                }
            }
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
    
    @IBAction func didTapView0NextButton(_ sender: UIButton) {
        pageNo = 2
        setupPage()
    }
    
    
    
    func setupPage(){
        self.searchBar.endEditing(true)
        if pageNo == 1 {
            page0view.isHidden = false
            page1view.isHidden = true
            page2view.isHidden = true
            page3view.isHidden = true
            page4view.isHidden = true
        }
        else if pageNo == 2 {
            page0view.isHidden = true
            page1view.isHidden = false
            page2view.isHidden = true
            page3view.isHidden = true
            page4view.isHidden = true
            line1.backgroundColor = blueColor1
            line2.backgroundColor = grayColor
            line3.backgroundColor = grayColor
            line4.backgroundColor = grayColor
            lblNum2.textColor = .white
            lblNum3.textColor = grayColor
            lblNum4.textColor = grayColor
            lblNum5.textColor = grayColor
            lblNum2.backgroundColor = blueColor1
            lblNum3.backgroundColor = .white
            lblNum4.backgroundColor = .white
            lblNum5.backgroundColor = .white
        }
        else if pageNo == 3 {
            page0view.isHidden = true
            page1view.isHidden = true
            page2view.isHidden = false
            page3view.isHidden = true
            page4view.isHidden = true
            line1.backgroundColor = blueColor1
            line2.backgroundColor = blueColor1
            line3.backgroundColor = grayColor
            line4.backgroundColor = grayColor
            lblNum2.textColor = .white
            lblNum3.textColor = .white
            lblNum4.textColor = grayColor
            lblNum5.textColor = grayColor
            lblNum2.backgroundColor = blueColor1
            lblNum3.backgroundColor = blueColor1
            lblNum4.backgroundColor = .white
            lblNum5.backgroundColor = .white
            itemsTableView.reloadData()
        }
        else if pageNo == 4 {
            page0view.isHidden = true
            page1view.isHidden = true
            page2view.isHidden = true
            page3view.isHidden = false
            page4view.isHidden = true
            line1.backgroundColor = blueColor1
            line2.backgroundColor = blueColor1
            line3.backgroundColor = blueColor1
            line4.backgroundColor = grayColor
            lblNum2.textColor = .white
            lblNum3.textColor = .white
            lblNum4.textColor = .white
            lblNum5.textColor = grayColor
            lblNum2.backgroundColor = blueColor1
            lblNum3.backgroundColor = blueColor1
            lblNum4.backgroundColor = blueColor1
            lblNum5.backgroundColor = .white
           /*if isSelectSMS {
                page3NextBtn.setTitle("Next", for: .normal)
                page3NextBtn.backgroundColor = blueColor1
                page3NextBtn.setTitleColor(.white, for: .normal)
            }else{
                page3NextBtn.setTitle("Done", for: .normal)
                page3NextBtn.backgroundColor = .white
                page3NextBtn.setTitleColor(blueColor1, for: .normal)
            } */
            if shareType == ShareType.socialShare{
                self.btnShare.isHidden = false
            }else{
                self.btnShare.isHidden = true
            }
            page3NextBtn.setTitle("Next", for: .normal)
            page3NextBtn.backgroundColor = blueColor1
            page3NextBtn.setTitleColor(.white, for: .normal)
            self.previewMainView.isHidden = false
        }
        else if pageNo == 5 {
            page0view.isHidden = true
            page1view.isHidden = true
            page2view.isHidden = true
            page3view.isHidden = true
            page4view.isHidden = false
            line1.backgroundColor = blueColor1
            line2.backgroundColor = blueColor1
            line3.backgroundColor = blueColor1
            line4.backgroundColor = blueColor1
            lblNum2.textColor = .white
            lblNum3.textColor = .white
            lblNum4.textColor = .white
            lblNum5.textColor = .white
            lblNum2.backgroundColor = blueColor1
            lblNum3.backgroundColor = blueColor1
            lblNum4.backgroundColor = blueColor1
            lblNum5.backgroundColor = blueColor1
            
            self.previewMainView.isHidden = true
            switch CNContactStore.authorizationStatus(for: CNEntityType.contacts){
                
            case .authorized: //access contacts
                self.showLoader()
                contactPermitView.isHidden = true
                self.getContactList(firstTime:true)
                break
            case .denied, .notDetermined:
                contactPermitView.isHidden = true
                self.getContactList(firstTime:true)
                break //request permission
            case .restricted:
                break
            @unknown default:
                break
            }
        }
    }
    func fetchTitleMessages(){
        let path = API.shared.baseUrlV2 + Paths.messageTitle
        let headerWithToken : HTTPHeaders =  ["Content-Type": "application/json",
                                       "userid": Defaults.shared.currentUser?.id ?? "",
                                       "deviceType": "1",
                                       "x-access-token": Defaults.shared.sessionToken ?? ""]
        let request = AF.request(path, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headerWithToken, interceptor: nil)

        request.responseDecodable(of: msgTitleList?.self) {(resposnse) in
            self.smsMsgListing = resposnse.value as? msgTitleList
            if self.isSelectSMS {
                self.itemsTableView.reloadData()
            }
//            print("smsMsgListing - \(self.smsMsgListing?.list)")
//            if (self.listingResponse?.list.count ?? 0) > 0{
//                self.itemsTableView.reloadData()
//            }
        }
    }
    func fetchEmailMessages(){
        let path = API.shared.baseUrlV2 + Paths.emailTitle
        let headerWithToken : HTTPHeaders =  ["Content-Type": "application/json",
                                       "userid": Defaults.shared.currentUser?.id ?? "",
                                       "deviceType": "1",
                                       "x-access-token": Defaults.shared.sessionToken ?? ""]
        let request = AF.request(path, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headerWithToken, interceptor: nil)

        request.responseDecodable(of: msgTitleList?.self) {(resposnse) in
            self.emailMsgListing = resposnse.value as? msgTitleList
            if !self.isSelectSMS {
                self.itemsTableView.reloadData()
            }
//            print("emailMsgListing - \(self.emailMsgListing?.list)")
//            if (self.listingResponse?.list.count ?? 0) > 0{
//                self.itemsTableView.reloadData()
//            }
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
            //self.socialPlatformsVerifiedBadgeView.isHidden = socialPlatforms.count != 4
        } else {
            self.verifiedView.isHidden = true
            //self.socialPlatformsVerifiedBadgeView.isHidden = true
        }
    }
    
    func setUpbadges() {
           let badgearry = Defaults.shared.getbadgesArray()
           preLunchBadge.isHidden = true
           foundingMergeBadge.isHidden = true
           socialBadgeicon.isHidden = true
           subscriptionBadgeicon.isHidden = true
         
           if  badgearry.count >  0 {
               preLunchBadge.isHidden = false
               preLunchBadge.image = UIImage.init(named: badgearry[0])
           }
           if  badgearry.count >  1 {
               foundingMergeBadge.isHidden = false
               foundingMergeBadge.image = UIImage.init(named: badgearry[1])
           }
           if  badgearry.count >  2 {
               socialBadgeicon.isHidden = false
               socialBadgeicon.image = UIImage.init(named: badgearry[2])
           }
           if  badgearry.count >  3 {
               subscriptionBadgeicon.isHidden = false
               subscriptionBadgeicon.image = UIImage.init(named: badgearry[3])
           }
        
        
        preLunchBadge1.isHidden = true
        foundingMergeBadge1.isHidden = true
        socialBadgeicon1.isHidden = true
        subscriptionBadgeicon1.isHidden = true
      
        if  badgearry.count >  0 {
            preLunchBadge1.isHidden = false
            preLunchBadge1.image = UIImage.init(named: badgearry[0])
        }
        if  badgearry.count >  1 {
            foundingMergeBadge1.isHidden = false
            foundingMergeBadge1.image = UIImage.init(named: badgearry[1])
        }
        if  badgearry.count >  2 {
            socialBadgeicon1.isHidden = false
            socialBadgeicon1.image = UIImage.init(named: badgearry[2])
        }
        if  badgearry.count >  3 {
            subscriptionBadgeicon1.isHidden = false
            subscriptionBadgeicon1.image = UIImage.init(named: badgearry[3])
        }
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
        
        self.showLoader()
        DispatchQueue.main.async {
            self.createContactJSON()
           // self.contactTableView.reloadData() // update your tableView having phoneContacts array
        }
    }
    func createContactJSON(){
      
        var contacts = [ContactDetails]()
        for contact in phoneContacts{
            if contact.phoneNumber.count > 0{
                print(contact.phoneNumber.first!)
                let newContact = ContactDetails(contact:contact)
                contacts.append(newContact)
            }
        }
        print(contacts)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(contacts)
          //  let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            self.createMobileContact(data:jsonData)
           
        } catch {
            print("error")
        }
    }
    func createMobileContact(data:Data){
        
        let path = API.shared.baseUrlV2 + "contact-list/mobile"
        print(path)
        var request = URLRequest(url:URL(string:path)!)
        //some header examples
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Defaults.shared.currentUser?.id ?? "", forHTTPHeaderField: "userid")
        request.setValue(Defaults.shared.sessionToken ?? "", forHTTPHeaderField: "x-access-token")
        request.setValue("1", forHTTPHeaderField: "deviceType")
        request.httpBody = data
        AF.request(request).responseJSON { response in
            print(response)
            switch (response.result) {
            case .success:
                self.getContactList()
                break
               
            case .failure(let error):
                print(error)
                self.hideLoader()
                break
                //failure code here
            }
        }
    }
    func getContactList(source:String = "mobile",page:Int = 1,limit:Int = 20,filter:String = ContactStatus.all,hide:Bool = false,firstTime:Bool = false){
        
        var searchText = searchBar.text!
        var contactType = selectedContactType
        if self.shareType == ShareType.email{
            contactType = ContactType.email
        }
        searchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        print(searchText)
        let path = API.shared.baseUrlV2 + "contact-list?contactSource=\(source)&contactType=\(contactType)&searchText=\(searchText)&filterType=\(filter)&limit=\(limit)&page=\(page)"
      //  &hide=\(hide)
       // let path = API.shared.baseUrlV2 + "contact-list?contactSource=\(source))&searchText=\("Na")&filterType=\(filter)&limit=\(limit)&page=\(page)"
        print("contact->\(path)")
       // let parameter : Parameters =  ["Content-Type": "application/json"]
        let headerWithToken : HTTPHeaders =  ["Content-Type": "application/json",
                                       "userid": Defaults.shared.currentUser?.id ?? "",
                                       "deviceType": "1",
                                       "x-access-token": Defaults.shared.sessionToken ?? ""]
        let request = AF.request(path, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headerWithToken, interceptor: nil)
        
        loadingStatus = true
        request.response { response in
          //  print(response)
            switch (response.result){
            case .success:
                
                let json = try! JSONSerialization.jsonObject(with: response.data ?? Data(), options: [])
               print(json)
                guard let value =  json as? [[String : Any]] else {
                    self.hideLoader()
                    return }
                   
                if page == 1{
                    if self.selectedContactType == ContactType.mobile{
                        self.allmobileContactsForHide = [ContactResponse]()
                        self.mobileContacts = [ContactResponse]()
                        self.allmobileContacts = [ContactResponse]()
                    }else{
                        self.allemailContactsForHide = [ContactResponse]()
                        self.emailContacts = [ContactResponse]()
                    }
                }
                
                let contacts = Mapper<ContactResponse>().mapArray(JSONArray:value)
               
                if page == 1{
                    if self.selectedContactType == ContactType.mobile{
                        self.allmobileContactsForHide = [ContactResponse]()
                        self.mobileContacts = [ContactResponse]()
                        self.allmobileContacts = [ContactResponse]()
                    }else{
                        self.allemailContactsForHide = [ContactResponse]()
                        self.emailContacts = [ContactResponse]()
                    }
                }
                if self.selectedContactType == ContactType.mobile{
                    self.allmobileContactsForHide.append(contentsOf:contacts)
                    self.mobileContacts.append(contentsOf:contacts)

                    self.allmobileContacts = self.mobileContacts
                    if self.mobileContacts.count > 0{
                        self.contactPermitView.isHidden = true
                    }
                    DispatchQueue.main.async {
                        self.contactTableView.reloadData()
                    }
                }else{
                    self.allemailContactsForHide.append(contentsOf:contacts)
                    self.emailContacts.append(contentsOf:contacts.filter {$0.hide == hide})
                    
                    if self.emailContacts.count > 0{
                        self.contactPermitView.isHidden = true
                    }
                    DispatchQueue.main.async {
                        self.emailContactTableView.reloadData()
                    }
                }
                self.hideLoader()
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.5) {
                    self.loadingStatus = false
                }
               
                break
               
            case .failure(let error):
                print(error)
                self.hideLoader()
                break

                //failure code here
            }
        }

    }
    func hideContact(contact:ContactResponse,index:Int,hide:Bool = true){
        print(contact.toJSON())
        var isHide = "unhide"
        if hide{
            isHide = "unhide"
        }else{
            isHide = "hide"
        }
        let path = API.shared.baseUrlV2 + "contact-list/\(contact.Id ?? "")/user?action=\(isHide)"
        print(path)
        var request = URLRequest(url:URL(string:path)!)
        //some header examples
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Defaults.shared.currentUser?.id ?? "", forHTTPHeaderField: "userid")
        request.setValue(Defaults.shared.sessionToken ?? "", forHTTPHeaderField: "x-access-token")
        request.setValue("1", forHTTPHeaderField: "deviceType")
        //request.httpBody = data
        AF.request(request).responseJSON { response in
            print(response)
            switch (response.result) {
            case .success:
              //  self.showLoader()
               // self.mobileContacts.remove(at:index)
                if hide{
                    self.selectedFilter = ContactStatus.hidden
                }else{
                    self.selectedFilter = ContactStatus.all
                }
               // self.selectedFilter = ContactStatus.all
                self.getContactList(filter:self.selectedFilter,hide:hide)
                break
               
            case .failure(let error):
                print(error)
                break

                //failure code here
            }
        }
    }
    func inviteGuestViaMobile(data:Data){
        let path = API.shared.baseUrlV2 + "contact-list/mobile/status"
        print(path)
        var request = URLRequest(url:URL(string:path)!)
        //some header examples
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Defaults.shared.currentUser?.id ?? "", forHTTPHeaderField: "userid")
        request.setValue(Defaults.shared.sessionToken ?? "", forHTTPHeaderField: "x-access-token")
        request.setValue("1", forHTTPHeaderField: "deviceType")
        request.httpBody = data
        self.showLoader()
        AF.request(request).responseJSON { response in
            print(response)
            switch (response.result) {
            case .success:
               // self.getContactList()
                if let indexMobile = self.mobileContacts.firstIndex(where: {$0.Id == self.selectedContact?.Id}){
                    self.mobileContacts[indexMobile].status = ContactStatus.invited
                }
                if let indexAll = self.allmobileContacts.firstIndex(where: {$0.Id == self.selectedContact?.Id}){
                    self.allmobileContacts[indexAll].status = ContactStatus.invited
                }
                if let indexAllHidden = self.allmobileContactsForHide.firstIndex(where: {$0.Id == self.selectedContact?.Id}){
                    self.allmobileContactsForHide[indexAllHidden].status = ContactStatus.invited
                }
                if let indexMobile = self.emailContacts.firstIndex(where: {$0.Id == self.selectedContact?.Id}){
                    self.emailContacts[indexMobile].status = ContactStatus.invited
                }
                if let indexAllHidden = self.allemailContactsForHide.firstIndex(where: {$0.Id == self.selectedContact?.Id}){
                    self.allemailContactsForHide[indexAllHidden].status = ContactStatus.invited
                }
                self.emailContactTableView.reloadData()
                self.contactTableView.reloadData()
                self.hideLoader()
                break
               
            case .failure(let error):
                print(error)
                self.hideLoader()
                break

                //failure code here
            }
        }
    }
    func inviteGuest(data:Data){
        let path = API.shared.baseUrlV2 + "contact-list/invite-guest"
        print(path)
        var request = URLRequest(url:URL(string:path)!)
        //some header examples
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Defaults.shared.currentUser?.id ?? "", forHTTPHeaderField: "userid")
        request.setValue(Defaults.shared.sessionToken ?? "", forHTTPHeaderField: "x-access-token")
        request.setValue("1", forHTTPHeaderField: "deviceType")
        request.httpBody = data
        self.showLoader()
        AF.request(request).responseJSON { response in
            print(response)
            switch (response.result) {
            case .success:
               // self.getContactList()
                if let indexMobile = self.emailContacts.firstIndex(where: {$0.Id == self.selectedContact?.Id}){
                    self.emailContacts[indexMobile].status = ContactStatus.invited
                }
                if let indexAllHidden = self.allemailContactsForHide.firstIndex(where: {$0.Id == self.selectedContact?.Id}){
                    self.allemailContactsForHide[indexAllHidden].status = ContactStatus.invited
                }
                self.emailContactTableView.reloadData()
                self.hideLoader()
                break
               
            case .failure(let error):
                print(error)
                self.hideLoader()
                break

                //failure code here
            }
        }
    }
    // /api/contact-list/623d521766010bedccb2bfe7
    func deleteContact(contact:ContactResponse,isEmail:Bool = false,index:Int){
        let path = API.shared.baseUrlV2 + "contact-list/\(contact.Id ?? "")"
        print(path)
        var request = URLRequest(url:URL(string:path)!)
        //some header examples
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Defaults.shared.currentUser?.id ?? "", forHTTPHeaderField: "userid")
        request.setValue(Defaults.shared.sessionToken ?? "", forHTTPHeaderField: "x-access-token")
        request.setValue("1", forHTTPHeaderField: "deviceType")
       
        self.showLoader()
        AF.request(request).responseJSON { response in
            print(response)
            switch (response.result) {
            case .success:
                if isEmail{
                    self.emailContacts.remove(at:index)
                    self.emailContactTableView.reloadData()
                }else{
                    self.mobileContacts.remove(at:index)
                    self.contactTableView.reloadData()
                }
                self.hideLoader()
                break
               
            case .failure(let error):
                print(error)
                self.hideLoader()
                break

                //failure code here
            }
        }
    }
    func validateInvite(contact:ContactResponse, completion: @escaping (_ success: Bool?) -> ()){
        self.selectedContact = nil
        let contactListids = [contact.Id ?? ""]
        if selectedContactType == ContactType.mobile{
            let inviteDetails = InviteDetails(content:contact.textLink ?? "", invitedFrom: "mobile", contactListIds: contactListids)
            let jsonEncoder = JSONEncoder()
            do {
                let jsonData = try jsonEncoder.encode(inviteDetails)
                self.inviteData = jsonData
                completion(true)
               
            } catch {
                print("error")
            }
        }else{
          //  let inviteDetails = InviteEmailDetails(emailTitle:contact.textLink ?? "", emailMessage: "email", contactListIds: contactListids)
            let inviteDetails = InviteDetails(content:contact.emailLink ?? "",subject:"Quickcam Invitation" ,invitedFrom: "mobile", contactListIds: contactListids)
            print("inviteDetails")
            print(inviteDetails)
            print(contact.toJSON())
            let jsonEncoder = JSONEncoder()
            do {
                let jsonData = try jsonEncoder.encode(inviteDetails)
                self.inviteData = jsonData
                completion(true)
               
            } catch {
                print("error")
            }
        }
        
        
    }
    @IBAction func doNotShowAgainButtonClicked(sender: UIButton) {
        print("Defaults.shared.isContactConfirmPopUpChecked")
        print("Before")
        print(Defaults.shared.isContactConfirmPopUpChecked)
        btnDoNotShowAgain.isSelected = !btnDoNotShowAgain.isSelected
        Defaults.shared.isContactConfirmPopUpChecked = btnDoNotShowAgain.isSelected
        print("After")
        print(Defaults.shared.isContactConfirmPopUpChecked)
    }
    
    @IBAction func okayButtonClicked(sender: UIButton) {
        if selectedContactType == ContactType.mobile{
            self.inviteGuestViaMobile(data:self.inviteData ?? Data())
        }else{
            self.inviteGuestViaMobile(data:self.inviteData ?? Data())
           // self.inviteGuest(data:self.inviteData ?? Data())
        }
        
        self.contactSentConfirmPopup.isHidden = true
    }
    
    @IBAction func cancelButtonClicked(sender: UIButton) {
        self.contactSentConfirmPopup.isHidden = true
    }
    @IBAction func inviteAgainYesButtonClicked(sender: UIButton) {
        self.didPressButton(PhoneContact(), mobileContact: self.selectedContact,reInvite:false)
        self.inviteAgainpopup.isHidden = true
    }
    
    @IBAction func inviteAgainCancelButtonClicked(sender: UIButton) {
        self.inviteAgainpopup.isHidden = true
    }
    @IBAction func filterButtonClicked(sender: UIButton) {
        if filterOptionView.isHidden{
            filterOptionView.isHidden = false
        }else{
            filterOptionView.isHidden = true
        }
    }
    func hasContactPermission() -> Bool {
        var hasPermission = false
        
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts){
        case .authorized: //access contacts
            hasPermission = true
            break
        case .denied, .notDetermined:
            hasPermission = false
            break //request permission
        case .restricted:
            hasPermission = false
            break
        @unknown default:
            hasPermission = true
            break
        }
        
        
        return hasPermission
    }
    func showContactPermission(){
        if !hasContactPermission() {
            let alertController = UIAlertController(title: "Contact Permission Required", message: "Please enable contact access permissions in settings.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                //Redirect to Settings app
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(cancelAction)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
   
    @IBAction func syncButtonClicked(sender: UIButton) {
        filterOptionView.isHidden = true
        
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts){
        case .authorized: //access contacts
            self.showLoader()
            self.loadContacts(filter: self.filter)
            break
        case .denied, .notDetermined:
            showContactPermission()
            break //request permission
        case .restricted:
            showContactPermission()
            break
        @unknown default:
            break
        }
       
       //ContactPermission()
    }
    @IBAction func filterOptionClicked(sender: UIButton) {
        filterOptionView.isHidden = true
        switch sender.tag {
        case 1:
            self.selectedFilter = ContactStatus.all
           // self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.all)
            break
        case 2:
            self.selectedFilter = ContactStatus.recent
           // self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.recent)
            break
        case 3:
            self.selectedFilter = ContactStatus.pending
           // self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.pending)
            break
        case 4:
            self.selectedFilter = ContactStatus.invited
            //self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.invited)
            break
        case 5:
            
            if selectedContactType == ContactType.mobile{
                self.mobileContacts = [ContactResponse]()
                self.contactTableView.reloadData()
            }else{
                self.emailContacts = [ContactResponse]()
                self.emailContactTableView.reloadData()
            }
           
            break
        case 6:
            self.selectedFilter = ContactStatus.signedup
           // self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.signedup)
            break
        case 7:
            self.selectedFilter = ContactStatus.subscriber
           // self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.subscriber)
            break
        case 8:
            self.selectedFilter = ContactStatus.optout
          //  self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.optout)
            break
        case 9:
            //hidden
            self.selectedFilter = ContactStatus.hidden
          //  self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.hidden,hide:true)
            break
        default:
            mobileContacts = allmobileContacts
            phoneContacts = allphoneContacts
            mailContacts = allmailContacts
            contactTableView.reloadData()
            break
        }
    }
    func setPreviewData(){
        if let referralPage = Defaults.shared.currentUser?.referralPage {
            self.getLinkPreview(link:referralPage) { image in
                
            }
        }
    }
    func getLinkPreview(link: String, completionHandler: @escaping (UIImage) -> Void) {
        
        
        OGDataProvider.shared.fetchOGData(urlString: link) { [weak self] ogData, error in
            guard let `self` = self else { return }
            if let _ = error {
                return
            }
            DispatchQueue.main.async {
                self.lblpreviewUrl.text = link
              //  self.previewImageview.layer.cornerRadius = self.previewImageview.bounds.width / 2
            
//                self.lblpreviewText.text = self.txtLinkWithCheckOut
            }
//            if ogData.imageUrl != nil {
               self.previewImageview.sd_setImage(with: ogData.imageUrl, placeholderImage: R.image.user_placeholder())
           
//            }
        }
        /* if #available(iOS 13.0, *) {
        guard let url = URL(string: link) else {
            return
        }
            let provider = LPMetadataProvider()
            provider.startFetchingMetadata(for: url) { [weak self] metaData, error in
                guard let `self` = self else {
                    return
                }
                guard let data = metaData, error == nil else {
                    if let previewImage = R.image.ssuQuickCam() {
                        completionHandler(previewImage)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.lblpreviewUrl.text = data.url?.absoluteString ?? ""
                    self.lblpreviewText.text = data.title ?? ""
                }
                self.getImage(data: data) { [weak self] image in
                    guard self != nil else { return }
                    DispatchQueue.main.async {
                        self?.previewImageview.image = image
                        completionHandler(image)
                    }
                }
            }
        }*/
    }
  /*  @available(iOS 13.0, *)
    func getImage(data: LPLinkMetadata, handler: @escaping (UIImage) -> Void) {
        data.iconProvider?.loadDataRepresentation(forTypeIdentifier: data.iconProvider!.registeredTypeIdentifiers[0], completionHandler: { (data, error) in
            guard let imageData = data else {
                return
            }
            if error != nil {
                self.showAlert(alertMessage: error?.localizedDescription ?? "Error")
            }
            if let previewImage = UIImage(data: imageData) {
                handler(previewImage)
            }
        })
    } */
    
    @IBAction func textMessageSelected(sender: UIButton) {
        searchBar.showsCancelButton = false
        if !isSelectSMS {
            isSelectSMS = true
            pageNo = 3
            setupPage()
            return
        }
        textMessageButton.setTitleColor(ApplicationSettings.appPrimaryColor, for: .normal)
        textMessageSeperatorView.backgroundColor = ApplicationSettings.appPrimaryColor
        textMessageSeperatorViewHeight.constant = 3.0
        
        emailButton.setTitleColor(UIColor(hexString: "676767"), for: .normal)
        emailSeperatorView.backgroundColor = UIColor(hexString: "676767")
        emailSeperatorViewHeight.constant = 1.0
        selectedContactType = ContactType.mobile
        self.emailContactTableView.isHidden = true
        self.contactTableView.isHidden = false
        if mobileContacts.count == 0{
            self.showLoader()
            self.getContactList(page: 1 ,filter: self.selectedFilter)
        }
    }
    @IBAction func emailSelected(sender: UIButton) {
        searchBar.showsCancelButton = false
        if isSelectSMS {
            isSelectSMS = false
            pageNo = 3
            setupPage()
            return
        }
        emailButton.setTitleColor(ApplicationSettings.appPrimaryColor, for: .normal)
        emailSeperatorView.backgroundColor = ApplicationSettings.appPrimaryColor
        emailSeperatorViewHeight.constant = 3.0
        
        textMessageButton.setTitleColor(UIColor(hexString: "676767"), for: .normal)
        textMessageSeperatorView.backgroundColor = UIColor(hexString: "676767")
        textMessageSeperatorViewHeight.constant = 1.0
        selectedContactType = ContactType.email
        self.emailContactTableView.isHidden = false
        self.contactTableView.isHidden = true
        if emailContacts.count == 0{
            self.showLoader()
            self.getContactList(page: 1 ,filter: self.selectedFilter)
        }
        
    }
    @IBAction func socialShareCloseClick(sender: UIButton) {
        self.socialSharePopupView.isHidden = true
    }
    @IBAction func socialShareButtonClick(sender: UIButton) {
        if sender.tag == 1{
            //Message
        }else if sender.tag == 2{
            //facebook Messanger
        }else if sender.tag == 3{
            //Instagram
        }else if sender.tag == 4{
            //Whatsapp
        }else if sender.tag == 5{
            //Snapchat
        }else if sender.tag == 6{
            //Facebook
        }else if sender.tag == 7{
            //Twitter
        }else if sender.tag == 8{
            //Skype
        }else if sender.tag == 9{
            //Telegram
        }else if sender.tag == 10{
            //Wechat
        }
    }
    // MARK: - tableview Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == itemsTableView{
            return UITableView.automaticDimension
        } else {
            return 75
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {

        if tableView == itemsTableView{
            return 1
        } else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == itemsTableView{
            if isSelectSMS {
                return self.smsMsgListing?.list.count ?? 0
            } else {
                return self.emailMsgListing?.list.count ?? 0
            }
        }else if tableView == emailContactTableView{
            return emailContacts.count
        } else {
            if section == 0 {
              return mobileContacts.count
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
            }else if section == 1 {
                if mailContacts.count > 0 {
                    let label = cutomHeaderView(title: "Contact Emails")
                    view.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)
//                    let bottomLine = CALayer()
//                    bottomLine.frame = CGRect(x: 0, y: 34.5, width: self.view.frame.size.width, height: 0.5)
//                    bottomLine.backgroundColor = UIColor.init(hexString: "#D4D4D4").cgColor
//                    view.layer.addSublayer(bottomLine)
                    view.addSubview(label)
                }
            }
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == itemsTableView{
            let cell:messageTitleCell = self.itemsTableView.dequeueReusableCell(withIdentifier: ContactImportVC.CELL_IDENTIFIER) as! messageTitleCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            var item : Titletext?
            if isSelectSMS {
                item = self.smsMsgListing?.list[indexPath.row]
                cell.setText(text: item?.content ?? "")
                cell.setSeletedState(state: selectedTitleRow == indexPath.row, details: "")
                print("isselectsms")
            } else {
                item = self.emailMsgListing?.list[indexPath.row]
                cell.setText(text: item?.content ?? "")
                cell.setSeletedState(state: selectedTitleRow == indexPath.row, details: item?.subject ?? "")
            }
          
            cell.handleRatioButtonAction = { (isSelected) in
                if isSelected {
                    self.selectedTitleRow = indexPath.row
                } else {
                    self.selectedTitleRow = -1
                }
                self.itemsTableView.reloadData()
            }
            if selectedTitleRow == indexPath.row {
                //set data to share
                self.txtLinkWithCheckOut = item?.content ?? ""
                self.txtDetailForEmail = item?.subject ?? ""
                let finalText = "\(txtLinkWithCheckOut)"
                txtLinkWithCheckOut = finalText
                self.lblpreviewText.text = self.txtLinkWithCheckOut
            }
            return cell

        }  else if tableView == emailContactTableView {
            let cell:contactTableViewCell = self.contactTableView.dequeueReusableCell(withIdentifier: ContactImportVC.CELL_IDENTIFIER_CONTACT) as! contactTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.cellDelegate = self
            //
          /*  let contact = mailContacts[indexPath.row] as PhoneContact
            cell.lblDisplayName.text = contact.name ?? ""
            cell.lblNumberEmail.text = contact.email[0]
            if let imagedata =  contact.avatarData {
                let avtar = UIImage(data:imagedata,scale:1.0)
                cell.contactImage.image = avtar
            }else {
                cell.contactImage.image = UIImage.init(named: "User_placeholder")
            }
            cell.phoneContactObj = contact */
            
            //
            let contact = emailContacts[indexPath.row]
            cell.lblDisplayName.text = contact.name ?? ""
            cell.lblNumberEmail.text = contact.email ?? ""
            cell.contactImage.image = UIImage.init(named: "User_placeholder")
            cell.mobileContactObj = contact
           
            if contact.status == ContactStatus.pending {
                cell.inviteBtn.isHidden = false
                cell.inviteBtn.setTitle("Invite", for: .normal)
                cell.inviteBtn.backgroundColor = UIColor(hex6:0xE9F1FF)
                cell.inviteBtn.setTitleColor(UIColor(hex6:0x4285F4), for: .normal)
                
            }else if contact.status == ContactStatus.subscriber {
                cell.inviteBtn.isHidden = true
            }else{
                cell.inviteBtn.isHidden = false
                cell.inviteBtn.setTitle("Invited", for: .normal)
                cell.inviteBtn.backgroundColor = UIColor(hex6:0x4285F4)
                cell.inviteBtn.setTitleColor(.white, for: .normal)
            }
            return cell
        }else {
            let cell:contactTableViewCell = self.contactTableView.dequeueReusableCell(withIdentifier: ContactImportVC.CELL_IDENTIFIER_CONTACT) as! contactTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.cellDelegate = self
            if indexPath.section == 0 {
               /* let contact = phoneContacts[indexPath.row] as PhoneContact
                cell.lblDisplayName.text = contact.name ?? ""
                cell.lblNumberEmail.text = contact.phoneNumber[0]
                if let imagedata =  contact.avatarData {
                    let avtar = UIImage(data:imagedata,scale:1.0)
                    cell.contactImage.image = avtar
                }else {
                    cell.contactImage.image = UIImage.init(named: "User_placeholder")
                }
                cell.phoneContactObj = contact */
                
                let contact = mobileContacts[indexPath.row]
                cell.lblDisplayName.text = contact.name ?? ""
                cell.lblNumberEmail.text = contact.mobile
                cell.contactImage.image = UIImage.init(named: "User_placeholder")
                cell.mobileContactObj = contact
               
                if contact.status == ContactStatus.pending{
                    cell.inviteBtn.isHidden = false
                    cell.inviteBtn.setTitle("Invite", for: .normal)
                    cell.inviteBtn.backgroundColor = UIColor(hex6:0xE9F1FF)
                    cell.inviteBtn.setTitleColor(UIColor(hex6:0x4285F4), for: .normal)
                    
                }else if contact.status == ContactStatus.subscriber{
                    cell.inviteBtn.isHidden = true
                }else{
                    cell.inviteBtn.isHidden = false
                    cell.inviteBtn.setTitle("Invited", for: .normal)
                    cell.inviteBtn.backgroundColor = UIColor(hex6:0x4285F4)
                    cell.inviteBtn.setTitleColor(.white, for: .normal)
                }
                
            }
            else {
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
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == itemsTableView{
            return false
        }else{
            return true
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == itemsTableView {
            if selectedTitleRow != indexPath.row {
                selectedTitleRow = indexPath.row
//                let item = self.listingResponse?.list[indexPath.row]
//                if item != nil {
//                    self.txtLinkWithCheckOut = item?.content ?? ""
//                }
                itemsTableView.reloadData()
//                if txtLinkWithCheckOut != "" {
//                    let finalText = "\(greetingMessage) \(txtLinkWithCheckOut)"
//                    txtLinkWithCheckOut = finalText
//                    print(txtLinkWithCheckOut)
//                }
            }
        } else{
            self.view.endEditing(true)
        }
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if tableView == itemsTableView{
            return UISwipeActionsConfiguration(actions: [])
            
        }else if tableView == emailContactTableView{
            if indexPath.section == 1{
                return UISwipeActionsConfiguration(actions: [])
            }
            let ishide = self.emailContacts[indexPath.row].hide ?? false
            let editAction = UIContextualAction(style: .normal, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                  
                self.hideContact(contact:self.emailContacts[indexPath.row],index:indexPath.row,hide:ishide)
                   success(true)
               })
            let title = !ishide ? "Hide" : "Unhide"
            editAction.image = UISwipeActionsConfiguration.makeTitledImage(
               image: #imageLiteral(resourceName: "hide"),
               title: title)
             
            editAction.backgroundColor = #colorLiteral(red: 0.9156094193, green: 0.945283711, blue: 1, alpha: 1)
            let swipeActions = UISwipeActionsConfiguration(actions: [editAction])

            return swipeActions
        }else{
            if indexPath.section == 1{
                return UISwipeActionsConfiguration(actions: [])
            }
            let ishide = self.mobileContacts[indexPath.row].hide ?? false
            let editAction = UIContextualAction(style: .normal, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                  
                self.hideContact(contact:self.mobileContacts[indexPath.row],index:indexPath.row,hide:ishide)
                   success(true)
               })
              
             let title = !ishide ? "Hide" : "Unhide"
             editAction.image = UISwipeActionsConfiguration.makeTitledImage(
                image: #imageLiteral(resourceName: "hide"),
                title: title)
             
            editAction.backgroundColor = #colorLiteral(red: 0.9156094193, green: 0.945283711, blue: 1, alpha: 1)
            let swipeActions = UISwipeActionsConfiguration(actions: [editAction])

            return swipeActions
        }
        
    }
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
           if let indexPath = configuration.identifier as? IndexPath, let cell = tableView.cellForRow(at: indexPath)  as? contactTableViewCell{
            
              let parameters = UIPreviewParameters()
              parameters.backgroundColor = .clear
            return UITargetedPreview(view: cell.contentView, parameters: parameters)
            
           } else{
                 return nil
           }
     
           
    }
      @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in
                return UIMenu(title: "", children: [
                    UIAction(title: "Delete", image: UIImage(systemName: "")) { action in
                        
                        if Defaults.shared.isDoNotShowAgainDeleteContactPopup{
                            self.deleteContactConfirmationView.isHidden = true
                            if tableView == self.emailContactTableView{
                                let contact = self.emailContacts[indexPath.row]
                                print(contact.email ?? "")
                                self.deleteContact(contact: contact, isEmail: true, index: indexPath.row)
                                
                            }else if tableView == self.contactTableView{
                                let contact = self.mobileContacts[indexPath.row]
                                print(contact.mobile ?? "")
                                self.deleteContact(contact: contact, isEmail: false, index: indexPath.row)
                            }
                        }else{
                            self.deleteContactConfirmationView.tag = indexPath.row
                            self.deleteContactConfirmationView.isHidden = false
                        }
                    },UIAction(title: "Edit", image: UIImage(systemName: "")) { action in
                        if tableView == self.emailContactTableView{
                            let contact = self.emailContacts[indexPath.row]
                            if let contactEdit = R.storyboard.contactWizardwithAboutUs.contactEditVC() {
                                contactEdit.contact = contact
                                contactEdit.isEmail = true
                                contactEdit.delegate = self
                                
                                self.present(contactEdit, animated: true, completion: nil)
                            }
                            print(contact.email ?? "")
                        }else if tableView == self.contactTableView{
                            let contact = self.mobileContacts[indexPath.row]
                            if let contactEdit = R.storyboard.contactWizardwithAboutUs.contactEditVC() {
                                contactEdit.contact = contact
                                contactEdit.isEmail = false
                                contactEdit.delegate = self
                                self.present(contactEdit, animated: true, completion: nil)
                            }
                        }
                        
                       
                       
                        
                    }
                ])
    }
        
         
      
    }
    func didFinishEdit(contact: ContactResponse?) {
        
        if let indexMobile = self.mobileContacts.firstIndex(where: {$0.Id == contact?.Id}){
            self.mobileContacts[indexMobile].name = contact?.name
        }
        if let indexMobile = self.emailContacts.firstIndex(where: {$0.Id == contact?.Id}){
            self.emailContacts[indexMobile].name = contact?.name
        }
        self.contactTableView.reloadData()
        self.emailContactTableView.reloadData()
    }
    
//    MARK: - Creating Alert For User Text Enter
    //not used
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
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        if searchBar.text == ""{
            searchBar.resignFirstResponder()
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
         self.searchBar.showsCancelButton = true
         self.filterOptionView.isHidden = true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //print(searchText)
        self.filterOptionView.isHidden = true
        self.getContactList( page:1,filter:self.selectedFilter)
        return

    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
        
     //   mobileContacts = allmobileContacts
      //  mailContacts = allmailContacts;
      //  contactTableView.reloadData()
        self.getContactList( page:1,filter:self.selectedFilter)
        
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
            pageNo = 2
            self.setupPage()
        }else if sender.tag == 2 {
            pageNo = 3
            self.setupPage()
        }else if sender.tag == 3 {
            pageNo = 4
            self.setupPage()
        }
    }
    
    @IBAction func nextClick(_ sender: UIButton) {
        if sender.tag == 1 {
            pageNo = 4
            self.setupPage()
        }
       else if sender.tag == 2 {
           pageNo = 5
           self.setupPage()
           if isSelectSMS {
               //emailSelected(sender: UIButton())
           } else {
               emailSelected(sender: UIButton())
           }
//          if isSelectSMS {
//               pageNo = 4
//               self.setupPage()
//           }else{
//               navigationController?.popViewController(animated: true)
//           }
        }else if sender.tag == 3 {
            let referSuccess = ReferSuccessVC(nibName: R.nib.referSuccessVC.name, bundle: nil)
            referSuccess.callback = { message in
                self.pageNo = 1
                self.setupPage()
            }
            navigationController?.pushViewController(referSuccess, animated: true)
            //navigationController?.popViewController(animated: true)
        }
        
    }
    @IBAction func mainOptionsClick(_ sender: UIButton) {
        if sender.tag == 1 {
            isSelectSMS = false
            pageNo = 3
            self.setupPage()
        }else if sender.tag == 2 {
            isSelectSMS = true
            pageNo = 3
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
    @IBAction func btnCopyReferralLink(_ sender: UIButton) {
        if let channelId = Defaults.shared.currentUser?.channelId {
            UIPasteboard.general.string = "\(websiteUrl)/\(channelId)"
            DispatchQueue.runOnMainThread {
                Utils.appDelegate?.window?.makeToast(R.string.localizable.linkCopied())
            }
        }
    }
    @IBAction func btnQuickCamAppAction(_ sender: UIButton) {
    }
    @IBAction func btnBusinessDashboardAction(_ sender: UIButton) {
        businessDashbardConfirmPopupView.isHidden = false
    }
    @IBAction func btnTextShareAction(_ sender: UIButton) {
        self.shareType = ShareType.textShare
        isSelectSMS = true
        pageNo = 3
        self.setupPage()
        self.itemsTableView.reloadData()
    }
    @IBAction func btnQRCodeShareAction(_ sender: UIButton) {
        print("Click on QR")
        self.shareType = ShareType.qrcode
        if let qrViewController = R.storyboard.editProfileViewController.qrCodeViewController() {
            navigationController?.pushViewController(qrViewController, animated: true)
        }
    }
    @IBAction func btnManualEmailAction(_ sender: UIButton) {
        self.shareType = ShareType.email
        isSelectSMS = false
        pageNo = 3
        self.setupPage()
        self.itemsTableView.reloadData()
    }
    @IBAction func btnSocialSharingAction(_ sender: UIButton) {
        self.shareType = ShareType.socialShare
        isSelectSMS = true
        pageNo = 3
        self.setupPage()
        self.itemsTableView.reloadData()
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
//        if shareType == ShareType.socialShare {
//            socialSharePopupView.isHidden = false
//            return
//        }
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
    @IBAction func businessDahboardConfirmPopupOkButtonClicked(_ sender: UIButton) {
        
//        if let token = Defaults.shared.sessionToken {
//        let urlString = "\(websiteUrl)/redirect?token=\(token)"
        let urlString = "\(websiteUrl)/share-wizard"
        guard let url = URL(string: urlString) else {
                return
            }
            presentSafariBrowser(url: url)
//        }
        Defaults.shared.callHapticFeedback(isHeavy: false)
        Defaults.shared.addEventWithName(eventName: Constant.EventName.cam_Bdashboard)
        businessDashbardConfirmPopupView.isHidden = true
    }
    @IBAction func doNotShowAgainBusinessCenterOpenPopupClicked(_ sender: UIButton) {
        btnDoNotShowAgainBusinessConfirmPopup.isSelected = !btnDoNotShowAgainBusinessConfirmPopup.isSelected
        Defaults.shared.isShowAllPopUpChecked = false
        Defaults.shared.isDoNotShowAgainOpenBusinessCenterPopup = btnDoNotShowAgainBusinessConfirmPopup.isSelected
    }
    @IBAction func didTapCloseButtonBusiessDashboard(_ sender: UIButton) {
        businessDashbardConfirmPopupView.isHidden = true
    }
    func cutomHeaderView(title:String) -> UILabel {
        let label = UILabel()
        label.frame = CGRect(x: 15,y: 6,width: 200,height: 0)
        label.text = title
        label.textAlignment = .natural
        label.textColor = UIColor(red:0.36, green:0.36, blue:0.36, alpha:1.0)
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }
    
    func openMessageComposer(mobileContact:ContactResponse?,reInvite :Bool = false){
        if let mobilecontact = mobileContact{
            self.selectedContact = mobilecontact
            if reInvite{
                self.inviteAgainpopup.isHidden = false
                return
            }
            
            let phoneNum = mobilecontact.mobile ?? ""
            let urlString = self.txtLinkWithCheckOut
//            let imageV = self.profileView.toImage()
//            let urlwithString = urlString + "\n" + "\n" + " \(mobilecontact.textLink ?? "")"
            
            if selectedContactType == ContactType.mobile{
                if !MFMessageComposeViewController.canSendText() {
                        //showAlert("Text services are not available")
                        return
                }
                let reflink = "\(websiteUrl)/\(Defaults.shared.currentUser?.channelId ?? "")"
                 let json = """
                 {
                     "contactId":"\(mobilecontact.Id ?? "")",
                     "refType":"text"
                 }
                 """
                let str = json.toBase64()
                let urlwithString = urlString + "\n" + "\n" + reflink + "?refCode=\(str)"
                let textComposer = MFMessageComposeViewController()
                textComposer.messageComposeDelegate = self
                let recipients:[String] = [phoneNum]
                textComposer.body = urlwithString
                textComposer.recipients = recipients

              /*  if MFMessageComposeViewController.canSendAttachments() {
                    let imageData = imageV.jpegData(compressionQuality: 1.0)
                    textComposer.addAttachmentData(imageData!, typeIdentifier: "image/jpg", filename: "photo.jpg")
                } */

                present(textComposer, animated: true)
            
            }else{
                if MFMailComposeViewController.canSendMail() {
                    let reflink = "\(websiteUrl)/\(Defaults.shared.currentUser?.channelId ?? "")"
                     let json = """
                     {
                         "contactId":"\(mobilecontact.Id ?? "")",
                         "refType":"email"
                     }
                     """
                    let str = json.toBase64()
                    let urlwithString = urlString + "\n" + "\n" + reflink + "?refCode=\(str)"
                    
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients([mobileContact?.email ?? ""])
                    mail.setSubject(self.txtDetailForEmail)
                    mail.setMessageBody(urlwithString, isHTML: false)
                    
                   /* let imageData = imageV.jpegData(compressionQuality: 1.0)
                    mail.addAttachmentData(imageData!, mimeType: "image/jpg", fileName: "photo.jpg") */
                    present(mail, animated: true)
                    
                    // Show third party email composer if default Mail app is not present
                }
            }
            
        }
    }
    func didPressButton(_ contact: PhoneContact, mobileContact:ContactResponse?,reInvite :Bool = false) {
        if let mobilecontact = mobileContact{
            self.selectedContact = mobilecontact
            if reInvite{
                self.inviteAgainpopup.isHidden = false
                return
            }
            // not used
           /* let phoneNum = mobilecontact.mobile ?? ""
            let urlString = self.txtLinkWithCheckOut
            //            let imageV = self.profileView.toImage()
            //            let urlwithString = urlString + "\n" + "\n" + " \(mobilecontact.textLink ?? "")"
            
            let reflink = "\(websiteUrl)/\(Defaults.shared.currentUser?.channelId ?? "")"
             let json = """
             {
                 "contactId":"\(mobilecontact.Id ?? "")",
                 "refType":"text"
             }
             """
            
            let str = json.toBase64()
            let urlwithString = urlString + "\n" + "\n" + reflink + "?refCode=\(str)"
            if !MFMessageComposeViewController.canSendText() {
                //showAlert("Text services are not available")
                return
            }

            let textComposer = MFMessageComposeViewController()
            textComposer.messageComposeDelegate = self
            let recipients:[String] = [phoneNum]
            textComposer.body = urlwithString
            textComposer.recipients = recipients
            */
            /*if MFMessageComposeViewController.canSendAttachments() {
                let imageData = imageV.jpegData(compressionQuality: 1.0)
                textComposer.addAttachmentData(imageData!, typeIdentifier: "image/jpg", filename: "photo.jpg")
            }*/
            
            self.validateInvite(contact:mobilecontact, completion: { success in
                if success ?? false{
                    self.openMessageComposer(mobileContact:mobilecontact,reInvite:reInvite)
                }
            })

        }else{
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
                    textComposer.delegate = self
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

    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        print(result)
        if result == .sent{
            self.contactSentConfirmPopup.isHidden = false
          /*  if Defaults.shared.isContactConfirmPopUpChecked{
                self.contactSentConfirmPopup.isHidden = true
            }else{
                self.contactSentConfirmPopup.isHidden = false
            } */
          //  self.inviteGuestViaMobile(data:self.inviteData ?? Data())
        }else if result == .cancelled || result == .failed{
           // self.selectedContact?.status = ContactStatus.invited
        }
        controller.dismiss(animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Swift.Error?) {
        if result == .sent{
            self.contactSentConfirmPopup.isHidden = false
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
   
    @IBAction func deleteContactDoNotShowClick(_ sender: UIButton) {
        
        deleteContactDoNotShowButton.isSelected = !deleteContactDoNotShowButton.isSelected
        Defaults.shared.isDoNotShowAgainDeleteContactPopup = deleteContactDoNotShowButton.isSelected
    }
    @IBAction func deleteContactYesClick(_ sender: UIButton) {
        deleteContactConfirmationView.isHidden = true
        if selectedContactType == ContactType.mobile{
            let contact = self.mobileContacts[deleteContactConfirmationView.tag]
            print(contact.mobile ?? "")
            self.deleteContact(contact: contact, isEmail: false, index: deleteContactConfirmationView.tag)
        }else{
            let contact = self.emailContacts[deleteContactConfirmationView.tag]
            print(contact.mobile ?? "")
            self.deleteContact(contact: contact, isEmail: true, index: deleteContactConfirmationView.tag)
        }
    }
    @IBAction func deleteContactNoClick(_ sender: UIButton) {
        deleteContactConfirmationView.isHidden = true
    }

}
extension ContactImportVC:UIScrollViewDelegate{
    //Pagination
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.filterOptionView.isHidden = true
       
        /*     let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
         if (actualPosition.y > 0){
            // Dragging down
            UIView.animate(withDuration: 0.5, animations: {
                self.segmentViewHeight.constant = 84.0
                self.stepViewHeight.constant = 50.0
                    self.view.layoutIfNeeded()
            })
        }else{
            // Dragging up
            UIView.animate(withDuration: 0.5, animations: {
                self.segmentViewHeight.constant = 0.0
                self.stepViewHeight.constant = 0.0
                    self.view.layoutIfNeeded()
            })
        }
        
        if (self.lastContentOffset > scrollView.contentOffset.y) {
                // move up
                UIView.animate(withDuration: 0.5, animations: {
                    self.segmentViewHeight.constant = 84.0
                    self.stepViewHeight.constant = 50.0
                        self.view.layoutIfNeeded()
                })
            }
            else if (self.lastContentOffset < scrollView.contentOffset.y) {
               // move down
                UIView.animate(withDuration: 0.5, animations: {
                    self.segmentViewHeight.constant = 0.0
                    self.stepViewHeight.constant = 0.0
                        self.view.layoutIfNeeded()
                })
            }

            // update the new position acquired
            self.lastContentOffset = scrollView.contentOffset.y */
    }
    /*  func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView == contactTableView || scrollView == emailContactTableView{
            if segmentViewHeight.constant == 84.0{
                UIView.animate(withDuration: 0.5, animations: {
                    self.segmentViewHeight.constant = 0.0
                    self.stepViewHeight.constant = 0.0
                        self.view.layoutIfNeeded()
                })
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == contactTableView || scrollView == emailContactTableView{
            if segmentViewHeight.constant == 0.0{
                UIView.animate(withDuration: 0.0, animations: {
                    self.segmentViewHeight.constant = 84.0
                    self.stepViewHeight.constant = 50.0
                        self.view.layoutIfNeeded()
                })
            }
        }
    }
     */
     func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == contactTableView || scrollView == emailContactTableView{
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            print(offsetY >= contentHeight - scrollView.frame.height)
            print(!loadingStatus)
            if (offsetY >= contentHeight - scrollView.frame.height) && !loadingStatus {
              //  self.showLoader()
                let page = (selectedContactType == ContactType.mobile) ? self.mobileContacts.count : self.emailContacts.count
                self.getContactList(page: page, filter: self.selectedFilter)
            }
        }
        
    }
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == contactTableView || scrollView == emailContactTableView{
         /*  let offsetY = scrollView.contentOffset.y
            print("offsetY \(offsetY)")
            if offsetY <= 84.0 + 50.0{
                segmentViewHeight.constant = 84.0 - offsetY
                if offsetY > 84.0 && segmentViewHeight.constant == 0{
                    stepViewHeight.constant = 50.0 - offsetY - 84
                }else{
                    stepViewHeight.constant = 50.0
                }
            }else{
                segmentViewHeight.constant = 0.0
                stepViewHeight.constant = 0.0
            }
            */
            if self.loadingStatus{
                return
            }
        if (self.lastContentOffset > scrollView.contentOffset.y) {
                // move up
                UIView.animate(withDuration: 0.5, animations: {
                    self.segmentViewHeight.constant = 84.0
                    self.stepViewHeight.constant = 50.0
                       // self.view.layoutIfNeeded()
                })
            }
            else if (self.lastContentOffset < scrollView.contentOffset.y) {
               // move down
                UIView.animate(withDuration: 0.5, animations: {
                    self.segmentViewHeight.constant = 0.0
                    self.stepViewHeight.constant = 0.0
                       // self.view.layoutIfNeeded()
                })
            }

            // update the new position acquired
            self.lastContentOffset = scrollView.contentOffset.y //
             
        }
      
    }
}
extension UISwipeActionsConfiguration {

    public static func makeTitledImage(
        image: UIImage?,
        title: String,
        textColor: UIColor = #colorLiteral(red: 0.6344200969, green: 0.6471487284, blue: 0.6713684797, alpha: 1),
        font: UIFont = .systemFont(ofSize: 14),
        size: CGSize = .init(width: 50, height: 50)
    ) -> UIImage? {
        
        /// Create attributed string attachment with image
        let attachment = NSTextAttachment()
        attachment.image = image
        let imageString = NSAttributedString(attachment: attachment)
        
        /// Create attributed string with title
        let text = NSAttributedString(
            string: "\n\(title)",
            attributes: [
                .foregroundColor: textColor,
                .font: font
            ]
        )
        
        /// Merge two attributed strings
        let mergedText = NSMutableAttributedString()
        mergedText.append(imageString)
        mergedText.append(text)
        
        /// Create label and append that merged attributed string
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        label.textAlignment = .center
        label.numberOfLines = 2
        label.attributedText = mergedText
       // label.backgroundColor = .blue
        
        /// Create image from that label
        let renderer = UIGraphicsImageRenderer(bounds: label.bounds)
        let image = renderer.image { rendererContext in
            label.layer.render(in: rendererContext.cgContext)
        }
        
        /// Convert it to UIImage and return
        if let cgImage = image.cgImage {
            return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        }
        
        return nil
    }
}
