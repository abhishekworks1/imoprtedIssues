//
//  FeedUploadVC.swift
//  ProManager
//
//  Created by Jasmin Patel on 21/10/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class FeedUploadVC: UIViewController {

    @IBOutlet weak var uploadTableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noDataView: UIView!

    let postUploadManager = PostDataManager.shared
    var postUploads = [PostUploadData]()
    
    var firstModalPersiontage: Double! = 0.0
    var firstModalUploadCompletedSize: Double! = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        self.postUploadManager.delegate = self
    }
    
    func reloadData() {
        postUploads = postUploadManager.getPostUploadDataNotCompleted()
        self.noDataView.isHidden = (postUploads.count > 0)
        self.collectionView.reloadData()
    }
    
    func sizePerMB(url: URL?) -> Double {
        guard let filePath = url?.path else {
            return 0.0
        }
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue / 1000000.0
            }
        } catch {
            print("Error: \(error)")
            
        }
        return 0.0
    }
    
    func getOneDecimalPlaceValue(_ num: Float) -> String {
        return String(format: "%.1f", num)
    }
    
}

extension FeedUploadVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postUploads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.storyUploadCollectionViewCell.identifier, for: indexPath) as? StoryUploadCollectionViewCell else {
            fatalError("cell with 'StoryUploadCollectionViewCell' identifier not found.")
        }

        let postUpload = postUploads[indexPath.row]
        if let postDatas = postUpload.postData?.allObjects as? [PostData],
            postDatas.count > 0 {
            
            let fileName = URL(string: postDatas[0].url!)!.lastPathComponent
            let url = Utils.getLocalPath(fileName)
            postDatas[0].url = url.absoluteString
            cell.remainFileLabel.text = "\(0)/\(postDatas.count)"
            if postDatas[0].postUploadData?.postType != "image" {
                cell.thumbImageView?.image = PostDataManager.shared.getThumbImage(postData: postDatas[0])
            } else {
                if let imageData = try? Data(contentsOf: URL.init(string: url.absoluteString)!) {
                    let image = UIImage(data: imageData)
                    cell.thumbImageView?.image = image
                }
            }
            
            cell.fileNameLabel.text = postDatas[0].createdDate?.asString(style: .medium)
            firstModalUploadCompletedSize = 0
            let downloadedSizeUnit = self.getOneDecimalPlaceValue(Float(Double(self.getOneDecimalPlaceValue(Float(firstModalUploadCompletedSize)))! / 1000000.0))
            
            cell.remainBytesLabel.text = "\(downloadedSizeUnit) MB of \(getOneDecimalPlaceValue(Float(sizePerMB(url: URL.init(string: url.absoluteString))))) MB"
            cell.videoIndicatorView.isHidden = postDatas[0].postUploadData?.postType == "image"
            if indexPath.row == 0  {
                cell.uploadProgressView.progress = Float(firstModalPersiontage/100)
            }
            cell.tag = indexPath.row
            cell.deleteHandler = { [weak self] (tag) in
                guard let strongSelf = self else {
                    return
                }
                print("\(tag)")
                if strongSelf.postUploads.count > tag {
                    if let postDatas = strongSelf.postUploads[tag].postData?.allObjects as? [PostData],
                        postDatas.count > 0 {
                        PostDataManager.shared.stopUploadFile(postData: postDatas[0])
                    }
                    
                }
            }
        }
        return cell
    }
    
}

extension FeedUploadVC: PostUploadDelegate {
    
    func didAddNewPost() {
        didCompletedPost()
    }
    
    func didCompletedPost() {
        reloadData()
    }
    
    func didChangePostCount(_ postCount: String) {
        if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? StoryUploadCollectionViewCell {
            DispatchQueue.main.async {
                cell.remainFileLabel.text = postCount
            }
        }
    }
    
    func didUpdatePostBytes(_ progress: Double) {
        guard postUploads.count > 0 else {
            return
        }
        let postUpload = postUploads[0]
        if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? StoryUploadCollectionViewCell,
            let postDatas = postUpload.postData?.allObjects as? [PostData] {
            DispatchQueue.main.async {
              
                var image = PostDataManager.shared.getThumbImage(postData: postDatas[0])
                let fileName = String.fileName + FileExtension.jpg.rawValue
                if image == nil {
                    image = UIImage()
                }
                let data = image!.jpegData(compressionQuality: 0.6)
                let url = Utils.getLocalPath(fileName)
                try? data?.write(to: url)
                
                let downloadedSizeUnit = self.getOneDecimalPlaceValue(Float(Double(self.getOneDecimalPlaceValue(Float(progress)))! / 1000000.0))
                
                cell.remainBytesLabel.text = "\(downloadedSizeUnit) MB of \(self.getOneDecimalPlaceValue(Float(self.sizePerMB(url: URL(string: postDatas[0].url!))))) MB"
                
            }
        }
    }
    
    func didChangePostThumbImage(_ image: UIImage) {
        if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? StoryUploadCollectionViewCell {
            DispatchQueue.main.async {
                cell.thumbImageView.image = image
            }
        }
    }
    
    func didUpdatePostProgress(_ progress: Double) {
        if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? StoryUploadCollectionViewCell {
            DispatchQueue.main.async {
                cell.uploadProgressView.progress = Float(progress/100)
            }
        }
    }
}
