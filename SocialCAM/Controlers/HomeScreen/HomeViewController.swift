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
    
    var settingsOptions = [R.string.localizable.prO(), R.string.localizable.logout(), R.string.localizable.prO(), R.string.localizable.logout()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(R.nib.homeTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.homeTableViewCell.identifier)
        tableView.register(R.nib.homeTableViewCellWithCollectionView(), forCellReuseIdentifier: R.reuseIdentifier.homeTableViewCellWithCollectionView.identifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("deinit-- \(self.description)")
    }

}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.homeTableViewCellWithCollectionView.identifier, for: indexPath) as? HomeTableViewCellWithCollectionView else {
                fatalError("HomeTableViewCellWithCollectionView Not Found")
            }
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.homeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else {
            fatalError("StorySettingsCell Not Found")
        }
        cell.lblTitle?.text = settingsOptions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
