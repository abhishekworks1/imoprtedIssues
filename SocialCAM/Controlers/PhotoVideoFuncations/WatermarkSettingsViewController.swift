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
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.fastesteverImage(), selected: false)], settingsType: .fatesteverWatermark),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.applicationIdentifier(), selected: false)], settingsType: .applIdentifierWatermark),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.giF(), selected: false)], settingsType: .madeWithGif)
    ]
}

class WatermarkSettingsViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var watermarkSettingsTableView: UITableView!
    
    // MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.watermarkSettingsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.watermarkSettingsTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let sharedModel = Defaults.shared
        setUserSettings(appWatermark: sharedModel.appIdentifierWatermarkSetting.rawValue, fastesteverWatermark: sharedModel.fastestEverWatermarkSetting.rawValue, faceDetection: sharedModel.enableFaceDetection, guidelineThickness: sharedModel.cameraGuidelineThickness.rawValue, guidelineTypes: sharedModel.cameraGuidelineTypes.rawValue, guidelinesShow: sharedModel.enableGuildlines, iconPosition: sharedModel.swapeContols, supportedFrameRates: sharedModel.supportedFrameRates, videoResolution: sharedModel.videoResolution.rawValue, watermarkOpacity: sharedModel.waterarkOpacity, guidelineActiveColor: CommonFunctions.hexStringFromColor(color: sharedModel.cameraGuidelineActiveColor), guidelineInActiveColor: CommonFunctions.hexStringFromColor(color: sharedModel.cameraGuidelineInActiveColor))
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
        let settingTitle = CameraSettings.storySettings[section]
        if settingTitle.settingsType != .supportedFrameRates {
            headerView.title.isHidden = true
        } else {
            headerView.title.isHidden = false
        }
        headerView.title.text = settingTitle.name
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let settingTitle = CameraSettings.storySettings[section]
        if settingTitle.settingsType != .supportedFrameRates {
            return 1
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
}

extension WatermarkSettingsViewController {
    
    func setUserSettings(appWatermark: Int? = 1, fastesteverWatermark: Int? = 1, faceDetection: Bool? = false, guidelineThickness: Int? = 3, guidelineTypes: Int? = 3, guidelinesShow: Bool? = false, iconPosition: Bool? = false, supportedFrameRates: [String]?, videoResolution: Int? = 1, watermarkOpacity: Int? = 30, guidelineActiveColor: String?, guidelineInActiveColor: String?) {
        ProManagerApi.setUserSettings(appWatermark: appWatermark ?? 1, fastesteverWatermark: fastesteverWatermark ?? 1, faceDetection: faceDetection ?? false, guidelineThickness: guidelineThickness ?? 3, guidelineTypes: guidelineTypes ?? 3, guidelinesShow: guidelinesShow ?? false, iconPosition: iconPosition ?? false, supportedFrameRates: supportedFrameRates ?? [], videoResolution: videoResolution ?? 1, watermarkOpacity: watermarkOpacity ?? 30, guidelineActiveColor: guidelineActiveColor ?? "", guidelineInActiveColor: guidelineInActiveColor ?? "").request(Result<UserSettingsResult>.self).subscribe(onNext: { response in
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
    
}
