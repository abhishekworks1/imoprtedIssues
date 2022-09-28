//
//  SelectLinkViewController.swift
//  SocialCAM
//
//  Created by Meet Mistry on 10/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import Alamofire
import LinkPresentation

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
    @IBOutlet weak var imageViewProfile: UIImageView!
    
    // MARK: - Variable Declaration
    var storyEditors: [StoryEditorView] = []
    private var currentStoryIndex = 0
    private lazy var yourAffiliateLinkVC = YourAffiliateLinkViewController()
    private lazy var storyEditorVC = StoryEditorViewController()
    var dismissCallback: ((_ dismissCompletion: Bool) -> Void)?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        view.backgroundColor = .clear
        blurBackGroundView.isHidden = true
        SelectLink.selectLinks.removeAll()
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            if userImageURL.isEmpty {
                imageViewProfile.isHidden = true
            }
            imageViewProfile.isHidden = false
            imageViewProfile.loadImageWithSDwebImage(imageUrlString: userImageURL)
        } else {
            imageViewProfile.isHidden = true
        }
//        imageViewProfile.isHidden = true
        
        getLinkCells()
        blurBackGroundView.isUserInteractionEnabled = true
        blurBackGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped)))
    }
    
    // MARK: - Action Methods
    @IBAction func btnYesTapped(_ sender: UIButton) {
        yourAffiliateLinkVC.setAffiliate(setAffiliateValue: true)
        callDidSelectMethod(type: QuickCam.SSUTagType.quickApp)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnNoTapped(_ sender: UIButton) {
        callDidSelectMethod(type: QuickCam.SSUTagType.quickApp)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnOkTapped(_ sender: UIButton) {
        let link = tfEnterLink.text ?? ""
        Defaults.shared.enterLinkValue = link
        guard let followMeStoryView: FollowMeStoryView = storyEditors[currentStoryIndex].subviews[4] as? FollowMeStoryView else {
            return
        }
        if !link.isEmpty && (link.contains("https") || link.contains("http")) {
            self.showHUD()
            getLinkPreview(link: link) { [weak self] image in
                guard let `self` = self else { return }
                DispatchQueue.main.sync {
                    followMeStoryView.userBitEmoji.image = image
                    self.dismiss(animated: true, completion: nil)
                    self.dismissHUD()
                }
            }
        } else {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterProperUrl())
        }
    }
    
    @IBAction func didTapCloseButton(_ sender: UIButton) {
        dismissCallback?(true)
        dismiss(animated: true, completion: nil)
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
                callDidSelectMethod(type: QuickCam.SSUTagType.quickApp)
                dismiss(animated: true, completion: nil)
            }
        } else if linkTitle.linkType == .vidPlay {
            callDidSelectMethod(type: QuickCam.SSUTagType.vidPlay)
            dismiss(animated: true, completion: nil)
        } else if linkTitle.linkType == .businessCenter {
            callDidSelectMethod(type: QuickCam.SSUTagType.businessCenter)
            dismiss(animated: true, completion: nil)
        } else if linkTitle.linkType == .enterLink {
            backgroundView.isHidden = true
            selectLinkTableView.isHidden = true
            blurBackGroundView.isHidden = false
            enterLinkPopupView.isHidden = false
            callDidSelectMethod(type: QuickCam.SSUTagType.enterLink)
        } else if linkTitle.linkType == .noLink {
            callDidSelectMethod(type: QuickCam.SSUTagType.noLink)
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
                storyEditors[currentStoryIndex].addReferLinkView(type: .noLink)
            default:
                storyEditors[currentStoryIndex].addReferLinkView(type: .socialScreenRecorder)
            }
        case .ssutWaitingList:
            storyEditors[currentStoryIndex].addReferLinkView(type: .socialCam)
        default: break
        }
        storyEditorVC.isSettingsChange = true
    }
}

// MARK: - Methods
extension SelectLinkViewController {
    
    @objc func backgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func callDidSelectMethod(type: SSUTagType) {
        if currentStoryIndex == 0 {
            self.didSelect(type: type, waitingListOptionType: nil, socialShareType: nil,
                           screenType: SSUTagScreen.ssutTypes)
        }
    }
    
    func getLinkCells() {
        guard let businessCenterAppUrl = URL(string: DeepLinkData.deepLinkUrlString),
              let vidPlayAppUrl = URL(string: DeepLinkData.vidplayDeepLinkUrlString) else {
            return
        }
        let quickCamCell = SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.quickCam(), image: R.image.iconQuickCam())], linkType: .quickCam)
        SelectLink.selectLinks.append(quickCamCell)
        if UIApplication.shared.canOpenURL(vidPlayAppUrl) {
            let vidPlayCell = SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.vidPlay(), image: R.image.iconVidPlay())], linkType: .vidPlay)
            SelectLink.selectLinks.append(vidPlayCell)
        }
        if UIApplication.shared.canOpenURL(businessCenterAppUrl) {
            let businessCenterCell = SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.businessCenter(), image: R.image.iconBusinessCenter())], linkType: .businessCenter)
            SelectLink.selectLinks.append(businessCenterCell)
        }
        // TODO: - Temporary disabled from client's side
        /* let enterLinkCell = SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.enterALink(), image: R.image.iconLink())], linkType: .enterLink)
         SelectLink.selectLinks.append(enterLinkCell)
         let noLinkCell = SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.noLink(), image: R.image.iconNoLink())], linkType: .noLink)
         SelectLink.selectLinks.append(noLinkCell) */
    }
    
    func getLinkPreview(link: String, completionHandler: @escaping (UIImage) -> Void) {
        guard let url = URL(string: link) else {
            return
        }

        if #available(iOS 13.0, *) {
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
                    self.getImage(data: data) { [weak self] image in
                        guard let `self` = self else { return }
                        completionHandler(image)
                    }
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
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
    }
}
