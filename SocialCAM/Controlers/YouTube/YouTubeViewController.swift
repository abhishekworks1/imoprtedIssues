//
//  YouTubeViewController.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 18/09/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import MXSegmentedPager
import RxCocoa
import RxSwift
import NSObject_Rx

class YouTubeViewController: MXSegmentedPagerController {
    @IBOutlet var headerView: UIView!
    var keyWordVc: KeywordViewController!
    var youTubeChannelVc: YouTubeChannelViewController!
    var simpleKeyWordVc: SimpleKeyWordViewController!
    var statsVC: StatsViewController!
    var shareHandler : ((_ url: String, _ hash: [String]?, _ title: String?, _ channelId: String?) -> Void)?
    @IBOutlet var txtField: UISearchBar!
    var textObservable: Observable<String>?
    @IBOutlet var subscribeChannel: UICollectionView!
    var channels: [YouTubeSubscription] = []
    @IBOutlet var lblNoChannel: UILabel!
    var isSignIn: Bool = true
    var isReview = false
 
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedPager.backgroundColor = ApplicationSettings.appLightWhiteColor
        // Parallax Header
        segmentedPager.segmentedControlEdgeInsets =  UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        segmentedPager.parallaxHeader.view = headerView
        segmentedPager.parallaxHeader.mode = .fill
        segmentedPager.parallaxHeader.height = 155
        segmentedPager.parallaxHeader.minimumHeight = 44
        segmentedPager.bounces = false
        segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        segmentedPager.segmentedControl.backgroundColor = ApplicationSettings.appLightWhiteColor
        segmentedPager.segmentedControl.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ApplicationSettings.appBlackColor, NSAttributedString.Key.font: R.font.sfuiTextMedium(size: 12)!]
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ApplicationSettings.appPrimaryColor, NSAttributedString.Key.font: R.font.sfuiTextMedium(size: 12)!]
        segmentedPager.segmentedControl.selectionStyle = .fullWidthStripe
        segmentedPager.segmentedControl.selectionIndicatorColor = ApplicationSettings.appPrimaryColor
        segmentedPager.segmentedControl.borderType = .bottom
        segmentedPager.segmentedControl.borderColor = ApplicationSettings.appLightWhiteColor
        segmentedPager.segmentedControl.borderWidth = 1
        segmentedPager.segmentedControl.selectionIndicatorHeight = 1
        segmentedPager.pager.isScrollEnabled = false
        segmentedPager.pager.transitionStyle = .tab
        textObservable = (self.txtField?.rx.text.orEmpty.throttle(0.5, scheduler: MainScheduler.instance).distinctUntilChanged())!
        self.getSubscribeChannels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ApplicationSettings.shared.shouldRotate = true
        super.viewWillAppear(animated)
        txtField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segmentedPager.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mx_page_0" {
            print("album")
            keyWordVc = segue.destination as? KeywordViewController
            keyWordVc.isReview = self.isReview
            keyWordVc.textObservable = self.textObservable
            keyWordVc.popHandler = { (youTubeUrl, hash, title, channelId) in
                if let handler = self.shareHandler {
                    handler(youTubeUrl, hash, title, channelId)
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
        if segue.identifier == "mx_page_2" {
            youTubeChannelVc = segue.destination as? YouTubeChannelViewController
            youTubeChannelVc.isReview = self.isReview
            youTubeChannelVc.textObservable = self.textObservable
            youTubeChannelVc.keyboardCloseHandler = {
                self.txtField.resignFirstResponder()
            }
        }
        if segue.identifier == "mx_page_3" {
            simpleKeyWordVc = segue.destination as? SimpleKeyWordViewController
            print("time line")
        }
        if segue.identifier == "mx_page_1" {
            statsVC = segue.destination as? StatsViewController
            statsVC.isReview = self.isReview
            statsVC.textObservable = self.textObservable
            statsVC.popHandler = { (youTubeUrl, hash, title, channelId) in
                if let handler = self.shareHandler {
                    handler(youTubeUrl, hash, title, channelId)
                }
                self.navigationController?.popViewController(animated: true)
            }
            statsVC.channelScreenHandler = { channelId in
                self.scrollAtIndex(index: 2)
                self.youTubeChannelVc.channelId = channelId
            }
            statsVC.keyboardCloseHandler = {
                self.txtField.resignFirstResponder()
            }
            print("time line")
        }
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return ["Keyword", "Stats", "Channel", "Similar Keyword"][index]
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, didScrollWith parallaxHeader: MXParallaxHeader) {
        print("progress \(parallaxHeader.progress)")
    }
    
    override func segmentedPagerShouldScroll(toTop segmentedPager: MXSegmentedPager) -> Bool {
        return false
    }
    
    @IBAction func btnBackClicked(sender: UIButton) {
        ApplicationSettings.shared.shouldRotate = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filterBtnClicked(sender: UIButton) {
        
    }
    
    func scrollAtIndex(index: Int) {
        self.segmentedPager.pager.showPage(at: index, animated: true)
    }
    
    func getSubscribeChannels() {
        if GoogleManager.shared.isUserLogin {
            self.getUserToken()
        } else {
            GoogleManager.shared.login(controller: self, complitionBlock: { (userData, error) in
                self.getUserToken()
            }) { (userData, error) in
                self.isSignIn = false
                self.subscribeChannel.reloadData()
            }
        }
    }
    
}

extension YouTubeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.isSignIn == true) ? self.channels.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isSignIn == true {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.subscribeChannelCell, for: indexPath) else {
                fatalError("SubscribeChannelCell")
            }
            cell.channel =  self.channels[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GoogleSignInCell", for: indexPath)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isSignIn == true {
            guard !self.channels.isEmpty,
                let channelId = self.channels[indexPath.row].snippet?.resourcechannelId else {
                return
            }
            if let channelListVc =  R.storyboard.youTube.channelVideoListViewController() {
                channelListVc.isReview = self.isReview
                channelListVc.channelId = channelId
                channelListVc.popHandler = { (youTubeUrl, hash, title, channelId) in
                    if let handler = self.shareHandler {
                        handler(youTubeUrl, hash, title, channelId)
                    }
                    if let createPost: [UIViewController] = self.navigationController?.viewControllers.filter({ (vc) -> Bool in
                        return vc.isKind(of: AddPostViewController.self)
                    }), !createPost.isEmpty {
                          self.navigationController?.popToViewController(createPost[0], animated: true)
                    } else if let potoEdit: [UIViewController] = self.navigationController?.viewControllers.filter({ (vc) -> Bool in
                        return vc.isKind(of: PhotoEditorViewController.self)
                    }), !potoEdit.isEmpty {
                         self.navigationController?.popToViewController(potoEdit[0], animated: true)
                    }
                }
                self.navigationController?.pushViewController(channelListVc, animated: true)
            }

        } else {
            GoogleManager.shared.login(controller: self, complitionBlock: { (userData, error) in
                self.getUserToken()
            }) { (userData, error) in
                self.isSignIn = false
                self.subscribeChannel.reloadData()
            }
        }
    }
    
    func getUserToken() {
        GoogleManager.shared.getUserToken { (token) in
            guard let token = token else {
                return
            }
            self.isSignIn = true
            ProManagerApi.getyoutubeSubscribedChannel(token: token, forChannelId: nil).request(YouTubeItmeListResponse<YouTubeSubscription>.self).subscribe(onNext: { (response) in
                if !response.item.isEmpty {
                    self.channels = response.item
                    self.lblNoChannel.isHidden = true
                } else {
                    self.lblNoChannel.isHidden = false
                }
                self.subscribeChannel.reloadData()
            }, onError: { (_) in
                
            }, onCompleted: {
                
            }).disposed(by: self.rx.disposeBag)
            self.subscribeChannel.reloadData()
        }
    }

}

extension YouTubeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.isSignIn == true {
            return CGSize(width: 80, height: 97)
        } else {
           return CGSize(width: UIScreen.main.bounds.size.width - 10, height: 97)
        }
    }
    
}
