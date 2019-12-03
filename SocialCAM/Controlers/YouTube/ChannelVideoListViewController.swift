//
//  ChannelVideoListViewController.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 01/03/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class ChannelVideoListViewController: UIViewController {
    @IBOutlet var tblYouTube: UITableView!
    @IBOutlet var emptyView: UIView?
    var videos: [Item] = []
    var channelId: String?
    var nextPageToken: String?
    var totalResult: Int?
    var resultPerPage: Int?
    var popHandler : ((_ youTubeUrl: String, _ hash: [String]?, _ title: String?, _ channelId: String?) -> Void)?
    var isReview = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblYouTube.estimatedRowHeight = 200
        self.tblYouTube.rowHeight = UITableView.automaticDimension
        self.videos = []
        self.getVideo(q: self.channelId!)
        self.tblYouTube.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVideo(q: String) {
        ProManagerApi.youTubeChannelSearch(channelId: q, order: nil, nextPageToken: self.nextPageToken).request(YTSerchResponse<Item>.self).subscribe(onNext: { response in
            self.nextPageToken = response.nextPageToken
            self.totalResult = response.pageInfo?.totalResults
            self.resultPerPage = response.pageInfo?.resultsPerPage
            if  self.videos.isEmpty && response.result?.isEmpty ?? false {
                self.emptyView?.isHidden = false
            } else {
                self.emptyView?.isHidden = true
            }
            _  =  response.result?.map({ item -> String in
                ProManagerApi.youTubeDetail(id: (item.id?.videoId)!).request(YTSerchResponse<Item>.self).subscribe(onNext: { response in
                    self.videos.append((response.result?[0])!)
                    self.tblYouTube.reloadData()
                }, onError: { _ in
                }, onCompleted: {
                    
                }).disposed(by: self.rx.disposeBag)
                return ""
            })
        }, onCompleted: {
            self.tblYouTube.reloadData()
        }).disposed(by: rx.disposeBag)
    }
    
    @IBAction func btnBackClciked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChannelVideoListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row ==  (ApplicationSettings.shared.videos.count) - 2 && self.nextPageToken != nil {
            self.getVideo(q: self.channelId!)
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.youTubeTableViewCell.identifier) as? YouTubeTableViewCell else {
            fatalError("YouTubeTableViewCell Not Found")
        }
        if  (self.videos.count) > indexPath.row {
            cell.observable =  self.videos[indexPath.row]
        }
        cell.shareHandler = { [weak self] item in
            guard let `self` = self else {
                return
            }
            let obj = R.storyboard.youTube.addPostViewController()!
            obj.video =  self.videos[indexPath.row]
            obj.shareHandler = self.popHandler
            obj.isReview = self.isReview
            self.navigationController?.pushViewController(obj, animated: true)
        }
        cell.playHandler = { [weak self] item in
            guard let `self` = self else {
                return
            }
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
