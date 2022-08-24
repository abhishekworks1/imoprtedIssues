//
//  WatermarkSettingsViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 07/04/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class WatermarkSettings {
    
    var name: String
    var settings: [StorySetting]
    var settingsType: SettingsMode
    
    init(name: String, settings: [StorySetting], settingsType: SettingsMode) {
        self.name = name
        self.settings = settings
        self.settingsType = settingsType
    }
    
    static var watermarkSettings = [
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.fastestevercontest(), selected: false)], settingsType: .fatesteverWatermark),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.madeWith(Constant.Application.displayName), selected: false)], settingsType: .applIdentifierWatermark),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.madeWithgif(Constant.Application.displayName), selected: false)], settingsType: .madeWithGif),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.fastestevercontest(), selected: false)], settingsType: .publicDisplaynameWatermark)
    ]
}

class WatermarkSettingsViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var watermarkSettingsTableView: UITableView!
    @IBOutlet weak var btnFastesteverWatermark: UIButton!
    @IBOutlet weak var btnSelectFastesteverWatermark: UIButton!
    @IBOutlet weak var btnAppIdentifierWatermark: UIButton!
    @IBOutlet weak var btnSelectAppIdentifierWatermark: UIButton!
    @IBOutlet weak var btnMadeWithWatermark: UIButton!
    @IBOutlet weak var imgViewMadeWithGif: UIImageView!
    @IBOutlet weak var btnSelectedMadeWithGif: UIButton!
    @IBOutlet weak var btnMadeWithGif: UIButton!
    @IBOutlet weak var lblUserNameWatermark: UILabel!
    @IBOutlet weak var lblPublicDisplaynameWatermark: UILabel!
    @IBOutlet weak var btnSelectPublicDisplaynameWatermark: UIButton!
    @IBOutlet weak var btnPublicDisplaynameWatermark: UIButton!
    
    // MARK: - Variables Declaration
    var isFastesteverWatermarkShow = false
    var isAppIdentifierWatermarkShow = false
    var isMadeWithGifShow = false
    var isPublicDisplaynameWatermarkShow = false
    // MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
//        "@\(Defaults.shared.channelName ?? "")"
        self.watermarkSettingsTableView.reloadData()
        imgViewMadeWithGif.loadGif(name: R.string.localizable.madeWithQuickCamLite())
        self.lblUserNameWatermark.text = "@\(Defaults.shared.channelName ?? "")"
//        "@\(Defaults.shared.currentUser?.username ?? "")"
        isFastesteverWatermarkShow = Defaults.shared.fastestEverWatermarkSetting == .show
        btnSelectFastesteverWatermark.isSelected = isFastesteverWatermarkShow
        btnFastesteverWatermark.isSelected = isFastesteverWatermarkShow
        isAppIdentifierWatermarkShow = Defaults.shared.appIdentifierWatermarkSetting == .show
        btnSelectAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        btnAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        isMadeWithGifShow = Defaults.shared.madeWithGifSetting == .show
        btnSelectedMadeWithGif.isSelected = isMadeWithGifShow
        isPublicDisplaynameWatermarkShow = Defaults.shared.publicDisplaynameWatermarkSetting == .show
        btnSelectPublicDisplaynameWatermark.isSelected = isPublicDisplaynameWatermarkShow
        isPublicDisplaynameWatermarkShow = Defaults.shared.publicDisplaynameWatermarkSetting == .show
        self.lblPublicDisplaynameWatermark.text = "@\(Defaults.shared.channelName ?? "")"
//        "@\(Defaults.shared.currentUser?.username ?? "")"
       /* if Defaults.shared.appMode == .free {
            btnFastesteverWatermark.isSelected = true
            btnAppIdentifierWatermark.isSelected = true
            btnSelectAppIdentifierWatermark.isSelected = true
            btnSelectedMadeWithGif.isSelected = true
        } */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.watermarkSettingsTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        callSetUserSetting()
    }
    
    deinit {
        print("Deinit \(self.description)")
    }
    
    @objc func goToSubscriptionVC() {
        if (Defaults.shared.appIdentifierWatermarkSetting == .hide || Defaults.shared.madeWithGifSetting == .hide) && Defaults.shared.appMode == .free {
            if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
                navigationController?.pushViewController(subscriptionVC, animated: true)
                Defaults.shared.appIdentifierWatermarkSetting = .show
            }
        }
    }
    
    // MARK: - Action Methods
    @IBAction func onBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func fastesteverWatermarkButtonClicked(sender: UIButton) {
        isFastesteverWatermarkShow = !isFastesteverWatermarkShow
        btnFastesteverWatermark.isSelected = isFastesteverWatermarkShow
        btnSelectFastesteverWatermark.isSelected = isFastesteverWatermarkShow
        Defaults.shared.fastestEverWatermarkSetting = self.isFastesteverWatermarkShow ? .show : .hide
    }
    
    @IBAction func appIdentifierWatermarkButtonClicked(sender: UIButton) {
       /* if Defaults.shared.appMode == .free {
            if let watermarkSettingsVC = R.storyboard.storyCameraViewController.watermarkSettingsViewController() {
                navigationController?.pushViewController(watermarkSettingsVC, animated: true)
            }
        } else {
            isAppIdentifierWatermarkShow = !isAppIdentifierWatermarkShow
            btnAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
            btnSelectAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        } */
        isAppIdentifierWatermarkShow = !isAppIdentifierWatermarkShow
        btnAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        btnSelectAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        Defaults.shared.appIdentifierWatermarkSetting = self.isAppIdentifierWatermarkShow ? .show : .hide
        if (Defaults.shared.publicDisplaynameWatermarkSetting == .show){
            Defaults.shared.publicDisplaynameWatermarkSetting = .hide
            isPublicDisplaynameWatermarkShow = false
            btnSelectPublicDisplaynameWatermark.isSelected = isPublicDisplaynameWatermarkShow
        }
        
    }
    
    @IBAction func madeWithGifButtonClicked(sender: UIButton) {
      /*  if Defaults.shared.appMode == .free {
            if let watermarkSettingsVC = R.storyboard.storyCameraViewController.watermarkSettingsViewController() {
                navigationController?.pushViewController(watermarkSettingsVC, animated: true)
            }
        } else {
            isMadeWithGifShow = !isMadeWithGifShow
            btnSelectedMadeWithGif.isSelected = isMadeWithGifShow
        } */
        isMadeWithGifShow = !isMadeWithGifShow
        btnSelectedMadeWithGif.isSelected = isMadeWithGifShow
        Defaults.shared.madeWithGifSetting = self.isMadeWithGifShow ? .show : .hide
    }
    @IBAction func publicDisplaynameButtonClicked(sender: UIButton) {
        isPublicDisplaynameWatermarkShow = !isPublicDisplaynameWatermarkShow
        btnSelectPublicDisplaynameWatermark.isSelected = isPublicDisplaynameWatermarkShow
        Defaults.shared.publicDisplaynameWatermarkSetting = self.isPublicDisplaynameWatermarkShow ? .show : .hide
        if (Defaults.shared.appIdentifierWatermarkSetting == .show){
            Defaults.shared.appIdentifierWatermarkSetting = .hide
            isAppIdentifierWatermarkShow = false
            btnSelectAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        }
    }
}

// MARK: - Table View DataSource
extension WatermarkSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return WatermarkSettings.watermarkSettings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let settingTitle = WatermarkSettings.watermarkSettings[section]
        return settingTitle.settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let watermarkSettingCell: WatermarkSettingCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.watermarkSettingCell.identifier) as? WatermarkSettingCell else {
            fatalError("\(R.reuseIdentifier.watermarkSettingCell.identifier) Not Found")
        }
        let settingTitle = WatermarkSettings.watermarkSettings[indexPath.section]
        if settingTitle.settingsType == .fatesteverWatermark {
            watermarkSettingCell.watermarkType = .fastestEverWatermark
            if Defaults.shared.appMode == .free {
                watermarkSettingCell.hideWatermarkButton.addTarget(self, action: #selector(goToSubscriptionVC), for: .touchUpInside)
            }
        } else if settingTitle.settingsType == .applIdentifierWatermark {
            watermarkSettingCell.watermarkType = .applicationIdentifier
            if Defaults.shared.appMode == .free {
                watermarkSettingCell.hideWatermarkButton.addTarget(self, action: #selector(goToSubscriptionVC), for: .touchUpInside)
            }
        } else if settingTitle.settingsType == .madeWithGif {
            watermarkSettingCell.watermarkType = .madeWithGif
            if Defaults.shared.appMode == .free {
                watermarkSettingCell.hideWatermarkButton.addTarget(self, action: #selector(goToSubscriptionVC), for: .touchUpInside)
            }
        } else if settingTitle.settingsType == .publicDisplaynameWatermark {
            watermarkSettingCell.watermarkType = .publicDisplaynameWatermark
            if Defaults.shared.appMode == .free {
                watermarkSettingCell.hideWatermarkButton.addTarget(self, action: #selector(goToSubscriptionVC), for: .touchUpInside)
            }
        }
        return watermarkSettingCell
    }
    
}

// MARK: - Table View Delegate
extension WatermarkSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsHeader.identifier) as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        headerView.title.isHidden = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
}

extension WatermarkSettingsViewController {
    
    func setUserSettings(appWatermark: Int? = 1, fastesteverWatermark: Int? = 2, faceDetection: Bool? = false, guidelineThickness: Int? = 3, guidelineTypes: Int? = 3, guidelinesShow: Bool? = false, iconPosition: Bool? = false, supportedFrameRates: [String]?, videoResolution: Int? = 1, watermarkOpacity: Int? = 30, guidelineActiveColor: String?, guidelineInActiveColor: String?) {
        ProManagerApi.setUserSettings(appWatermark: appWatermark ?? 1, fastesteverWatermark: fastesteverWatermark ?? 2, faceDetection: faceDetection ?? false, guidelineThickness: guidelineThickness ?? 3, guidelineTypes: guidelineTypes ?? 3, guidelinesShow: guidelinesShow ?? false, iconPosition: iconPosition ?? false, supportedFrameRates: supportedFrameRates ?? [], videoResolution: videoResolution ?? 1, watermarkOpacity: watermarkOpacity ?? 30, guidelineActiveColor: guidelineActiveColor ?? "", guidelineInActiveColor: guidelineInActiveColor ?? "").request(Result<UserSettingsResult>.self).subscribe(onNext: { response in
            if response.status == ResponseType.success {
                print(R.string.localizable.success())
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            print(error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: (rx.disposeBag))
    }
    
    func callSetUserSetting() {
        let sharedModel = Defaults.shared
        setUserSettings(appWatermark: sharedModel.appIdentifierWatermarkSetting.rawValue, fastesteverWatermark: sharedModel.fastestEverWatermarkSetting.rawValue, faceDetection: sharedModel.enableFaceDetection, guidelineThickness: sharedModel.cameraGuidelineThickness.rawValue, guidelineTypes: sharedModel.cameraGuidelineTypes.rawValue, guidelinesShow: sharedModel.enableGuildlines, iconPosition: sharedModel.swapeContols, supportedFrameRates: sharedModel.supportedFrameRates, videoResolution: sharedModel.videoResolution.rawValue, watermarkOpacity: sharedModel.waterarkOpacity, guidelineActiveColor: CommonFunctions.hexStringFromColor(color: sharedModel.cameraGuidelineActiveColor), guidelineInActiveColor: CommonFunctions.hexStringFromColor(color: sharedModel.cameraGuidelineInActiveColor))
    }
    
}
