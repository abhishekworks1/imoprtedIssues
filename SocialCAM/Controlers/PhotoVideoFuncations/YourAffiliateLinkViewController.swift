//
//  YourAffiliateLinkViewController.swift
//  SocialCAM
//
//  Created by Meet Mistry on 12/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import SafariServices
import NSObject_Rx

enum Type: Int {
    case copyLink = 0
    case goToAffiliatePage
    case activateAffiliateLink
    case listOfReferredUsers
}

class YourAffiliateLinkViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var affiliateLinkTabeView: UITableView!
    @IBOutlet weak var affiliateLinkCellView: UITableViewCell!
    
    // MARK: - Variable Declarations
    var referredUserList: [Referee] = []
    var referredUserPageIndex: Int = 1
    var userCount = 0
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetUp()
    }
    
    func viewSetUp() {
        refresh(index: self.referredUserPageIndex)
        YourAffiliateLink.yourAffiliteLinks.removeAll()
        if Defaults.shared.isAffiliateLinkActivated {
            getAffiliateLinkActivatedCell()
        } else {
            getAffiliateLinkNotActivatedCell()
        }
    }
    
    func refresh(index: Int) {
        self.referredUserPageIndex = index
        self.getRefferdUserList(index: self.referredUserPageIndex)
    }
    
    func getAffiliateLinkActivatedCell() {
        let copyLinkCell = YourAffiliateLink(name: "", settings: [AffiliateSetting(name: R.string.localizable.copyLink())], type: .copyLink)
        let gotoAffiliatePageCell = YourAffiliateLink(name: "", settings: [AffiliateSetting(name: R.string.localizable.goToAffiliatePage())], type: .goToAffiliatePage)
        YourAffiliateLink.yourAffiliteLinks.append(copyLinkCell)
        YourAffiliateLink.yourAffiliteLinks.append(gotoAffiliatePageCell)
    }
    
    func getAffiliateLinkNotActivatedCell() {
        let activateAffiliateLinkCell = YourAffiliateLink(name: "", settings: [AffiliateSetting(name: "")], type: .activateAffiliateLink)
        let listOfReferredUserCell = YourAffiliateLink(name: "", settings: [AffiliateSetting(name: "")], type: .listOfReferredUsers)
        YourAffiliateLink.yourAffiliteLinks.append(activateAffiliateLinkCell)
        YourAffiliateLink.yourAffiliteLinks.append(listOfReferredUserCell)
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Table View DataSource
extension YourAffiliateLinkViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return YourAffiliateLink.yourAffiliteLinks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellTitle = YourAffiliateLink.yourAffiliteLinks[section]
        return section == 1 && cellTitle.type == .listOfReferredUsers ? referredUserList.count : cellTitle.settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let affiliateLinkCell: AffiliateLinkCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.affiliateLinkCell.identifier) as? AffiliateLinkCell else {
            fatalError("\(R.reuseIdentifier.affiliateLinkCell.identifier) Not Found")
        }
        
        let cellTitle = YourAffiliateLink.yourAffiliteLinks[indexPath.section]
        if cellTitle.type == .copyLink || cellTitle.type == .goToAffiliatePage {
            let affiliateTitle = cellTitle.settings[indexPath.row]
            affiliateLinkCell.lblAffiliateTitle.text = affiliateTitle.name
        } else if cellTitle.type == .activateAffiliateLink {
            guard let activateAffiliateLinkCell: ActivateAffiliateLinkCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.activateAffiliateLinkCell.identifier) as? ActivateAffiliateLinkCell else {
                return affiliateLinkCell
            }
            activateAffiliateLinkCell.delegate = self
            activateAffiliateLinkCell.dismissViewDelegate = self
            return activateAffiliateLinkCell
        } else if cellTitle.type == .listOfReferredUsers {
            if userCount > referredUserList.count {
                referredUserPageIndex += 1
                refresh(index: referredUserPageIndex)
            } else {
                affiliateLinkCell.lblAffiliateTitle.text = referredUserList[indexPath.row].user?.channelId
                self.dismissHUD()
            }
        }
        
        return affiliateLinkCell
    }
}

// MARK: - Table view Delegate
extension YourAffiliateLinkViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsHeader.identifier) as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        let cellTitle = YourAffiliateLink.yourAffiliteLinks[section]
        if cellTitle.type == .listOfReferredUsers && section == 1 {
            headerView.title.isHidden = false
            referredUserList.isEmpty ? (headerView.title.text = R.string.localizable.noReferredUser()) : (headerView.title.text = R.string.localizable.referredUserList())
            headerView.title.textColor = UIColor.black
        } else {
            headerView.title.isHidden = true
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let cellTitle = YourAffiliateLink.yourAffiliteLinks[section]
        return cellTitle.type == .listOfReferredUsers && section == 1 ? 40.0 : 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellTitle = YourAffiliateLink.yourAffiliteLinks[indexPath.section]
        return cellTitle.type == .activateAffiliateLink ? 140 : 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellTitle = YourAffiliateLink.yourAffiliteLinks[indexPath.section]
        let urlString = "\(websiteUrl)/ref/\(Defaults.shared.currentUser?.channelId ?? "")"
        if cellTitle.type == .copyLink {
            UIPasteboard.general.string = urlString
            showAlert(alertMessage: R.string.localizable.linkIsCopiedToClipboard())
        } else if cellTitle.type == .goToAffiliatePage {
            guard let url = URL(string: urlString) else {
                return
            }
            presentSafariBrowser(url: url)
        }
    }
    
    func presentSafariBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
}

// MARK: - ChangeDataDelegate
extension YourAffiliateLinkViewController: ChangeDataDelegate {
    
    func changeTableData() {
        setAffiliate(setAffiliateValue: true)
        YourAffiliateLink.yourAffiliteLinks.removeAll()
        getAffiliateLinkActivatedCell()
        affiliateLinkTabeView.reloadData()
    }
}

// MARK: - DismissViewDelegate
extension YourAffiliateLinkViewController: DismissViewDelegate {
    func dismissView() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - API Methods
extension YourAffiliateLinkViewController {
    
    func getRefferdUserList(index: Int) {
        self.showHUD()
        ProManagerApi.getReferredUserList(page: index, limit: 10).request(Result<ReferredUserModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let self = self else {
                return
            }
            if response.status == ResponseType.success {
                guard let arrayOfUsers = response.result else {
                    return
                }
                self.dismissHUD()
                if let  userCount = response.result?.count {
                    self.userCount = userCount
                }
                if let referees = arrayOfUsers.referees {
                    if self.referredUserPageIndex == 0 {
                        self.referredUserList = referees
                    } else {
                        self.referredUserList.append(contentsOf: referees)
                    }
                }
                self.affiliateLinkTabeView.reloadData()
                self.affiliateLinkTabeView.es.stopLoadingMore()
                if self.referredUserList.isEmpty {
                    self.dismissHUD()
                }
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
            
        }).disposed(by: self.rx.disposeBag)
    }
    
    func setAffiliate(setAffiliateValue: Bool) {
        ProManagerApi.setAffiliate(isAllowAffiliate: setAffiliateValue).request(Result<SetAffiliateModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let self = self else {
                return
            }
            if response.status == ResponseType.success {
                // No furthur action 
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
}
