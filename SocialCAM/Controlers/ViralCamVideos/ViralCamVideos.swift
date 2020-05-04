//
//  ViralCamVideos.swift
//  ViralCam
//
//  Created by Viraj Patel on 22/04/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit
import ESPullToRefresh

class ViralCamVideos: UIViewController, SegmentTypeController {
    
    var segmentType: TopSegments?
    
    @IBOutlet weak var tableView: UITableView!
    var videosPageIndex: Int = 0
    var videosCount: Int = 0
    var videos: [CreatePostViralCam] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh(index: self.videosPageIndex)
        tableView.register(R.nib.videoTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.videoTableViewCell.identifier)
        self.tableView.alwaysBounceVertical = true
        self.tableView.es.addPullToRefresh { [weak self] in
            guard let `self` = self else {
                return
            }
            self.refresh(index: 0)
            self.tableView.es.resetNoMoreData()
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
        }
        self.tableView.es.addInfiniteScrolling { [weak self] in
            guard let `self` = self else {
                return
            }
            if self.videosCount > self.videos.count {
                self.videosPageIndex += 1
                self.refresh(index: self.videosPageIndex)
            } else {
                self.tableView?.es.noticeNoMoreData()
            }
        }
    }
    
    func refresh(index: Int) {
        self.videosPageIndex = index
        self.getAllVideos(index: self.videosPageIndex)
    }
    
    func getAllVideos(index: Int) {
        let loadingView = LoadingView.instanceFromNib()
        loadingView.loadingViewShow = true
        loadingView.shouldCancelShow = true
        loadingView.show(on: self.view)
        ProManagerApi.getViralvids(page: index, limit: 10, socialPlatform: self.segmentType?.rawValue).request(ResultArray<CreatePostViralCam>.self).subscribe(onNext: { (response) in
            guard let array = response.result else {
                return
            }
            loadingView.hide()
            if let videosCount = response.resultCount {
                self.videosCount = videosCount
            }
            if self.videosPageIndex == 0 {
                self.videos = array
            } else {
                self.videos.append(contentsOf: array)
            }
            self.tableView.reloadData()
            self.tableView.es.stopLoadingMore()
        }, onError: { error in
            self.dismissHUD()
            print(error)
        }, onCompleted: {
            
        }).disposed(by: rx.disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("deinit-- \(self.description)")
    }

    @IBAction func btnBackClicked(sender: Any?) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ViralCamVideos: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.videoTableViewCell.identifier, for: indexPath) as? VideoTableViewCell else {
            fatalError("VideoTableViewCell Not Found")
        }
        cell.postModel = videos[indexPath.row]
        return cell
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videosWebViewVC: VideosWebViewVC = VideosWebViewVC()
        videosWebViewVC.websiteUrl = videos[indexPath.row].referenceLink ?? "www.google.com"
        //videosWebViewVC.delegate = self
        self.present(videosWebViewVC, animated: true) {
            
        }
    }
}
