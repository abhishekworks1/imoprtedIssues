//
//  LocksEventHistory+CoreDataClass.swift
//  FillRite
//
//  Created by Jasmin Patel on 07/02/17.
//  Copyright © 2017 Jason Tezanos. All rights reserved.
//  This file was automatically generated and should not be edited.
//
import CoreData
import UIKit
import RxSwift
import SCRecorder

class InternalPostData {
    
    var albumID: String?
    var checkedIn: String?
    var feelings: String?
    var friendExcept: String?
    var friendsOnly: String?
    var hashTags: String?
    var isCheckIn: Bool
    var postMedia: String?
    var postText: String?
    var postType: String?
    var previewUrlData: String?
    var privacy: String?
    var userID: String?
    var wallTheme: String?
    var thumbTime: Double?
    var mediaUrls: [String]?
    var actionType: String?
    var removedMedia: String?
    var oldPostId: String?
    var mentions:[String]?
    
    init(albumID: String? = nil, checkedIn: String? = nil, feelings: String? = nil, friendExcept: String? = nil, friendsOnly: String? = nil, hashTags: String? = nil, postMedia: String? = nil, postText: String? = nil, postType: String? = nil, isCheckIn: Bool = false, previewUrlData: String? = nil, mediaUrls: [String]? = nil, privacy: String? = nil, userID: String? = nil, wallTheme: String? = nil, thumbTime: Double? = nil, actionType: String? = nil, removedMedia: String? = nil, oldPostId: String? = nil, mentions:[String]? = nil) {
        self.albumID = albumID
        self.checkedIn = checkedIn
        self.feelings = feelings
        self.friendExcept = friendExcept
        self.friendsOnly = friendsOnly
        if hashTags != "" {
            self.hashTags = hashTags
        }
        self.postMedia = postMedia
        self.postText = postText
        self.postType = postType
        self.isCheckIn = isCheckIn
        self.previewUrlData = previewUrlData
        self.privacy = privacy
        self.userID = userID
        self.wallTheme = wallTheme
        self.thumbTime = thumbTime
        self.mediaUrls = mediaUrls
        self.actionType = actionType
        self.removedMedia = removedMedia
        self.oldPostId = oldPostId
        self.mentions = mentions
    }
    
}

protocol PostUploadDelegate: class {
    func didUpdatePostProgress(_ progress: Double)
    func didUpdatePostBytes(_ progress: Double)
    func didChangePostCount(_ postCount: String)
    func didChangePostThumbImage(_ image: UIImage)
    func didCompletedPost()
    func didAddNewPost()
}

class PostDataManager {
    
    static let postDataEntityName = "PostData"
    static let postUploadDataEntityName = "PostUploadData"
    
    var context: NSManagedObjectContext
    fileprivate var disposeBag = DisposeBag()
    
    var currentPostData: PostData?
    var currentPostUploadData: PostUploadData?
    var isThumbCreated: Bool = false
    var isPostUploaded: Bool = false
    
    weak var delegate: PostUploadDelegate?
    var postMediaSave: String?
    
    static let shared = PostDataManager(context: Utils.appDelegate?.persistentContainer.viewContext ?? NSManagedObjectContext.init())

    init(context: NSManagedObjectContext) {
        debugPrint("init PostDataManager")
        self.context = context
    }
    
    func createPostData(_ internalPostData: InternalPostData, url: String) -> PostData? {
        
        if let newItem = NSEntityDescription.insertNewObject(forEntityName: PostDataManager.postDataEntityName, into: context) as? PostData {
            newItem.isPostUploaded = false
            newItem.thumbServerURL = ""
            newItem.url = url
            newItem.thumbTime = internalPostData.thumbTime ?? 0.0
            newItem.isCompleted = false
            newItem.priority = Int64(self.getAllPostDatas().count + 1)
            newItem.createdDate = Date()
            if internalPostData.postType == "image" {
                newItem.isThumbUploaded = true
            } else {
                newItem.isThumbUploaded = false
            }
            return newItem
        } else {
            return nil
        }
        
    }
    
    func createPostUploadData(_ internalPostdata: InternalPostData) -> PostUploadData? {
        if let newItem = NSEntityDescription.insertNewObject(forEntityName: PostDataManager.postUploadDataEntityName, into: context) as? PostUploadData {
            
            newItem.isCompleted = false
            newItem.priority = Int64(self.getAllPostUploadData().count + 1)
            var postData = [PostData]()
            for internalPost in internalPostdata.mediaUrls! {
                postData.append(self.createPostData(internalPostdata, url: internalPost)!)
            }
            newItem.postData = NSSet(array: postData)
            newItem.albumID = internalPostdata.albumID
            newItem.checkedIn = internalPostdata.checkedIn
            newItem.feelings = internalPostdata.feelings
            newItem.friendExcept = internalPostdata.friendExcept
            newItem.friendsOnly = internalPostdata.friendsOnly
            newItem.hashTags = internalPostdata.hashTags
            newItem.postMedia = internalPostdata.postMedia
            newItem.postText = internalPostdata.postText
            newItem.postType = internalPostdata.postType
            newItem.isCheckIn = internalPostdata.isCheckIn
            newItem.previewUrlData = internalPostdata.previewUrlData
            newItem.privacy = internalPostdata.privacy
            newItem.userID = internalPostdata.userID
            newItem.wallTheme = internalPostdata.wallTheme
            newItem.actionType = internalPostdata.actionType
            newItem.removedMedia = internalPostdata.removedMedia
            newItem.oldPostId = internalPostdata.oldPostId
            newItem.mentions = internalPostdata.mentions
            
            return newItem
        } else {
            return nil
        }
        
    }
    
    func getPostDataById(id: NSManagedObjectID) -> PostData? {
        return context.object(with: id) as? PostData
    }
    
    func getAllPostData() -> [PostData] {
        guard let postData = currentPostUploadData else {
            return []
        }
        return getPostData(withPredicate: NSPredicate(format: "postUploadData.priority == %d", (postData.priority)))
    }
    
    func getAllPostDatas() -> [PostData] {
        return getPostData(withPredicate: NSPredicate(value: true))
    }
    
    
    func getPostDataNotCompleted() -> [PostData] {
        guard let postData = currentPostUploadData else {
            return []
        }
        let predicate = NSPredicate(format: "isCompleted == NO AND postUploadData.priority == %d", (postData.priority))
        return getPostData(withPredicate: predicate)
    }
    
    func getPostDataCompleted() -> [PostData] {
        guard let postData = currentPostUploadData else {
            return []
        }
        let predicate = NSPredicate(format: "isCompleted == YES AND postUploadData.priority == %d", (postData.priority))
        return getPostData(withPredicate: predicate)
    }
    
    func getCellDataCompleted(postUpdateData: PostUploadData?) -> [PostData] {
        guard let postData = postUpdateData else {
            return []
        }
        let predicate = NSPredicate(format: "isCompleted == YES AND postUploadData.priority == %d", (postData.priority))
        return getPostData(withPredicate: predicate)
    }
    
    func getPostData(withPredicate queryPredicate: NSPredicate) -> [PostData] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PostDataManager.postDataEntityName)
        
        fetchRequest.predicate = queryPredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true)]
        
        do {
            guard let response = try context.fetch(fetchRequest) as? [PostData] else {
                return [PostData]()
            }
            return response
        } catch let _ as NSError {
            // failure
            return [PostData]()
        }
    }
    
    func updatePostData(updateddata: PostData) {
        if getPostDataById(id: updateddata.objectID) != nil {
            
        }
    }
    
    func deletePostData(id: NSManagedObjectID) {
        if let dataToDelete = getPostDataById(id: id) {
            context.delete(dataToDelete)
        }
    }
    
    func getPostUploadDataById(id: NSManagedObjectID) -> PostUploadData? {
        return context.object(with: id) as? PostUploadData
    }
    
    func getAllPostUploadData() -> [PostUploadData] {
        return getPostUploadData(withPredicate: NSPredicate(value: true))
    }
    
    func getPostUploadDataNotCompleted() -> [PostUploadData] {
        let predicate = NSPredicate(format: "isCompleted == NO")
        return getPostUploadData(withPredicate: predicate)
    }
    
    func getPostUploadDataCompleted() -> [PostUploadData] {
        let predicate = NSPredicate(format: "isCompleted == YES")
        return getPostUploadData(withPredicate: predicate)
    }
    
    func getPostUploadData(withPredicate queryPredicate: NSPredicate) -> [PostUploadData] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PostDataManager.postUploadDataEntityName)
        
        fetchRequest.predicate = queryPredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true)]
        
        do {
            guard let response = try context.fetch(fetchRequest) as? [PostUploadData] else {
                return [PostUploadData]()
            }
            return response
        } catch let _ as NSError {
            // failure
            return [PostUploadData]()
        }
    }
    
    func updatePostUploadData(updateddata: PostUploadData) {
        if getPostUploadDataById(id: updateddata.objectID) != nil {
            
        }
    }
    
    func deletePostUploadData(id: NSManagedObjectID) {
        if let dataToDelete = getPostUploadDataById(id: id) {
            context.delete(dataToDelete)
        }
    }
    
    // MARK:- Saves all changes
    func saveChanges() {
        do {
            try context.save()
        } catch let _ as NSError {
            // failure
        }
    }
    
}

extension PostDataManager {
    
    func stopUploadFile(postData: PostData) {
        
        for (_,item) in getAllPostDatas().enumerated()
        {
            if postData.url == item.url {
                postData.postUploadData?.isCompleted = true
                self.saveChanges()
                self.isThumbCreated = false
                self.isPostUploaded = false
                self.currentPostData = nil
                self.currentPostUploadData = nil
                
                AWSManager.shared.cancelOneFileUpload(postData.url ?? "")
                
                self.delegate?.didCompletedPost()
                PostDataManager.shared.startUpload()
                break
            }
        }
    }
    
    func restartAll() {
        
        for (_ ,item) in getAllPostDatas().enumerated() {
            self.isThumbCreated = false
            self.isPostUploaded = false
            self.currentPostData = nil
            self.currentPostUploadData = nil
            AWSManager.shared.cancelOneFileUpload(item.url ?? "")
        }
        self.delegate?.didCompletedPost()
        PostDataManager.shared.startUpload()
    }
    
    func uploadPost(_ postData: PostData) {
        currentPostData = postData
        
        guard !postData.isPostUploaded else {
            debugPrint("Post already uploaded")
            self.isPostUploaded = true
            if currentPostUploadData?.postType != "image" {
                self.uploadThumb()
            } else {
                self.createPost()
            }
            return
        }
        
        let urlFileName = URL(string: postData.url!)!.lastPathComponent
        let url = Utils.getLocalPath(urlFileName)
        
        do {
            let path = FileManager.documentsDir()
            let documentDirectory = URL(fileURLWithPath: path)
            let destinationPath = documentDirectory.appendingPathComponent(urlFileName)
            try FileManager.default.moveItem(at: URL(string: postData.url!)!, to: destinationPath)
        } catch let error {
            debugPrint(error)
        }
        
        postData.url = url.absoluteString
        saveChanges()
        
        var contentType = "image/jpeg"
        var fileName: String = String.fileName
        
        if currentPostUploadData?.postType != "image" {
            uploadThumb()
            contentType = "video/mp4"
            fileName += ".mp4"
        } else {
            fileName += FileExtension.jpg.rawValue
            if let imageData = try? Data(contentsOf: URL(string: postData.url!)!) {
                let image = UIImage(data: imageData)
                self.delegate?.didChangePostThumbImage(image!)
            }
        }
        
        Utils.uploadFile(fileName: fileName, fileURL: URL(string: postData.url!)!, contentType: contentType, progressBlock: { progress in
            let remainString = "\(self.getPostDataCompleted().count)/\(self.getAllPostData().count)"
            debugPrint(remainString)
            self.delegate?.didUpdatePostProgress(Double(progress))
        }, otherProgressBlock: { bytesSent, totalBytesSent, totalBytesExpectedToSend in
            self.delegate?.didUpdatePostBytes(Double(totalBytesSent))
        }, callBack: { url -> Void? in
            postData.serverURL = url
            postData.isPostUploaded = true
            self.saveChanges()
            self.isPostUploaded = true
            self.createPost()
            return nil
        }, failedBlock: { error in
            if error != nil {
                postData.isPostUploaded = false
                self.saveChanges()
                self.isPostUploaded = false
                self.currentPostData = nil
                self.currentPostUploadData = nil
                InternetConnectionAlert.shared.internetConnectionHandler = { reachability in
                    if reachability.connection != .none {
                        PostDataManager.shared.startUpload()
                    }
                }
            }
            debugPrint(error?.localizedDescription ?? "")
        })
    }
    
    func getThumbImage(postData: PostData) -> UIImage? {
        let img = UIImage.getThumbnailFrom(videoUrl: URL(string: postData.url!)!, CMTime(value: CMTimeValue(postData.thumbTime*10000000), timescale: 10000000))
        let width = 400.0
        let image = img?.resizeImage(newWidth: CGFloat(width))
        return image
    }
    
    func uploadThumb() {
        guard let postData = currentPostData,
            !postData.isThumbUploaded else {
                debugPrint("thumb already uploaded")
                let image = getThumbImage(postData: currentPostData!)
                self.delegate?.didChangePostThumbImage(image!)
                self.isThumbCreated = true
                self.createPost()
                return
        }
        
        let contentType = "image/jpeg"
        var image = getThumbImage(postData: postData)
        let fileName = String.fileName + FileExtension.jpg.rawValue
        
        if image == nil {
            image = UIImage()
        }
        let data = image!.jpegData(compressionQuality: 0.6)
        let url = Utils.getLocalPath(fileName)
        try? data?.write(to: url)
        
        self.delegate?.didChangePostThumbImage(image!)
        
        Utils.uploadFile(fileName: fileName, fileURL: url, contentType: contentType, progressBlock: { _ in
        }, otherProgressBlock: { _, _, _ in
            
        }, callBack: { url -> Void? in
            postData.thumbServerURL = url
            postData.isThumbUploaded = true
            self.saveChanges()
            self.isThumbCreated = true
            self.createPost()
            return nil
        }, failedBlock: { error in
            if error != nil {
                postData.isThumbUploaded = false
                self.saveChanges()
                self.currentPostData = nil
                self.currentPostUploadData = nil
                InternetConnectionAlert.shared.internetConnectionHandler = { reachability in
                    if reachability.connection != .none {
                        PostDataManager.shared.startUpload()
                    }
                }
            }
            debugPrint(error?.localizedDescription ?? "")
        })
        
    }
    
    func createPost() {
        guard let postData = currentPostData,
            postData.isThumbUploaded,
            postData.isPostUploaded else { return }
        
        if let postMedia = currentPostUploadData?.postMedia, postMedia != "" {
            
            var postMediaDic: [[String: String]] = []
            let arrayString = postMedia.components(separatedBy: "*:-:-:*")
            for item in arrayString {
                postMediaDic.append(item.json2dict() as? [String: String] ?? [:])
            }
            debugPrint(postMediaDic)
            let newPostString = ["mediaType": "image", "url": postData.serverURL ?? "", "thumbNail": ""]
            postMediaDic.append(newPostString)
            
            var postMediaArray: [String]?
            
            for item in postMediaDic {
                if postMediaArray != nil {
                    postMediaArray?.append(item.dict2json()!)
                }
                else {
                    postMediaArray = [item.dict2json()!]
                }
            }
            postMediaSave = postMediaArray?.joined(separator: "*:-:-:*")
            currentPostUploadData?.postMedia = postMediaArray?.joined(separator: "*:-:-:*")
            
        } else {
            let arrayString = [["mediaType": "image", "url": postData.serverURL ?? "", "thumbNail": ""].dict2json() ?? ""]
            currentPostUploadData?.postMedia = arrayString.joined(separator: "*:-:-:*")
        }
        
        postData.isCompleted = true
        self.saveChanges()
        self.isThumbCreated = false
        self.isPostUploaded = false
        //        self.currentPostData = nil
        self.currentPostUploadData = nil
        PostDataManager.shared.startUpload()
    }
    
    func startUpload() {
        self.saveChanges()
        guard currentPostUploadData == nil else {
            return
        }
        self.delegate?.didAddNewPost()
        let completedPostData = self.getPostUploadDataCompleted()
        let postData = self.getPostUploadDataNotCompleted()
        
        if postData.count > 0 {
            self.currentPostUploadData = postData[0]
            debugPrint("uploadData -> \(postData[0].priority)")
            debugPrint("\(completedPostData.count)/\(self.getAllPostUploadData().count)")
            if self.getPostDataCompleted().count == self.getAllPostData().count {
                postData[0].isCompleted = true
                self.delegate?.didCompletedPost()
                if postMediaSave != nil {
                    currentPostUploadData?.postMedia = postMediaSave!
                    postMediaSave = nil
                    self.currentPostData?.postUploadData?.postMedia = currentPostUploadData?.postMedia
                }
                
                self.saveChanges()
                self.isThumbCreated = false
                self.isPostUploaded = false
                
                if self.currentPostData?.postUploadData?.actionType == "create" {
                    self.creatNewPost()
                } else {
                    self.updatePost()
                }
                
                self.currentPostData = nil
                self.currentPostUploadData = nil
                PostDataManager.shared.startUpload()
            } else {
                if self.getPostDataNotCompleted().count > 0 {
                    debugPrint("PostData -> \(self.getPostDataNotCompleted()[0].priority)")
                    let remainString = "\(self.getPostDataCompleted().count)/\(self.getAllPostData().count)"
                    debugPrint(remainString)
                    self.delegate?.didChangePostCount(remainString)
                    uploadPost(self.getPostDataNotCompleted()[0])
                }
            }
        } else {
            self.delegate?.didChangePostCount("")
        }
    }
    
    func deleteAllRecords() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetchPost = NSFetchRequest<NSFetchRequestResult>(entityName: PostDataManager.postDataEntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetchPost)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            
        }
        
        let deleteFetchPostData = NSFetchRequest<NSFetchRequestResult>(entityName: PostDataManager.postUploadDataEntityName)
        let deletePostRequest = NSBatchDeleteRequest(fetchRequest: deleteFetchPostData)
        
        do {
            try context.execute(deletePostRequest)
            try context.save()
        } catch {
            
        }
    }
    
    func creatNewPost() {
        
        guard let postData = currentPostData else { return }
        
        let selectedPlace: [String: Any]? = postData.postUploadData?.checkedIn?.json2dict()
        var postMediaDic: [[String: String]] = []
        let arrayString = postData.postUploadData?.postMedia?.components(separatedBy: "*:-:-:*")
        for item in arrayString! {
            postMediaDic.append(item.json2dict() as? [String: String] ?? [:])
        }
        
        let postMedia: [[String: Any]]? = postMediaDic
        let selectedPrivacy: String? = postData.postUploadData?.privacy
        
        var previewUrlData: [String: Any]? = postData.postUploadData?.previewUrlData?.json2dict()
        let postTags: [String]? = postData.postUploadData?.hashTags?.components(separatedBy: "*:-:-:*")
        let colorThemeView: [String: Any]? = postData.postUploadData?.wallTheme?.json2dict()
        let selectedAlbum: String? = postData.postUploadData?.albumID
        let text: String? = postData.postUploadData?.postText
        let postType = postData.postUploadData?.postType
        
        let friendExcept: [String]? = postData.postUploadData?.friendExcept?.components(separatedBy: "*:-:-:*")
        let friendOnly: [String]? = postData.postUploadData?.friendsOnly?.components(separatedBy: "*:-:-:*")
        
        var arrayfeelings: [[String: String]] = []
        let arrayfeeling = postData.postUploadData?.feelings?.components(separatedBy: "*:-:-:*")
        if arrayfeeling != nil
        {
            for item in arrayfeeling! {
                arrayfeelings.append(item.json2dict() as? [String: String] ?? [:])
            }
        }
        
        if selectedPlace != nil {
            previewUrlData = nil
        }
        let tagArray = postData.postUploadData?.mentions
        if Defaults.shared.currentUser?.id == nil {
            postData.isCompleted = true
            self.saveChanges()
            self.isThumbCreated = false
            self.isPostUploaded = false
            self.currentPostData = nil
            self.currentPostUploadData = nil
            return
        }
        
        ProManagerApi.writePost(type: postType!, text: text, isChekedIn: (selectedPlace == nil ? false : true), user: (Defaults.shared.currentUser?.id)!, media: postMedia, youTubeData: nil, wallTheme: colorThemeView, albumId: selectedAlbum, checkedIn: selectedPlace, hashTags: postTags, privacy: selectedPrivacy, friendExcept: friendExcept, friendsOnly: friendOnly, feelingType: "", feelings: arrayfeelings, previewUrlData: previewUrlData, tagChannelAry: tagArray).request(Result<Posts>.self).subscribe(onNext: { (response) in
            
            debugPrint("Create Post API Done")
            postData.isCompleted = true
            self.saveChanges()
            self.isThumbCreated = false
            self.isPostUploaded = false
            self.currentPostData = nil
            self.currentPostUploadData = nil
            PostDataManager.shared.startUpload()
            
            guard (response.result != nil) else {
                return
            }
            if response.status == ResponseType.success {
                // dashboardPosts.insert(post, at: 0)
                ApplicationSettings.shared.needtoRefresh = true
                if ApplicationSettings.shared.needtoRefresh == true {
                    ApplicationSettings.shared.needtoRefresh = false
                    AppEventBus.post("FirstPostGet", sender: self)
                }
            }
            Utils.deleteFileFromLocal(URL(string: postData.url!)!.lastPathComponent)
        }, onError: { error in
            
            postData.isCompleted = false
            self.saveChanges()
            self.isThumbCreated = false
            self.isPostUploaded = false
            self.currentPostData = nil
            self.currentPostUploadData = nil
            InternetConnectionAlert.shared.internetConnectionHandler = { reachability in
                if reachability.connection != .none {
                    PostDataManager.shared.startUpload()
                }
            }
            
        }, onCompleted: {
        }).disposed(by: disposeBag)
    }
    
    func updatePost() {
        guard let postData = currentPostData else { return }
        
        let selectedPlace: [String: Any]? = postData.postUploadData?.checkedIn?.json2dict()
        var postMediaDic: [[String: String]] = []
        let arrayString = postData.postUploadData?.postMedia?.components(separatedBy: "*:-:-:*")
        for item in arrayString! {
            postMediaDic.append(item.json2dict() as? [String: String] ?? [:])
        }
        
        let postMedia: [[String: Any]]? = postMediaDic
        let selectedPrivacy: String? = postData.postUploadData?.privacy
        
        var previewUrlData: [String: Any]? = postData.postUploadData?.previewUrlData?.json2dict()
        let postTags: [String]? = postData.postUploadData?.hashTags?.components(separatedBy: "*:-:-:*")
        let colorThemeView: [String: Any]? = postData.postUploadData?.wallTheme?.json2dict()
        let selectedAlbum: String? = postData.postUploadData?.albumID
        let text: String? = postData.postUploadData?.postText
        let tagArray = postData.postUploadData?.mentions
        let postType = postData.postUploadData?.postType
        
        let friendExcept: [String]? = postData.postUploadData?.friendExcept?.components(separatedBy: "*:-:-:*")
        let friendOnly: [String]? = postData.postUploadData?.friendsOnly?.components(separatedBy: "*:-:-:*")
        
        var arrayfeelings: [[String: String]] = []
        let arrayfeeling = postData.postUploadData?.feelings?.components(separatedBy: "*:-:-:*")
        if arrayfeeling != nil {
            for item in arrayfeeling! {
                arrayfeelings.append(item.json2dict() as? [String: String] ?? [:])
            }
        }
        
        let removedMedia: [String]? = postData.postUploadData?.removedMedia?.components(separatedBy: "*:-:-:*")
        
        if selectedPlace != nil {
            previewUrlData = nil
        }
        
        ProManagerApi.updatePost(postID: (postData.postUploadData?.oldPostId)!, type: postType!, text: text, isChekedIn: (selectedPlace == nil ? false : true), user: (Defaults.shared.currentUser?.id)!, media: postMedia, youTubeData: nil, wallTheme: colorThemeView, albumId: selectedAlbum, checkedIn: selectedPlace, hashTags: postTags, privacy: selectedPrivacy, friendExcept: friendExcept, friendsOnly: friendOnly, feelingType: "", feelings: arrayfeelings, previewUrlData: previewUrlData, removedMedia: removedMedia, tagArray: tagArray).request(Result<Posts>.self).subscribe(onNext: { (response) in
            debugPrint("Update Post")
            postData.isCompleted = true
            self.saveChanges()
            self.isThumbCreated = false
            self.isPostUploaded = false
            self.currentPostData = nil
            self.currentPostUploadData = nil
            PostDataManager.shared.startUpload()
            
            guard (response.result != nil) else {
                return
            }
            if response.status == ResponseType.success {
                ApplicationSettings.shared.needtoRefresh = true
                if ApplicationSettings.shared.needtoRefresh == true {
                    ApplicationSettings.shared.needtoRefresh = false
                    AppEventBus.post("FirstPostGet", sender: self)
                }
            }
        }, onError: { error in
            postData.isCompleted = false
            self.saveChanges()
            self.isThumbCreated = false
            self.isPostUploaded = false
            self.currentPostData = nil
            self.currentPostUploadData = nil
            InternetConnectionAlert.shared.internetConnectionHandler = { reachability in
                if reachability.connection != .none {
                    PostDataManager.shared.startUpload()
                }
            }
        }, onCompleted: {
        }).disposed(by: (disposeBag))
    }
}

