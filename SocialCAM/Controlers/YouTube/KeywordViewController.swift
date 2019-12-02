//
//  KeywordViewController.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 18/09/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx
import SVProgressHUD
import NVActivityIndicatorView

class KeywordViewController: UIViewController {
    
    @IBOutlet var tblYouTube: UITableView!
    @IBOutlet var emptyView: UIView?
    @IBOutlet var indicatorView: NVActivityIndicatorView! {
        didSet {
            indicatorView.color = ApplicationSettings.appPrimaryColor
        }
    }
    
    var Videos: [Observable<YTSerchResponse<Item>>] = []
    var textObservable: Observable<String>?
    var isReview = false
    var searchText: String = ""
    var nextPageToken: String?
    var totalResult: Int?
    var resultPerPage: Int?
    var popHandler : ((_ youTubeUrl: String, _ hash: [String]?, _ title: String?, _ channelId: String?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblYouTube.estimatedRowHeight = 200
        self.tblYouTube.rowHeight = UITableView.automaticDimension
        self.textObservable?.subscribe(onNext: { Q in
            ApplicationSettings.shared.videos = []
            self.searchText = Q
            print(self.searchText)
            self.getVideo(q: Q)
        }).disposed(by: self.rx.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          self.tblYouTube.reloadData()
    }
    
    func getVideo(q: String) {
        self.indicatorView.startAnimating()
        ProManagerApi.youTubeKeyWordSerch(q: q, order: nil, nextPageToken: self.nextPageToken).request(YTSerchResponse<Item>.self).subscribe(onNext: { response in
            self.nextPageToken = response.nextPageToken
            self.totalResult = response.pageInfo?.totalResults
            self.resultPerPage = response.pageInfo?.resultsPerPage
            if ApplicationSettings.shared.videos.isEmpty && response.result?.isEmpty ?? false {
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
                    
                }).disposed(by: self.rx.disposeBag)
                return ""
            })
        }, onCompleted: {
            self.tblYouTube.reloadData()
        }).disposed(by: rx.disposeBag)
    }

}

extension KeywordViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ApplicationSettings.shared.videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row ==  (ApplicationSettings.shared.videos.count) - 2 && self.nextPageToken != nil {
            self.getVideo(q: self.searchText)
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.youTubeTableViewCell.identifier) as? YouTubeTableViewCell else {
            fatalError("YouTubeTableViewCell Not Found")
        }
        if  (ApplicationSettings.shared.videos.count) > indexPath.row {
            cell.observable =  ApplicationSettings.shared.videos[indexPath.row]
        }
        cell.shareHandler = { item in
            let obj = R.storyboard.youTube.addPostViewController()!
            obj.video =  ApplicationSettings.shared.videos[indexPath.row]
            obj.shareHandler = self.popHandler
            obj.isReview = self.isReview
            self.navigationController?.pushViewController(obj, animated: true)
        }
        cell.playHandler = { item in
            self.openYoutubeView(item.ids!, previewUrl: nil)
        }
        cell.selectionStyle = .none
        cell.updateConstraintsIfNeeded()
        cell.setNeedsUpdateConstraints()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
    }
    
}
