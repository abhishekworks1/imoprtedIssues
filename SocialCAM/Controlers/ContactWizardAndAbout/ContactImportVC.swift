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
import FBSDKShareKit
import SCSDKCreativeKit
import Toast_Swift

enum ShareType:Int{
    case textShare = 1
    case qrcode = 2
    case email = 3
    case socialShare = 4
    
}
struct ContactGroup{
    var contacts = [ContactResponse]()
    var char:String?
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
class ContactImportVC: UIViewController, UITableViewDelegate, UITableViewDataSource, contactCelldelegate , MFMessageComposeViewControllerDelegate , MFMailComposeViewControllerDelegate , UISearchBarDelegate, UINavigationControllerDelegate,ContactImportDelegate{
    
    var shareType:ShareType = ShareType.textShare
    @IBOutlet weak var line1: UILabel!
    @IBOutlet weak var line2: UILabel!
    @IBOutlet weak var line3: UILabel!
    @IBOutlet weak var line4: UILabel!
    
    let characterArray = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
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
    @IBOutlet weak var emailMaualtextView: UIView!
    @IBOutlet weak var messageMaualtextView: UIView!
    @IBOutlet weak var messageImagePreviewView: UIView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var messageTextPreviewTextView: UILabel!
    
    @IBOutlet weak var selectedShareTitleLabel: UILabel!
    @IBOutlet weak var nocontactView: UIView!
    @IBOutlet weak var lblnocontact: UILabel!
    
    @IBOutlet weak var deleteContactConfirmationView: UIView!
    @IBOutlet weak var deleteContactDoNotShowButton: UIButton!
    @IBOutlet weak var filterOptionView: UIView!
    var loadingStatus = false
    let blueColor1 = UIColor(red: 0/255, green: 125/255, blue: 255/255, alpha: 1.0)
    let grayColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    var pageNo : Int = 1
    var isSelectSMS : Bool = false
    var isFromContactManager : Bool = false
    var listingResponse : msgTitleList? = nil
    var emailMsgListing : msgTitleList? = nil
    var smsMsgListing : msgTitleList? = nil
    @IBOutlet weak var lblNumberofContacts: UILabel!
    var isSelectModeOn : Bool = false
   @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var filterScrollview: UIScrollView?
    @IBOutlet weak var btnDoNotShowAgain: UIButton!
    @IBOutlet weak var lblCurrentFilter: UILabel!
    
    @IBOutlet weak var rightFilterArrowButton: UIButton!
    @IBOutlet weak var leftFilterArrowButton: UIButton!
    var selectedTitleRow: IndexPath?
//    var deleteContactIndexPath: IndexPath?
//    Int = -1
    fileprivate static let CELL_IDENTIFIER = "messageTitleCell"

    //share page declaration
    var txtDetailForEmail: String = ""
    var txtLinkWithCheckOut: String = ""
//    var ReferralLink: String = ""
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
    @IBOutlet weak var inviteAgainLabel: UILabel!
    @IBOutlet weak var contactSentConfirmPopup: UIView!
    var isIncludeProfileImg = Defaults.shared.includeProfileImgForShare
    var isIncludeQrImg = Defaults.shared.includeQRImgForShare
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var contactPermitView: UIView!
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var emailContactTableView: UITableView!
    
    @IBOutlet weak var emailSubjectTextLabel: UILabel!
    @IBOutlet weak var emailSubjectView: UIView!
    @IBOutlet weak var emailBodyTitleLabel: UILabel!
    @IBOutlet weak var previewMainView: UIView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewImageview: UIImageView!
//    @IBOutlet weak var lblpreviewText: UILabel!
    @IBOutlet weak var txtvwpreviewText: UILabel!
//    @IBOutlet weak var lblpreviewUrl: UILabel!
    @IBOutlet weak var socialSharePopupView: UIView!
    
    fileprivate static let CELL_IDENTIFIER_CONTACT = "contactTableViewCell"
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //for View One
    @IBOutlet weak var lblReferralLink: UILabel!
    
    @IBOutlet weak var businessDashboardStackView: UIStackView!
    @IBOutlet weak var businessDashboardButton: UIButton!
    @IBOutlet weak var businessDashbardConfirmPopupView: UIView!
    @IBOutlet weak var btnDoNotShowAgainBusinessConfirmPopup: UIButton!
    
    
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var recentButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var invitedButton: UIButton!
    @IBOutlet weak var openedButton: UIButton!
    @IBOutlet weak var signedupButton: UIButton!
    @IBOutlet weak var subscriberButton: UIButton!
    @IBOutlet weak var optOutButton: UIButton!
    @IBOutlet weak var hiddenButton: UIButton!
    
    
    @IBOutlet weak var emailOptionsMainView: UIView!
    @IBOutlet weak var appleEmailOptionView: UIView!
    @IBOutlet weak var gmailOptionView: UIView!
    @IBOutlet weak var setDefaultEmailAppButton: UIButton!
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var previewTitleLabel: UILabel!
    @IBOutlet weak var chooseMessageTitleTextLabel: UILabel!
    
    @IBOutlet weak var subTitleOfPreview: UILabel!
    @IBOutlet weak var imgPreviewImageAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgPreviewImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgPreviewImageWidthConstraint: NSLayoutConstraint!
    var isGmailOpened = false
    var isAppleEmailOpened = false
    
    
    var searchText:String = ""
    var selectedContact:ContactResponse?
    var selectedContactManage:ContactResponse?
    var inviteData:Data?
    var selectedPhoneContact: ContactResponse?
    var phoneContacts = [PhoneContact]()
    var mailContacts = [PhoneContact]()
    var allphoneContacts = [PhoneContact]()
    var allmailContacts = [PhoneContact]()
    var mobileContacts = [ContactResponse]()
    var emailContacts = [ContactResponse]()
    var selectedMobileContacts = [ContactResponse]()
    var selectedEmailContacts = [ContactResponse]()
    var allmobileContacts = [ContactResponse]()
    var allmobileContactsForHide = [ContactResponse]()
    var allemailContactsForHide = [ContactResponse]()
    var filter: ContactsFilter = .none
    var selectedFilter:String = ContactStatus.all
    var loadingView: LoadingView? = LoadingView.instanceFromNib()
    var selectedContactType:String = ContactType.mobile
    var urlToShare = ""
    let themeBlueColor = UIColor(hexString:"4F2AD8")
    let logoImage = UIImage(named:"qr_applogo")
    private var lastContentOffset: CGFloat = 0
    
    var emailSubjectstr = ""
    var emailBodystr = ""
    var toEmailAddress = ""
    var isFromOnboarding = false
    var groupedContactArray = [[ContactResponse]()]
    var groupedEmailContactArray = [[ContactResponse]()]
    var contactSections = [ContactGroup]()
    var emailContactSection = [ContactGroup]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
        if isFromContactManager{
            pageNo = 5
        }
        self.setupPage()
        self.fetchTitleMessages()
        self.fetchEmailMessages()
      //  self.getContactList()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector:#selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    // MARK: - UI setup
    func setupUI(){
//        frwrdarrow1.setImageColor(color: UIColor(hexString: "007DFF"))
//        frwrdarrow2.setImageColor(color: UIColor(hexString: "7D46F5"))
//        frwrdarrow3.setImageColor(color: UIColor(hexString: "E48C4C"))

        messageImagePreviewView.dropShadowNew()
       
        itemsTableView.register(UINib.init(nibName: ContactImportVC.CELL_IDENTIFIER, bundle: nil), forCellReuseIdentifier: ContactImportVC.CELL_IDENTIFIER)
        
        itemsTableView.allowsSelection = true
        itemsTableView.dataSource = self
        itemsTableView.delegate = self
        itemsTableView.sectionHeaderHeight = 0.0
        itemsTableView.sectionFooterHeight = 0.0
        
        contactTableView.register(UINib.init(nibName: ContactImportVC.CELL_IDENTIFIER_CONTACT, bundle: nil), forCellReuseIdentifier: ContactImportVC.CELL_IDENTIFIER_CONTACT)
        
        emailContactTableView.register(UINib.init(nibName: ContactImportVC.CELL_IDENTIFIER_CONTACT, bundle: nil), forCellReuseIdentifier: ContactImportVC.CELL_IDENTIFIER_CONTACT)
        
        contactTableView.allowsSelection = true
        contactTableView.dataSource = self
        contactTableView.delegate = self
        
        emailContactTableView.allowsSelection = true
        emailContactTableView.dataSource = self
        emailContactTableView.delegate = self
        
        self.contactTableView.estimatedRowHeight = 88.0
        self.contactTableView.rowHeight = UITableView.automaticDimension
        
        self.emailContactTableView.estimatedRowHeight = 88.0
        self.emailContactTableView.rowHeight = UITableView.automaticDimension
        
        searchBar.delegate = self
        filterScrollview?.delegate = self
          
        if let channelId = Defaults.shared.currentUser?.channelId {
            //self.txtLinkWithCheckOut = "\(R.string.localizable.checkOutThisCoolNewAppQuickCam())"
//            self.ReferralLink = "\(websiteUrl)/\(channelId)"
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

        
        self.textShareView.dropShadowNew()
        self.qrCodeShareView.dropShadowNew()
        self.manualEmailView.dropShadowNew()
        self.socialShareView.dropShadowNew()
        self.businessDashboardView.dropShadowNew()
        
        self.appleEmailOptionView.dropShadow()
        self.gmailOptionView.dropShadow()
        
        previewImageview.contentMode = .scaleAspectFit
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont.systemFont(ofSize: 13)
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor.gray79
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        EasyTipView.globalPreferences = preferences
        
        self.lblCurrentFilter.text = "All"
    }
    func setupUIBasedOnUrlToShare() {
      
        let image =  URL(string: urlToShare)?.qrImage(using: themeBlueColor, logo: logoImage)
        self.imageQrCode.image = image?.convert()

        lblReferralLink.attributedText = NSAttributedString(string: urlToShare, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])

        setPreviewData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon

        filterOptionView.isHidden = true

        textMessageButton.setTitleColor(ApplicationSettings.appPrimaryColor, for: .normal)
        textMessageSeperatorView.backgroundColor = ApplicationSettings.appPrimaryColor
        textMessageSeperatorViewHeight.constant = 3.0
        
        emailButton.setTitleColor(UIColor(hexString: "676767"), for: .normal)
        emailSeperatorView.backgroundColor = UIColor(hexString: "676767")
        emailSeperatorViewHeight.constant = 1.0
        selectedContactType = ContactType.mobile
        self.emailContactTableView.isHidden = true
        
        if selectedFilter == ContactStatus.all {
            leftFilterArrowButton.tintColor = .lightGray
            rightFilterArrowButton.tintColor = .black
        }
    }
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
        if pageNo == 4{
            self.getContactList(source: self.selectedContactType,filter:self.selectedFilter)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        if pageNo == 4{
//            
//            if UIScreen.main.sizeType == .iPhone5 || UIScreen.main.sizeType == .iPhone6 {
//                
//                self.imgPreviewImageAspectRatioConstraint.isActive = false
//                self.imgPreviewImageHeightConstraint.isActive = true
//                self.imgPreviewImageWidthConstraint.isActive = true
//
//            } else {
//                self.imgPreviewImageAspectRatioConstraint.isActive = true
//                self.imgPreviewImageHeightConstraint.isActive = true
//                self.imgPreviewImageWidthConstraint.isActive = true
//            }
//        }
    }
    
    @objc func appMovedToForeground() {
        //print("App moved to foreground!")
        if isGmailOpened{
            self.contactSentConfirmPopup.isHidden = false
        }else if isAppleEmailOpened{
            self.contactSentConfirmPopup.isHidden = false
        }
        isGmailOpened = false
        isAppleEmailOpened = false
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if !filterOptionView.isHidden{
            filterOptionView.isHidden = true
        }
    }
    func showLoader(){
        self.loadingView = LoadingView.instanceFromNib()
        self.loadingView?.loadingText = "Please wait while your contacts are loaded."
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
            
        case .authorized,.notDetermined: //access contacts
            contactPermitView.isHidden = true
            print("here")
            self.loadContacts(filter: self.filter) // Calling loadContacts methods

            self.hideLoader()
        case .denied: //request permission
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
        for view in page0view.subviews {
            if view is EasyTipView {
                view.removeFromSuperview()
            }
        }
        if pageNo == 1 {
            page0view.isHidden = false
            page1view.isHidden = true
            page2view.isHidden = true
            page3view.isHidden = true
            page4view.isHidden = true
            line1.backgroundColor = grayColor
            line2.backgroundColor = grayColor
            line3.backgroundColor = grayColor
            line4.backgroundColor = grayColor
            lblNum2.textColor = grayColor
            lblNum3.textColor = grayColor
            lblNum4.textColor = grayColor
            lblNum5.textColor = grayColor
            lblNum2.backgroundColor = .white
            lblNum3.backgroundColor = .white
            lblNum4.backgroundColor = .white
            lblNum5.backgroundColor = .white
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
            
            if self.shareType == .email{
                self.isSelectSMS = false
            }else{
                self.isSelectSMS = true
            }
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
            if self.shareType == .email{
                self.isSelectSMS = false
                emailMaualtextView.isHidden = false
                messageImagePreviewView.isHidden = true
            }else{
                self.isSelectSMS = true
                emailMaualtextView.isHidden = true
                messageImagePreviewView.isHidden = false
            }
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
                self.getContactList(filter: self.selectedFilter)
                break
               
            case .failure(let error):
                print(error)
                self.hideLoader()
                break
                //failure code here
            }
        }
    }
    func groupContacts(sortedContacts:[ContactResponse])->[[ContactResponse]]{

        let groupedContacts = sortedContacts.reduce([[ContactResponse]]()) {
            guard var last = $0.last else { return [[$1]] }
            var collection = $0
            if (last.first!.name ?? "").first == $1.name!.first {
                last += [$1]
                collection[collection.count - 1] = last
            } else {
                collection += [[$1]]
            }
            return collection
        }
    
       return groupedContacts
    }
    func getContactList(source:String = "mobile",page:Int = 1,limit:Int = 200,filter:String = ContactStatus.all,hide:Bool = false,firstTime:Bool = false){
        
        var searchText = searchBar.text!
        var contactType = selectedContactType
        if self.shareType == ShareType.email{
            contactType = ContactType.email
        }
        searchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        print(searchText)
        var lim = 200
        if page == 1 {
            lim = 40
        }
        var fil = filter
        if fil == "opened" {
            fil = "visited"
        }
        let path = API.shared.baseUrlV2 + "contact-list?contactSource=\(source)&contactType=\(contactType)&searchText=\(searchText)&filterType=\(fil)&limit=\(lim)&page=\(page)&sortBy=name&sortType=asc"

        print("contact->\(path)")
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
                    if self.mobileContacts.count == 0{
                      //  self.lblCurrentFilter.text = ""
                       
                        
                        if self.hasContactPermission() == false && self.selectedFilter == ContactStatus.all{
                            self.contactPermitView.isHidden = false
                            self.lblnocontact.text = "Import Contacts"
                        }else{
                            self.nocontactView.isHidden = false
                            if searchText.count > 0 {
                                self.lblnocontact.text = "No contacts found containing '\(searchText)'."
                            } else {
                                self.lblnocontact.text = "No contacts found with '\(filter)' status."
                            }
                            self.nocontactView.isHidden = false
                        }
                    }else{
                        self.contactPermitView.isHidden = true
                        self.nocontactView.isHidden = true
                    }
                    self.lblNumberofContacts.text = "Contacts(\(self.mobileContacts.count))"
                    self.groupedContactArray = self.groupContacts(sortedContacts:self.mobileContacts)
                    self.contactSections =  self.checkForCharacter(groupedArray:self.groupedContactArray)
                   
                    DispatchQueue.main.async {
                        let contentOffset = self.contactTableView.contentOffset
                        self.contactTableView.reloadData()
                        self.contactTableView.layoutIfNeeded()
                        self.contactTableView.setContentOffset(contentOffset, animated: false)
                    }
                }else{
                    self.allemailContactsForHide.append(contentsOf:contacts)
                    self.emailContacts.append(contentsOf:contacts)
                    if self.emailContacts.count == 0{
                      //  self.lblCurrentFilter.text = ""
                        if self.hasContactPermission() == false && self.selectedFilter == ContactStatus.all{
                            self.contactPermitView.isHidden = false
                            self.lblnocontact.text = "Import Contacts"
                        }else{
                            if searchText.count > 0 {
                                self.lblnocontact.text = "No contacts found containing '\(searchText)'."
                            } else {
                                self.lblnocontact.text = "No contacts found with '\(filter)' status."
                            }
                            self.nocontactView.isHidden = false
                        }
                    }else{
                        self.contactPermitView.isHidden = true
                        self.nocontactView.isHidden = true
                    }
                    self.lblNumberofContacts.text = "Contacts(\(self.emailContacts.count))"
                    self.groupedEmailContactArray = self.groupContacts(sortedContacts:self.emailContacts)
                    self.emailContactSection =  self.checkForCharacter(groupedArray:self.groupedEmailContactArray)
                    DispatchQueue.main.async {
                        if page == 1 {
                            let contentOffset = self.emailContactTableView.contentOffset
                            self.emailContactTableView.reloadData()
                            self.emailContactTableView.layoutIfNeeded()
                            self.emailContactTableView.setContentOffset(contentOffset, animated: false)
                        }
                    }
                }
                self.hideLoader()
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.5) {
                    self.loadingStatus = false
                }
                if contacts.count == lim {
                    let page = (self.selectedContactType == ContactType.mobile) ? self.mobileContacts.count : self.emailContacts.count
                    self.getContactList(page: page, filter: self.selectedFilter)
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
    func checkForCharacter(groupedArray:[[ContactResponse]])->[ContactGroup]{
        //"+","0","1","2","3","4","5","6","8","9",
        let sections = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        
        var contactGroupedArray = [ContactGroup]()
        var groupedArrayCopy = groupedArray
        for section in sections{
            let contactGroup = ContactGroup(contacts: [ContactResponse](), char:  section)
            contactGroupedArray.append(contactGroup)
        }
        for (i,obj) in contactGroupedArray.enumerated(){
            let contact = groupedArray.filter({$0.first?.name?.first?.uppercased() == obj.char })
            contactGroupedArray[i].contacts = contact.first ?? [ContactResponse]()
 
        }
        return contactGroupedArray
        print(contactGroupedArray)
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
                    self.getContactList(source: self.selectedContactType,filter:self.selectedFilter)
//                    self.emailContactTableView.reloadData()
                }else{
                    self.mobileContacts.remove(at:index)
                    self.getContactList(source: self.selectedContactType,filter:self.selectedFilter)
//                    self.contactTableView.reloadData()
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
    func validateMultipleInvite(contacts:[ContactResponse], completion: @escaping (_ success: Bool?) -> ()){
        let contact = contacts.first!
        self.selectedContact = nil
        var contactListids = [String]()
        for con in  contacts{
            contactListids.append(con.Id ?? "")
        }
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
            
            let okAction = UIAlertAction(title: "Enable", style: .default, handler: {(cAlertAction) in
                //Redirect to Settings app
                self.ContactPermission()
              //  UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
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
        
        allButton.backgroundColor = ApplicationSettings.appLightWhiteColor
        recentButton.backgroundColor = ApplicationSettings.appLightWhiteColor
        inviteButton.backgroundColor = ApplicationSettings.appLightWhiteColor
        invitedButton.backgroundColor = ApplicationSettings.appLightWhiteColor
        openedButton.backgroundColor = ApplicationSettings.appLightWhiteColor
        signedupButton.backgroundColor = ApplicationSettings.appLightWhiteColor
        subscriberButton.backgroundColor = ApplicationSettings.appLightWhiteColor
        optOutButton.backgroundColor = ApplicationSettings.appLightWhiteColor
        hiddenButton.backgroundColor  = ApplicationSettings.appLightWhiteColor
        
        allButton.setTitleColor(ApplicationSettings.appTextGrayColor, for: .normal)
        recentButton.setTitleColor(ApplicationSettings.appTextGrayColor, for: .normal)
        inviteButton.setTitleColor(ApplicationSettings.appTextGrayColor, for: .normal)
        invitedButton.setTitleColor(ApplicationSettings.appTextGrayColor, for: .normal)
        openedButton.setTitleColor(ApplicationSettings.appTextGrayColor, for: .normal)
        signedupButton.setTitleColor(ApplicationSettings.appTextGrayColor, for: .normal)
        subscriberButton.setTitleColor(ApplicationSettings.appTextGrayColor, for: .normal)
        optOutButton.setTitleColor(ApplicationSettings.appTextGrayColor, for: .normal)
        hiddenButton.setTitleColor(ApplicationSettings.appTextGrayColor, for: .normal)
        
       
        
        sender.backgroundColor = ApplicationSettings.appPrimaryColor
        sender.setTitleColor(ApplicationSettings.appWhiteColor, for: .normal)
      
        
        switch sender.tag {
        case 1:
            self.selectedFilter = ContactStatus.all
            self.lblCurrentFilter.text = "All"
           // self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.all)
//            leftFilterArrowButton.tintColor = .lightGray
//            rightFilterArrowButton.tintColor = .black
            break
        case 2:
            self.selectedFilter = ContactStatus.recent
            self.lblCurrentFilter.text = "Recent"
           // self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.recent)
            break
        case 3:
            self.selectedFilter = ContactStatus.pending
            self.lblCurrentFilter.text = "Invite"
           // self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.pending)
            break
        case 4:
            self.selectedFilter = ContactStatus.invited
            self.lblCurrentFilter.text = "Invited"
            //self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.invited)
            break
        case 5:
            self.selectedFilter = ContactStatus.opened
            self.lblCurrentFilter.text = "Opened"
            self.getContactList( page:1,filter:ContactStatus.opened)
          /*  if selectedContactType == ContactType.mobile{
                self.mobileContacts = [ContactResponse]()
                self.contactTableView.reloadData()
            }else{
                self.emailContacts = [ContactResponse]()
                self.emailContactTableView.reloadData()
            } */
            
           
            break
        case 6:
            self.selectedFilter = ContactStatus.signedup
            self.lblCurrentFilter.text = "Signed up"
           // self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.signedup)
            break
        case 7:
            self.selectedFilter = ContactStatus.subscriber
            self.lblCurrentFilter.text = "Subscriber"
           // self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.subscriber)
            break
        case 8:
            self.selectedFilter = ContactStatus.optout
            self.lblCurrentFilter.text = "Opt-out"
          //  self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.optout)
            break
        case 9:
            //hidden
            self.selectedFilter = ContactStatus.hidden
            self.lblCurrentFilter.text = "Hidden"
          //  self.showLoader()
            self.getContactList( page:1,filter:ContactStatus.hidden,hide:true)
//            rightFilterArrowButton.tintColor = .lightGray
//            leftFilterArrowButton.tintColor = .black
            break
        default:
            mobileContacts = allmobileContacts
            phoneContacts = allphoneContacts
            mailContacts = allmailContacts
            contactTableView.reloadData()
            break
        }
    }
    @IBAction func filterScroll(sender:UIButton){
        if sender.tag == 1{
            //left scroll
            var contentOffsetX = 0.0
            if (filterScrollview?.contentOffset.x ?? 0.0) > 70.0{
                contentOffsetX =  (filterScrollview?.contentOffset.x ?? 70.0) - 70.0
            }else{
                contentOffsetX = 0.0
            }
            filterScrollview?.setContentOffset(CGPoint(x:contentOffsetX, y: filterScrollview?.contentOffset.y ?? 0.0), animated: true)
            
        }else if sender.tag == 2{
            //right scroll
            
            //left scroll
            var contentOffsetX = 0.0
          
            if (filterScrollview?.contentOffset.x ?? 0) > (CGFloat(filterScrollview?.contentSize.width ?? 0.0) - (filterScrollview?.frame.width  ?? 0.0)) - 70{
                contentOffsetX =  CGFloat(filterScrollview?.contentSize.width ?? 0.0) - (filterScrollview?.frame.width  ?? 0.0)
            }else{
                contentOffsetX =  (filterScrollview?.contentOffset.x ?? 0.0) + 70.0
            }
            filterScrollview?.setContentOffset(CGPoint(x:contentOffsetX, y: filterScrollview?.contentOffset.y ?? 0.0), animated: true)
        }
    }
    func setPreviewData(){
//        if let referralPage = Defaults.shared.currentUser?.referralPage {
            self.getLinkPreview(link:urlToShare) { image in
            }
//        }
    }
    func getLinkPreview(link: String, completionHandler: @escaping (UIImage) -> Void) {
        
        OpenGraphDataDownloader.shared.fetchOGData(urlString: link) { result in
            switch result {
            case let .success(data, isExpired):
                self.previewImageview.sd_setImage(with: data.imageUrl, placeholderImage: R.image.user_placeholder())
                self.messageImageView.sd_setImage(with: data.imageUrl, placeholderImage: R.image.user_placeholder())
                break
                // do something
            case let .failure(error, isExpired): break
                // do something
            }
        }
        
        OGDataProvider.shared.fetchOGData(urlString: link) { [weak self] ogData, error in
            guard let `self` = self else { return }
            if let _ = error {
                return
            }
            DispatchQueue.main.async {
                self.txtvwpreviewText.text = "\(self.txtLinkWithCheckOut)\n\n\(link)"
                self.messageTextPreviewTextView.text = "\(self.txtLinkWithCheckOut)\n\n\(link)"
            }
//            if ogData.imageUrl != nil {
             //  self.previewImageview.sd_setImage(with: ogData.imageUrl, placeholderImage: R.image.user_placeholder())
           
//            }
        }
        
    }
    
    @IBAction func textMessageSelected(sender: UIButton) {
        itemsTableView.reloadData()
        selectedTitleRow = nil
        self.shareType = ShareType.textShare
        searchBar.showsCancelButton = false
        if !isSelectSMS {
          //  isSelectSMS = true
            pageNo = 3
            selectedContactType = ContactType.mobile
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
        isSelectSMS = false
    }
    @IBAction func emailSelected(sender: UIButton) {
        itemsTableView.reloadData()
        selectedTitleRow = nil
        searchBar.showsCancelButton = false
        self.shareType = ShareType.email
        
        if !isSelectSMS && !isFromContactManager{
          //  isSelectSMS = false
            self.shareType = ShareType.email
            selectedContactType = ContactType.email
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
        isSelectSMS = false
        
    }
    @IBAction func socialShareCloseClick(sender: UIButton) {
        self.socialSharePopupView.isHidden = true
    }
    @IBAction func socialShareButtonClick(sender: UIButton) {
        let urlString = self.txtLinkWithCheckOut
        let urlwithString = urlString + "\n" + "\n" + urlToShare//" \(websiteUrl)/\(channelId)"
        
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            guard let imageUrl = URL(string: userImageURL) else { return }
            UIPasteboard.general.string = urlwithString
        }
        
        if sender.tag == 1{
            //Message
            textMessage(imageUrlText: urlwithString)
        }else if sender.tag == 2{
            //facebook Messanger
            UIPasteboard.general.string = urlString
            sharingWithFBMessangerApp(message: urlString, shareUrl: urlToShare)
        }else if sender.tag == 4{
            //Whatsapp
            sharingWithWhatsUp(message: urlwithString)
        }else if sender.tag == 6{
            //Facebook
           shareTextOnFaceBook(message: urlString, newUrl: urlToShare)
        }else if sender.tag == 7{
            //Twitter
            sharingTextToTwitter(message: urlString, shareUrl: urlToShare)
        }else if sender.tag == 9{
            //Telegram
            sharingTextWithTelegram(message: urlwithString)
        }else if sender.tag == 10{
            //More
            let urlString = self.txtLinkWithCheckOut
            let urlwithString = urlString + "\n" + "\n" + urlToShare//" \(websiteUrl)/\(channelId)"
            if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
                let imageUrl = URL(string: userImageURL)
                share(shareText: urlwithString, shareImage: imageUrl)
            }
        }
    }
    
//    MARK: - Sharing With Telegram Messanger App
    func sharingTextWithTelegram(message: String) {
        let urlString = "tg://msg?text=\(message)"
        let tgUrl = URL.init(string:urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        if UIApplication.shared.canOpenURL(tgUrl!)
            {
                UIApplication.shared.openURL(tgUrl!)
            }else
            {
               //App not installed.
                debugPrint("please install Telegram")
                DispatchQueue.runOnMainThread {
                    Utils.appDelegate?.window?.makeToast("please install Telegram")
                }
            }
    }
    
//    MARK: - Sharing With Twitter Messanger App
    func sharingTextToTwitter(message: String, shareUrl: String) {
        let tweetText = message
        let tweetUrl = shareUrl
        let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(tweetUrl)"
        // encode a space to %20 for example
        let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // cast to an url
        let url = URL(string: escapedShareString)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [: ], completionHandler: nil)
        } else {
            debugPrint("please install Twitter")
            DispatchQueue.runOnMainThread {
                Utils.appDelegate?.window?.makeToast("Please install Twitter")
            }
        }
    }
    
    
//    MARK: - Sharing With FB Messanger App
    func sharingWithFBMessangerApp(message: String, shareUrl: String) {
        guard let url = URL(string: shareUrl) else {
            preconditionFailure("URL is invalid")
        }
        
        let content = ShareLinkContent()
        content.contentURL = url
        content.quote = message
        let dialog = MessageDialog(content: content, delegate: self)
        do {
            try dialog.validate()
        } catch {
            print(error)
            DispatchQueue.runOnMainThread {
                Utils.appDelegate?.window?.makeToast("Please install FB Messanger")
            }
        }
        dialog.show()
    }
    
    
//    MARK: - Sharing With FaceBook App
    func shareTextOnFaceBook(message: String, newUrl: String) {
        let shareContent = ShareLinkContent()
        if let channelId = Defaults.shared.currentUser?.channelId {
            let text = newUrl
            if let url = URL(string: text) {
                shareContent.contentURL = url
                shareContent.quote = message
                SocialShareVideo.shared.showShareDialog(shareContent)
            }
        }
    }
    
//    MARK: - Sharing With WhatsUp Messanger App
    func sharingWithWhatsUp(message: String) {
        var queryCharSet = NSCharacterSet.urlQueryAllowed
        
        // if your text message contains special char like **+ and &** then add this line
        queryCharSet.remove(charactersIn: "+&")
        if let escapedString = message.addingPercentEncoding(withAllowedCharacters: queryCharSet) {
            if let whatsappURL = URL(string: "whatsapp://send?text=\(escapedString)") {
                if UIApplication.shared.canOpenURL(whatsappURL) {
                    UIApplication.shared.open(whatsappURL, options: [: ], completionHandler: nil)
                } else {
                    debugPrint("please install WhatsApp")
                    DispatchQueue.runOnMainThread {
                        Utils.appDelegate?.window?.makeToast("Please install WhatsApp")
                    }
                }
            }
        }
    }
    @IBAction func selectContactToggleClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setTitleColor(R.color.appPrimaryColor(), for: .normal)
        sender.setTitleColor(R.color.appTextGrayColor(), for: .selected)
        if sender.isSelected{
            self.isSelectModeOn = true
            self.btnNext.setTitle("Invite", for: .normal)
        }else{
            self.isSelectModeOn = false
            self.btnNext.setTitle("Done", for: .normal)
        }
        self.emailContactTableView.reloadData()
        self.contactTableView.reloadData()
    }
    @objc func selectContactTapped(_ sender: SelectButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            if sender.isMobileContact{
                self.contactSections[sender.sectionIndex ?? 0].contacts[sender.rowIndex ?? 0].isSelected = true
                self.groupedContactArray[sender.sectionIndex ?? 0][sender.rowIndex ?? 0].isSelected = true
                self.selectedMobileContacts.append( self.contactSections[sender.sectionIndex ?? 0].contacts[sender.rowIndex ?? 0])
               
                if self.selectedMobileContacts.count == 0{
                    self.btnNext.setTitle("Invite", for: .normal)
                }else{
                    self.btnNext.setTitle("Invite \( self.selectedMobileContacts.count)", for: .normal)
                }
            }else{
                self.groupedEmailContactArray[sender.sectionIndex ?? 0][sender.rowIndex ?? 0].isSelected = true
                self.emailContactSection[sender.sectionIndex ?? 0].contacts[sender.rowIndex ?? 0].isSelected = true
                self.selectedEmailContacts.append(self.emailContactSection[sender.sectionIndex ?? 0].contacts[sender.rowIndex ?? 0])
                if self.selectedEmailContacts.count == 0{
                    self.btnNext.setTitle("Invite", for: .normal)
                }else{
                    self.btnNext.setTitle("Invite \( self.selectedEmailContacts.count)", for: .normal)
                }
               
            }
        }else{
            if sender.isMobileContact{
                self.contactSections[sender.sectionIndex ?? 0].contacts[sender.rowIndex ?? 0].isSelected = false
                let contactid =  self.contactSections[sender.sectionIndex ?? 0].contacts[sender.rowIndex ?? 0].Id ?? ""
                self.selectedMobileContacts = self.selectedMobileContacts.filter({$0.Id != contactid})
               
                if self.selectedMobileContacts.count == 0{
                    self.btnNext.setTitle("Invite", for: .normal)
                }else{
                    self.btnNext.setTitle("Invite \( self.selectedMobileContacts.count)", for: .normal)
                }
            }else{
                self.emailContactSection[sender.sectionIndex ?? 0].contacts[sender.rowIndex ?? 0].isSelected = false
                self.groupedEmailContactArray[sender.sectionIndex ?? 0][sender.rowIndex ?? 0].isSelected = false
                let contactid =  self.emailContactSection[sender.sectionIndex ?? 0].contacts[sender.rowIndex ?? 0].Id ?? ""
                self.selectedEmailContacts = self.selectedEmailContacts.filter({$0.Id != contactid})
              
                if self.selectedEmailContacts.count == 0{
                    self.btnNext.setTitle("Invite", for: .normal)
                }else{
                    self.btnNext.setTitle("Invite \( self.selectedEmailContacts.count)", for: .normal)
                }
            }
           
        }
        for contact in  self.selectedMobileContacts{
            print(contact.textLink ?? "")
            
        }
        for contact in  self.selectedMobileContacts{
            print(contact.emailLink ?? "")
            
        }
      
      
        print("Selected Mobile Contacts \(self.selectedMobileContacts.count)")
    }
//    MARK: - Sharing With Default Iphone Messanger App
    fileprivate func textMessage(imageUrlText: String) {
        let appURL_Id = imageUrlText
        let canSend = MFMessageComposeViewController.canSendText()
        if canSend == true {
            let messageVC = MFMessageComposeViewController()
            messageVC.body = appURL_Id
            messageVC.messageComposeDelegate = self
            self.present(messageVC, animated: true, completion: nil)
        }else{
//            cantSendTextOrEmailAlert(alertTitle: multiUse.alertTitle, alertMessage: multiUse.messageSMS)
        }
    }
    
    // MARK: - tableview Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == itemsTableView{
            return UITableView.automaticDimension
        } else {
            
            return UITableView.automaticDimension
            //return 75
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        print(self.mobileContacts.count)
        print(self.contactSections.count)
      
        if tableView == itemsTableView{
            return 2
        } else if tableView == emailContactTableView{
            return self.emailContactSection.count
        }else{
            return self.contactSections.count
          
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == itemsTableView{
            if section == 0 {
              return 1
            } else {
                if self.shareType == .textShare{    //if isSelectSMS {
                    return self.smsMsgListing?.list.count ?? 0
                } else {
                    return self.emailMsgListing?.list.count ?? 0
                }
            }
        }else if tableView == emailContactTableView{
          //  return emailContacts.count
            return self.emailContactSection[section].contacts.count
        } else {
           // return self.mobileContacts.count
            return self.contactSections[section].contacts.count
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView == self.contactTableView{
           // let sections = self.groupedContactArray.map({$0.first?.name?.first?.uppercased() ?? ""})
            let sections = self.contactSections.map({$0.char?.uppercased() ?? ""})
            return sections
        }else if tableView == self.emailContactTableView{
         //   let sections = self.groupedEmailContactArray.map({$0.first?.name?.first?.uppercased() ?? ""})
            let sections = self.emailContactSection.map({$0.char?.uppercased() ?? ""})
            return sections
        }
        return nil
    }

    func tableView(_ tableView: UITableView,
                   sectionForSectionIndexTitle title: String,
                   at index: Int) -> Int{
            print(index)
            print(title)
           
        if tableView == self.contactTableView{
            let newIndex = self.contactSections.firstIndex(where: {$0.char == title}) ?? 0
            print(newIndex)
            return newIndex
        }else{
            let newIndex = self.emailContactSection.firstIndex(where: {$0.char == title}) ?? 0
            print(newIndex)
            return newIndex
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            headerTitle.textLabel?.textColor = UIColor.black
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        if tableView == self.contactTableView{
            if self.contactSections[section].contacts.count == 0 {
                return nil
            } else {
                return contactSections[section].char
            }
        }else if tableView == self.emailContactTableView{
            if self.emailContactSection[section].contacts.count == 0 {
                return nil
            } else {
                return emailContactSection[section].char
            }
        }
       return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.contactTableView {
            if self.contactSections[section].contacts.count > 0 {
                return 30
            }
        } else if tableView == self.emailContactTableView {
            if self.emailContactSection[section].contacts.count > 0 {
                return 30
            }
        } else if tableView == itemsTableView {
            return 0
        }
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == itemsTableView {
            return 0
        }
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       /* if tableView == emailContactTableView{
          //  return emailContacts.count
            if indexPath.row == self.emailContacts.count{
                let page = (selectedContactType == ContactType.mobile) ? self.mobileContacts.count : self.emailContacts.count
                self.getContactList(page: page, filter: self.selectedFilter)
            }
        } else if tableView == contactTableView{
            //  return emailContacts.count
              if indexPath.row == self.mobileContacts.count{
                  let page = (selectedContactType == ContactType.mobile) ? self.mobileContacts.count : self.emailContacts.count
                  self.getContactList(page: page, filter: self.selectedFilter)
              }
          }*/
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == itemsTableView{
            
            let cell:messageTitleCell = self.itemsTableView.dequeueReusableCell(withIdentifier: ContactImportVC.CELL_IDENTIFIER) as! messageTitleCell
            
            if self.shareType == .textShare{//isSelectSMS {
                previewTitleLabel.text = "Preview Message"
                subTitleOfPreview.text = "Your invitation will appear similar to this depending on your contact’s messaging app."
            } else if self.shareType == .email {
                previewTitleLabel.text = "Preview Email"
                subTitleOfPreview.text = "Your invitation will appear similar to this depending on your contact’s email app."
            } else if self.shareType == .socialShare {
                if isSelectSMS {
                    previewTitleLabel.text = "Preview Message"
                } else {
                    previewTitleLabel.text = "Preview Email"
                }
                subTitleOfPreview.text = "Your social post will appear similar to this, depending on the social media platform."
            }
            
            cell.delegate = self
            cell.handleRatioButtonAction = { (isSelected) in
                if isSelected {
                    self.selectedTitleRow = indexPath
                } else {
                    self.selectedTitleRow = IndexPath(row: 0, section: 0)
                }
                self.itemsTableView.reloadData()
            }
            
            if indexPath.section == 0 {
                
                if shareType == .textShare || shareType == .socialShare {
                    cell.setText(text: "Compose your message")
                    chooseMessageTitleTextLabel.text = "Choose the message to send"
                } else if shareType == .email {
                    cell.setText(text: "Compose your email")
                    chooseMessageTitleTextLabel.text = "Choose the email to send"
                }
                
                var item : Titletext?
                if isSelectSMS {
                    item = self.smsMsgListing?.list[indexPath.row]
                    cell.setSeletedState(state: selectedTitleRow == indexPath, details: "", indexPath: indexPath)
                    print("isselectsms")
                } else {
                    item = self.emailMsgListing?.list[indexPath.row]
                    cell.detailView.isHidden = true
                    cell.setupViewForEmailSelection(isSelected: selectedTitleRow == indexPath, subTitle: item?.subject ?? "", indexPath: indexPath)
                }
                cell.radioButtonWidthConstraint.constant = 20
                cell.emailRadioButtonWidthConstraint.constant = 0
                
                var finalText = ""
            
                if selectedTitleRow == indexPath {
                    if isSelectSMS {
                        emailBodyTitleLabel.text = "Message"
                        emailSubjectView.isHidden = true
                        emailMaualtextView.isHidden = true
                    } else {
                        emailBodyTitleLabel.text = "Email Body"
                        emailMaualtextView.isHidden = false
                    }
                }

                return cell
                
            } else {
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.ownMessageView.isHidden = true
                var item : Titletext?
                if isSelectSMS {
                    emailMaualtextView.isHidden = true
                    cell.detailView.isHidden = true
                    cell.radioButtonWidthConstraint.constant = 20
                    cell.emailRadioButtonWidthConstraint.constant = 0
                    item = self.smsMsgListing?.list[indexPath.row]
                    cell.setText(text: item?.content ?? "")
                    print(item?.content ?? "")
                    cell.setSeletedState(state: selectedTitleRow == indexPath, details: "", indexPath: indexPath)
                    print("isselectsms")
                } else {
                    emailMaualtextView.isHidden = false
                    cell.radioButtonWidthConstraint.constant = 0
                    cell.emailRadioButtonWidthConstraint.constant = 20
                    item = self.emailMsgListing?.list[indexPath.row]
                    cell.setText(text: item?.content ?? "")
                    cell.detailsLabel.text = item?.subject ?? ""
                    print(item?.content ?? "")
                    cell.detailView.isHidden = false
                    cell.setupViewForEmailSelection(isSelected: selectedTitleRow == indexPath, subTitle: item?.subject ?? "", indexPath: indexPath)

                }
                

                if selectedTitleRow == indexPath {
                    
                    if isSelectSMS {
                        emailBodyTitleLabel.text = "Message"
                        self.txtLinkWithCheckOut = item?.content ?? ""
                        emailSubjectView.isHidden = true
                        emailMaualtextView.isHidden = true
                        if self.txtLinkWithCheckOut == "" {
                        } else {
                            emailSubjectTextLabel.text = txtLinkWithCheckOut
                        }
                    } else {
                        emailMaualtextView.isHidden = false
                        emailBodyTitleLabel.text = "Email Body"
                        self.txtDetailForEmail = item?.subject ?? ""
                        if self.txtDetailForEmail == "" {
                            emailSubjectView.isHidden = true
                        } else {
                            emailSubjectView.isHidden = false
                            emailSubjectTextLabel.text = txtDetailForEmail
                        }
                    }
                    //set data to share
                    self.txtLinkWithCheckOut = item?.content ?? ""
                    let finalText = "\(txtLinkWithCheckOut)"
                    txtLinkWithCheckOut = finalText
                    print(self.txtLinkWithCheckOut)
                    self.txtvwpreviewText.text = "\(self.txtLinkWithCheckOut)\n\n\(urlToShare)"
                    self.messageTextPreviewTextView.text = "\(self.txtLinkWithCheckOut)\n\n\(urlToShare)"
                    //                self.lblpreviewText.text = self.txtLinkWithCheckOut
                }
                return cell
            }
            
        }  else if tableView == emailContactTableView {
            let cell:contactTableViewCell = self.contactTableView.dequeueReusableCell(withIdentifier: ContactImportVC.CELL_IDENTIFIER_CONTACT) as! contactTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.cellDelegate = self
            //
            let emailContacts = self.emailContactSection[indexPath.section].contacts
            let contact = emailContacts[indexPath.row]
            cell.lblDisplayName.text = contact.name ?? ""
            cell.lblNumberEmail.text = contact.email ?? ""
            cell.contactImage.image = UIImage.init(named: "User_placeholder")
            cell.mobileContactObj = contact
            cell.inviteButtonView.layer.borderWidth = 0.0
            cell.btnSelect.rowIndex = indexPath.row
            cell.btnSelect.sectionIndex = indexPath.section
            cell.btnSelect.isMobileContact = false
            cell.btnSelect.addTarget(self, action: #selector(selectContactTapped(_:)), for: UIControl.Event.touchUpInside)
            if contact.status == ContactStatus.pending{
                cell.inviteBtn.isHidden = false
                cell.lblInviteButtonTitle.text = "Invite"
                cell.buttonInvite.setTitle("", for: .normal)
                cell.buttonImageview.image = R.image.inviteContact()
                cell.inviteButtonView.isHidden = false
                cell.inviteButtonView.backgroundColor = UIColor(hex6:0x4285F4)
                cell.lblInviteButtonTitle.textColor = .white
            }else if contact.status == ContactStatus.subscriber{
                cell.inviteBtn.isHidden = true
                cell.inviteButtonView.isHidden = true
            }else if contact.status == ContactStatus.invited{
                cell.buttonInvite.isHidden = false

                cell.buttonImageview.image = R.image.invitedContact()
                cell.lblInviteButtonTitle.text = "Invited"
                cell.inviteButtonView.backgroundColor = UIColor(hex6:0xE3E3E3)
                cell.lblInviteButtonTitle.textColor = UIColor(hex6: 0x909090)
                cell.inviteButtonView.isHidden = false
            }else{
                cell.buttonInvite.isHidden = false

                cell.buttonImageview.image = R.image.invitedContact()
                cell.lblInviteButtonTitle.text = "Invited"
                cell.inviteButtonView.backgroundColor = UIColor(hex6:0xE3E3E3)
                cell.lblInviteButtonTitle.textColor = UIColor(hex6: 0x909090)
                cell.inviteButtonView.isHidden = false
            }
            cell.inviteBtn.isHidden = true
            if let registerUser = contact.registeredUserDetails{
                cell.refferalView.isHidden = false
                cell.inviteButtonView.isHidden = true
                cell.contactStatusView.isHidden = false
                cell.lblReferralCount.text = "\(registerUser.refferal ?? 0)"
                cell.lblSubscriberCount.text = "\(registerUser.susbscribers ?? 0)"
                //  cell.lblStatus.text = "\(contact.subscriptionStatus ?? "")".capitalized
                cell.lblStatus.text = ""
                cell.badges = registerUser.badges ?? [ParentBadges]()
                print(registerUser.toJSON())
                cell.setBadges()
            }else{
                cell.refferalView.isHidden = true
                cell.inviteButtonView.isHidden = false
                cell.contactStatusView.isHidden = true
            }
           
            cell.inviteBtn.isHidden = true
            if contact.isSelected{
                cell.btnSelect.isSelected = true
            }else{
                cell.btnSelect.isSelected = false
            }
            if self.isSelectModeOn{
                if contact.status == ContactStatus.invited ||  contact.status == ContactStatus.pending{
                    cell.btnSelect.isHidden = false
                }
                cell.inviteButtonView.isHidden = true
            }else{
                cell.btnSelect.isHidden = true
            }
            return cell
        }else {
            let cell:contactTableViewCell = self.contactTableView.dequeueReusableCell(withIdentifier: ContactImportVC.CELL_IDENTIFIER_CONTACT) as! contactTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.cellDelegate = self
           
            
                let mobileContacts = self.contactSections[indexPath.section].contacts
                let contact = mobileContacts[indexPath.row]
                cell.lblDisplayName.text = contact.name ?? ""
                cell.lblNumberEmail.text = contact.mobile
                cell.contactImage.image = UIImage.init(named: "User_placeholder")
                cell.mobileContactObj = contact
                cell.btnSelect.rowIndex = indexPath.row
                cell.btnSelect.sectionIndex = indexPath.section
                cell.btnSelect.isMobileContact = true
                cell.btnSelect.addTarget(self, action: #selector(selectContactTapped(_:)), for: UIControl.Event.touchUpInside)
                if contact.status == ContactStatus.pending{
                    cell.inviteBtn.isHidden = false
                    cell.lblInviteButtonTitle.text = "Invite"
                    cell.buttonInvite.setTitle("", for: .normal)
                    cell.buttonImageview.image = R.image.inviteContact()
                    cell.inviteButtonView.isHidden = false
                    cell.inviteButtonView.backgroundColor = UIColor(hex6:0x4285F4)
                    cell.lblInviteButtonTitle.textColor = .white
                }else if contact.status == ContactStatus.opened{
                    cell.buttonInvite.isHidden = true
                    cell.buttonImageview.image = R.image.contactOpened()
                    cell.lblInviteButtonTitle.text = "Opened"
                    cell.inviteButtonView.backgroundColor = UIColor(hex6:0xE9F1FF)
                    cell.lblInviteButtonTitle.textColor = UIColor(hex6: 0x4285F4)
                    cell.inviteButtonView.isHidden = false
                    
                } else if contact.status == ContactStatus.optout{
                    cell.buttonInvite.isHidden = true
                    cell.buttonImageview.image = R.image.optOutContact()
                    cell.lblInviteButtonTitle.text = "Opt-out"
                    cell.inviteButtonView.backgroundColor = UIColor(hex6:0xFFE9E9)
                    cell.lblInviteButtonTitle.textColor = UIColor(hex6: 0xFF0536)
                    cell.inviteButtonView.isHidden = false
                    
                }else if contact.status == ContactStatus.subscriber{
                    cell.inviteBtn.isHidden = true
                    cell.inviteButtonView.isHidden = true
                }else{
                    cell.buttonInvite.isHidden = false

                    cell.buttonImageview.image = R.image.invitedContact()
                    cell.lblInviteButtonTitle.text = "Invited"
                    cell.inviteButtonView.backgroundColor = UIColor(hex6:0xE3E3E3)
                    cell.lblInviteButtonTitle.textColor = UIColor(hex6: 0x909090)
                    cell.inviteButtonView.isHidden = false
                }
                cell.inviteBtn.isHidden = true
                
                if let registerUser = contact.registeredUserDetails{
                    cell.refferalView.isHidden = false
                    cell.inviteButtonView.isHidden = true
                    cell.contactStatusView.isHidden = false
                    cell.lblReferralCount.text = "\(registerUser.refferal ?? 0)"
                    cell.lblSubscriberCount.text = "\(registerUser.susbscribers ?? 0)"
                
                    cell.lblStatus.text = ""
                    cell.setBadges()
                }else{
                    cell.refferalView.isHidden = true
                    cell.inviteButtonView.isHidden = false
                    cell.contactStatusView.isHidden = true
                }
                if contact.isSelected{
                    cell.btnSelect.isSelected = true
                }else{
                    cell.btnSelect.isSelected = false
                }
                if self.isSelectModeOn{
                    if contact.status == ContactStatus.invited ||  contact.status == ContactStatus.pending{
                        cell.btnSelect.isHidden = false
                    }
                    cell.inviteButtonView.isHidden = true
                }else{
                    cell.btnSelect.isHidden = true
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
            
            selectedTitleRow = indexPath
            itemsTableView.reloadData()
//            if indexPath.section == 0 {
//                print(indexPath.row)
//            } else {
//                if selectedTitleRow != indexPath.row {
//                    selectedTitleRow = indexPath.row
//    //                let item = self.listingResponse?.list[indexPath.row]
//    //                if item != nil {
//    //                    self.txtLinkWithCheckOut = item?.content ?? ""
//    //                }
//                    itemsTableView.reloadData()
//    //                if txtLinkWithCheckOut != "" {
//    //                    let finalText = "\(greetingMessage) \(txtLinkWithCheckOut)"
//    //                    txtLinkWithCheckOut = finalText
//    //                    print(txtLinkWithCheckOut)
//    //                }
//                }
//            }
        } else{
            if tableView == emailContactTableView {
                
            } else {
            self.view.endEditing(true)
            print("&&&&&&&&&&&&&&")
            print(indexPath.row)
            let contact = mobileContacts[indexPath.row] as ContactResponse
            selectedPhoneContact = contact
            print("&&&&&&&&&&&&&&")
            }
        }
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if tableView == itemsTableView{
            return UISwipeActionsConfiguration(actions: [])
            
        }else if tableView == emailContactTableView{
            if indexPath.section == 1{
                return UISwipeActionsConfiguration(actions: [])
            }
            let ishide = self.emailContactSection[indexPath.section].contacts[indexPath.row].hide ?? false
            let editAction = UIContextualAction(style: .normal, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                let contact = self.emailContactSection[indexPath.section].contacts[indexPath.row]
                self.hideContact(contact:contact,index:indexPath.row,hide:ishide)
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
            let ishide = self.contactSections[indexPath.section].contacts[indexPath.row].hide ?? false
            let editAction = UIContextualAction(style: .normal, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                let contact = self.contactSections[indexPath.section].contacts[indexPath.row]
                self.hideContact(contact:contact,index:indexPath.row,hide:ishide)
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
        if let indexPath = configuration.identifier as? IndexPath, let cell = tableView.cellForRow(at: indexPath) as? contactTableViewCell{
            
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
                            let emailContacts = self.emailContactSection[indexPath.section].contacts
                            let contact = emailContacts[indexPath.row]
                            print(contact.email ?? "")
                            self.deleteContact(contact: contact, isEmail: true, index: indexPath.row)
                            
                        }else if tableView == self.contactTableView{
                            let mobileContacts = self.contactSections[indexPath.section].contacts
                            let contact = mobileContacts[indexPath.row]
                            print(contact.mobile ?? "")
                            self.deleteContact(contact: contact, isEmail: false, index: indexPath.row)
                        }
                    }else{
                        self.deleteContactConfirmationView.superview?.tag = indexPath.section
                        self.deleteContactConfirmationView.tag = indexPath.row
                        print(self.deleteContactConfirmationView.superview?.tag ?? 0)
                        print(self.deleteContactConfirmationView.tag)
                        self.deleteContactConfirmationView.isHidden = false
                    }
                    
                },UIAction(title: "Edit", image: UIImage(systemName: "")) { action in
                    if tableView == self.emailContactTableView{
                        let emailContacts = self.emailContactSection[indexPath.section].contacts
                        let contact = emailContacts[indexPath.row]
                       // let contact = self.emailContacts[indexPath.row]
                        if let contactEdit = R.storyboard.contactWizardwithAboutUs.contactEditVC() {
                            contactEdit.contact = contact
                            contactEdit.isEmail = true
                            contactEdit.delegate = self
                            
                            self.present(contactEdit, animated: true, completion: nil)
                        }
                        print(contact.email ?? "")
                    }else if tableView == self.contactTableView{
                        let mobileContacts = self.contactSections[indexPath.section].contacts
                        let contact = mobileContacts[indexPath.row]
                        //let contact = self.mobileContacts[indexPath.row]
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
        contactTableView.reloadData()
        emailContactTableView.reloadData()
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
        selectedTitleRow = nil
        pageNo = pageNo - 1
        setupPage()
    }
    
    @IBAction func nextClick(_ sender: UIButton) {
        if isFromContactManager{
            if pageNo == 5 {
                if self.selectedContactManage == nil{
//                    self.view.makeToast(("Please select contact"))
                    DispatchQueue.main.async {
                        self.view.makeToast("Please select contact", duration: ToastManager.shared.duration, position: .bottom)
                    }
                    
                }
            }else if pageNo == 5{
                if self.selectedContactManage == nil{
//                    showToast("Please select contact")
                    DispatchQueue.main.async {
                        self.view.makeToast("Please select contact", duration: ToastManager.shared.duration, position: .bottom)
                    }
                }
            }else if pageNo == 3 {
                guard selectedTitleRow != nil else {
                    DispatchQueue.main.async {
                        self.view.makeToast("Please Choose Message to send", duration: ToastManager.shared.duration, position: .bottom)
                    }
                    return
                }
                let rows = itemsTableView.numberOfRows(inSection: 0)
                if rows == 0 {
                    showAlert(alertMessage: "No text available to send")
                    return
                }
                pageNo = 4
                self.setupPage()
            }else if pageNo == 4{
                if self.shareType == ShareType.textShare{
                   
                    self.validateInvite(contact:self.selectedContactManage!, completion: { success in
                        if success ?? false{
                            self.openMessageComposer(mobileContact:self.selectedContactManage!,reInvite:false)
                        }
                    })
                }else{
                    self.validateInvite(contact:self.selectedContactManage!, completion: { success in
                        if success ?? false{
                            self.openMessageComposer(mobileContact:self.selectedContactManage!,reInvite:false)
                        }
                    })
                }
                
            }
            return
        }
        if pageNo == 1 {
            pageNo = 2
            self.setupPage()
        }
        else if pageNo == 2 {
            pageNo = 3
            self.setupPage()
        }
        else if pageNo == 3 {
            guard selectedTitleRow != nil else {
                DispatchQueue.main.async {
                    self.view.makeToast("Please Choose Message to send", duration: ToastManager.shared.duration, position: .bottom)
                }
                return
            }
            if selectedTitleRow == IndexPath(row: 0, section: 0)  {
                if isSelectSMS {
                    guard txtLinkWithCheckOut != "" else {
                        DispatchQueue.main.async {
                            self.view.makeToast("Please Enter Message to send", duration: ToastManager.shared.duration, position: .bottom)
                        }
                        return
                    }
                } else {
                    guard emailSubjectTextLabel.text != "" || emailSubjectTextLabel.text != nil else {
                        DispatchQueue.main.async {
                            self.view.makeToast("Please Enter Email Subject to send", duration: ToastManager.shared.duration, position: .bottom)
                        }
                        return
                    }
                    
                    guard txtDetailForEmail != "" else {
                        DispatchQueue.main.async {
                            self.view.makeToast("Please Enter Email Body to send", duration: ToastManager.shared.duration, position: .bottom)
                        }
                        return
                    }
                }
            }
            let rows = itemsTableView.numberOfRows(inSection: 0)
            if rows == 0 {
                showAlert(alertMessage: "No text available to send")
                return
            }
            pageNo = 4
            self.setupPage()
        }
        else if pageNo == 4 {
            
            if self.shareType == ShareType.socialShare{
                let referSuccess = ReferSuccessVC(nibName: R.nib.referSuccessVC.name, bundle: nil)
                referSuccess.callback = { message in
                    self.pageNo = 1
                    self.setupPage()
                }
                referSuccess.isFromOnboarding = self.isFromOnboarding
                selectedPhoneContact = nil
                navigationController?.pushViewController(referSuccess, animated: true)
                
            } else {
                pageNo = 5
                self.setupPage()
                isSelectSMS = true
                if isSelectSMS {
                    if self.shareType == ShareType.textShare{
                        textMessageSelected(sender: UIButton())
                    }else if self.shareType == ShareType.email{
                        emailSelected(sender: UIButton())
                    }
                } else {
                    if self.shareType == ShareType.textShare{
                        textMessageSelected(sender: UIButton())
                        isSelectSMS = false
                    }else if self.shareType == ShareType.email{
                        emailSelected(sender: UIButton())
                        isSelectSMS = false
                    }
                }
            }
        }
        else if sender.tag == 3 {
            
            let referSuccess = ReferSuccessVC(nibName: R.nib.referSuccessVC.name, bundle: nil)
            referSuccess.callback = { message in
                self.pageNo = 1
                self.setupPage()
            }
            referSuccess.isFromOnboarding = self.isFromOnboarding
            selectedPhoneContact = nil
            navigationController?.pushViewController(referSuccess, animated: true)
        }
    }
    
    
    @IBAction func didTapQuickTourButton(_ sender: UIButton) {

        selectedShareTitleLabel.text = "Share your QuickCam QuickTour link"
        urlToShare = "https://quickcam.app/quick-tour"
        
        if isFromContactManager{
            pageNo = 3
            setupPage()
            setupUIBasedOnUrlToShare()
        }else{
            pageNo = 2
            setupPage()
            setupUIBasedOnUrlToShare()
        }
    }
    
    
    @IBAction func didTapReferalButtonClick(_ sender: UIButton) {
        
        selectedShareTitleLabel.text = "Share your Referral Page invite link"
        if let shareUrl = Defaults.shared.currentUser?.referralPage {
           urlToShare = shareUrl
        }
        if isFromContactManager{
            pageNo = 3
            setupPage()
            setupUIBasedOnUrlToShare()
        }else{
            pageNo = 2
            setupPage()
            setupUIBasedOnUrlToShare()
        }
       
    }
    
    @IBAction func didTapQuickStartButton(_ sender: Any) {
        selectedShareTitleLabel.text = "Share your QuickStart Invite Link"
        if let shareUrl = Defaults.shared.currentUser?.quickStartPage {
           urlToShare = shareUrl
        }
        if isFromContactManager{
            pageNo = 3
            setupPage()
            setupUIBasedOnUrlToShare()
        }else{
            pageNo = 2
            setupPage()
            setupUIBasedOnUrlToShare()
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
//        if let channelId = Defaults.shared.currentUser?.channelId {
            UIPasteboard.general.string = urlToShare//"\(websiteUrl)/\(channelId)"
            DispatchQueue.runOnMainThread {
                Utils.appDelegate?.window?.makeToast(R.string.localizable.linkCopied())
            }
//        }
    }
    @IBAction func btnQuickCamAppAction(_ sender: UIButton) {
    }
    @IBAction func showTooltipAction(_ sender: UIButton) {
        for view in page0view.subviews {
            if view is EasyTipView {
                view.removeFromSuperview()
            }
        }
        if sender.tag == 101 {
            EasyTipView.show(forView: sender,
                             withinSuperview: page0view,
                             text: R.string.localizable.quickstartTooltip(),
                             delegate: self)
        }
        else if sender.tag == 102 {
            EasyTipView.show(forView: sender,
                             withinSuperview: page0view,
                             text: R.string.localizable.referralTooltip(),
                             delegate: self)
        }
        else if sender.tag == 103 {
            EasyTipView.show(forView: sender,
                             withinSuperview: page0view,
                             text: R.string.localizable.quickTourToolTip(),
                             delegate: self)
        }
    }
    
    @IBAction func btnBusinessDashboardAction(_ sender: UIButton) {
        
        if Defaults.shared.isDoNotShowAgainOpenBusinessCenterPopup {
            if let viewController = R.storyboard.storyCameraViewController.businessDashboardWebViewVC() {
                navigationController?.pushViewController(viewController, animated: true)
            }
        } else {
            businessDashbardConfirmPopupView.isHidden = false
        }
//        let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsVC()!
//        navigationController?.pushViewController(storySettingsVC, animated: true)
    }
    @IBAction func btnTextShareAction(_ sender: UIButton) {
        self.shareType = ShareType.textShare
        isSelectSMS = true
        pageNo = 3
        self.setupPage()
        self.itemsTableView.reloadData()
    }
    @IBAction func btnQRCodeShareAction(_ sender: UIButton) {
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
        self.socialSharePopupView.isHidden = false
    }
    
    func share(shareText: String?, shareImage: URL?) {
        var objectsToShare = [Any]()

        if let shareTextObj2 = shareText {
            objectsToShare.append(shareTextObj2)
        }
        
        if let shareImageObj = shareImage{
            objectsToShare.append(shareImageObj)
        }
        
        UIPasteboard.general.string = shareText
//        if let shareTextObj2 = shareText {
//            objectsToShare.append(shareTextObj2)
//        }
//
        print(objectsToShare)
        
        if let text = shareText {
            let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.showToast("Paste Your text on clipboard")
            present(activityViewController, animated: true, completion: nil)            
            activityViewController.completionWithItemsHandler = { activity, success, items, error in
                if !success{
                    print("cancelled")
                    return
                }
                
                if activity == .message {
                    var text = items
                    text?.removeFirst()
                    print("Default Messanger")
                }
            }
            
        }else{
            print("There is nothing to share")
        }
    }
    
    
    @IBAction func enableContactClicked(_ sender: UIButton) {
        
        ContactPermission()
    }
    @IBAction func businessDahboardConfirmPopupOkButtonClicked(_ sender: UIButton) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        Defaults.shared.addEventWithName(eventName: Constant.EventName.cam_Bdashboard)
        businessDashbardConfirmPopupView.isHidden = true
        
        if let viewController = R.storyboard.storyCameraViewController.businessDashboardWebViewVC() {
            navigationController?.pushViewController(viewController, animated: true)
        }
//        if let token = Defaults.shared.sessionToken {
//        let urlString = "\(websiteUrl)/redirect?token=\(token)"
//       let urlString = "\(websiteUrl)/share-wizard?redirect_uri=\(redirectUri)"
//        print(urlString)
//        guard let url = URL(string: urlString) else {
//                return
//        }
//            presentSafariBrowser(url: url)
//        }
//        let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsVC()!
//        navigationController?.pushViewController(storySettingsVC, animated: true)
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
            self.selectedContactManage = mobilecontact
            if reInvite{
                self.inviteAgainpopup.isHidden = false
                self.inviteAgainLabel.text = "Invite \(mobilecontact.name ?? "") again?"
                return
            }
            
            let phoneNum = mobilecontact.mobile ?? ""
            let urlString = self.txtLinkWithCheckOut

            if selectedContactType == ContactType.mobile{
                if !MFMessageComposeViewController.canSendText() {
                        //showAlert("Text services are not available")
                        return
                }
                let reflink = urlToShare//"\(websiteUrl)/\(Defaults.shared.currentUser?.channelId ?? "")"
                let json = ["contactId":"\(mobilecontact.Id ?? "")",
                            "refType":"text"]
                var str = ""
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    let jsonString = String(data: jsonData, encoding: .utf8)!
                    str = jsonString.toBase64()
                } catch _ as NSError {
                }
                let urlwithString = urlString + "\n" + "\n" + reflink + "?refCode=\(str)"
                let textComposer = MFMessageComposeViewController()
                textComposer.messageComposeDelegate = self
                let recipients:[String] = [phoneNum]
                textComposer.body = urlwithString
                textComposer.recipients = recipients


                present(textComposer, animated: true)
            
            } else {
                let reflink = urlToShare//"\(websiteUrl)/\(Defaults.shared.currentUser?.channelId ?? "")"
                let json = ["contactId":"\(mobilecontact.Id ?? "")",
                            "refType":"email"]
                var str = ""
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    let jsonString = String(data: jsonData, encoding: .utf8)!
                    str = jsonString.toBase64()
                } catch _ as NSError {
                }
                let urlwithString = urlString + "\n" + "\n" + reflink + "?refCode=\(str)"
                
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients([mobileContact?.email ?? ""])
                    mail.setSubject(self.txtDetailForEmail)
                    mail.setMessageBody(urlwithString, isHTML: false)
                    
                    /* let imageData = imageV.jpegData(compressionQuality: 1.0)
                     mail.addAttachmentData(imageData!, mimeType: "image/jpg", fileName: "photo.jpg") */
                    present(mail, animated: true)
                    
                    // Show third party email composer if default Mail app is not present
                }  else {
                    
                    self.emailSubjectstr = self.txtDetailForEmail
                    self.emailBodystr = urlwithString
                    self.toEmailAddress = mobileContact?.email ?? ""
                    let defaulEmail = Defaults.shared.defaultEmailApp
                    if defaulEmail?.lowercased()  == "gmail" {
                        gmailOptionSelected(UIButton())
                    } else if defaulEmail?.lowercased()  == "apple" {
                        appleEmailOptionSelected(UIButton())
                    } else {
                        self.emailOptionsMainView.isHidden = false
                    }
                }
            }
            
        }
    }
    
    private func createEmailUrl(to: String, subject: String, body: String,isGmail:Bool) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        
        if isGmail{
            let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
            if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
                return gmailUrl
            }
        }else{
            let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
            if let defaultUrl = defaultUrl, UIApplication.shared.canOpenURL(defaultUrl) {
                return defaultUrl
            }
            
        }
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        //TODO: In future if need to add other mail options
        //                let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        //                let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        //                let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        }
        // else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
        //                    return outlookUrl
        //                } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
        //                    return yahooMail
        //                } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
        //                    return sparkUrl
        //                }
        
        return defaultUrl
    }
    func inviteMultipleContactClicked(){
        
    }
    func didPressButton(_ contact: PhoneContact, mobileContact:ContactResponse?,reInvite :Bool = false) {
        if let mobilecontact = mobileContact{
            self.selectedContact = mobilecontact
            self.selectedContactManage = mobilecontact
            if isFromContactManager{
                self.nextClick(btnNext)
                return
            }
            
            if reInvite{
                self.inviteAgainpopup.isHidden = false
                self.inviteAgainLabel.text = "Invite \(mobilecontact.name ?? "") again?"
                return
            }
        
            
            self.validateInvite(contact:mobilecontact, completion: { success in
                if success ?? false{
                    self.openMessageComposer(mobileContact:mobilecontact,reInvite:reInvite)
                }
            })

        }else{
            
            if isFromContactManager{
                self.nextClick(btnNext)
                return
            }
            
            
            let urlString = self.txtLinkWithCheckOut

            let urlwithString = urlString + "\n" + "\n" + urlToShare//"
           

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
            
            let mobileContacts = self.contactSections[deleteContactConfirmationView.superview?.tag ?? 0].contacts
            let contact = mobileContacts[deleteContactConfirmationView.tag]
            print(contact.name ?? "")
            print(contact.mobile ?? "")
            self.deleteContact(contact: contact, isEmail: false, index: deleteContactConfirmationView.tag)
            
        }else{
            
            let emailContacts = self.emailContactSection[deleteContactConfirmationView.superview?.tag ?? 0].contacts
            let contact = emailContacts[deleteContactConfirmationView.tag]
            print(contact.email ?? "")
            self.deleteContact(contact: contact, isEmail: true, index: deleteContactConfirmationView.tag)
            
        }
    }
    @IBAction func deleteContactNoClick(_ sender: UIButton) {
        deleteContactConfirmationView.isHidden = true
    }
    
    @IBAction func appleEmailOptionSelected(_ sender: UIButton) {
        if setDefaultEmailAppButton.isSelected {
            Defaults.shared.defaultEmailApp = "apple"
        }
        self.emailOptionsMainView.isHidden = true
        if let emailUrl = createEmailUrl(to:self.toEmailAddress, subject:self.emailSubjectstr, body: self.emailBodystr, isGmail: false) {
            UIApplication.shared.open(emailUrl) { sucess in
                if sucess{
                    self.isAppleEmailOpened = true
                }else{
                    self.isAppleEmailOpened = false
                }
            }
        }
    }
    
    @IBAction func gmailOptionSelected(_ sender: UIButton) {
        if setDefaultEmailAppButton.isSelected {
            Defaults.shared.defaultEmailApp = "gmail"
        }
        self.emailOptionsMainView.isHidden = true
        if let emailUrl = createEmailUrl(to:self.toEmailAddress, subject:self.emailSubjectstr, body: self.emailBodystr, isGmail: true) {
            UIApplication.shared.open(emailUrl) { sucess in
                if sucess{
                    self.isGmailOpened = true
                }else{
                    self.isGmailOpened = false
                }
            }
        }
    }

    @IBAction func setDefaultEmailAppAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
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
    /* func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == contactTableView || scrollView == emailContactTableView{
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            print(offsetY >= contentHeight - scrollView.frame.height)
            print(!loadingStatus)
            if ((offsetY) >= contentHeight - scrollView.frame.height - 150.0) && !loadingStatus {
              //  self.showLoader()
                selectedContactType == ContactType.mobile ? contactTableView.reloadData() : emailContactTableView.reloadData()
            }
        }
        
    }
   */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == contactTableView || scrollView == emailContactTableView{
           let offsetY = scrollView.contentOffset.y
//            print("offsetY \(offsetY)")
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
            
            if self.loadingStatus{
                return
            }
            if self.contactTableView.isHidden == true {
                if emailContactTableView.contentSize.height > (124.0 + 50.0 + self.emailContactTableView.frame.size.height){
                    
                }else{
                    return
                }
            } else {
                if contactTableView.contentSize.height > (124.0 + 50.0 + self.contactTableView.frame.size.height){
                    
                }else{
                    return
                }
            }
        if (self.lastContentOffset > scrollView.contentOffset.y) {
                // move up
            self.segmentViewHeight.constant = 124.0
            self.stepViewHeight.constant = 50.0
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.view.layoutIfNeeded()
                })
            }
            else if (self.lastContentOffset < scrollView.contentOffset.y) {
               // move down
                self.segmentViewHeight.constant = 0.0
                self.stepViewHeight.constant = 0.0
                UIView.animate(withDuration: 0.5, animations: {
                   
                    self.view.layoutIfNeeded()
                })
            }

            // update the new position acquired
            self.lastContentOffset = scrollView.contentOffset.y
        }
        else if scrollView == filterScrollview
        {
            let rightOffset = CGPoint(x: scrollView.contentSize.width - scrollView.bounds.size.width, y: 0)
            if scrollView.contentOffset.x == 0.0 {
                leftFilterArrowButton.tintColor = .lightGray
                rightFilterArrowButton.tintColor = .black
            } else if scrollView.contentOffset.x == rightOffset.x {
                leftFilterArrowButton.tintColor = .black
                rightFilterArrowButton.tintColor = .lightGray
             } else {
                leftFilterArrowButton.tintColor = .black
                rightFilterArrowButton.tintColor = .black
            }
        }

    }
}
extension ContactImportVC:EasyTipViewDelegate,SharingDelegate {
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
    }
    
    func easyTipViewDidTap(_ tipView: EasyTipView) {
        
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        
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

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}

extension ContactImportVC: MessageTitleDelagate {
    func getTextFromWhenUserEnter(textViewText: String, tag: Int) {
        switch tag {
        case 1:
            self.txtLinkWithCheckOut = textViewText
            self.messageTextPreviewTextView.text = "\(self.txtLinkWithCheckOut)\n\n\(urlToShare)"
        case 2:
            self.txtLinkWithCheckOut = textViewText
            if textViewText == "" {
                emailSubjectView.isHidden = true
            } else {
                emailSubjectView.isHidden = false
                emailSubjectTextLabel.text = textViewText
            }
        case 3:
            self.txtDetailForEmail = textViewText
            self.txtvwpreviewText.text = "\(textViewText)\n\n\(urlToShare)"
        default:
            break
        }
    }
}
