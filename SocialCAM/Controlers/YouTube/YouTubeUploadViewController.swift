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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultDropDown()
        IQKeyboardManager.shared.enableAutoToolbar = true
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
            self.playerView.isAutoPlay = false
            self.playerView.playUrl = videourl
            self.playerView.pause()
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
        btnPublish.isUserInteractionEnabled = false
        if GoogleManager.shared.isUserLogin {
            self.getUserToken()
        } else {
            GoogleManager.shared.login(controller: self, complitionBlock: { [weak self] (userData, error) in
                guard let `self` = self else { return }
                self.getUserToken()
            }) { (_, _) in
                self.btnPublish.isUserInteractionEnabled = true
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
        
        var snippet: [String: Any] = ["title": title, "categoryId": selectCat.id ?? ""]
        
        if let describtion = txtDescribtion.text, describtion.length > 0 {
            snippet["description"] = describtion
        }
        
        if !tagView.tags.isEmpty {
            snippet["tags"] = tagView.tags
        }
        
        if let channelId = selectedChannel?.id {
            snippet["channelId"] = channelId
        }
        
        var status: String = ""
        
        if let privacy = selectedPrivacy {
            status = privacy
        }
        let loadingView = LoadingView.instanceFromNib()
        loadingView.loadingViewShow = true
        loadingView.shouldCancelShow = true
        loadingView.show(on: self.view)
        
        self.isUploading = true
        ProManagerApi.uploadYoutubeVideo(token: token, videoURL: videoUrl!, snippet: snippet, status: status).request().subscribe(onNext: { (_) in
            self.isUploading = false
            loadingView.hide()
            Utils.appDelegate?.window?.makeToast(R.string.localizable.postSuccess())
            self.dismiss(animated: true)
        }, onError: { (error) in
            self.isUploading = false
            loadingView.hide()
            self.showAlert(alertMessage: error.localizedDescription)
        }).disposed(by: disposeBag ?? rx.disposeBag)
    }
    
    @IBAction func btnHashSetClicked(_ sender: Any) {
        
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
            self.playerView.play()
            self.btnPlayPause.setImage(R.image.storyPause(), for: .normal)
        }
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
