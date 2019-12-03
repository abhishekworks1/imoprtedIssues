//
//  SelectHashTagViewController.swift
//  ProManager
//
//  Created by Steffi Pravasi on 11/09/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AVKit

var dictOfSets = [[String: Any]]()
var youtubeTag: [String] = []
var changedTags: [String] = []

protocol SelectHashSetDelegate {
    func setSelectedSet(hashSet: HashTagSetList, isHashSetSelected: Bool)
    func noSetSelected(isSelected: Bool)
}

class SelectHashTagViewController: UIViewController {
    
    // MARK: - - Variables
    var hashSet: [HashTagSetList] = []
    var hashTagList: [String] = []
    var delegate: SelectHashSetDelegate?
    var isDone: Bool = false
    
    // MARK: - - Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicator: NVActivityIndicatorView! {
        didSet {
            activityIndicator.color = ApplicationSettings.appPrimaryColor
        }
    }
    
    // MARK: - - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        self.tableView.rowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getHashTags()
        if isDone {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - - Functions
    
    func getHashTags() {
        ProManagerApi.getHashTagSets(Void()).request(ResultArray<HashTagSetList>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                self.hashSet = response.result ?? []
                self.tableView.reloadData()
                if self.hashSet.isEmpty {
                    self.activityIndicator.stopAnimating()
                }
            }
        }, onError: { _ in
            
        }, onCompleted: {
            
        }).disposed(by: (rx.disposeBag))
    }
    
    func deleteHashSet(hashID: String) {
        ProManagerApi.deleteHashTagSet(hashId: hashID).request(Result<HashTagSetList>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                self.getHashTags()
                self.activityIndicator.stopAnimating()
            }
        }, onError: { _ in
            UIApplication.showAlert(title: Constant.Application.displayName, message: R.string.localizable.somethingWentWrongPleaseTryAgainLater())
        }, onCompleted: {
            
        }).disposed(by: (rx.disposeBag))
    }
    
    // MARK: - - Actions
    
    @IBAction func backBtnClicked(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.noSetSelected(isSelected: true)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createHashTagBtnCLicked(_ sender: Any) {
        //        let vc = R.storyboard.addPost.createHashTagViewController()!
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - - TableView Delegate Methods

extension SelectHashTagViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hashSet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HashTagCell") as? HashTagCell else {
            fatalError("HashTagCell Not Found")
        }
        let hashSet = self.hashSet[indexPath.row].hashTags?.joined(separator: " ")
        cell.setData(name: self.hashSet[indexPath.row].categoryName ?? "", subName: self.hashSet[indexPath.row].hashTags?.count ?? 0, set: hashSet ?? "", count: self.hashSet[indexPath.row].usedCount ?? 0)
        cell.selectionStyle = .none
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        self.activityIndicator.stopAnimating()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let delegate = self.delegate {
            let arrayOfData: [String: Any] = ["id": self.hashSet[indexPath.row]._id!, "hashTags": self.hashSet[indexPath.row].hashTags!, "usedCount": self.hashSet[indexPath.row].usedCount ?? 0]
            dictOfSets.append(arrayOfData)
            
            print(dictOfSets)
            delegate.setSelectedSet(hashSet: self.hashSet[indexPath.row], isHashSetSelected: true)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @available(iOS 11.0, *)
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "") { (_, _, _) in
            let refreshAlert = UIAlertController(title: Constant.Application.displayName, message: "Are you sure you want to remove this tag from set?", preferredStyle: .alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_: UIAlertAction!) in
                self.activityIndicator.startAnimating()
                self.deleteHashSet(hashID: self.hashSet[indexPath.row]._id ?? "")
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (_: UIAlertAction!) in
                refreshAlert .dismiss(animated: true, completion: nil)
                self.tableView.reloadData()
            }))
            self.present(refreshAlert, animated: true, completion: nil)
        }
        let edit = UIContextualAction(style: .normal, title: "") { (_, _, _) in
            //            let vc = R.storyboard.addPost.createHashTagViewController()!
            //            vc.setData = self.hashSet[indexPath.row]
            //            vc.isEdit = true
            //            self.navigationController?.pushViewController(vc, animated: true)
        }
        edit.backgroundColor = #colorLiteral(red: 0.3215686275, green: 0.5960784314, blue: 0.2470588235, alpha: 1)
        edit.image = #imageLiteral(resourceName: "edit")
        edit.title = "Edit"
        delete.backgroundColor = #colorLiteral(red: 0.3215686275, green: 0.5960784314, blue: 0.2470588235, alpha: 1)
        delete.image = #imageLiteral(resourceName: "storyDelete")
        delete.title = "Delete"
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
}

extension SelectHashTagViewController: FinishedTag {
    
    func didFinish(isDone: Bool) {
        self.isDone = isDone
    }
    
}
