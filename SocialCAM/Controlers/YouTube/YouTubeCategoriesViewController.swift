//
//  YouTubeCategoriesViewController.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 13/03/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import GoogleSignIn

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
        ProManagerApi.getYoutubeCategory(token: "").request(YouTubeItmeListResponse<YouCategory>.self).subscribe(onNext: { (response) in
            self.categories = response.item
            self.tblCategories.reloadData()
            
        }, onError: { (_) in
            
        }, onCompleted: {
            
        }).disposed(by: self.rx.disposeBag)
        
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
