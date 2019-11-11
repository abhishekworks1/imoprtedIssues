//
//  StoryUploadVC.swift
//  ProManager
//
//  Created by Jasmin Patel on 11/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

extension StoryUploadVC: URLSessionDataDelegate, URLSessionDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        bytesReceived += CGFloat(data.count)
        stopTime = CFAbsoluteTimeGetCurrent()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let elapsed = (stopTime - startTime) //as? CFAbsoluteTime
        let speed: CGFloat = elapsed != 0 ? bytesReceived / (CGFloat(CFAbsoluteTimeGetCurrent() - startTime)) / 1024.0 / 1024.0 : 0.0
        // treat timeout as no error (as we're testing speed, not worried about whether we got entire resource or not
        if error == nil || ((((error as NSError?)?.domain) == NSURLErrorDomain) && (error as NSError?)?.code == NSURLErrorTimedOut) {
            speedTestCompletionHandler?(speed, nil)
        }
        else {
            speedTestCompletionHandler?(speed, error)
        }
    }
}

class StoryUploadCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var videoIndicatorView: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var remainBytesLabel: UILabel!
    @IBOutlet weak var remainFileLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var uploadProgressView: UIProgressView!

    var deleteHandler: ((_ index: Int) -> Void)?
    
    @IBAction func cancleButtonTapped(_ sender: AnyObject) {
        deleteHandler?(self.tag)
    }

}

class StoryUploadVC: UIViewController {

    @IBOutlet weak var uploadTableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noDataView: UIView!
    
    let storyUploadManager = StoryDataManager.shared
    
    var storyUploads = [StoryData]()
    var firstModalPersiontage: Double! = 0.0
    var firstModalUploadCompletedSize: Double! = 0.0
    
   
    var startTime = CFAbsoluteTime()
    var stopTime = CFAbsoluteTime()
    var bytesReceived: CGFloat = 0
    var speedTestCompletionHandler: ((_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void)? = nil
    
    @IBOutlet weak var lblSignal: UILabel!
    @IBOutlet weak var imgSignal: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        self.storyUploadManager.delegate = self
    }
    
    func reloadData() {
        storyUploads.removeAll()
        for storyUploadData in storyUploadManager.getStoryUploadDataNotCompleted() {
            for storyData in storyUploadData.storyData?.allObjects as? [StoryData] ?? [] {
                if !storyData.isCompleted {
                    storyUploads.append(storyData)
                }
            }
        }
        self.noDataView.isHidden = (storyUploads.count > 0)
        self.collectionView.reloadData()
    }
    
    deinit {
        print("StroyUploadVC deinit")
    }
    
    // MARK: IBActions
    func testDownloadSpeed(withTimout timeout: TimeInterval, completionHandler: @escaping (_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void) {
        
        // you set any relevant string with any file
        let urlForSpeedTest = URL(string: "https://s3-us-west-2.amazonaws.com/spinach-cafe/audio/14+Mysterious+Intro.mp3")
        
        startTime = CFAbsoluteTimeGetCurrent()
        stopTime = startTime
        bytesReceived = 0
        speedTestCompletionHandler = completionHandler
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        guard let checkedUrl = urlForSpeedTest else { return }
        
        session.dataTask(with: checkedUrl).resume()
    }
    
    @IBAction func onDownloadTest(_ sender: Any) {
        testDownloadSpeed(withTimout: 10.0, completionHandler: { [weak self] (_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void in
            guard let strongSelf = self else {
                return
            }
            print("%0.1f; error = \(megabytesPerSecond)")
            DispatchQueue.main.async {
                if megabytesPerSecond <= 0.002 {
                    strongSelf.imgSignal.image = #imageLiteral(resourceName: "emoji3")
                    strongSelf.lblSignal.text = "Very Slow"
                }
                else if megabytesPerSecond >= 0.002 && megabytesPerSecond <= 0.008 {
                    strongSelf.imgSignal.image = #imageLiteral(resourceName: "like")
                    strongSelf.lblSignal.text = "Slow"
                }
                else if megabytesPerSecond >= 0.008 && megabytesPerSecond <= 0.02 {
                    strongSelf.imgSignal.image = #imageLiteral(resourceName: "feedGridIcon")
                    strongSelf.lblSignal.text = "Medium"
                }
                else if megabytesPerSecond >= 0.02 && megabytesPerSecond <= 0.010 {
                    strongSelf.imgSignal.image = #imageLiteral(resourceName: "storyNext")
                    strongSelf.lblSignal.text = "High"
                }
                else {
                    strongSelf.imgSignal.image = #imageLiteral(resourceName: "like-template")
                    strongSelf.lblSignal.text = "Very High"
                }
            }
        })
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

extension StoryUploadVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyUploads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryUploadCollectionViewCell", for: indexPath) as? StoryUploadCollectionViewCell else {
            fatalError("cell with 'StoryUploadCollectionViewCell' identifier not found.")
        }
        
        let storyUpload = storyUploads[indexPath.row]
        cell.remainFileLabel.text = ""
        var fileName = ""
        
        if storyUpload.url! != "" {
            fileName = URL(string: storyUpload.url!)!.lastPathComponent
        }
        else {
            if let storyExports = Array(storyUpload.storyExport!) as? [StoryExport],
                storyExports.count > 0
            {
                fileName = URL(string: storyExports[0].url!)!.lastPathComponent
            }
        }
        let url = Utils.getLocalPath(fileName)
        storyUpload.url = url.absoluteString
        
        cell.videoIndicatorView.isHidden = storyUpload.type == StoryType.image.rawValue
        if storyUpload.type != StoryType.image.rawValue {
            cell.thumbImageView?.image = StoryDataManager.shared.getThumbImage(storyData: storyUpload)
        } else {
            if let imageData = try? Data(contentsOf: URL(string: url.absoluteString)!) {
                let image = UIImage(data: imageData)
                cell.thumbImageView?.image = image
            }
        }
        
        cell.fileNameLabel.text = storyUpload.createdDate?.asString(style: .medium)
        if indexPath.row != 0  {
            firstModalUploadCompletedSize = 0
        }
        let downloadedSizeUnit = self.getOneDecimalPlaceValue(Float(Double(self.getOneDecimalPlaceValue(Float(firstModalUploadCompletedSize)))! / 1000000.0))
        
        cell.remainBytesLabel.text = "\(downloadedSizeUnit) MB of \(getOneDecimalPlaceValue(Float(sizePerMB(url: url)))) MB"
        if indexPath.row == 0 {
            cell.uploadProgressView.progress = Float(firstModalPersiontage/100)
        } else {
            cell.uploadProgressView.progress = 0
        }
        
        cell.tag = indexPath.row
        cell.deleteHandler = { [weak self] (tag) in
            guard let strongSelf = self else {
                return
            }
            print("\(tag)")
            if strongSelf.storyUploads.count > tag {
                StoryDataManager.shared.stopUploadFile(storyData: strongSelf.storyUploads[tag])
            }
        }
        return cell
    }
    
    
}
class CustomHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifer = "CustomHeaderReuseIdentifier"
    let customLabel = UILabel.init()
    
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        customLabel.font = UIFont.init(name: "SFUIText-Bold", size: 14)!
      
        self.contentView.backgroundColor = ApplicationSettings.appWhiteColor
        self.backgroundColor = ApplicationSettings.appWhiteColor
        customLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(customLabel)
        
        let margins = contentView.layoutMarginsGuide
        customLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        customLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        customLabel.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        customLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomFooter: UITableViewHeaderFooterView {
    
    static let reuseIdentifer = "CustomFooterReuseIdentifier"
    let customLabel = UILabel.init()
 
    let customImage:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        customLabel.font = UIFont.init(name: "SFUIText-Medium", size: 17)!
        
        self.contentView.backgroundColor = ApplicationSettings.appWhiteColor
        self.backgroundColor = ApplicationSettings.appWhiteColor
        customLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(customLabel)
        customLabel.textAlignment = .center
        
        let margins = contentView.layoutMarginsGuide
        customLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        customLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        customLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        customLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.contentView.addSubview(customImage)
       
//        customImage.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        customImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        customImage.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        customImage.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        customImage.bottomAnchor.constraint(equalTo: customLabel.topAnchor, constant: -15).isActive = true
     
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StoryUploadVC: StoryUploadDelegate {
    
    func didCompletedStory() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    func didUpdateBytes(_ progress: Double, _ totalFile: Double, _ storyData: StoryData) {
        guard storyUploads.count > 0 else {
            return
        }
        DispatchQueue.main.async {
            if let cell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? StoryUploadCollectionViewCell {
                DispatchQueue.main.async {
                    let downloadedSizeUnit = self.getOneDecimalPlaceValue(Float(Double(self.getOneDecimalPlaceValue(Float(progress)))! / 1000000.0))
                    let totalSizeUnit = self.getOneDecimalPlaceValue(Float(Double(self.getOneDecimalPlaceValue(Float(totalFile)))! / 1000000.0))
                    cell.fileNameLabel.text = storyData.createdDate?.asString(style: .medium)
                    cell.remainBytesLabel.text = "\(downloadedSizeUnit) MB of \(totalSizeUnit) MB"
                }
            }
        }
    }
    
    func didChangeThumbImage(_ image: UIImage) {
        DispatchQueue.main.async {
            if let cell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? StoryUploadCollectionViewCell {
                cell.thumbImageView.image = image
            }
        }
        
    }
    
    func didUpdateProgress(_ progress: Double) {
        DispatchQueue.main.async {
            if let cell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? StoryUploadCollectionViewCell {
                DispatchQueue.main.async {
                    cell.uploadProgressView.progress = Float(progress/100)
                }
            }
        }
    }
    
    func didChangeStoryCount(_ storyCount: String) {

    }
    
}
