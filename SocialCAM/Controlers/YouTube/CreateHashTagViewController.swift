//
//  CreateHashTagViewController.swift
//  ProManager
//
//  Created by Steffi Pravasi on 11/09/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol finishedTag {
    func didFinish(isDone: Bool)
}

class CreateHashTagViewController: UIViewController {
    
    // MARK: -- Variables
    var youtubeTag: [String]?
    var isEdit: Bool = false
    var setData: HashTagSetList?
    var usedSetsName: [String] = []
    var delegate: finishedTag?
    
    @IBOutlet var categoryNameLbl: UITextField!
    @IBOutlet var tagView: RKTagsView!
    @IBOutlet var activityIndicator: NVActivityIndicatorView! {
        didSet {
            activityIndicator.color = ApplicationSettings.appPrimaryColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tagView.isMerge = true
        self.tagView.textField.placeholder = R.string.localizable.hashtags()
        self.tagView.textField.returnKeyType = .done
        self.tagView.tintColor = UIColor.gray79
        self.tagView.interitemSpacing =  4.0
        self.tagView.lineSpacing =  4.0
        self.tagView.isHasTag = true
        self.tagView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isEdit {
            youtubeTag = setData?.hashTags
            self.categoryNameLbl.text = setData?.categoryName
        }
        if let youhash = youtubeTag {
            for t in youhash {
                let newTag = t.replace("#", with: "")
                self.tagView.addTag(newTag)
            }
        }
    }

    @IBAction func createHashTagBtnClicked(_ sender: Any) {
        if self.categoryNameLbl.text == ""  || self.tagView.tags.count == 0 {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterHashtagDetails())
        } else {
            if let name = self.categoryNameLbl.text {
                self.activityIndicator.startAnimating()
                if isEdit {
                    ProManagerApi.updateHashTagSet(categoryName: name, hashTags: self.tagView.tags, usedCount: setData?.usedCount, hashId: setData?.id ?? "").request(Result<HashTagSetList>.self).subscribe(onNext: { (response) in
                        if response.status == ResponseType.success {
                            self.navigationController?.popViewController(animated: true)
                            self.activityIndicator.stopAnimating()
                            self.delegate?.didFinish(isDone: true)
                        }
                    }, onError: { error in
                        self.activityIndicator.stopAnimating()
                    }, onCompleted: {
                        
                    }).disposed(by: (rx.disposeBag))
                } else {
                    ProManagerApi.addHashTagSet(categoryName: name , hashTags: self.tagView.tags, user: Defaults.shared.currentUser?.id ?? "").request(Result<HashTagSetList>.self).subscribe(onNext: { (response) in
                        if response.status == ResponseType.success {
                            self.navigationController?.popViewController(animated: true)
                            self.activityIndicator.stopAnimating()
                            self.delegate?.didFinish(isDone: true)
                        }
                    }, onError: { error in
                        self.activityIndicator.stopAnimating()
                    }, onCompleted: {
                        
                    }).disposed(by: (rx.disposeBag))
                }
            } else {
                self.showAlert(alertMessage: R.string.localizable.pleaseEnterHashtagDetails())
            }
        }
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.delegate?.didFinish(isDone: true)
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension CreateHashTagViewController : RKTagsViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tagView.textField.resignFirstResponder()
        return true
    }
    
}
