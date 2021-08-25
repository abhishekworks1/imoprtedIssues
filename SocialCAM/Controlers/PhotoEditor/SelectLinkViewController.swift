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

class SelectLinkViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var selectLinkTableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var activateAffiliateLinkPopup: UIView!
    @IBOutlet weak var blurBackGroundView: UIView!
    @IBOutlet weak var enterLinkPopupView: UIView!
    @IBOutlet weak var tfEnterLink: UITextField!
    
    // MARK: - Variable Declaration
    var storyEditors: [StoryEditorView] = []
    private var currentStoryIndex = 0
    private lazy var yourAffiliateLinkVC = YourAffiliateLinkViewController()
    private lazy var storyEditorVC = StoryEditorViewController()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        blurBackGroundView.isHidden = true
        self.selectLinkTableView.reloadData()
    }
    
    // MARK: - Action Methods
    @IBAction func btnYesTapped(_ sender: UIButton) {
        yourAffiliateLinkVC.setAffiliate(setAffiliateValue: true)
        callDidSelectMethod(type: QuickCamLiteApp.SSUTagType.quickApp)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnNoTapped(_ sender: UIButton) {
        callDidSelectMethod(type: QuickCamLiteApp.SSUTagType.quickApp)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnOkTapped(_ sender: UIButton) {
        Defaults.shared.enterLinkValue = tfEnterLink.text ?? ""
        dismiss(animated: true, completion: nil)
    }
    
    func callDidSelectMethod(type: SSUTagType) {
        if currentStoryIndex == 0 {
            self.didSelect(type: type, waitingListOptionType: nil, socialShareType: nil,
                           screenType: SSUTagScreen.ssutTypes)
        }
    }
}

// MARK: - Table View DataSource
extension SelectLinkViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SelectLink.selectLinks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectLink.selectLinks[section].linkSettings.count
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
            if Defaults.shared.isFromSignup ?? false && !Defaults.shared.isAffiliatePopupShowed
                && !Defaults.shared.isAffiliateLinkActivated {
                backgroundView.isHidden = true
                selectLinkTableView.isHidden = true
                blurBackGroundView.isHidden = false
                activateAffiliateLinkPopup.isHidden = false
                Defaults.shared.isAffiliatePopupShowed = true
            } else {
                callDidSelectMethod(type: QuickCamLiteApp.SSUTagType.quickApp)
                dismiss(animated: true, completion: nil)
            }
        } else if linkTitle.linkType == .vidPlay {
            callDidSelectMethod(type: QuickCamLiteApp.SSUTagType.vidPlay)
            dismiss(animated: true, completion: nil)
        } else if linkTitle.linkType == .businessCenter {
            callDidSelectMethod(type: QuickCamLiteApp.SSUTagType.businessCenter)
            dismiss(animated: true, completion: nil)
        } else if linkTitle.linkType == .enterLink {
            backgroundView.isHidden = true
            selectLinkTableView.isHidden = true
            blurBackGroundView.isHidden = false
            enterLinkPopupView.isHidden = false
            callDidSelectMethod(type: QuickCamLiteApp.SSUTagType.enterLink)
        } else if linkTitle.linkType == .noLink {
            callDidSelectMethod(type: QuickCamLiteApp.SSUTagType.noLink)
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
        storyEditorVC.videoExportedURL = nil
    }
}
