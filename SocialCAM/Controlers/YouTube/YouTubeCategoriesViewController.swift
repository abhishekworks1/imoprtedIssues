//
//  YouTubeCategoriesViewController.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 13/03/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import GoogleSignIn
import Alamofire
import ObjectMapper

protocol YouCategoryDelegate {
    func didFinishWith(category: YouCategory)
}

class YouTubeCategoriesViewController: UIViewController {

    @IBOutlet weak var tblCategories: UITableView!
    var categories: [YouCategory] = []
    var delegate: YouCategoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblCategories.estimatedRowHeight = 40
        self.tblCategories.rowHeight = UITableView.automaticDimension
        self.getCategories()
    }
    
    func getCategories() {
        AF.request(Constant.URLs.youtube + Paths.getYoutubeCategoty + "?part=snippet&regionCode=US&key=\(Constant.GoogleService.serviceKey)").responseJSON(completionHandler: { (response) in
            switch(response.result) {
            case.success(let jsonData):
                print("success", jsonData)
                guard let json = jsonData as? [String: Any] else {
                    return
                }
                guard let userProfile = Mapper<YouTubeItmeListResponse<YouCategory>>().map(JSONString: json.dict2json() ?? "") else {
                    return
                }                     
                self.categories = userProfile.item
                self.tblCategories.reloadData()
            case.failure(let error):
                print("Not Success",error.localizedDescription)
            }
        })
    }
    
    @IBAction func btnBackClicked(_ sender: Any?) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension YouTubeCategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.youCategoryTableViewCell.identifier) as? YouCategoryTableViewCell else {
            fatalError("YouCategoryTableViewCell not Found")
        }
        cell.category = categories[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        if let delegate = self.delegate {
            delegate.didFinishWith(category: category)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}
