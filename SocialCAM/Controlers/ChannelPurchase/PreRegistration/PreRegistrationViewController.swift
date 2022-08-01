//
//  PreRegistrationViewController.swift
//  ProManager
//
//  Created by Steffi Pravasi on 20/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx
import MXSegmentedPager
import NVActivityIndicatorView

struct PurchasedPackageForOthers {
    var numberOfPackages: Int = 0
    var availableChannel: Int = 0
    var getPackage: GetPackage?
    var noOfChannels : Int = 0
}

var purchasedPackageForOthers = PurchasedPackageForOthers()

class PreRegistrationViewController: UIViewController {
    
    // MARK: -- Outlets
    
    @IBOutlet var channelCountView: UIView!
    @IBOutlet var packageDisplayView: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var indicatorView: NVActivityIndicatorView! {
        didSet {
            indicatorView.color = ApplicationSettings.appPrimaryColor
        }
    }
    
    @IBOutlet var emptyChannel: UIView!
    @IBOutlet var packageTableView: UITableView!
    @IBOutlet var cartCountLbl: UILabel!
    @IBOutlet var availableChannelsLbl: UILabel!
    @IBOutlet var purchaseViewHeight: NSLayoutConstraint!
    @IBOutlet var firstTimePurchaseLbl: UILabel!
    @IBOutlet var availableChannelBottomConstraint: NSLayoutConstraint!
    @IBOutlet var benefactorBtn: UIButton!
    @IBOutlet var benefactorImgVw: UIImageView!
    @IBOutlet var benefactorLbl: UILabel!
    @IBOutlet var dashedBorderVw: DashedBorderView!
    
    // MARK: -- Variables
    var textObservable: Observable<String>?
    var channelList: [String] = []
    var hashSection: Bool  = true
    var myCart: CartResult?
    var unSelectedChannels: [String] = []
    var noOfChannels: Int  = 0
    var isFromUpgrade: Bool = false
    var selectedChannels: [String] = []
    var isCartClicked: Bool = true
    var isPackagePurchasedForFriend: Bool = true
    var remainingPackageCountForOthers: Int = 0
    var getPackage: GetPackage?
    var fromSignup = false

    // MARK: -- Actions
    
    @IBAction func benefactorBtnClicked(_ sender: Any) {
        let channels = addFinalChannels()
        self.addToCart(channel: channels,{(cartSuccess) in })
        if let vc = R.storyboard.preRegistration.purchaseFriendPackageViewController() {
            vc.userId = Defaults.shared.currentUser?.id ?? ""
            vc.remainingPackageCountForOthers = purchasedPackageForOthers.numberOfPackages
            vc.isFromPreRegistration = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func cartBtnClicked(_ sender: Any) {
        if self.cartCountLbl.isHidden {
            UIApplication.showAlert(title: Constant.Application.displayName, message: "Cart is empty.")
        } else {
            if isCartClicked {
                isCartClicked = false
                self.indicatorView.startAnimating()
                let channels = self.addFinalChannels()
                self.addToCart(channel: channels,{(cartSuccess) in
                    ChannelManagment.instance.getCart { (cartResult) in
                        let vc = R.storyboard.preRegistration.cartViewController()!
                        vc.fromSignup = self.fromSignup
                        vc.myCart = cartResult
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            }
        }
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        if self.fromSignup {
            self.navigationController?.popViewController(animated: true)
        } else if self.unSelectedChannels.count > 0 && self.selectedChannels.count == 0 {
            self.indicatorView.startAnimating()
            self.navigationController?.popViewController(animated: true)
            for j in 0..<self.unSelectedChannels.count {
                ChannelManagment.instance.deleteFromCart(channel: self.unSelectedChannels[j], {(cartResult) in
                    self.myCart = cartResult
                    self.indicatorView.stopAnimating()
                })
            }
        } else if self.selectedChannels.count > 0 {
            self.addToCart(channel: addFinalChannels(), {(cartSuccess) in
                
            })
            if let vc = self.navigationController?.viewControllers.first(where: { return $0 is ChannelListViewController }) {
                self.navigationController?.popToViewController(vc, animated: true)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            if let vc = self.navigationController?.viewControllers.first(where: { return $0 is ChannelListViewController }) {
                self.navigationController?.popToViewController(vc, animated: true)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    // MARK: -- View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedChannels = []
        self.indicatorView.stopAnimating()
        self.indicatorView.startAnimating()
        self.emptyChannel.isHidden = true
        self.setLabel()
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        self.tabBarController?.tabBar.isHidden = true
        packageDisplayView.isHidden = false
        setSearchBarData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isCartClicked = true
       
        ChannelManagment.instance.getCart { (cartResult) in
            self.myCart = cartResult
            self.perform(#selector(self.flip), with: nil, afterDelay: 0)
            self.selectedChannels = self.myCart?.individualChannels ?? []
            print(self.selectedChannels.count)
            self.packageTableView.reloadData()
            self.indicatorView.stopAnimating()
        }
        self.setData()
        self.tabBarController?.tabBar.isHidden = true
        if !isFromUpgrade {
            firstTimePurchaseLbl.isHidden = true
        }

        if self.myCart?.individualChannels?.count ?? 0 == 0 {
            self.cartCountLbl.isHidden = true
            self.channelCountView.isHidden = true
        } else {
            self.cartCountLbl.isHidden = false
            self.channelCountView.isHidden = false
        }
    }
    
    // MARK: -- Functions
    
    @objc func hideKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    @objc func flip() {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromTop, .showHideTransitionViews]
        if self.selectedChannels.count == 0 {
            self.cartCountLbl.isHidden = true
            self.channelCountView.isHidden = true
        } else {
            self.cartCountLbl.isHidden = false
            self.channelCountView.isHidden = false
            UIView.transition(with: cartCountLbl, duration: 1.0, options: transitionOptions, animations: {
                self.cartCountLbl.text = String(describing: (self.selectedChannels.count))
            })
            UIView.transition(with: channelCountView, duration: 1.0, options: transitionOptions, animations: {
            })
        }
    }
    
    func setData() {
        print(purchasedPackageForOthers.numberOfPackages)
        self.remainingPackageCountForOthers = purchasedPackageForOthers.numberOfPackages
        self.benefactorLbl.text = "Benefactor Channels \(self.remainingPackageCountForOthers)"
        if ((self.remainingPackageCountForOthers) >= 96) {
            self.benefactorImgVw.isHidden = true
            self.benefactorBtn.isEnabled = false
        } else {
            self.benefactorImgVw.isHidden = false
            self.benefactorBtn.isEnabled = true
        }
        if purchasedPackageForOthers.availableChannel > 0 {
            self.availableChannelsLbl.text = "Avaliable Channels \(purchasedPackageForOthers.availableChannel)"
        }
    }
    
    func addFinalChannels() -> ([String]) {
        var unique : [String] = []
        for i in 0..<self.selectedChannels.count {
            if !(self.myCart?.individualChannels?.contains(self.selectedChannels[i]) ?? false) {
                unique.append(self.selectedChannels[i])
            } else {
                print("no new channel to be added")
            }
        }
        if self.unSelectedChannels.count > 0 {
            for i in 0..<(myCart?.individualChannels?.count ?? 0) {
                if self.unSelectedChannels.contains((myCart?.individualChannels![i]) ?? "") {
                    self.indicatorView.startAnimating()
                ChannelManagment.instance.deleteFromCart(channel: myCart?.individualChannels![i] ?? "", {(cartResult) in
                    self.myCart = cartResult
                    self.indicatorView.stopAnimating()
                })
                } else {
                    print("No duplicate channels")
                }
            }
        }
        return (unique)
    }
    
    func setSearchBarData() {
        var a : String?
        textObservable = (self.searchBar?.rx.text.orEmpty.throttle(0.5, latest: true, scheduler: MainScheduler.instance).distinctUntilChanged())!
        let result = textObservable?.flatMapLatest( { (Q:String) -> Observable<ChannelSuggestionResult> in
            if  Q.count > 5 {
                self.indicatorView.startAnimating()
                self.hashSection = false
                a = Q.replacingOccurrences(of: " ", with: "")
            } else {
                self.hashSection = true
                self.packageTableView.isHidden = true
                self.indicatorView.stopAnimating()
            }
            return ProManagerApi.getChannelSuggestion(channelName: a ?? "").request(ChannelSuggestionResult.self)
        })
        self.packageTableView.rowHeight = UITableView.automaticDimension
        self.packageTableView.estimatedRowHeight = 100
        
        result?.subscribe(onNext: { response in
            self.dismissHUD()
            self.indicatorView.stopAnimating()
            if response.status == ResponseType.success {
                if response.suggestionList == nil {
                    self.emptyChannel.isHidden = false
                    self.packageTableView.isHidden = true
                } else {
                    if self.hashSection == false {
                        self.packageTableView.isHidden = false
                        self.emptyChannel.isHidden = true
                    }
                    self.channelList = response.suggestionList ?? []
                    self.packageTableView.reloadData()
                }
            } else {
                UIApplication.showAlert(title: Constant.Application.displayName, message: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.dismissHUD()
        }, onCompleted: {
            self.dismissHUD()
        }).disposed(by: rx.disposeBag)
    }
    
    func setLabel() {
        channelCountView.layer.masksToBounds = true
        channelCountView.layer.cornerRadius = channelCountView.frame.width / 2
        channelCountView.layer.borderWidth = 1.5
        channelCountView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cartCountLbl.layer.masksToBounds = true
        cartCountLbl.layer.cornerRadius = cartCountLbl.frame.width / 2
        cartCountLbl.layer.borderWidth = 1.5
        cartCountLbl.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addToCart(channel: [String],_ cartBlock:((_ cartSuccess:String?)->Void)?) {
        let parentId = Defaults.shared.parentID ?? (Defaults.shared.currentUser?.id ?? "")
        ProManagerApi.addToCart(userId: parentId, packageName: 0, individualChannels : channel).request(Result<CartResult>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                print(response)
                if let ch = cartBlock {
                    ch("success")
                }
            }
        }, onError: { error in
             self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
            
        }).disposed(by: self.rx.disposeBag)
    }
    
}

// MARK: -- TableView Delegate Methods
extension PreRegistrationViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.hashSection == true {
            return 0
        } else {
            return channelList.count
        }
    }
    
    func setComboChannels(index: Int) {
        self.channelList.remove(at: index)
        self.packageTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = packageTableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.packageSuggesstionTableViewCell.identifier) as? PackageSuggesstionTableViewCell else {
            fatalError("PackageSuggesstionTableViewCell not found")
        }
//        if selectedChannels.count > 0 {
            if selectedChannels.contains(self.channelList[indexPath.row]) {
                cell.addToCartBtn.setImage(R.image.channelSelected(), for: .normal)
                cell.addToCartBtn.imageView?.setImageWithTintColor(color: ApplicationSettings.appPrimaryColor)
            } else {
                cell.addToCartBtn.setImage(R.image.channelAdd(), for: .normal)
                cell.addToCartBtn.imageView?.setImageWithTintColor(color: ApplicationSettings.appPrimaryColor)
            }
//        }
        cell.addToCartBtn.tag = indexPath.row
        cell.channelNameLbl.text = channelList[indexPath.row]
        cell.buttonAction = { sender in
            if !(self.selectedChannels.contains(self.channelList[sender.tag])) {
                if self.selectedChannels.count < purchasedPackageForOthers.availableChannel {
                    self.selectedChannels.append(self.channelList[indexPath.row])
                    self.packageTableView.reloadData()
                    self.perform(#selector(self.flip), with: nil, afterDelay: 0)
                } else {
                    UIApplication.showAlert(title: Constant.Application.displayName, message: R.string.localizable.youReachedMaxLimitIfYouWantToAddThisChannelPleaseRemoveAnyChannelFromYourPackageComboAndTryAgainLater())
                }
            } else {
                if self.selectedChannels.count > 0 {
                    if self.selectedChannels.contains(self.channelList[sender.tag]) {
                        self.unSelectedChannels.append(self.channelList[sender.tag])
                        self.selectedChannels.remove(at: self.selectedChannels.firstIndex(of: self.channelList[sender.tag]) ?? 0)
                        self.packageTableView.reloadData()
                        self.perform(#selector(self.flip), with: nil, afterDelay: 0)
                    } else {
                        print("")
                    }
                } else {
                    print("")
                }
            }
        }
        return cell
    }
}

extension PreRegistrationViewController : UISearchBarDelegate {
    
}

extension PreRegistrationViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder() 
    }
}
