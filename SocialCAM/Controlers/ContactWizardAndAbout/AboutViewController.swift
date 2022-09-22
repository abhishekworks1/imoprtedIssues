//
//  AboutViewController.swift
//  SocialCAM
//
//  Created by Gaurang Pandya on 30/01/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import StoreKit

class AboutViewController: UIViewController {
    @IBOutlet weak var otherLink: UIView!
    @IBOutlet weak var versionLbl: UILabel!

    @IBOutlet weak var tiktokView: UIView!
    @IBOutlet weak var instagramView: UIView!
    @IBOutlet weak var twitterView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //otherLink.dropShadow()
        versionLbl.text = "\(Constant.Application.displayName) - 1.3(43.\(Constant.Application.appBuildNumber))"
    }
    
    // MARK: - Button Methods
    func animateView(view:UIView){
        UIView.animate(withDuration: 0.6,
            animations: {
                view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.6) {
                    view.transform = CGAffineTransform.identity
                }
        })
    }
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func tiktokTapped(_ sender: UIButton) {
        if let url = URL(string: "https://www.tiktok.com/@quickcamapp") {
            UIApplication.shared.open(url, options: [:])
        }
        self.animateView(view:self.tiktokView)
    }
    @IBAction func twitterTapped(_ sender: UIButton) {
        if let url = URL(string: "https://twitter.com/QuickCamApp") {
            UIApplication.shared.open(url, options: [:])
        }
        self.animateView(view:self.twitterView)
    }
    @IBAction func instagramTapped(_ sender: UIButton) {
        if let url = URL(string: "https://www.instagram.com/quickcam.app/") {
            UIApplication.shared.open(url, options: [:])
        }
        self.animateView(view:self.instagramView)
    }
    
    
    @IBAction func didTapCookiePolicyButton(_ sender: UIButton) {
        guard let legalVc = R.storyboard.legal.legalViewController() else { return }
        legalVc.otherLink = OtherLinks.cookiePolicy
        self.navigationController?.pushViewController(legalVc, animated: true)
    }
    
    
    @IBAction func websiteTapped(_ sender: UIButton) {
        guard let legalVc = R.storyboard.legal.legalViewController() else { return }
        legalVc.otherLink = OtherLinks.website
        self.navigationController?.pushViewController(legalVc, animated: true)
        
    }
    
    @IBAction func btnLegalDetailsTapped(_ sender: UIButton) {
        guard let legalVc = R.storyboard.legal.legalViewController() else { return }
        legalVc.isTermsAndConditions = (sender.tag == 0)
        self.navigationController?.pushViewController(legalVc, animated: true)
    }
    
    @IBAction func btnPatentsTapped(_ sender: UIButton) {
        guard let patentsVc = R.storyboard.legal.patentsViewController() else { return }
        self.navigationController?.pushViewController(patentsVc, animated: true)
    }
    
    @IBAction func rateUsTapped(_ sender: UIButton) {
        if #available(iOS 10.3, *) {
            if #available(iOS 14, *){
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }else{
                SKStoreReviewController.requestReview()
            }
        } else {
            
            let appID = "1580876968"
            //let urlStr = "https://itunes.apple.com/app/id\(appID)" // (Option 1) Open App Page
            let urlStr = "https://itunes.apple.com/app/id\(appID)?action=write-review" // (Option 2) Open App Review Page
            
            guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.openURL(url) // openURL(_:) is deprecated from iOS 10.
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
