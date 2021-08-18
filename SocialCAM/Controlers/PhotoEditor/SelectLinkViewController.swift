//
//  SelectLinkViewController.swift
//  SocialCAM
//
//  Created by Meet Mistry on 10/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

enum LinkMode: Int {
    case quickCam = 0
    case vidPlay
    case businessCenter
    case enterLink
    case noLink
}

class SelectLinkSetting {
    var name: String
    var image: UIImage?
    
    init(name: String, image: UIImage? = UIImage()) {
        self.name = name
        self.image = image
    }
}

class SelectLink {
    
    var name: String
    var linkSettings: [SelectLinkSetting]
    var linkType: LinkMode
    
    init(name: String, linkSettings: [SelectLinkSetting], linkType: LinkMode) {
        self.name = name
        self.linkSettings = linkSettings
        self.linkType = linkType
    }
    
    static var selectLinks = [SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.quickCam(), image: UIImage(named: "iconQuickCam"))], linkType: .quickCam),
                              SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.vidPlay(), image: UIImage(named: "iconVidPlay"))], linkType: .vidPlay),
                              SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.newBusinessCenter(), image: UIImage(named: "iconBusinessCenter"))], linkType: .businessCenter),
                              SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.enterALink(), image: UIImage(named: "iconLink"))], linkType: .enterLink),
                              SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.noLink(), image: UIImage(named: "iconNoLink"))], linkType: .noLink)
    ]
}

class SelectLinkViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var selectLinkTableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var activateAffiliateLinkPopup: UIView!
    @IBOutlet weak var tempBackGroundView: UIView!
    @IBOutlet weak var enterLinkPopupView: UIView!
    @IBOutlet weak var tfEnterLink: UITextField!
    
    // MARK: - Variable Declaration
    var storyEditors: [StoryEditorView] = []
    private var currentStoryIndex = 0
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tempBackGroundView.isHidden = true
        self.selectLinkTableView.reloadData()
    }
    
    // MARK: - Action Methods
    @IBAction func btnYesTapped(_ sender: UIButton) {
        if currentStoryIndex == 0 {
            self.didSelect(type: QuickCamLiteApp.SSUTagType.quickApp, waitingListOptionType: nil, socialShareType: nil,
                           screenType: SSUTagScreen.ssutTypes)
        }
        Defaults.shared.isAffiliateLinkActivated = true
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnNoTapped(_ sender: UIButton) {
        if currentStoryIndex == 0 {
            self.didSelect(type: QuickCamLiteApp.SSUTagType.quickApp, waitingListOptionType: nil, socialShareType: nil,
                           screenType: SSUTagScreen.ssutTypes)
        }
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnOkTapped(_ sender: UIButton) {
        Defaults.shared.enterLinkValue = tfEnterLink.text!
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Table View DataSource
extension SelectLinkViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SelectLink.selectLinks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let linkTitle = SelectLink.selectLinks[section]
        return linkTitle.linkSettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let selectLinkCell: SelectLinkCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.selectLinkCell.identifier) as? SelectLinkCell else {
            fatalError("\(R.reuseIdentifier.selectLinkCell.identifier) Not Found")
        }
        
        let linkTitle = SelectLink.selectLinks[indexPath.section]
        let link = linkTitle.linkSettings[indexPath.row]
        selectLinkCell.lblLinkName.text = link.name
        selectLinkCell.imgLinkIcon.image = link.image
        
        return selectLinkCell
    }
}

// MARK: - Table View Delegate
extension SelectLinkViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsHeader.identifier) as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        headerView.title.isHidden = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let linkTitle = SelectLink.selectLinks[section]
        return linkTitle.linkType == .quickCam ? 30 : 5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let linkTitle = SelectLink.selectLinks[indexPath.section]
        if linkTitle.linkType == .quickCam {
            if Defaults.shared.isFromSignup! && !Defaults.shared.isAffiliatePopupShowed
                && !Defaults.shared.isAffiliateLinkActivated {
                backgroundView.isHidden = true
                selectLinkTableView.isHidden = true
                tempBackGroundView.isHidden = false
                activateAffiliateLinkPopup.isHidden = false
                Defaults.shared.isAffiliatePopupShowed = true
            } else {
                if currentStoryIndex == 0 {
                    self.didSelect(type: QuickCamLiteApp.SSUTagType.quickApp, waitingListOptionType: nil, socialShareType: nil,
                                   screenType: SSUTagScreen.ssutTypes)
                }
                dismiss(animated: true, completion: nil)
            }
        } else if linkTitle.linkType == .vidPlay {
            if currentStoryIndex == 0 {
                self.didSelect(type: QuickCamLiteApp.SSUTagType.vidPlay, waitingListOptionType: nil, socialShareType: nil,
                               screenType: SSUTagScreen.ssutTypes)
            }
            dismiss(animated: true, completion: nil)
        } else if linkTitle.linkType == .businessCenter {
            if currentStoryIndex == 0 {
                self.didSelect(type: QuickCamLiteApp.SSUTagType.businessCenter, waitingListOptionType: nil,
                               socialShareType: nil, screenType: SSUTagScreen.ssutTypes)
            }
            dismiss(animated: true, completion: nil)
        } else if linkTitle.linkType == .enterLink {
            backgroundView.isHidden = true
            selectLinkTableView.isHidden = true
            tempBackGroundView.isHidden = false
            enterLinkPopupView.isHidden = false
            if currentStoryIndex == 0 {
                self.didSelect(type: QuickCamLiteApp.SSUTagType.enterLink, waitingListOptionType: nil,
                               socialShareType: nil, screenType: SSUTagScreen.ssutTypes)
            }
        } else if linkTitle.linkType == .noLink {
            if currentStoryIndex == 0 {
                self.didSelect(type: QuickCamLiteApp.SSUTagType.noLink, waitingListOptionType: nil,
                               socialShareType: nil, screenType: SSUTagScreen.ssutTypes)
            }
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - SSUTagSelection Delegate
extension SelectLinkViewController: SSUTagSelectionDelegate {
    
    func didSelect(type: SSUTagType?, waitingListOptionType: SSUWaitingListOptionType?, socialShareType: SocialShare?, screenType: SSUTagScreen) {
        switch screenType {
        case .ssutTypes:
            switch type {
            case .quickCam:
                storyEditors[currentStoryIndex].addReferLinkView(type: .quickcam)
            case .quickCamLite:
                storyEditors[currentStoryIndex].addReferLinkView(type: .quickCamLite)
            case .quickApp:
                storyEditors[currentStoryIndex].addReferLinkView(type: .quickCamLite)
            case .businessCenter:
                storyEditors[currentStoryIndex].addReferLinkView(type: .businessCenter)
            case .vidPlay:
                storyEditors[currentStoryIndex].addReferLinkView(type: .vidPlay)
            case .enterLink:
                storyEditors[currentStoryIndex].addReferLinkView(type: .enterLink)
            case .noLink:
                storyEditors[currentStoryIndex].addReferLinkView(type: .NoLink)
            default:
                storyEditors[currentStoryIndex].addReferLinkView(type: .socialScreenRecorder)
            }
        case .ssutWaitingList:
            storyEditors[currentStoryIndex].addReferLinkView(type: .socialCam)
        default: break
        }
        //        self.needToExportVideo()
    }
}
