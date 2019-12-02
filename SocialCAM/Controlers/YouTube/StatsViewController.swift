//
//  StatsViewController.swift
//  ProManager
//
//  Created by Arpit Shah on 27/09/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import MXSegmentedPager
import SVProgressHUD
import NVActivityIndicatorView
import RxCocoa
import RxSwift
import NSObject_Rx
import TagListView

class StatsViewController: UIViewController, TagListViewDelegate {
    
    @IBOutlet var tblYouTube: UITableView!
    @IBOutlet var indicatorView: NVActivityIndicatorView! {
        didSet {
            indicatorView.color = ApplicationSettings.appPrimaryColor
        }
    }
    @IBOutlet var emptyView: UIView?
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tagView: UIView!
    @IBOutlet var tagList: TagListView!
    @IBOutlet var scrollHeight: NSLayoutConstraint!
    @IBOutlet var sectionHeader: UIView!
    @IBOutlet var imgArrowView: UIImageView!
    @IBOutlet var imgArrowDate: UIImageView!
    
    var textObservable: Observable<String>?
    var isReview = false
    var searchText: String = ""
    var nextPageToken: String?
    var totalResult: Int?
    var resultPerPage: Int?
    var popHandler : ((_ youTubeUrl: String, _ hash: [String]?, _ title: String?, _ channelId: String?) -> Void)?
    var channelScreenHandler : ((_ chId: String) -> Void)?
    var keyboardCloseHandler:(() -> Void)?
    var isOrderByView: Bool? {
        didSet {
            if let isV = isOrderByView {
                if isV == true {
                    self.imgArrowView.image = #imageLiteral(resourceName: "DownArrow")
                    ApplicationSettings.shared.videos.sort(by: { (a, b) -> Bool in
                        let viewsA = a.statistics?.viewInt ?? 0
                        let viewsB = b.statistics?.viewInt ?? 0
                        return  (viewsA >= viewsB)
                    })
                    self.tblYouTube.reloadData()
                } else {
                    self.imgArrowView.image = #imageLiteral(resourceName: "UPArrow")
                    ApplicationSettings.shared.videos.sort(by: { (a, b) -> Bool in
                        
                        let viewsA = a.statistics?.viewInt ?? 0
                        let viewsB = b.statistics?.viewInt ?? 0
                        return  (viewsA <= viewsB)
                    })
                    self.tblYouTube.reloadData()
                }
            } else {
                self.imgArrowView.image = nil
            }
        }
    }
    var isOrderByDate: Bool? {
        didSet {
            if let isD = isOrderByDate {
                if isD == true {
                    self.imgArrowDate.image = #imageLiteral(resourceName: "DownArrow")
                    ApplicationSettings.shared.videos.sort(by: { (a, b) -> Bool in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                        let dateObj = formatter.date(from: (a.snippet?.publishedAt)!)
                        let dateObj2 = formatter.date(from: (b.snippet?.publishedAt)!)
                        return  (dateObj?.compare(dateObj2!) == ComparisonResult.orderedAscending)
                    })
                    self.tblYouTube.reloadData()
                } else {
                    self.imgArrowDate.image = #imageLiteral(resourceName: "UPArrow")
                    ApplicationSettings.shared.videos.sort(by: { (a, b) -> Bool in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                        let dateObj = formatter.date(from: (a.snippet?.publishedAt)!)
                        let dateObj2 = formatter.date(from: (b.snippet?.publishedAt)!)
                        return  (dateObj?.compare(dateObj2!) == ComparisonResult.orderedDescending)
                    })
                    self.tblYouTube.reloadData()
                }
            } else {
                self.imgArrowDate.image = nil
            }
        }
    }

    override func viewDidLoad() {
        tagView.isHidden = true
        tblYouTube.separatorStyle = .none
        self.textObservable?.subscribe(onNext: { Q in
            ApplicationSettings.shared.videos = []
            self.searchText = Q
            print(self.searchText)
            self.getVideo(q: Q)
        }).disposed(by: (rx.disposeBag))
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ApplicationSettings.shared.shouldRotate = true
        self.tblYouTube.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ApplicationSettings.shared.shouldRotate = false
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    func setTagView(tagArr: [String]) {
        tagList.removeAllTags()
        tagList.textFont = UIFont.systemFont(ofSize: 16)
        tagList.alignment = .center // possible values are .Left, .Center, and .Right
        tagList.addTags(tagArr)
        tagList.delegate = self
        scrollHeight.constant = tagList.frame.size.height
        tagView.isHidden = false
        tagList.layoutSubviews()
        tagList.layoutIfNeeded()
        scrollHeight.constant = tagList.intrinsicContentSize.height
    }
    
    func getVideo(q: String) {
        self.indicatorView.startAnimating()
        ProManagerApi.youTubeKeyWordSerch(q: q, order: nil, nextPageToken: self.nextPageToken).request(YTSerchResponse<Item>.self).subscribe(onNext: { response in
            self.nextPageToken = response.nextPageToken
            self.totalResult = response.pageInfo?.totalResults
            self.resultPerPage = response.pageInfo?.resultsPerPage
            if  ApplicationSettings.shared.videos.isEmpty && response.result?.isEmpty ?? false {
                self.emptyView?.isHidden = false
                self.indicatorView.stopAnimating()
            } else {
                self.emptyView?.isHidden = true
            }
            _  =  response.result?.map({ item -> String in
                ProManagerApi.youTubeDetail(id: (item.id?.videoId)!).request(YTSerchResponse<Item>.self).subscribe(onNext: { response in
                    self.indicatorView.stopAnimating()
                     ApplicationSettings.shared.videos.append((response.result?[0])!)
                    self.tblYouTube.reloadData()
                }, onError: { _ in
                    self.indicatorView.stopAnimating()
                }, onCompleted: {
                    self.indicatorView.stopAnimating()
                }).disposed(by: (self.rx.disposeBag))
                return ""
            })
        }, onCompleted: {
            self.tblYouTube.reloadData()
        }).disposed(by: (rx.disposeBag))
    }
    
    // MARK: IBActions
    
    @IBAction func onTagDone(_ sender: Any) {
        tagView.isHidden = true
    }
    
    // MARK: TagView Delegate
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
    }
    
    @IBAction func orderByViews(sender: Any) {
        self.isOrderByDate = nil
        if let ov = self.isOrderByView {
            if ov == true {
                self.isOrderByView = false
            } else {
                self.isOrderByView = true
            }
        } else {
            self.isOrderByView = false
        }
    }
    
    @IBAction func orderByDate(sender: Any) {
        self.isOrderByView = nil
        if let ob = self.isOrderByDate {
            if ob == true {
                self.isOrderByDate = false
            } else {
                self.isOrderByDate = true
            }
        } else {
            self.isOrderByDate = false
        }
    }
    
}

extension StatsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ApplicationSettings.shared.videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row ==  (ApplicationSettings.shared.videos.count) - 2 && self.nextPageToken != nil {
            self.getVideo(q: self.searchText)
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.statTableViewCell.identifier) as? StatTableViewCell else {
            fatalError("StatTableViewCell Not Found")
        }
        if  (ApplicationSettings.shared.videos.count) > indexPath.row {
            cell.observable =  ApplicationSettings.shared.videos[indexPath.row]
        }
        cell.playHandler = { item in
            if let obj = R.storyboard.youTube.addPostViewController() {
                obj.video =  ApplicationSettings.shared.videos[indexPath.row]
                obj.shareHandler = self.popHandler
                obj.isReview = self.isReview
                self.navigationController?.pushViewController(obj, animated: true)
            }
        }
        cell.tagHandler = { item in
            if let tags = item.snippet?.tags, !tags.isEmpty {
                if let clsHandler = self.keyboardCloseHandler {
                    clsHandler()
                }
                self.setTagView(tagArr: tags)
            } else {
                
            }
        }
        cell.channelHandler = { item in
            if let channelId = item.snippet?.channelId {
                if let handler = self.channelScreenHandler {
                    handler(channelId)
                }
            }
        }
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = ApplicationSettings.appPrimaryColor
        } else {
            cell.backgroundColor = ApplicationSettings.appClearColor
        }
        cell.lblNumber.text = "\(indexPath.row + 1)"
        cell.selectionStyle = .none
        cell.updateConstraintsIfNeeded()
        cell.setNeedsUpdateConstraints()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.sectionHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
}
