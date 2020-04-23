//
//  UpgradeViewController.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 20/06/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import FSPagerView
typealias PrimumTuple = (color:UIColor, price : String ,channel:String)
class UpgradeViewController: UIViewController {
    
    @IBOutlet weak var skipView: UIView!
    @IBOutlet weak var backButton: UIButton!

    var fromSignup = false
    
    var isFromUpgrade : Bool = false
    var pages : [PrimumTuple] = [(UIColor.squashTwo,"$5.00/mo","( 5 Channels )")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        skipView.isHidden = !fromSignup
        backButton.isHidden = fromSignup
    }
    
    @IBAction func btnBackClicked(_ sender:Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func skipClicked(_ sender:Any) {
        Utils.appDelegate?.window?.rootViewController = R.storyboard.pageViewController.pageViewController()
    }
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(UINib(resource: R.nib.upgradePageCollectionViewCell), forCellWithReuseIdentifier: R.reuseIdentifier.upgradePageCollectionViewCell.identifier)
            self.pagerView.transformer = FSPagerViewTransformer(type: .linear)
            self.pagerView.backgroundColor = ApplicationSettings.appClearColor
            
        }
    }
    
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.numberOfPages = pages.count
            self.pageControl.contentHorizontalAlignment = .center
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            self.pageControl.hidesForSinglePage = true
            self.pageControl.setStrokeColor(ApplicationSettings.appPrimaryColor, for: .normal)
            self.pageControl.setStrokeColor(ApplicationSettings.appPrimaryColor, for: .selected)
            self.pageControl.setFillColor(ApplicationSettings.appPrimaryColor, for: .selected)
        }
    }
    
    @IBAction func upgradeBtnClicked(_ sender: Any) {
        print(self.pageControl.currentPage)
        if let vc = R.storyboard.preRegistration.paymentViewController() {
            vc.fromSignup = fromSignup
            if self.pageControl.currentPage > 0 {
                vc.price = Int(pages[self.pageControl.currentPage].price.substring(1, end: 3)) ?? 0
                vc.numberOfChannels = Int(pages[self.pageControl.currentPage].channel.substring(2, end: 4)) ?? 0
            } else {
                vc.price = Int(pages[self.pageControl.currentPage].price.substring(1, end: 2)) ?? 0
                vc.numberOfChannels = Int(pages[self.pageControl.currentPage].channel.substring(2, end: 3)) ?? 0
            }
            vc.packageName = pages[self.pageControl.currentPage].channel
            vc.userId = Defaults.shared.currentUser?.id ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
  
}

extension UpgradeViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    
    // MARK:- FSPagerViewDataSource
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return pages.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "UpgradePageCollectionViewCell", at: index) as? UpgradePageCollectionViewCell else {
            fatalError("UpgradePageCollectionViewCell Not Found")
        }
         cell.primumTuple = pages[index]
         return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pageControl.currentPage = pagerView.currentIndex // Or Use KVO with property "currentIndex"
    }
    
}
