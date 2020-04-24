//
//  ViralCamVideos.swift
//  ViralCam
//
//  Created by Viraj Patel on 22/04/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class ViralCamVideos: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    
    var videos: [CreatePostViralCam] = []
      
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllVideos()
        tableView.register(R.nib.videoTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.videoTableViewCell.identifier)
    }
    
    func getAllVideos() {
        self.showHUD()
        ProManagerApi.getViralvids.request(ResultArray<CreatePostViralCam>.self).subscribe(onNext: { (response) in
            guard let array = response.result else {
                return
            }
            self.dismissHUD()
            self.videos = array
            self.tableView.reloadData()
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
        
    }
}
