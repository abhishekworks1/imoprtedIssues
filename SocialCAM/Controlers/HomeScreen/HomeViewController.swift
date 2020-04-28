//
//  HomeViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 22/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation

class HomeViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    var videos: [CreatePostViralCam] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(R.nib.videoTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.videoTableViewCell.identifier)
    }
    
    func getAllVideos() {
        let loadingView = LoadingView.instanceFromNib()
        loadingView.loadingViewShow = true
        loadingView.shouldCancelShow = true
        loadingView.show(on: self.view)
        ProManagerApi.getViralvids.request(ResultArray<CreatePostViralCam>.self).subscribe(onNext: { (response) in
            guard let array = response.result else {
                return
            }
            loadingView.hide()
            self.videos = array
            self.tableView.reloadData()
        }, onError: { error in
            self.dismissHUD()
            print(error)
        }, onCompleted: {
            
        }).disposed(by: rx.disposeBag)
    }
    
    deinit {
        print("deinit-- \(self.description)")
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        
    }
}
