//
//  YouTubeUploadViewController.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 13/03/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import RxSwift
import IQKeyboardManagerSwift
import AVFoundation
import GoogleAPIClientForREST

class YouTubeUploadViewController: UIViewController {
    @IBOutlet weak var txtTitle: SkyFloatingLabelTextField!
    @IBOutlet weak var txtDescribtion: GrowingTextView!
    @IBOutlet weak var tagView: RKTagsView!
    @IBOutlet weak var txtPermision: SkyFloatingLabelTextField!
    @IBOutlet weak var txtChannels: SkyFloatingLabelTextField!
    @IBOutlet weak var txtCategoty: SkyFloatingLabelTextField!
    @IBOutlet weak var btnPublish: UIButton!
    @IBOutlet weak var privacyPicker: UIPickerView!
    @IBOutlet weak var pickerContainer: UIView?
    @IBOutlet var playerView: PlayerView!
    @IBOutlet var btnPlayPause: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var postSuccessPopupView: UIView!
    @IBOutlet weak var lblPostSuccess: UILabel!
    @IBOutlet weak var loadingVideoUploadView: UIView!
    @IBOutlet weak var loadingThumbImageView: UIImageView!
    @IBOutlet weak var loadingSpinnerView: UIView!
    @IBOutlet weak var spinnerImageView: UIImageView!
    @IBOutlet weak var tipOfDayLabel: UILabel! {
        didSet {
            tipOfDayLabel.text = (Defaults.shared.tipOfDay ?? []).randomElement()
        }
    }

    let dropDownMenu = DropDown()
    var privacy: [String] =  ["Public", "Private", "Unlisted"]
    var channels: [Item] = []
    
    var videoUrl: URL?
    var selectedCategory: YouCategory? {
        didSet {
            if let category = selectedCategory {
                txtCategoty.text = category.snippet?.title ?? ""
            } else {
                txtCategoty.text = ""
            }
        }
    }
    var selectedPrivacy: String? {
        didSet {
            if let privacy = selectedPrivacy {
                self.txtPermision.text = privacy
            } else {
                self.txtPermision.text = ""
            }
        }
    }
    
    var selectedChannel: Item? {
        didSet {
            if let channel = selectedChannel {
                self.txtChannels.text = channel.snippet?.title
            } else {
                self.txtChannels.text = ""
            }
        }
    }
    
    var disposeBag: DisposeBag? = DisposeBag()
    
    var isUploading = false {
        didSet {
            btnPublish.isHidden = isUploading
            activityIndicator.isHidden = !isUploading
            if isUploading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    var token: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultDropDown()
        IQKeyboardManager.shared.enableAutoToolbar = true
        spinnerImageView.loadGif(asset: "Spinner")
        self.tagView.isMerge = true
        self.tagView.textField.placeholder = "#Hashtags"
        self.tagView.textField.returnKeyType = .done
        self.tagView.textField.tag = 1
        self.tagView.textField.delegate = self
        self.tagView.tintColor = UIColor.gray79
        self.tagView.interitemSpacing =  4.0
        self.tagView.lineSpacing =  4.0
        self.tagView.isHasTag = true
        self.tagView.font = UIFont.sfuifont
        self.tagView.layoutIfNeeded()
        if let videourl = self.videoUrl {
            self.playerView.isAutoPlay = true
            self.playerView.playUrl = videourl
            self.playerView.pause()
            self.imgThumbnail.contentMode = .scaleAspectFit
            self.imgThumbnail.image = UIImage.getThumbnailFrom(videoUrl: videourl)
            self.loadingThumbImageView.image = UIImage.getThumbnailFrom(videoUrl: videourl)
        }
        getChannelName()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if Defaults.shared.isSkipYoutubeLogin == false {
            GoogleManager.shared.logout()
        }
    }
    
    func setupDefaultDropDown() {
        DropDown.setupDefaultAppearance()
        dropDownMenu.cellNib = UINib(nibName: "MyCell", bundle: nil)
        dropDownMenu.anchorView = txtChannels
        dropDownMenu.topOffset = CGPoint(x: 0, y: -50)
        dropDownMenu.direction = .top
        
        self.dropDownMenu.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? MyCell else { return }
            cell.logoImageView.isHidden = true
        }
        
        self.dropDownMenu.selectionAction = { [weak self] (index, item) in
            guard let `self` = self else {
                return
            }
            self.selectedChannel = self.channels[index]
        }
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        disposeBag = nil
        self.dismiss(animated: true)
    }
    
    @IBAction func btnPublishClicked(_ sender: Any?) {
        btnPublish.isUserInteractionEnabled = true
        uploadVideo(token: token)
    }
    
    @IBAction func loadingOKClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            DispatchQueue.runOnMainThread {
                Utils.customaizeToastMessage(title: "Your Quickie will continue uploading in the background.", toastView: (Utils.appDelegate?.window)!)
            }
        }

    }
    
    func getUserToken() {
        GoogleManager.shared.getUserToken { [weak self] (token) in
            guard let `self` = self else { return }
            guard let token = token else {
                return
            }
            self.btnPublish.isUserInteractionEnabled = true
            self.uploadVideo(token: token)
        }
    }
    
    func getChannelName() {
        GoogleManager.shared.getUserToken { (token) in
            guard let token = token else {
                return
            }
            ProManagerApi.youTubeChannels(token: token).request(YouTubeItmeListResponse<Item>.self).subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else {
                    return
                }
                if response.item.count > 0 {
                    if let data = response.item[0].snippet {
                        guard let channelName = data.title,
                              let thumbNail = data.thumbnail else {
                            return
                        }
                        Defaults.shared.ytChannelName = channelName
                        Defaults.shared.channelThumbNail = thumbNail
                    }
                } else {
                    self.showAlert(alertMessage: R.string.localizable.noChannelFound())
                    Defaults.shared.ytChannelName = ""
                    
                }
            }, onError: { error in
                self.showAlert(alertMessage: error.localizedDescription)
            }, onCompleted: {
            }).disposed(by: self.rx.disposeBag)
        }
    }
    
    func uploadVideo(token: String) {
        guard !self.isUploading else {
            return
        }
        guard let title = txtTitle.text, title.length > 0 else {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterTitle())
            return
        }
        
        guard let selectCat = self.selectedCategory else {
            self.showAlert(alertMessage: R.string.localizable.pleaseSelectCategory())
            return
        }
        
        loadingVideoUploadView.isHidden = false
        self.isUploading = true
        YouTubeUploadManager.shared.uploadVideo(videoUrl: videoUrl!,
                                                selectedPrivacy: selectedPrivacy ?? "", title: title, selectCat: selectCat, description: txtDescribtion.text ?? "", tags: tagView.tags, selectedChannel: selectedChannel) { [weak self] isUpload in
            guard let `self` = self else {
                return
            }
            if isUpload ?? false {
                self.isUploading = false
                self.loadingVideoUploadView.isHidden = true
                self.showPostSuccessPopupView(isSuccess: true)
            } else {
                self.isUploading = false
                self.loadingVideoUploadView.isHidden = true
                self.showPostSuccessPopupView(isSuccess: false)
            }
        }
        
//        let loadingView = LoadingView.instanceFromNib()
//        loadingView.processingYourQuickieLabel.text = "Uploading your Quickie to YouTube"
//        loadingView.loadingViewShow = true
//        loadingView.shouldCancelShow = true
//        loadingView.show(on: self.view)
        
        //Status
//        let status = GTLRYouTube_VideoStatus()
//        switch selectedPrivacy ?? "" {
//        case "Public":
//            status.privacyStatus = kGTLRYouTube_ChannelStatus_PrivacyStatus_Public
//        case "Private":
//            status.privacyStatus = kGTLRYouTube_ChannelStatus_PrivacyStatus_Private
//        case "Unlisted":
//            status.privacyStatus = kGTLRYouTube_ChannelStatus_PrivacyStatus_Unlisted
//        default:
//            status.privacyStatus = kGTLRYouTube_ChannelStatus_PrivacyStatus_Private
//        }
//
//        //Snippet
//        let snippet = GTLRYouTube_VideoSnippet()
//        snippet.title = title
//        snippet.categoryId = selectCat.id ?? ""
//        if let describtion = txtDescribtion.text, describtion.length > 0 {
//            snippet.descriptionProperty = describtion
//        }
//        if !tagView.tags.isEmpty {
//            snippet.tags = tagView.tags
//        }
//        if let channelId = selectedChannel?.id {
//            snippet.channelId = channelId.videoId
//        }
//        //Upload parameters
//        let params = GTLRUploadParameters(fileURL: videoUrl!, mimeType: "video/mp4")
//        let video = GTLRYouTube_Video()
//        video.status = status
//        video.snippet = snippet
//
//        GoogleManager.shared.uploadVideoOnYoutube(youtubeObject: video, params: params) { [weak self] isUpload in
//            guard let `self` = self else {
//                return
//            }
//            if isUpload ?? false {
//                self.isUploading = false
//                self.loadingVideoUploadView.isHidden = true
//                self.showPostSuccessPopupView(isSuccess: true)
//            } else {
//                self.isUploading = false
//                self.loadingVideoUploadView.isHidden = true
//                self.showPostSuccessPopupView(isSuccess: false)
//            }
//        }
    }
    
    @IBAction func btnHashSetClicked(_ sender: Any) {
        if let vc = R.storyboard.youTubeUpload.selectHashTagViewController() {
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        self.pickerContainer?.isHidden = true
    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        let index = self.privacyPicker.selectedRow(inComponent: 0)
        selectedPrivacy =  privacy[index]
        self.pickerContainer?.isHidden = true
    }
    
    @IBAction func btnPlayPauseClicked(_ sender: Any) {
        switch playerView.currentPlayStatus {
        case .playing:
            self.playerView.pause()
            self.btnPlayPause.setImage(R.image.storyPlay(), for: .normal)
        default:
            self.imgThumbnail.isHidden = true
            self.playerView.play()
            self.btnPlayPause.setImage(R.image.storyPause(), for: .normal)
        }
    }
    
    @IBAction func btnPostSuccessOkClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func showPostSuccessPopupView(isSuccess: Bool) {
        lblPostSuccess.text = isSuccess ? R.string.localizable.yourVideoPostedSuccessfully() : R.string.localizable.somethingWentWrongPleaseTryAgainLater()
        self.postSuccessPopupView.isHidden = false
    }
    
    func channelClicked() {
        if let obj = R.storyboard.youTubeUpload.youTubeCategoriesViewController() {
            obj.delegate = self
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    func privacyClicked() {
        if let selectedPrivacy = self.selectedPrivacy {
            let index = self.privacy.firstIndex(of: selectedPrivacy)
            self.privacyPicker.selectRow(index ?? 0, inComponent: 0, animated: false)
            self.privacyPicker.reloadAllComponents()
        }
        self.pickerContainer?.isHidden = false
    }
}

extension YouTubeUploadViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            txtDescribtion.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            return true
        }
        return false
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if txtCategoty == textField {
            self.channelClicked()
            return false
        }
        if txtPermision == textField {
            self.privacyClicked()
            return false
        }
        if txtChannels == textField {
            return false
        }
        return true
    }
    
}

extension YouTubeUploadViewController: YouCategoryDelegate {
    
    func didFinishWith(category: YouCategory) {
        self.selectedCategory = category
    }
    
}

extension YouTubeUploadViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return privacy[row]
    }
    
}

extension YouTubeUploadViewController: SelectHashSetDelegate {
    
    func setSelectedSet(hashSet: HashTagSetList, isHashSetSelected: Bool) {
        if let youhash = hashSet.hashTags {
            for youhashValue in youhash {
                let newTag = youhashValue.replace("#", with: "")
                self.tagView.addTag(newTag)
                let bottomOffset = CGPoint(x: 0, y: self.tagView.scrollView.contentSize.height - self.tagView.scrollView.bounds.size.height)
                self.tagView.scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    func noSetSelected(isSelected: Bool) {
        
    }
    
}

class YouTubeUploadManager {
    
    static let shared = YouTubeUploadManager()
    
    func uploadVideo(videoUrl: URL, selectedPrivacy: String, title: String, selectCat: YouCategory, description: String, tags: [String], selectedChannel: Item?, completion: @escaping (_ isUpload: Bool?) -> ()) {
        //Status
        let status = GTLRYouTube_VideoStatus()
        switch selectedPrivacy {
        case "Public":
            status.privacyStatus = kGTLRYouTube_ChannelStatus_PrivacyStatus_Public
        case "Private":
            status.privacyStatus = kGTLRYouTube_ChannelStatus_PrivacyStatus_Private
        case "Unlisted":
            status.privacyStatus = kGTLRYouTube_ChannelStatus_PrivacyStatus_Unlisted
        default:
            status.privacyStatus = kGTLRYouTube_ChannelStatus_PrivacyStatus_Private
        }
        
        //Snippet
        let snippet = GTLRYouTube_VideoSnippet()
        snippet.title = title
        snippet.categoryId = selectCat.id ?? ""
        if description.length > 0 {
            snippet.descriptionProperty = description
        }
        if !tags.isEmpty {
            snippet.tags = tags
        }
        if let channelId = selectedChannel?.id {
            snippet.channelId = channelId.videoId
        }
        //Upload parameters
        let params = GTLRUploadParameters(fileURL: videoUrl, mimeType: "video/mp4")
        let video = GTLRYouTube_Video()
        video.status = status
        video.snippet = snippet
        
        GoogleManager.shared.uploadVideoOnYoutube(youtubeObject: video, params: params) { isUpload in
            completion(isUpload ?? false)
            if isUpload ?? false {
                DispatchQueue.runOnMainThread {
                    Utils.customaizeToastMessage(title: "Video uploaded successfully", toastView: (Utils.appDelegate?.window)!)
                }
            } else {
                DispatchQueue.runOnMainThread {
                    Utils.customaizeToastMessage(title: "Video upload failed", toastView: (Utils.appDelegate?.window)!)
                }
            }
        }
    }
    
}
