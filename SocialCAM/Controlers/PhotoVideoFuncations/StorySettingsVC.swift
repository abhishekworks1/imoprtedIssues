//
//  StorySettingsVC.swift
//  ProManager
//
//  Created by Jasmin Patel on 21/06/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import GoogleSignIn
import SafariServices
import Alamofire
import SDWebImage
import Reorder

enum SettingsMode: Int, Codable {
    case subscriptions = 0
    case socialLogins
    case faceDetection
    case supportedFrameRates
    case swapeContols
    case cameraSettings
    case socialConnections
    case channelManagement
    case socialLogout
    case logout
    case controlcenter
    case video
    case appInfo
    case appStartScreen
    case guidelineType
    case guidelineTickness
    case guidelineColor
    case guildlines
    case termsAndConditions
    case privacyPolicy
    case watermarkAlpha30 = 30
    case watermarkAlpha50 = 50
    case watermarkAlpha80 = 80
    case subscription
    case goToWebsite
    case watermarkSettings
    case fatesteverWatermark
    case applIdentifierWatermark
    case videoResolution
    case applicationSurvey
    case instruction
    case intellectualProperties
    case madeWithGif
    case pic2Art
    case help
    case edit
    case quickLink
    case deleteAccount
    case system
    case showAllPopups
    case accountSettings
    case referringChannelName
    case skipYoutubeLogin
    case saveVideoAfterRecording
    case autoSaveAfterEditing
    case muteRecordingSlowMotion
    case muteRecordingFastMotion
    case shareSetting
    case userDashboard
    case notification
    case newSignupsNotificationSetting
    case newSubscriptionNotificationSetting
    case milestoneReachedNotification
    case publicDisplayName
    case privateDisplayName
    case email
    case checkUpdate
    case referringChannel
    case qrcode
    case mutehapticFeedbackOnSpeedSelection
    case publicDisplaynameWatermark
    case editProfileCard
    case socialMediaConnections
    case hapticNone
    case hapticAll
    case hapticSome
    case aboutPage
    case autoSavePic2Art
    case onboarding
    case openingScreen
    case quickCamCamera
    case mobileDashboard
}

class StorySetting: Codable {
       var name: String
    var selected: Bool
    var image: UIImage?
    var selectedImage: UIImage?
    
    init(name: String, selected: Bool, image: UIImage? = UIImage(), selectedImage: UIImage? = UIImage()) {
        self.name = name
        self.selected = selected
        self.image = image
        self.selectedImage = selectedImage
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case selected
        case image
        case selectedImage
    }
    
    required init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        name = (try? container?.decode(String.self, forKey: .name)) ?? ""
        // image = (try? container?.decode(UIImage.self, forKey: .image)) ?? UIImage()
        // selectedImage = (try? container?.decode(selectedImage.self, forKey: .selectedImage)) ?? UIImage()
        selected = (try? container?.decode(Bool.self, forKey: .selected)) ?? false
    }
    
    func encode(to encoder: Encoder) {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(name, forKey: .name)
        // try? container.encode(image, forKey: .image)
        // try? container.encode(selectedImage, forKey: .selectedImage)
        try? container.encode(selected, forKey: .selected)
    }
}

class StorySettings: Codable {
    
    var name: String
    var settings: [StorySetting]
    var settingsType: SettingsMode
    var isCollapsible: Bool {
        return true
    }
    var isCollapsed = false
    
    init(name: String, settings: [StorySetting], settingsType: SettingsMode) {
        self.name = name
        self.settings = settings
        self.settingsType = settingsType
    }
    
    enum CodingKeys: String, CodingKey {
            case name
            case settings
            case settingsType
            case isCollapsible
            case isCollapsed
        }

        required init(from decoder: Decoder) {
            let container = try? decoder.container(keyedBy: CodingKeys.self)
            name = (try? container?.decode(String.self, forKey: .name)) ?? "0"
            settings = (try? container?.decode([StorySetting].self, forKey: .settings)) ?? [StorySetting]()
            settingsType = (try? container?.decode(SettingsMode.self, forKey: .settingsType)) ?? SettingsMode.aboutPage
            isCollapsed = (try? container?.decode(Bool.self, forKey: .isCollapsed)) ?? false
        }

        func encode(to encoder: Encoder) {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try? container.encode(name, forKey: .name)
            try? container.encode(settings, forKey: .settings)
            try? container.encode(isCollapsible, forKey: .isCollapsible)
            try? container.encode(settingsType, forKey: .settingsType)
            try? container.encode(isCollapsed, forKey: .isCollapsed)
        }
    
    static var storySettings = /*[StorySettings(name: R.string.localizable.subscriptions(),
                                              settings: [StorySetting(name: R.string.localizable.free(),
                                                                      selected: true),
                                                         StorySetting(name: R.string.localizable.basic(),
                                                                      selected: false),
                                                         StorySetting(name: R.string.localizable.advanced(),
                                                                      selected: true),
                                                         StorySetting(name: R.string.localizable.professional(),
                                                                      selected: true)], settingsType: .subscriptions), */
                                [StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.businessDashboard(), selected: false)], settingsType: .userDashboard),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.subscriptions(), selected: false)], settingsType: .subscription),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.notifications(), selected: false)], settingsType: .notification),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.shareYourReferralLink(), selected: false)], settingsType: .shareSetting),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.qrCode(), selected: false)], settingsType: .qrcode),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.cameraSettings(), selected: false)], settingsType: .cameraSettings),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.editProfileCard(), selected: false)], settingsType: .editProfileCard),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.howItWorks(), selected: false)], settingsType: .help),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.accountSettings(), selected: false)], settingsType: .accountSettings),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.system(), selected: false)], settingsType: .system),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.checkUpdates(), selected: false)], settingsType: .checkUpdate),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: "About", selected: false)], settingsType: .aboutPage),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.logout(), selected: false)], settingsType: .logout)]
    
   /* StorySettings(name: "",
                  settings: [StorySetting(name: R.string.localizable.referringChannelOption(), selected: false)], settingsType: .referringChannel), */
    
    /*StorySettings(name: "",
                  settings: [StorySetting(name: R.string.localizable.socialMediaConnections(), selected: false)], settingsType: .socialMediaConnections) */
}

class StorySettingsVC: UIViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var youTubeVerifiedView: UIView!
    @IBOutlet weak var snapVerifiedView: UIView!
    @IBOutlet weak var faceBookVerifiedView: UIView!
    @IBOutlet weak var twitterVerifiedView: UIView!
    @IBOutlet weak var preLunchBadge: UIImageView!
    @IBOutlet weak var foundingMergeBadge: UIImageView!
    @IBOutlet weak var socialBadgeicon: UIImageView!
    @IBOutlet weak var subscriptionBadgeicon: UIImageView!
    
    @IBOutlet weak var userPlaceHolderImageView: UIImageView!
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var joinedDateLabel: UILabel!
    @IBOutlet weak var userNametitleLabel: UILabel!
    @IBOutlet weak var profileDisplayView: UIView!
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var lblAppInfo: UILabel!
    @IBOutlet weak var imgAppLogo: UIImageView!
    @IBOutlet weak var lblLogoutPopup: UILabel!
    @IBOutlet weak var logoutPopupView: UIView!
    @IBOutlet weak var longPressPopupView: UIView!
    @IBOutlet weak var doubleButtonStackView: UIStackView!
    @IBOutlet weak var singleButtonSttackView: UIStackView!
    @IBOutlet var btnTable: UIButton!
    @IBOutlet var btnCollection: UIButton!
    @IBOutlet weak var businessDashboardStackView: UIStackView!
    @IBOutlet weak var businessDashboardButton: UIButton!
    @IBOutlet weak var businessDashbardConfirmPopupView: UIView!
    @IBOutlet weak var btnDoNotShowAgainBusinessConfirmPopup: UIButton!
    @IBOutlet weak var settingCollectionView: UICollectionView!
    
    
    //new settings header
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var btnProfilePic: UIButton!
  
    @IBOutlet weak var imgSocialMediaBadge: UIImageView!
    @IBOutlet weak var imgprelaunch: UIImageView!
    @IBOutlet weak var imgfoundingMember: UIImageView!
    @IBOutlet weak var imgSubscribeBadge: UIImageView!

    @IBOutlet weak var bottomCopyRightView: UIView!
    @IBOutlet weak var tableViewBottomConstraints: NSLayoutConstraint!
    private var lastContentOffset: CGFloat = 0
//
//    @IBOutlet weak var iconSettingsImage: UIImageView!
//    @IBOutlet weak var badgesView: UIStackView!
//
    // MARK: - Variables declaration
    var isDeletePopup = false
    let releaseType = Defaults.shared.releaseType
    private lazy var storyCameraVC = StoryCameraViewController()
    var notificationUnreadCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton.imageView?.contentMode = .scaleAspectFit
        self.backButton.imageEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
      
       /* let json = """
        {
            "contactId":"vhjgjghjhgjkvhjgjghjhgjk",
            "refType":"qrCode"
        }
        """
     
        print("**********Josn String To Base 64**************")
        let str = json.toBase64()
        print(str)
        print("************Josn String From Base 64************")
        print(str.fromBase64() ?? "No Json Data Found")
        print("************************")
    */
        self.setUpCopyRightView()
        settingCollectionView.register(UINib(nibName: "SettingsCollectionCell", bundle: .main), forCellWithReuseIdentifier: "SettingsCollectionCell")
        settingCollectionView.dataSource = self
        settingCollectionView.delegate = self
        guard let collectionView = settingCollectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let margin: CGFloat = 10
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
         self.faceBookVerifiedView.isHidden = true
        self.twitterVerifiedView.isHidden = true
        self.snapVerifiedView.isHidden = true
        self.youTubeVerifiedView.isHidden = true
        lblAppInfo.text = "\(Constant.Application.displayName) - \(Constant.Application.appVersion)(\(Constant.Application.appBuildNumber))"
        lblLogoutPopup.text = R.string.localizable.areYouSureYouWantToLogoutFromApp("\(Constant.Application.displayName)")
        setupUI()
       
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        longpress.minimumPressDuration = 0.5
        settingsTableView.addGestureRecognizer(longpress)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileView))
        tapGesture.numberOfTapsRequired = 1
        profileDisplayView.addGestureRecognizer(tapGesture)
        
        settingsTableView.reorder.delegate = self
        settingCollectionView.reorder.delegate = self
        
        if Defaults.shared.settingsPreference == 1 {
            showCollectionAction(UIButton())
        } else {
            showTableAction(UIButton())
        }
        
        if let count = Defaults.shared.currentUser?.unreadCount {
            self.notificationUnreadCount = count
        }
        self.getUserNotificationModel { isSuccess in}
    }
  
    @objc func didTapProfileView(sender: UITapGestureRecognizer) {
        profileDisplayView.isHidden = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        StorySettings.storySettings = Defaults.shared.userStorySettings ?? StorySettings.storySettings
        self.settingsTableView.reloadData()
        setUpProfileHeader()
        storyCameraVC.syncUserModel { _ in
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Defaults.shared.userStorySettings = StorySettings.storySettings
}
    deinit {
        print("Deinit \(self.description)")
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            let touchPoint = sender.location(in: settingsTableView)
            if let indexPath = settingsTableView.indexPathForRow(at: touchPoint) {
                if indexPath.row == 4 {
                    let urlString = "\(websiteUrl)/\(Defaults.shared.currentUser?.channelId ?? "")"
                    UIPasteboard.general.string = urlString
                    longPressPopupView.isHidden = false
                }
            }
        default:
            break
        }
    }
    // MARK: - Setup UI Methods
    func setUpbadgesTop() {
        var badgearry = Defaults.shared.getbadgesArray()
        badgearry = badgearry.filter { $0 != "iosbadge" && $0 != "androidbadge"}
        imgprelaunch.isHidden = true
        imgfoundingMember.isHidden = true
        imgSocialMediaBadge.isHidden = true
        imgSubscribeBadge.isHidden = true
        
        if  badgearry.count >  0 {
            imgprelaunch.isHidden = false
            imgprelaunch.image = UIImage.init(named: badgearry[0])
        }
        if  badgearry.count >  1 {
            imgfoundingMember.isHidden = false
            imgfoundingMember.image = UIImage.init(named: badgearry[1])
        }
        if  badgearry.count >  2 {
            imgSocialMediaBadge.isHidden = false
            imgSocialMediaBadge.image = UIImage.init(named: badgearry[2])
        }
        if  badgearry.count >  3 {
            imgSubscribeBadge.isHidden = false
            imgSubscribeBadge.image = UIImage.init(named: badgearry[3])
        }
    }
    
    func setUpbadgesPopUp() {
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
    }
    
    func setUpProfileHeader() {
        userImage.layer.cornerRadius = userImage.bounds.width / 2
//        if settingTitle.settingsType == .userDashboard {
          if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
                userImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
                userImage.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: ApplicationSettings.userPlaceHolder)
            } else {
                userImage.image = ApplicationSettings.userPlaceHolder
            }
        nameLabel.text = R.string.localizable.channelName(Defaults.shared.currentUser?.channelId ?? "")
        userName.text =  Defaults.shared.publicDisplayName ?? ""
            if let socialPlatForms = Defaults.shared.socialPlatforms {
                imgSocialMediaBadge.isHidden = socialPlatForms.count != 4
            }
        setUpbadgesTop()
//        setUpbadgesPopUp()
      
       /* } else {
            blueBgImg.isHidden = true
            title.isHidden = true
            userImage.isHidden = true
            addProfilePic.isHidden = true
            badgesView.isHidden = true
            imgSocialMediaBadge.isHidden = true
        } */
    }
    private func setupUI() {
        #if SOCIALCAMAPP
        imgAppLogo.image = R.image.socialCamSplashLogo()
        #elseif VIRALCAMAPP
        imgAppLogo.image = R.image.viralcamrgb()
        #elseif SOCCERCAMAPP || FUTBOLCAMAPP
        imgAppLogo.image = R.image.soccercamWatermarkLogo()
        #elseif QUICKCAMAPP
        imgAppLogo.image = R.image.ssuQuickCam()
        #elseif SNAPCAMAPP
        imgAppLogo.image = R.image.snapcamWatermarkLogo()
        #elseif SPEEDCAMAPP
        imgAppLogo.image = R.image.ssuSpeedCam()
        #elseif TIMESPEEDAPP
        imgAppLogo.image = R.image.timeSpeedWatermarkLogo()
        #elseif FASTCAMAPP
        imgAppLogo.image = R.image.ssuFastCam()
        #elseif BOOMICAMAPP
        imgAppLogo.image = R.image.boomicamWatermarkLogo()
        #elseif VIRALCAMLITEAPP
        imgAppLogo.image = R.image.viralcamLiteWatermark()
        #elseif FASTCAMLITEAPP
        imgAppLogo.image = R.image.ssuFastCamLite()
        #elseif QUICKCAMLITEAPP || QUICKAPP
        imgAppLogo.image = (releaseType == .store) ? R.image.ssuQuickCam() : R.image.ssuQuickCamLite()
        #elseif SPEEDCAMLITEAPP
        imgAppLogo.image = R.image.speedcamLiteSsu()
        #elseif SNAPCAMLITEAPP
        imgAppLogo.image = R.image.snapcamliteSplashLogo()
        #elseif RECORDERAPP
        imgAppLogo.image = R.image.socialScreenRecorderWatermarkLogo()
        #else
        imgAppLogo.image = R.image.pic2artWatermarkLogo()
        #endif
    }
    
    func showHideButtonView(isHide: Bool) {
        self.singleButtonSttackView.isHidden = isHide
        self.doubleButtonStackView.isHidden = !isHide
    }
    
    
    @IBAction func didTapCameraButton(_ sender: UIButton) {
        if let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsOptionsVC() {
            navigationController?.pushViewController(storySettingsVC, animated: true)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
   
    
    @IBAction func btnLogoutTapped(_ sender: UIButton) {
        self.logoutWithKeycloak()
    }
    
    @IBAction func btnCancelLogout(_ sender: UIButton) {
        isDeletePopup = false
        logoutPopupView.isHidden = true
    }
    @IBAction func btnOkTapped(_ sender: UIButton) {
        longPressPopupView.isHidden = true
    }
    
    @IBAction func btnOkPopupTapped(_ sender: UIButton) {
        logoutPopupView.isHidden = true
    }
    @IBAction func businessDahboardConfirmPopupOkButtonClicked(_ sender: UIButton) {
        
        if let token = Defaults.shared.sessionToken {
            let urlString = "\(websiteUrl)/redirect?token=\(token)"
            guard let url = URL(string: urlString) else {
                return
            }
            presentSafariBrowser(url: url)
        }
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
    @IBAction func showCollectionAction(_ sender: Any) {
        btnTable.isSelected = false
        btnCollection.isSelected = true
        settingCollectionView.isHidden = false
        settingsTableView.isHidden = true
        Defaults.shared.settingsPreference = 1
        settingCollectionView.reloadData()
    }
    @IBAction func showTableAction(_ sender: Any) {
        btnTable.isSelected = true
        btnCollection.isSelected = false
        settingCollectionView.isHidden = true
        settingsTableView.isHidden = false
        Defaults.shared.settingsPreference = 0
        settingsTableView.reloadData()
    }
    @IBAction func showProfileAction(_ sender: Any) {
        getVerifiedSocialPlatforms()
        setUpbadgesPopUp()
        profileDisplayView.isHidden = false
        let name = "\(Defaults.shared.currentUser?.firstName ?? "") \(Defaults.shared.currentUser?.lastName ?? "")"
        nameTitleLabel.text = R.string.localizable.channelName(Defaults.shared.currentUser?.channelId ?? "")
        userNametitleLabel.text = Defaults.shared.publicDisplayName
        if let createdDate = Defaults.shared.currentUser?.created {
            let date = CommonFunctions.getDateInSpecificFormat(dateInput: createdDate, dateOutput: R.string.localizable.mmmdYyyy())
            joinedDateLabel.text = R.string.localizable.sinceJoined(date)
        }
        //R.string.localizable.channelName(Defaults.shared.currentUser?.channelId ?? "")
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            if userImageURL.isEmpty {
                userPlaceHolderImageView.isHidden = false
            }
            userPlaceHolderImageView.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: ApplicationSettings.userPlaceHolder)
        } else {
            userPlaceHolderImageView.image = ApplicationSettings.userPlaceHolder
        }
        
    }
    
}

extension StorySettingsVC {
    func getUserNotificationModel(completion: @escaping (_ isCompleted: Bool?) -> Void) {
        let path = API.shared.baseUrlV2 + Paths.userNotificationUnreadCount
        let headerWithToken : HTTPHeaders =  ["Content-Type": "application/json",
                                              "userid": Defaults.shared.currentUser?.id ?? "",
                                              "deviceType": "1",
                                              "x-access-token": Defaults.shared.sessionToken ?? ""]
        let request = AF.request(path, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headerWithToken, interceptor: nil)
        request.responseDecodable(of: NotificationCountResult?.self) {(resposnse) in
            let resultsNotificationCount = resposnse.value as? NotificationCountResult
            if resultsNotificationCount?.success == true {
                if let unreadCount = resultsNotificationCount?.data?.count {
                    self.notificationUnreadCount = resultsNotificationCount?.data?.count ?? 0
                    self.settingsTableView.reloadData()
                    self.settingCollectionView.reloadData()
                }
            }
        }
    }
}

extension StorySettingsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1//StorySettings.storySettings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StorySettings.storySettings.count
       /* if StorySettings.storySettings[section].settingsType == .subscriptions {
            let item = StorySettings.storySettings[section]
            guard item.isCollapsible else {
                print("no of row --> \(section)--\(StorySettings.storySettings[section].settings.count)")
                return StorySettings.storySettings[section].settings.count
            }
            
            if item.isCollapsed {
                print("no of roww --> \(section)--0")
                return 0
            } else {
                print("no of rowww --> \(section)--\(item.settings.count)")
                return item.settings.count
            }
        }
        print("no of rowwww --> \(section)--\(StorySettings.storySettings[section].settings.count)")
        return StorySettings.storySettings[section].settings.count */
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.appOpenSettingsCell.identifier, for: indexPath) as? AppOpenSettingsCell, StorySettings.storySettings[indexPath.row].settingsType == .appStartScreen {
            #if PIC2ARTAPP || SOCIALCAMAPP || VIRALCAMAPP || SOCCERCAMAPP || FUTBOLCAMAPP || QUICKCAMAPP || VIRALCAMLITEAPP || VIRALCAMLITEAPP || FASTCAMLITEAPP || QUICKCAMLITEAPP || SPEEDCAMLITEAPP || SNAPCAMLITEAPP || QUICKAPP
            cell.dashBoardView.isHidden = true
            #else
            cell.dashBoardView.isHidden = false
            #endif
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StorySettingsListCell.identifier, for: indexPath) as? StorySettingsListCell else {
            fatalError("\(StorySettingsListCell.identifier) Not Found")
        }
        let settingTitle = StorySettings.storySettings[indexPath.row]
        let settings = settingTitle.settings[0]
        cell.settingsName.text = settings.name
        cell.detailButton.isHidden = true
        cell.settingsName.textColor = R.color.appBlackColor()
        cell.roundedView.isHidden = true
        cell.badgeView.isHidden = true
        cell.newBadgesImageView.isHidden = true
        cell.notificationCountView.isHidden = true
       if settingTitle.settingsType == .controlcenter || settingTitle.settingsType == .socialLogout || settingTitle.settingsType == .socialConnections || settingTitle.settingsType == .channelManagement || settingTitle.settingsType == .appInfo || settingTitle.settingsType == .video || settingTitle.settingsType == .termsAndConditions || settingTitle.settingsType == .privacyPolicy || settingTitle.settingsType == .goToWebsite || settingTitle.settingsType == .watermarkSettings || settingTitle.settingsType == .applicationSurvey || settingTitle.settingsType == .intellectualProperties {
            if settingTitle.settingsType == .appInfo {
                cell.settingsName.textColor = R.color.appPrimaryColor()
            } else if settingTitle.settingsType == .applicationSurvey || settingTitle.settingsType == .intellectualProperties {
                cell.settingsName.alpha = 0.5
            }
            cell.onOffButton.isHidden = true
        }else if settingTitle.settingsType == .userDashboard {
            hideUnhideImgButton(cell, R.image.settings_Dashboard())
        }else if settingTitle.settingsType == .editProfileCard {
            hideUnhideImgButton(cell, R.image.settings_EditProfileCard())
            cell.newBadgesImageView.isHidden = true//false
            cell.newBadgesImageView.image = R.image.editProfileBadge()
        }else if settingTitle.settingsType == .socialMediaConnections {
            hideUnhideImgButton(cell, R.image.settings_Account())
        }else if settingTitle.settingsType == .shareSetting {
            hideUnhideImgButton(cell, R.image.referralWizard())
            cell.newBadgesImageView.isHidden = true//false
            cell.newBadgesImageView.image = R.image.referralWizardBadge()
        }else if settingTitle.settingsType == .qrcode {
            hideUnhideImgButton(cell, R.image.settings_QRCode())
            cell.newBadgesImageView.isHidden = true//false
            cell.newBadgesImageView.image = R.image.qrCodeBadge()
        }else if settingTitle.settingsType == .accountSettings {
            hideUnhideImgButton(cell, R.image.settings_Account())
        } else if settingTitle.settingsType == .cameraSettings {
            hideUnhideImgButton(cell, R.image.settings_CameraSettings())
        } else if settingTitle.settingsType == .system {
            hideUnhideImgButton(cell, R.image.settings_System())
        } else if settingTitle.settingsType == .help {
            hideUnhideImgButton(cell, R.image.settings_HowItWorks())
        }else if settingTitle.settingsType == .aboutPage {
            hideUnhideImgButton(cell, R.image.settings_About())
        } else if settingTitle.settingsType == .logout {
            hideUnhideImgButton(cell, R.image.settings_Logout())
        } else if settingTitle.settingsType == .notification {
            cell.roundedView.isHidden = false
            cell.notificationCountView.isHidden = false
            hideUnhideImgButton(cell, R.image.settings_Notifications())
            cell.badgesCountLabel.text = "\(self.notificationUnreadCount)"
            if self.notificationUnreadCount == 0 {
                cell.roundedView.isHidden = true
                cell.notificationCountView.isHidden = true
            }
        } else if settingTitle.settingsType == .checkUpdate {
            hideUnhideImgButton(cell, R.image.settings_CheckUpdate())
        } else if settingTitle.settingsType == .referringChannel {
            hideUnhideImgButton(cell, R.image.settings_ReferringChannel())
        } else if settingTitle.settingsType == .subscription {
            hideUnhideImgButton(cell, R.image.settings_Subscription())
            cell.setUpSubscriptionBadges()
            /*let badgearry = Defaults.shared.getbadgesArray()
            if badgearry.contains("iosbadge") {
                cell.imgSubscribeBadge.image = R.image.newIosBadge()
                cell.imgSubscribeBadge.isHidden = false
            } else if badgearry.contains("androidbadge") {
                cell.imgSubscribeBadge.image = R.image.newAndroidBadge()
                cell.imgSubscribeBadge.isHidden = false
            } else if badgearry.contains("webbadge") {
                cell.imgSubscribeBadge.image = R.image.webbadge()
                cell.imgSubscribeBadge.isHidden = false
            } */
        } else if settingTitle.settingsType == .socialLogins {
            cell.onOffButton.isHidden = true
            cell.onOffButton.isSelected = false
            cell.socialImageView?.isHidden = false
            cell.socialImageView?.image = cell.onOffButton.isSelected ? settings.selectedImage : settings.image
            
            let socialLogin: SocialLogin = SocialLogin(rawValue: indexPath.row) ?? .facebook
            self.socialLoadProfile(socialLogin: socialLogin) { [weak cell] (userName, socialId) in
                guard let cell = cell else {
                    return
                }
                DispatchQueue.runOnMainThread {
                    cell.settingsName.text = userName
                    cell.onOffButton.isSelected = true
                    cell.socialImageView?.image = cell.onOffButton.isSelected ? settings.selectedImage : settings.image
                }
            }
        } else if settingTitle.settingsType == .subscriptions {
            cell.onOffButton.isHidden = false
            if indexPath.row == Defaults.shared.appMode.rawValue {
                cell.onOffButton.isSelected = true
            } else {
                cell.onOffButton.isSelected = false
            }
        } else if settingTitle.settingsType == .faceDetection {
            cell.onOffButton.isHidden = false
            cell.onOffButton.isSelected = Defaults.shared.enableFaceDetection
        } else if settingTitle.settingsType == .swapeContols {
            cell.onOffButton.isHidden = false
            cell.onOffButton.isSelected = Defaults.shared.swapeContols
        }
        return cell
    }
    
    func hideUnhideImgButton(_ cell: StorySettingsCell, _ image: UIImage?) {
        cell.onOffButton.isHidden = true
        cell.socialImageView?.isHidden = false
        cell.socialImageView?.image = image
    }
    func hideUnhideImgButton(_ cell: StorySettingsListCell, _ image: UIImage?) {
        cell.onOffButton.isHidden = true
        cell.socialImageView?.isHidden = false
        cell.socialImageView?.image = image
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsHeader.identifier) as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        
        let settingTitle = StorySettings.storySettings[section]
        if settingTitle.settingsType != .subscriptions && settingTitle.settingsType != .appInfo {
            headerView.title.isHidden = true
        } else {
            headerView.title.isHidden = false
        }
        headerView.section = section
        headerView.delegate = self
        if settingTitle.settingsType == .subscriptions {
            headerView.collapsed = settingTitle.isCollapsed
            headerView.arrowLabel?.isHidden = false
            headerView.title.text = settingTitle.name + " - \(Defaults.shared.appMode.description)"
        } else {
            headerView.title.text = settingTitle.name
            headerView.arrowLabel?.isHidden = true
        }
       
        headerView.userImage.layer.cornerRadius = headerView.userImage.bounds.width / 2
        if settingTitle.settingsType == .userDashboard {
            headerView.title.isHidden = false
            headerView.addProfilePic.isHidden = true
            if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
                if userImageURL.isEmpty {
                    headerView.addProfilePic.isHidden = false
                }
                headerView.userImage.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: ApplicationSettings.userPlaceHolder)
            } else {
                headerView.userImage.image = ApplicationSettings.userPlaceHolder
            }
            headerView.blueBgImg.isHidden = false
            headerView.title.text = R.string.localizable.channelName(Defaults.shared.currentUser?.channelId ?? "")
            headerView.nameLabel.text = Defaults.shared.publicDisplayName ?? ""
            if let socialPlatForms = Defaults.shared.socialPlatforms {
                headerView.imgSocialMediaBadge.isHidden = socialPlatForms.count != 4
            }
        } else {
            headerView.blueBgImg.isHidden = true
            headerView.title.isHidden = true
            headerView.userImage.isHidden = true
            headerView.addProfilePic.isHidden = true
            headerView.badgesView.isHidden = true
            headerView.imgSocialMediaBadge.isHidden = true
        }
       
        if section == 0 {
            headerView.btnProfilePic.addTarget(self, action: #selector(btnEditProfilePic), for: .touchUpInside)
        }
        
        headerView.btnProfilePic.tag = section
        headerView.callBackForReload = { [weak self] (isCalled) -> Void in
            self?.getVerifiedSocialPlatforms()
            self?.setUpbadgesTop()
            self?.setUpbadgesPopUp()
            headerView.badgeIconHeightConstraint.constant = 45
            self?.profileDisplayView.isHidden = false
            let name = "\(Defaults.shared.currentUser?.firstName ?? "") \(Defaults.shared.currentUser?.lastName ?? "")"
            self?.nameTitleLabel.text = R.string.localizable.channelName(Defaults.shared.currentUser?.channelId ?? "")
            self?.userNametitleLabel.text = Defaults.shared.publicDisplayName
            if let createdDate = Defaults.shared.currentUser?.created {
                let date = CommonFunctions.getDateInSpecificFormat(dateInput: createdDate, dateOutput: R.string.localizable.mmmdYyyy())
                self?.joinedDateLabel.text = R.string.localizable.sinceJoined(date)
            }
            //R.string.localizable.channelName(Defaults.shared.currentUser?.channelId ?? "")
            if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
                if userImageURL.isEmpty {
                    self?.userPlaceHolderImageView.isHidden = false
                }
                self?.userPlaceHolderImageView.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: ApplicationSettings.userPlaceHolder)
            } else {
                self?.userPlaceHolderImageView.image = ApplicationSettings.userPlaceHolder
            }
            
        }
        
        return headerView
    }
   /* func setUpbadgesTop() {
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
    } */
    func getVerifiedSocialPlatforms() {
        if let socialPlatforms = Defaults.shared.socialPlatforms {
            for socialPlatform in socialPlatforms {
                if socialPlatform == R.string.localizable.facebook().lowercased() {
                    self.faceBookVerifiedView.isHidden = false
                } else if socialPlatform == R.string.localizable.twitter().lowercased() {
                    self.twitterVerifiedView.isHidden = false
                } else if socialPlatform == R.string.localizable.snapchat().lowercased() {
                    self.snapVerifiedView.isHidden = false
                } else if socialPlatform == R.string.localizable.youtube().lowercased() {
                    self.youTubeVerifiedView.isHidden = false
                }
            }
//            socialBadgeicon.isHidden = (socialPlatforms.count == 4) ? false : true
        }
    }
   
    @objc func btnEditProfilePic(sender: UIButton) {
        
//        headerView.badgeIconHeightConstraint.constant = 45
       /* if let editProfilePicViewController = R.storyboard.editProfileViewController.editProfilePicViewController() {
            navigationController?.pushViewController(editProfilePicViewController, animated: true)
        } */
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
      /*  let settingTitle = StorySettings.storySettings[section]
        print("section--> \(section)")
        if settingTitle.settingsType == .subscriptions {
            print("60")
            return 60
        } else if settingTitle.settingsType == .userDashboard {
            print("80")
            return 80
        } else {
            print("0")
            return 0
        } */
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingTitle = StorySettings.storySettings[indexPath.row]
       
        if settingTitle.settingsType == .controlcenter {
            if let baseUploadVC = R.storyboard.storyCameraViewController.baseUploadVC() {
                navigationController?.pushViewController(baseUploadVC, animated: true)
            }
        } else if settingTitle.settingsType == .notification {
            if let baseUploadVC = R.storyboard.notificationVC.notificationVC() {
                navigationController?.pushViewController(baseUploadVC, animated: true)
            }
        } else if settingTitle.settingsType == .editProfileCard {
            if let editProfilePicViewController = R.storyboard.editProfileViewController.editProfilePicViewController() {
                navigationController?.pushViewController(editProfilePicViewController, animated: true)
            }
        } else if settingTitle.settingsType == .socialMediaConnections {
            if let addSocialConnectionViewController = R.storyboard.socialConnection.addSocialConnectionViewController() {
                navigationController?.pushViewController(addSocialConnectionViewController, animated: true)
            }
        } else if settingTitle.settingsType == .video {
            if let viralCamVideos = R.storyboard.viralCamVideos.viralCamVideos() {
                navigationController?.pushViewController(viralCamVideos, animated: true)
            }
        } else if settingTitle.settingsType == .cameraSettings {
            if let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsOptionsVC() {
                navigationController?.pushViewController(storySettingsVC, animated: true)
            }
        } else if settingTitle.settingsType == .system {
            if let systemSettingsVC = R.storyboard.storyCameraViewController.systemSettingsViewController() {
                navigationController?.pushViewController(systemSettingsVC, animated: true)
            }
        } else if settingTitle.settingsType == .qrcode {
            if let qrViewController = R.storyboard.editProfileViewController.qrCodeViewController() {
                navigationController?.pushViewController(qrViewController, animated: true)
            }
        }
        else if settingTitle.settingsType == .logout {
            lblLogoutPopup.text = R.string.localizable.areYouSureYouWantToLogoutFromApp("\(Constant.Application.displayName)")
            showHideButtonView(isHide: true)
            logoutPopupView.isHidden = false
        }
        else if settingTitle.settingsType == .socialLogout {
            logoutUser()
        }
        else if settingTitle.settingsType == .socialLogins {
            let socialLogin: SocialLogin = SocialLogin(rawValue: indexPath.row) ?? .facebook
            socialLoginLogout(socialLogin: socialLogin) { [weak self] (isLogin) in
                guard let `self` = self else {
                    return
                }
                if socialLogin == .storiCam, !isLogin {
                    if let loginNav = R.storyboard.loginViewController.loginNavigation() {
                        Defaults.shared.clearData()
                        Utils.appDelegate?.window?.rootViewController = loginNav
                        return
                    }
                } else if isLogin {
                    var socialPlatform: String = "facebook"
                    switch socialLogin {
                    case .twitter:
                        socialPlatform = "twitter"
                    case .instagram:
                        socialPlatform = "instagram"
                    case .snapchat:
                        socialPlatform = "snapchat"
                    case .youtube:
                        socialPlatform = "google"
                    default:
                        break
                    }
                    self.socialLoadProfile(socialLogin: socialLogin) { [weak self] (socialName, socialId) in
                        guard let `self` = self else {
                            return
                        }
                        self.connectSocial(socialPlatform: socialPlatform, socialId: socialId ?? "", socialName: socialName ?? "")
                    }
                }
            }
        }
        else if settingTitle.settingsType == .subscriptions {
            guard Defaults.shared.appMode.rawValue != indexPath.row else {
                return
            }
            self.enableMode(appMode: AppMode(rawValue: indexPath.row) ?? .free)
        }
        else if settingTitle.settingsType == .faceDetection {
            Defaults.shared.enableFaceDetection = !Defaults.shared.enableFaceDetection
            self.settingsTableView.reloadData()
        }
        else if settingTitle.settingsType == .swapeContols {
            Defaults.shared.swapeContols = !Defaults.shared.swapeContols
            self.settingsTableView.reloadData()
        }
        else if settingTitle.settingsType == .channelManagement {
            let chVc = R.storyboard.preRegistration.channelListViewController()
            chVc?.remainingPackageCountForOthers = Defaults.shared.currentUser?.remainingOtherUserPackageCount ?? 0
            self.navigationController?.pushViewController(chVc!, animated: true)
        }
        else if settingTitle.settingsType == .socialConnections {
            if let addSocialConnectionViewController = R.storyboard.socialConnection.addSocialConnectionViewController() {
                navigationController?.pushViewController(addSocialConnectionViewController, animated: true)
            }
        }
        else if settingTitle.settingsType == .termsAndConditions || settingTitle.settingsType == .privacyPolicy {
            guard let legalVc = R.storyboard.legal.legalViewController() else { return }
            legalVc.isTermsAndConditions = settingTitle.settingsType == .termsAndConditions
            self.navigationController?.pushViewController(legalVc, animated: true)
        } else if settingTitle.settingsType == .subscription {
            if Defaults.shared.allowFullAccess == true {
                lblLogoutPopup.text = R.string.localizable.freeDuringBetaTest()
                showHideButtonView(isHide: false)
                logoutPopupView.isHidden = false
            } else {
                if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
                    navigationController?.pushViewController(subscriptionVC, animated: true)
                }
            }
        } else if settingTitle.settingsType == .goToWebsite {
            if let yourAffiliateLinkVC = R.storyboard.storyCameraViewController.yourAffiliateLinkViewController() {
                navigationController?.pushViewController(yourAffiliateLinkVC, animated: true)
            }
        } else if settingTitle.settingsType == .applicationSurvey {
            if !isQuickApp {
                guard let url = URL(string: Constant.URLs.applicationSurveyURL) else { return }
                presentSafariBrowser(url: url)
            }
        } else if settingTitle.settingsType == .watermarkSettings {
            if let watermarkSettingsVC = R.storyboard.storyCameraViewController.watermarkSettingsViewController() {
                navigationController?.pushViewController(watermarkSettingsVC, animated: true)
            }
        } else if settingTitle.settingsType == .help {
            if let helpSettingsViewController = R.storyboard.storyCameraViewController.helpSettingsViewController() {
                navigationController?.pushViewController(helpSettingsViewController, animated: true)
            }
        } else if settingTitle.settingsType == .intellectualProperties {
            // TODO: - Need to add redirection link
        } else if settingTitle.settingsType == .accountSettings {
            if let accountSettingsViewController = R.storyboard.storyCameraViewController.accountSettingsViewController() {
                navigationController?.pushViewController(accountSettingsViewController, animated: true)
            }
        } else if settingTitle.settingsType == .deleteAccount {
            lblLogoutPopup.text = R.string.localizable.areYouSureYouWantToDeactivateYourAccount()
            isDeletePopup = true
            showHideButtonView(isHide: true)
            logoutPopupView.isHidden = false
        }
        else if settingTitle.settingsType == .shareSetting {
//          if let editProfileController = R.storyboard.refferalEditProfile.refferalEditProfileViewController() {
//                navigationController?.pushViewController(editProfileController, animated: true)
//            }
            if let userImageURL = Defaults.shared.currentUser?.profileImageURL , !userImageURL.isEmpty {
                if let contactWizardController = R.storyboard.contactWizardwithAboutUs.contactImportVC() {
                    navigationController?.pushViewController(contactWizardController, animated: true)
                }
            } else {
                if let editProfileController = R.storyboard.refferalEditProfile.refferalEditProfileViewController() {
                    navigationController?.pushViewController(editProfileController, animated: true)
                }
            }
        }
        else if settingTitle.settingsType == .userDashboard {
            openBussinessDashboard()
           
        } else if settingTitle.settingsType == .checkUpdate {
            SSAppUpdater.shared.performCheck(isForceUpdate: false, showDefaultAlert: true) { (_) in
            }
        } else if settingTitle.settingsType == .referringChannel {
            if let userDetailsVC = R.storyboard.notificationVC.userDetailsVC() {
                MIBlurPopup.show(userDetailsVC, on: self)
            }
        }else if settingTitle.settingsType == .aboutPage {
            if let aboutViewController = R.storyboard.aboutStoryboard.aboutViewController() {
                navigationController?.pushViewController(aboutViewController, animated: true)
            }
        }
    }
    
    func openBussinessDashboard(){
//        print("isShowAllPopUpChecked: \(Defaults.shared.isShowAllPopUpChecked)\nisDoNotShowAgainOpenBusinessCenterPopup: \(Defaults.shared.isDoNotShowAgainOpenBusinessCenterPopup) ")
        if Defaults.shared.isShowAllPopUpChecked == true && Defaults.shared.isDoNotShowAgainOpenBusinessCenterPopup == false {
             businessDashbardConfirmPopupView.isHidden = false
            btnDoNotShowAgainBusinessConfirmPopup.isSelected = Defaults.shared.isDoNotShowAgainOpenBusinessCenterPopup
            self.view.bringSubviewToFront(businessDashbardConfirmPopupView)
          //  lblQuickLinkTooltipView.text = R.string.localizable.quickLinkTooltip(R.string.localizable.businessCenter(), Defaults.shared.currentUser?.channelId ?? "")
        }else{
            if let token = Defaults.shared.sessionToken {
                 let urlString = "\(websiteUrl)/redirect?token=\(token)"
                 guard let url = URL(string: urlString) else {
                     return
                 }
                 presentSafariBrowser(url: url)
             }
             Defaults.shared.callHapticFeedback(isHeavy: false,isImportant: true)
             Defaults.shared.addEventWithName(eventName: Constant.EventName.cam_Bdashboard)
        }
    }
        
    func viralCamLogout() {
        let objAlert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.areYouSureYouWantToLogout(), preferredStyle: .alert)
        let actionlogOut = UIAlertAction(title: R.string.localizable.logout(), style: .default) { (_: UIAlertAction) in
            StoriCamManager.shared.logout()
            TwitterManger.shared.logout()
            GoogleManager.shared.logout()
            FaceBookManager.shared.logout()
            InstagramManager.shared.logout()
            SnapKitManager.shared.logout { _ in
                
            }
            if #available(iOS 13.0, *) {
                AppleSignInManager.shared.logout()
            }
            self.settingsTableView.reloadData()
            if let loginNav = R.storyboard.loginViewController.loginNavigation() {
                Defaults.shared.clearData()
                Utils.appDelegate?.window?.rootViewController = loginNav
            }
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in }
        objAlert.addAction(actionlogOut)
        objAlert.addAction(cancelAction)
        self.present(objAlert, animated: true, completion: nil)
    }
    
    func logoutWithKeycloak() {
        ProManagerApi.logoutKeycloak.request(Result<EmptyModel>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                StoriCamManager.shared.logout()
                TwitterManger.shared.logout()
                GoogleManager.shared.logout()
                FaceBookManager.shared.logout()
                InstagramManager.shared.logout()
                SnapKitManager.shared.logout { _ in
                    
                }
                if #available(iOS 13.0, *) {
                    AppleSignInManager.shared.logout()
                }
                self.settingsTableView.reloadData()
                self.removeDeviceToken()
                if let loginNav = R.storyboard.loginViewController.loginNavigation() {
                   // Defaults.shared.clearData()
                    Utils.appDelegate?.window?.rootViewController = loginNav
                }
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
            self.logoutPopupView.isHidden = true
        }, onError: { error in
            self.logoutPopupView.isHidden = true
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func removeDeviceToken() {
        if let deviceToken = Defaults.shared.deviceToken {
            ProManagerApi.removeToken(deviceToken: deviceToken).request(Result<RemoveTokenModel>.self).subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else {
                    return
                }
                if response.status != ResponseType.success {
                    self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
                }
            }, onError: { error in
                self.showAlert(alertMessage: error.localizedDescription)
            }, onCompleted: {
            }).disposed(by: rx.disposeBag)
        }
    }
    
    func presentSafariBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    func connectSocial(socialPlatform: String, socialId: String, socialName: String) {
        self.showHUD()
        ProManagerApi.connectSocial(socialPlatform: socialPlatform, socialId: socialId, socialName: socialName).request(Result<SocialUserConnect>.self).subscribe(onNext: { (response) in
            self.dismissHUD()
            if response.status != ResponseType.success {
                UIApplication.showAlert(title: Constant.Application.displayName, message: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.dismissHUD()
            
            print(error)
        }, onCompleted: {
            
        }).disposed(by: rx.disposeBag)
    }
    
    func socialLoadProfile(socialLogin: SocialLogin, completion: @escaping (String?, String?) -> ()) {
        switch socialLogin {
        case .facebook:
            if FaceBookManager.shared.isUserLogin {
                FaceBookManager.shared.loadUserData { (userModel) in
                    completion(userModel?.userName, userModel?.userId)
                }
            }
        case .twitter:
            if TwitterManger.shared.isUserLogin {
                TwitterManger.shared.loadUserData { (userModel) in
                    completion(userModel?.userName, userModel?.userId)
                }
            }
        case .instagram:
            if InstagramManager.shared.isUserLogin {
                if let userModel = InstagramManager.shared.profileDetails {
                    completion(userModel.username, userModel.id)
                }
            }
        case .snapchat:
            if SnapKitManager.shared.isUserLogin {
                SnapKitManager.shared.loadUserData { (userModel) in
                    completion(userModel?.userName, userModel?.userId)
                }
            }
        case .youtube:
            if GoogleManager.shared.isUserLogin {
                GoogleManager.shared.loadUserData { (userModel) in
                    completion(userModel?.userName, userModel?.userId)
                }
            }
        case .storiCam:
            if StoriCamManager.shared.isUserLogin {
                StoriCamManager.shared.loadUserData { (userModel) in
                    completion(userModel?.userName, userModel?.userId)
                }
            }
        case .apple:
            if #available(iOS 13.0, *) {
                if AppleSignInManager.shared.isUserLogin {
                    AppleSignInManager.shared.loadUserData { (userModel) in
                        completion(userModel?.userName, userModel?.userId)
                    }
                }
            }
        }
    }
    
    func socialLoginLogout(socialLogin: SocialLogin, completion: @escaping (Bool) -> ()) {
        switch socialLogin {
        case .facebook:
            if !FaceBookManager.shared.isUserLogin {
                FaceBookManager.shared.login(controller: self, loginCompletion: { (_, _) in
                    completion(true)
                }) { (_, _) in
                    completion(false)
                }
            } else {
                FaceBookManager.shared.logout()
                completion(false)
            }
        case .twitter:
            if !TwitterManger.shared.isUserLogin {
                TwitterManger.shared.login { (_, _) in
                    completion(true)
                }
            } else {
                TwitterManger.shared.logout()
                completion(false)
            }
        case .instagram:
            if !InstagramManager.shared.isUserLogin {
                let loginViewController: WebViewController = WebViewController()
                loginViewController.delegate = self
                self.present(loginViewController, animated: true) {
                    completion(true)
                }
            } else {
                InstagramManager.shared.logout()
                completion(false)
            }
        case .snapchat:
            if !SnapKitManager.shared.isUserLogin {
                SnapKitManager.shared.login(viewController: self) { (isLogin, error) in
                    if !isLogin {
                        DispatchQueue.main.async {
                            self.showAlert(alertMessage: error ?? "")
                        }
                    }
                    completion(isLogin)
                }
            } else {
                SnapKitManager.shared.logout { _ in
                    completion(false)
                }
            }
        case .youtube:
            if !GoogleManager.shared.isUserLogin {
                GoogleManager.shared.login(controller: self, complitionBlock: { (_, _) in
                    completion(true)
                }) { (_, _) in
                    completion(false)
                }
            } else {
                GoogleManager.shared.logout()
                completion(false)
            }
        case .storiCam:
            if !StoriCamManager.shared.isUserLogin {
                StoriCamManager.shared.login(controller: self) { (_, _) in
                    StoriCamManager.shared.delegate = self
                }
            } else {
                StoriCamManager.shared.logout()
                completion(false)
            }
        case .apple:
            if #available(iOS 13.0, *) {
                if !AppleSignInManager.shared.isUserLogin {
                    AppleSignInManager.shared.login(controller: self, complitionBlock: { _, _  in
                        completion(true)
                    }) { _, _  in
                        completion(false)
                    }
                } else {
                    AppleSignInManager.shared.logout()
                    completion(false)
                }
            }
        }
    }
    
    func enableMode(appMode: AppMode) {
        var message: String? = ""
        let placeholder: String? = R.string.localizable.enterYourUniqueCodeToEnableBasicMode()
        let proModeCode: String? = Constant.Application.proModeCode
        var successMessage: String? = ""
        switch appMode {
        case .free:
            message = R.string.localizable.areYouSureYouWantToEnableFree()
            successMessage = R.string.localizable.freeModeIsEnabled()
        case .basic:
            message = R.string.localizable.areYouSureYouWantToEnableBasic()
            successMessage = R.string.localizable.basicModeIsEnabled()
        case .advanced:
            message = R.string.localizable.areYouSureYouWantToEnableAdvanced()
            successMessage = R.string.localizable.advancedModeIsEnabled()
        default:
            message = R.string.localizable.areYouSureYouWantToEnableProfessional()
            successMessage = R.string.localizable.professionalModeIsEnabled()
        }
        
        let objAlert = UIAlertController(title: Constant.Application.displayName, message: message, preferredStyle: .alert)
        if appMode != .free {
            objAlert.addTextField { (textField: UITextField) -> Void in
                if isDebug {
                    textField.text = proModeCode
                }
                textField.placeholder = placeholder
            }
        }
        
        let actionSave = UIAlertAction(title: R.string.localizable.oK(), style: .default) { ( _: UIAlertAction) in
            if appMode != .free {
                if let textField = objAlert.textFields?[0],
                    textField.text!.count > 0, textField.text?.lowercased() != proModeCode {
                    self.view.makeToast(R.string.localizable.pleaseEnterValidCode())
                    return
                }
            }
            Defaults.shared.appMode = appMode
            StorySettings.storySettings[0].settings[appMode.rawValue].selected = true
            self.settingsTableView.reloadData()
            AppEventBus.post("changeMode")
            self.navigationController?.popViewController(animated: true)
            //Utils.appDelegate?.window?.makeToast(successMessage)
            Utils.appDelegate?.window?.currentController?.showAlert(alertMessage: successMessage ?? "")
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in }
        objAlert.addAction(actionSave)
        objAlert.addAction(cancelAction)
        self.present(objAlert, animated: true, completion: nil)
    }
    
    func logoutUser() {
        let objAlert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.areYouSureYouWantToLogout(), preferredStyle: .alert)
        let actionlogOut = UIAlertAction(title: R.string.localizable.logout(), style: .default) { (_: UIAlertAction) in
            TwitterManger.shared.logout()
            GoogleManager.shared.logout()
            FaceBookManager.shared.logout()
            InstagramManager.shared.logout()
            SnapKitManager.shared.logout { _ in
                self.settingsTableView.reloadData()
            }
            if #available(iOS 13.0, *) {
                AppleSignInManager.shared.logout()
            }
            self.settingsTableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in }
        objAlert.addAction(actionlogOut)
        objAlert.addAction(cancelAction)
        self.present(objAlert, animated: true, completion: nil)
    }
    
}
// MARK: TableViewReorderDelegate
extension StorySettingsVC: TableViewReorderDelegate {
    var reorderSuperview: UIView {
        return self.navigationController?.view ?? UIView()
    }
    
    func tableViewReorder(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        StorySettings.storySettings.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    func tableViewReorder(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
extension StorySettingsVC: InstagramLoginViewControllerDelegate, ProfileDelegate {
   
    func profileDidLoad(profile: ProfileDetailsResponse) {
        self.settingsTableView.reloadData()
    }
    
    func profileLoadFailed(error: Error) {
        
    }
   
    func instagramLoginDidFinish(accessToken: String?, error: Error?) {
        if accessToken != nil {
            InstagramManager.shared.delegate = self
            InstagramManager.shared.loadProfile()
        }
    }
}

extension StorySettingsVC: StoriCamManagerDelegate {
    func loginDidFinish(user: User?, error: Error?) {
        self.settingsTableView.reloadData()
    }
}

class ScreenSelectionView: UIView {
    @IBOutlet var viewSelection: UIView?
    var isSelected: Bool? {
        didSet {
            viewSelection?.isHidden = !(isSelected ?? false)
        }
    }
    var selectionHandler: (() -> Void)?
    
    @IBAction func btnClicked(_sender: Any) {
        self.isSelected = true
        if let handler = selectionHandler {
            handler()
        }
    }
    
}
extension StorySettingsVC: HeaderViewDelegate {
    func toggleSection(header: StorySettingsHeader, section: Int) {
        let settingTitle = StorySettings.storySettings[section]
        if settingTitle.isCollapsible {

            // Toggle collapse
            let collapsed = !settingTitle.isCollapsed
            settingTitle.isCollapsed = collapsed
            self.settingsTableView?.reloadData()
        }
    }
}
extension StorySettingsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return StorySettings.storySettings.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingsCollectionCell", for: indexPath) as! SettingsCollectionCell
        let settingTitle = StorySettings.storySettings[indexPath.item]
        let settings = settingTitle.settings[0]
        cell.settingsName.text = settings.name
        cell.roundedView.isHidden = true
        cell.badgeView.isHidden = true
        cell.newBadgesImageView.isHidden = true
        cell.notificationCountView.isHidden = true
        if settingTitle.settingsType == .userDashboard {
            cell.socialImageView?.image = R.image.settings_Dashboard()
        }else if settingTitle.settingsType == .editProfileCard {
            cell.socialImageView?.image = R.image.settings_EditProfileCard()
            cell.newBadgesImageView.isHidden = false
            cell.newBadgesImageView.image = R.image.editProfileBadge()
        }else if settingTitle.settingsType == .socialMediaConnections {
            cell.socialImageView?.image = R.image.settings_Account()
        }else if settingTitle.settingsType == .shareSetting {
            cell.socialImageView?.image = R.image.referralWizard()
            cell.newBadgesImageView.isHidden = false
            cell.newBadgesImageView.image = R.image.referralWizardBadge()
        }else if settingTitle.settingsType == .qrcode {
            cell.socialImageView?.image =  R.image.settings_QRCode()
            cell.newBadgesImageView.isHidden = false
            cell.newBadgesImageView.image = R.image.qrCodeBadge()
        }else if settingTitle.settingsType == .accountSettings {
            cell.socialImageView?.image = R.image.settings_Account()
        } else if settingTitle.settingsType == .cameraSettings {
            cell.socialImageView?.image = R.image.settings_CameraSettings()
        } else if settingTitle.settingsType == .system {
            cell.socialImageView?.image = R.image.settings_System()
        } else if settingTitle.settingsType == .help {
            cell.socialImageView?.image = R.image.settings_HowItWorks()
        }else if settingTitle.settingsType == .aboutPage {
            cell.socialImageView?.image = R.image.settings_About()
        } else if settingTitle.settingsType == .logout {
            cell.socialImageView?.image = R.image.settings_Logout()
        } else if settingTitle.settingsType == .notification {
            cell.socialImageView?.image = R.image.settings_Notifications()
            cell.roundedView.isHidden = false
            cell.notificationCountView.isHidden = false
            cell.countLabel.text = "\(self.notificationUnreadCount)"
            if self.notificationUnreadCount == 0 {
                cell.roundedView.isHidden = true
                cell.notificationCountView.isHidden = true
            }
        } else if settingTitle.settingsType == .checkUpdate {
            cell.socialImageView?.image = R.image.settings_CheckUpdate()
        } else if settingTitle.settingsType == .referringChannel {
            cell.socialImageView?.image = R.image.settings_ReferringChannel()
        } else if settingTitle.settingsType == .subscription {
            cell.socialImageView?.image = R.image.settings_Subscription()
            cell.setUpSubscriptionBadges()
//            let badgearry = Defaults.shared.getbadgesArray()
//            if badgearry.contains("iosbadge") {
//                cell.imgSubscribeBadge.image = R.image.newIosBadge()
//                cell.imgSubscribeBadge.isHidden = false
//            } else if badgearry.contains("androidbadge") {
//                cell.imgSubscribeBadge.image = R.image.newAndroidBadge()
//                cell.imgSubscribeBadge.isHidden = false
//            } else if badgearry.contains("webbadge") {
//                cell.imgSubscribeBadge.image = R.image.webbadge()
//                cell.imgSubscribeBadge.isHidden = false
//            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let settingTitle = StorySettings.storySettings[indexPath.item]
       
        if settingTitle.settingsType == .controlcenter {
            if let baseUploadVC = R.storyboard.storyCameraViewController.baseUploadVC() {
                navigationController?.pushViewController(baseUploadVC, animated: true)
            }
        } else if settingTitle.settingsType == .notification {
            if let baseUploadVC = R.storyboard.notificationVC.notificationVC() {
                navigationController?.pushViewController(baseUploadVC, animated: true)
            }
        } else if settingTitle.settingsType == .editProfileCard {
            if let editProfilePicViewController = R.storyboard.editProfileViewController.editProfilePicViewController() {
                navigationController?.pushViewController(editProfilePicViewController, animated: true)
            }
        } else if settingTitle.settingsType == .socialMediaConnections {
            if let addSocialConnectionViewController = R.storyboard.socialConnection.addSocialConnectionViewController() {
                navigationController?.pushViewController(addSocialConnectionViewController, animated: true)
            }
        } else if settingTitle.settingsType == .video {
            if let viralCamVideos = R.storyboard.viralCamVideos.viralCamVideos() {
                navigationController?.pushViewController(viralCamVideos, animated: true)
            }
        } else if settingTitle.settingsType == .cameraSettings {
            if let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsOptionsVC() {
                navigationController?.pushViewController(storySettingsVC, animated: true)
            }
        } else if settingTitle.settingsType == .system {
            if let systemSettingsVC = R.storyboard.storyCameraViewController.systemSettingsViewController() {
                navigationController?.pushViewController(systemSettingsVC, animated: true)
            }
        } else if settingTitle.settingsType == .qrcode {
            if let qrViewController = R.storyboard.editProfileViewController.qrCodeViewController() {
                navigationController?.pushViewController(qrViewController, animated: true)
            }
        }
        else if settingTitle.settingsType == .logout {
            lblLogoutPopup.text = R.string.localizable.areYouSureYouWantToLogoutFromApp("\(Constant.Application.displayName)")
            showHideButtonView(isHide: true)
            logoutPopupView.isHidden = false
        }
        else if settingTitle.settingsType == .socialLogout {
            logoutUser()
        }
        else if settingTitle.settingsType == .socialLogins {
            let socialLogin: SocialLogin = SocialLogin(rawValue: indexPath.row) ?? .facebook
            socialLoginLogout(socialLogin: socialLogin) { [weak self] (isLogin) in
                guard let `self` = self else {
                    return
                }
                if socialLogin == .storiCam, !isLogin {
                    if let loginNav = R.storyboard.loginViewController.loginNavigation() {
                        Defaults.shared.clearData()
                        Utils.appDelegate?.window?.rootViewController = loginNav
                        return
                    }
                } else if isLogin {
                    var socialPlatform: String = "facebook"
                    switch socialLogin {
                    case .twitter:
                        socialPlatform = "twitter"
                    case .instagram:
                        socialPlatform = "instagram"
                    case .snapchat:
                        socialPlatform = "snapchat"
                    case .youtube:
                        socialPlatform = "google"
                    default:
                        break
                    }
                    self.socialLoadProfile(socialLogin: socialLogin) { [weak self] (socialName, socialId) in
                        guard let `self` = self else {
                            return
                        }
                        self.connectSocial(socialPlatform: socialPlatform, socialId: socialId ?? "", socialName: socialName ?? "")
                    }
                }
            }
        }
        else if settingTitle.settingsType == .subscriptions {
            guard Defaults.shared.appMode.rawValue != indexPath.row else {
                return
            }
            self.enableMode(appMode: AppMode(rawValue: indexPath.row) ?? .free)
        }
        else if settingTitle.settingsType == .faceDetection {
            Defaults.shared.enableFaceDetection = !Defaults.shared.enableFaceDetection
            self.settingsTableView.reloadData()
        }
        else if settingTitle.settingsType == .swapeContols {
            Defaults.shared.swapeContols = !Defaults.shared.swapeContols
            self.settingsTableView.reloadData()
        }
        else if settingTitle.settingsType == .channelManagement {
            let chVc = R.storyboard.preRegistration.channelListViewController()
            chVc?.remainingPackageCountForOthers = Defaults.shared.currentUser?.remainingOtherUserPackageCount ?? 0
            self.navigationController?.pushViewController(chVc!, animated: true)
        }
        else if settingTitle.settingsType == .socialConnections {
            if let addSocialConnectionViewController = R.storyboard.socialConnection.addSocialConnectionViewController() {
                navigationController?.pushViewController(addSocialConnectionViewController, animated: true)
            }
        }
        else if settingTitle.settingsType == .termsAndConditions || settingTitle.settingsType == .privacyPolicy {
            guard let legalVc = R.storyboard.legal.legalViewController() else { return }
            legalVc.isTermsAndConditions = settingTitle.settingsType == .termsAndConditions
            self.navigationController?.pushViewController(legalVc, animated: true)
        } else if settingTitle.settingsType == .subscription {
            if Defaults.shared.allowFullAccess == true {
                lblLogoutPopup.text = R.string.localizable.freeDuringBetaTest()
                showHideButtonView(isHide: false)
                logoutPopupView.isHidden = false
            } else {
                if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
                    navigationController?.pushViewController(subscriptionVC, animated: true)
                }
            }
        } else if settingTitle.settingsType == .goToWebsite {
            if let yourAffiliateLinkVC = R.storyboard.storyCameraViewController.yourAffiliateLinkViewController() {
                navigationController?.pushViewController(yourAffiliateLinkVC, animated: true)
            }
        } else if settingTitle.settingsType == .applicationSurvey {
            if !isQuickApp {
                guard let url = URL(string: Constant.URLs.applicationSurveyURL) else { return }
                presentSafariBrowser(url: url)
            }
        } else if settingTitle.settingsType == .watermarkSettings {
            if let watermarkSettingsVC = R.storyboard.storyCameraViewController.watermarkSettingsViewController() {
                navigationController?.pushViewController(watermarkSettingsVC, animated: true)
            }
        } else if settingTitle.settingsType == .help {
            if let helpSettingsViewController = R.storyboard.storyCameraViewController.helpSettingsViewController() {
                navigationController?.pushViewController(helpSettingsViewController, animated: true)
            }
        } else if settingTitle.settingsType == .intellectualProperties {
            // TODO: - Need to add redirection link
        } else if settingTitle.settingsType == .accountSettings {
            if let accountSettingsViewController = R.storyboard.storyCameraViewController.accountSettingsViewController() {
                navigationController?.pushViewController(accountSettingsViewController, animated: true)
            }
        } else if settingTitle.settingsType == .deleteAccount {
            lblLogoutPopup.text = R.string.localizable.areYouSureYouWantToDeactivateYourAccount()
            isDeletePopup = true
            showHideButtonView(isHide: true)
            logoutPopupView.isHidden = false
        }
        else if settingTitle.settingsType == .shareSetting {
//          if let editProfileController = R.storyboard.refferalEditProfile.refferalEditProfileViewController() {
//                navigationController?.pushViewController(editProfileController, animated: true)
//            }
            if let userImageURL = Defaults.shared.currentUser?.profileImageURL , !userImageURL.isEmpty {
                if let contactWizardController = R.storyboard.contactWizardwithAboutUs.contactImportVC() {
                    navigationController?.pushViewController(contactWizardController, animated: true)
                }
            } else {
                if let editProfileController = R.storyboard.refferalEditProfile.refferalEditProfileViewController() {
                    navigationController?.pushViewController(editProfileController, animated: true)
                }
            }
        }
        else if settingTitle.settingsType == .userDashboard {
            openBussinessDashboard()
           
        } else if settingTitle.settingsType == .checkUpdate {
            SSAppUpdater.shared.performCheck(isForceUpdate: false, showDefaultAlert: true) { (_) in
            }
        } else if settingTitle.settingsType == .referringChannel {
            if let userDetailsVC = R.storyboard.notificationVC.userDetailsVC() {
                MIBlurPopup.show(userDetailsVC, on: self)
            }
        }else if settingTitle.settingsType == .aboutPage {
            if let aboutViewController = R.storyboard.aboutStoryboard.aboutViewController() {
                navigationController?.pushViewController(aboutViewController, animated: true)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        let noOfCellsInRow = 2   //number of column you want
//            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//            let totalSpace = flowLayout.sectionInset.left
//                + flowLayout.sectionInset.right
//                + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
//
//            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
//            return CGSize(width: size, height: 150)
        return CGSize(width: Int(collectionView.bounds.width/2), height: 150)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: CollectionViewReorderDelegate
extension StorySettingsVC: CollectionViewReorderDelegate {
    
    func collectionViewReorder(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = StorySettings.storySettings[sourceIndexPath.item]
        StorySettings.storySettings.remove(at: sourceIndexPath.item)
        StorySettings.storySettings.insert(item, at: destinationIndexPath.item)
    }
    
    func collectionViewReorder(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension StorySettingsVC {
    func setUpCopyRightView(showView: Bool = false) {
        self.tableViewBottomConstraints.constant = showView ? 90 : 0
        self.bottomCopyRightView.isHidden = !showView
    }
}

extension StorySettingsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // move up
            if self.lastContentOffset < 400 {
                UIView.animate(withDuration: 0.5, animations: {
                    self.setUpCopyRightView()
                })
            }
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // move down
            UIView.animate(withDuration: 0.5, animations: {
                if self.lastContentOffset > 400 {
                    self.setUpCopyRightView(showView: true)
                } else {
                    self.setUpCopyRightView()
                }
            })
        }
        self.lastContentOffset = scrollView.contentOffset.y
    }
}
