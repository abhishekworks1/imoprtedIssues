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
import RxCocoa
import NSObject_Rx
import SCRecorder

extension CustomStringConvertible {
    var description: String {
        var description: String = "\(type(of: self)){ "
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label {
                description += "\(propertyName): \(child.value), "
            }
        }
        description = String(description.dropLast(2))
        description += " }"
        return description
    }
}

class InternalStoryTag: CustomStringConvertible {
    var tagType: Int
    var tagFontSize: Float
    var tagHeight: Float
    var tagWidth: Float
    var centerX: Float
    var centerY: Float
    var scaleX: Float
    var scaleY: Float
    var rotation: Float
    var tagText: String
    var latitude: Double
    var longitude: Double
    var themeType: Int
    var videoId: String
    var postId: String?
    var storyID: String?
    var userId: String?
    var userProfileURL: String?
    var placeId: String?
    var playlistId: String?
    var sliderTag: String?
    var askQuestionTag: String?
    var pollTag: String?
    
    init(tagType: Int, tagFontSize: Float, tagHeight: Float, tagWidth: Float, centerX: Float, centerY: Float, scaleX: Float, scaleY: Float, rotation: Float, tagText: String, latitude: Double, longitude: Double, themeType: Int, videoId: String) {
        self.tagType = tagType
        self.tagFontSize = tagFontSize
        self.tagHeight = tagHeight
        self.tagWidth = tagWidth
        self.centerX = centerX
        self.centerY = centerY
        self.scaleX = scaleX
        self.scaleY = scaleY
        self.rotation = rotation
        self.tagText = tagText
        self.latitude = latitude
        self.longitude = longitude
        self.themeType = Int(themeType)
        self.videoId = videoId
    }

}

class InternalStoryData {
    
    var address: String?
    var duration: String?
    var lat: String?
    var long: String?
    var thumbTime: Double
    var type: String?
    var storiType: StoriType = .default
    var url: String?
    var userId: String?
    var watermarkURL: String?
    var isMute: Bool?
    var filterName: String?
    var exportedURLs: [String]?
    var hiddenHashtags: String?
    var tags: [InternalStoryTag]?
    var videotx: Double?
    var videoty: Double?
    var videoScaleX: Double?
    var videoScaleY: Double?
    var videoRotation: Double?
    var hasTransformation: Bool = false
    var publish: Int = 1
    
    init(address: String?, duration: String?, lat: String?, long: String?, thumbTime: Double, type: String?, url: String?, userId: String?, watermarkURL: String?, isMute: Bool, filterName: String?, exportedUrls: [String], hiddenHashtags: String?, tags: [InternalStoryTag]?) {
        self.address = address
        self.duration = duration
        self.lat = lat
        self.long = long
        self.thumbTime = thumbTime
        self.type = type
        self.url = url
        self.userId = userId
        self.watermarkURL = watermarkURL
        self.isMute = isMute
        self.filterName = filterName
        self.exportedURLs = exportedUrls
        self.hiddenHashtags = hiddenHashtags
        self.tags = tags
    }

}

protocol StoryUploadDelegate: class {
    func didUpdateProgress(_ progress: Double)
    func didUpdateBytes(_ progress: Double, _ totalFile: Double, _ storyData: StoryData)
    func didChangeStoryCount(_ storyCount: String)
    func didChangeThumbImage(_ image: UIImage)
    func didCompletedStory()
}

class StoryDataManager {
    
    static let storyDataEntityName = "StoryData"
    static let storyUploadDataEntityName = "StoryUploadData"
    static let storyExportEntityName = "StoryExport"
    static let storyTagEntityName = "StoryTag"

    var context: NSManagedObjectContext
    fileprivate var disposeBag = DisposeBag()
    
    var currentStoryData: StoryData?
    var currentStoryUploadData: StoryUploadData?
    var isThumbCreated: Bool = false
    var isStoryUploaded: Bool = false
    
    weak var delegate: StoryUploadDelegate?
    let exportSession = StoryAssetExportSession()
    
    static let shared = StoryDataManager(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    
    init(context: NSManagedObjectContext) {
        debugPrint("init StoryDataManager")
        self.context = context
    }
    
    func createStoryTag(_ tag: InternalStoryTag) -> StoryTag? {
        if let newItem = NSEntityDescription.insertNewObject(forEntityName: StoryDataManager.storyTagEntityName, into: context) as? StoryTag {
            newItem.tagType = Int64(tag.tagType)
            newItem.tagFontSize = tag.tagFontSize
            newItem.tagHeight = tag.tagHeight
            newItem.tagWidth = tag.tagWidth
            newItem.centerX = tag.centerX
            newItem.centerY = tag.centerY
            newItem.scaleX = tag.scaleX
            newItem.scaleY = tag.scaleY
            newItem.rotation = tag.rotation
            newItem.lattitude = tag.latitude
            newItem.longitude = tag.longitude
            newItem.themeType = Int64(tag.themeType)
            newItem.tagText = tag.tagText
            newItem.videoID = tag.videoId
            newItem.postId = tag.postId
            newItem.storyId = tag.storyID
            newItem.userId = tag.userId
            newItem.userProfileURL = tag.userProfileURL
            newItem.placeId = tag.placeId
            newItem.playlistId = tag.playlistId
            newItem.askQuestionTag = tag.askQuestionTag
            newItem.sliderTag = tag.sliderTag
            newItem.pollTag = tag.pollTag
            return newItem
        }
        return nil
    }
    
    func createStoryData(_ internalStoryData: InternalStoryData) -> StoryData? {

        if let newItem = NSEntityDescription.insertNewObject(forEntityName: StoryDataManager.storyDataEntityName, into: context) as? StoryData {
            newItem.address = internalStoryData.address
            newItem.createdDate = Date()
            newItem.duration = internalStoryData.duration
            newItem.lat = internalStoryData.lat
            newItem.long = internalStoryData.long
            newItem.thumbURL = ""
            newItem.type = internalStoryData.type
            newItem.storiType = Int64(internalStoryData.storiType.rawValue)
            if internalStoryData.type == "image" {
                newItem.isThumbUploaded = true
            } else {
                newItem.isThumbUploaded = false
            }
            newItem.url = internalStoryData.url
            newItem.serverURL = ""
            newItem.userId = internalStoryData.userId
            newItem.thumbTime = internalStoryData.thumbTime
            newItem.isCompleted = false
            newItem.priority = Int64(self.getAllStoryDatas().count + 1)
            newItem.isStoryUploaded = false
            if internalStoryData.type == "slideshow" {
                newItem.type = "video"
                newItem.isExported = false
            } else {
                newItem.isExported = false
            }
            newItem.filterName = internalStoryData.filterName
            newItem.isMute = internalStoryData.isMute ?? false
            newItem.watermarkURL = internalStoryData.watermarkURL
            var storyExportData = [StoryExport]()
            for url in internalStoryData.exportedURLs ?? [""] {
                storyExportData.append(self.createStoryExportData(url)!)
            }
            newItem.storyExport = NSSet(array: storyExportData)
            newItem.hiddenHashtags = internalStoryData.hiddenHashtags
            var tags = [StoryTag]()
            for tag in internalStoryData.tags ?? [InternalStoryTag]() {
                if let storyTag = self.createStoryTag(tag) {
                    tags.append(storyTag)
                }
            }
            newItem.publish = Int64(internalStoryData.publish)
            newItem.tags = NSSet(array: tags)
            newItem.videotx = internalStoryData.videotx ?? 0
            newItem.videoty = internalStoryData.videoty ?? 0
            newItem.videoScaleX = internalStoryData.videoScaleX ?? 0
            newItem.videoScaleY = internalStoryData.videoScaleY ?? 0
            newItem.videoRotation = internalStoryData.videoRotation ?? 0
            newItem.hasTransformation = internalStoryData.hasTransformation
            return newItem
        } else {
            return nil
        }

    }
    
    func createStoryExportData(_ url: String?) -> StoryExport? {
        
        if let newItem = NSEntityDescription.insertNewObject(forEntityName: StoryDataManager.storyExportEntityName, into: context) as? StoryExport {
            newItem.priority = Int64(1)
            newItem.url = url
            return newItem
        } else {
            return nil
        }
        
    }
    
    func createStoryUploadData(_ internalStorydata: [InternalStoryData]) -> StoryUploadData? {
        if let newItem = NSEntityDescription.insertNewObject(forEntityName: StoryDataManager.storyUploadDataEntityName, into: context) as? StoryUploadData {
            newItem.isCompleted = false
            newItem.priority = Int64(self.getAllStoryUploadData().count + 1)
            var storyData = [StoryData]()
            for internalStory in internalStorydata {
                storyData.append(self.createStoryData(internalStory)!)
            }
            newItem.storyData = NSSet(array: storyData)
            return newItem
        } else {
            return nil
        }

    }
    
    func getStoryDataById(id: NSManagedObjectID) -> StoryData? {
        return context.object(with: id) as? StoryData
    }
    
    func getAllStoryData() -> [StoryData] {
        guard let storyData = currentStoryUploadData else {
            return []
        }
        return getStoryData(withPredicate: NSPredicate(format: "storyUploadData.priority == %d", (storyData.priority)))
    }
    
    func getAllStoryDatas() -> [StoryData] {
        return getStoryData(withPredicate: NSPredicate(value: true))
    }
    
    func getStoryDataNotCompleted() -> [StoryData] {
        guard let storyData = currentStoryUploadData else {
            return []
        }
        let predicate = NSPredicate(format: "isCompleted == NO AND storyUploadData.priority == %d", (storyData.priority))
        return getStoryData(withPredicate: predicate)
    }
    
    func getStoryDataCompleted() -> [StoryData] {
        guard let storyData = currentStoryUploadData else {
            return []
        }
        let predicate = NSPredicate(format: "isCompleted == YES AND storyUploadData.priority == %d", (storyData.priority))
        return getStoryData(withPredicate: predicate)
    }
    
    func getStoryData(withPredicate queryPredicate: NSPredicate) -> [StoryData] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: StoryDataManager.storyDataEntityName)
        
        fetchRequest.predicate = queryPredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true)]
        
        do {
            let response = try context.fetch(fetchRequest)
            return response as! [StoryData]
            
        } catch let error as NSError {
            // failure
            debugPrint(error)
            return [StoryData]()
        }
    }

    func updateStoryData(updateddata: StoryData) {
        if getStoryDataById(id: updateddata.objectID) != nil {
            
        }
    }
    
    func deleteStoryData(id: NSManagedObjectID) {
        if let dataToDelete = getStoryDataById(id: id) {
            context.delete(dataToDelete)
        }
    }
    
    func getStoryUploadDataById(id: NSManagedObjectID) -> StoryUploadData? {
        return context.object(with: id) as? StoryUploadData
    }
    
    func getAllStoryUploadData() -> [StoryUploadData] {
        return getStoryUploadData(withPredicate: NSPredicate(value: true))
    }
    
    func getStoryUploadDataNotCompleted() -> [StoryUploadData] {
        let predicate = NSPredicate(format: "isCompleted == NO")
        return getStoryUploadData(withPredicate: predicate)
    }
    
    func getStoryUploadDataCompleted() -> [StoryUploadData] {
        let predicate = NSPredicate(format: "isCompleted == YES")
        return getStoryUploadData(withPredicate: predicate)
    }
    
    func getStoryUploadData(withPredicate queryPredicate: NSPredicate) -> [StoryUploadData] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: StoryDataManager.storyUploadDataEntityName)
        
        fetchRequest.predicate = queryPredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true)]
        
        do {
            let response = try context.fetch(fetchRequest)
            return response as! [StoryUploadData]
            
        } catch let error as NSError {
            // failure
            debugPrint(error)
            return [StoryUploadData]()
        }
    }
    
    func updateStoryUploadData(updateddata: StoryUploadData) {
        if getStoryUploadDataById(id: updateddata.objectID) != nil {
            
        }
    }
    
    func deleteStoryUploadData(id: NSManagedObjectID) {
        if let dataToDelete = getStoryUploadDataById(id: id) {
            context.delete(dataToDelete)
        }
    }
    
    // MARK: - Saves all changes
    func saveChanges() {
        do {
            try context.save()
        } catch let error as NSError {
            // failure
            debugPrint(error)
        }
    }
    
}

extension StoryDataManager {
 
    func stopUploadFile(storyData: StoryData) {

        for (_, item) in getAllStoryDatas().enumerated() {
            if storyData.url == item.url {
                storyData.storyUploadData?.isCompleted = true
                self.saveChanges()
                self.isThumbCreated = false
                self.isStoryUploaded = false
                self.currentStoryData = nil
                self.currentStoryUploadData = nil
                exportSession.cancelExporting()
                Utils.uploadSingleUrlStop(storyData.url)
                StoryDataManager.shared.startUpload()
                self.delegate?.didChangeStoryCount("")
                self.delegate?.didCompletedStory()
                break
            }
        }
    }
    
    func stopAll() {
        Utils.uploadStopAll()
        self.delegate?.didCompletedStory()
    }
    
    func restartAll() {
        for (_, item) in getAllStoryDatas().enumerated() {
            self.isThumbCreated = false
            self.isStoryUploaded = false
            self.currentStoryData = nil
            self.currentStoryUploadData = nil
            Utils.uploadSingleUrlStop(item.url)
        }
        
        StoryDataManager.shared.startUpload()
        self.delegate?.didCompletedStory()
    }
     
    func exportStory() {
        guard let storyData = currentStoryData else { return }
        
        let storyExports = storyData.storyExport?.allObjects as? [StoryExport]
        let session = SCRecordSession()
        
        for storyExport in storyExports! {
            let fileName = URL(string: storyExport.url!)!.lastPathComponent
            let url = Utils.getLocalPath(fileName)
            session.addSegment(SCRecordSessionSegment(url: url, info: nil))
        }
        
        if let filterName = storyData.filterName,
            filterName != "CIFilter" {
            var filter: CIFilter?
            if filterName == "CISharpenLuminance" {
                filter = CIFilter(name: "CISharpenLuminance", parameters: ["inputSharpness": 5.0])
            } else {
                filter = CIFilter(name: filterName)
            }
            exportSession.filter = filter
            if filterName.hasPrefix("/") {
                if let styleImage = UIImage(contentsOfFile: filterName),
                    let ciFilter = CIFilter.filter(from: styleImage) {
                    exportSession.filter = ciFilter
                } else {
                    exportSession.filter = nil
                }
            }
        }
        exportSession.isMute = storyData.isMute
        if let imageData = try? Data(contentsOf: URL(string: storyData.watermarkURL!)!) {
            let image = UIImage(data: imageData)
            exportSession.overlayImage = image
        }
        if storyData.hasTransformation {
            exportSession.inputTransformation = StoryImageView.ImageTransformation(tx: CGFloat(storyData.videotx), ty: CGFloat(storyData.videoty), scaleX: CGFloat(storyData.videoScaleX), scaleY: CGFloat(storyData.videoScaleY), rotation: CGFloat(storyData.videoRotation))
        }
        
        exportSession.export(for: session.assetRepresentingSegments(), progress: { progress in
            debugPrint(progress)
        }) { exportedURL in
            if let url = exportedURL {
                storyData.url = url.absoluteString
                let album = SCAlbum.shared
                album.albumName = "\(Constant.Application.displayName)"
                let avPlayer = AVPlayer(url: url)
                if let duration = avPlayer.currentItem?.asset.duration.seconds {
                    storyData.duration = "\(duration)"
                }
                album.saveMovieToLibrary(movieURL: url)
                storyData.isExported = true
                self.saveChanges()
                self.uploadStory(storyData)
                for storyExport in storyExports! {
                    Utils.deleteFileFromLocal(URL(string: storyExport.url!)!.lastPathComponent)
                }
            }
        }
    }
    
    func uploadStory(_ storyData: StoryData) {
        currentStoryData = storyData
        
        if currentStoryData?.type != "image" && !storyData.isExported {
            exportStory()
            return
        }
        
        guard !storyData.isStoryUploaded else {
            debugPrint("story already uploaded")
            self.isStoryUploaded = true
            if currentStoryData?.type != "image" {
                self.uploadThumb()
            } else {
                self.createStory()
            }
            return
        }
        
        let urlFileName = URL(string: storyData.url!)!.lastPathComponent
        let url = Utils.getLocalPath(urlFileName)
        
        do {
            let path = FileManager.documentsDir()
            let documentDirectory = URL(fileURLWithPath: path)
            let destinationPath = documentDirectory.appendingPathComponent(urlFileName)
            try FileManager.default.moveItem(at: URL(string: storyData.url!)!, to: destinationPath)
        } catch let error {
            debugPrint(error)
        }
        
        storyData.url = url.absoluteString
        saveChanges()
        
        var contentType = "image/jpeg"
        var fileName: String = String.fileName
        
        if currentStoryData?.type != "image" {
            uploadThumb()
            contentType = "video/mp4"
            fileName = fileName + ".mp4"
        } else {
            fileName = fileName + FileExtension.jpg.rawValue
            if let imageData = try? Data(contentsOf: URL(string: storyData.url!)!) {
                let image = UIImage(data: imageData)
                self.delegate?.didChangeThumbImage(image!)
            }
        }

        Utils.uploadFile(fileName: fileName, fileURL: URL(string: storyData.url!)!, contentType: contentType, progressBlock: { progress in
            let remainString = "\(self.getStoryDataCompleted().count + 1)/\(self.getAllStoryData().count)"
            debugPrint(remainString)
            self.delegate?.didChangeStoryCount(remainString)
            self.delegate?.didUpdateProgress(Double(progress))
        }, otherProgressBlock: { bytesSent, totalBytesSent, _ in
            self.delegate?.didUpdateBytes(Double(bytesSent), Double(totalBytesSent), storyData)
        }, callBack: { url -> Void? in
            storyData.serverURL = url
            storyData.isStoryUploaded = true
            self.saveChanges()
            self.isStoryUploaded = true
            self.createStory()
            return nil
        }, failedBlock: { error in
            if error != nil {
                storyData.isStoryUploaded = false
                self.saveChanges()
                self.isStoryUploaded = false
                self.currentStoryData = nil
                self.currentStoryUploadData = nil
            }
            debugPrint(error?.localizedDescription ?? "")
        })
    }
    
    func getOneDecimalPlaceValue(_ num: Float) -> String {
        return String(format: "%.1f", num)
    }
    
    func getThumbImage(storyData: StoryData) -> UIImage? {
        var image: UIImage? = UIImage()
        if storyData.url != "" {
            
            let img = UIImage.getThumbnailFrom(videoUrl: URL(string: storyData.url!)!, CMTime(value: CMTimeValue(storyData.thumbTime*10000000), timescale: 10000000))
            let width = 400.0
            image = img?.resizeImage(newWidth: CGFloat(width))
            
        }
        return image
    }
    
    func uploadThumb() {
        guard let storyData = currentStoryData,
                !storyData.isThumbUploaded else {
                    debugPrint("thumb already uploaded")
                    var image = getThumbImage(storyData: currentStoryData!)
                    if image == nil {
                        image = UIImage()
                        self.delegate?.didChangeThumbImage(image!)
                        self.isThumbCreated = true
                        self.createStory()
                        return
                    }
                    let fileName = String.fileName + FileExtension.jpg.rawValue
                    let data = image!.jpegData(compressionQuality: 0.6)
                    let url = Utils.getLocalPath(fileName)
                    try? data?.write(to: url)

                    self.delegate?.didChangeThumbImage(image!)
                    self.isThumbCreated = true
                    self.createStory()
                    return
        }
        
        let contentType = "image/jpeg"
        var image = getThumbImage(storyData: storyData)
        let fileName = String.fileName + FileExtension.jpg.rawValue
        if image == nil {
            image = UIImage()
        }
        let data = image!.jpegData(compressionQuality: 0.6)
        let url = Utils.getLocalPath(fileName)
        try? data?.write(to: url)

        self.delegate?.didChangeThumbImage(image!)
    
        Utils.uploadFile(fileName: fileName, fileURL: url, contentType: contentType, progressBlock: { _ in
            
        }, otherProgressBlock: { _, _, _ in
            
        }, callBack: { url -> Void? in
            storyData.thumbURL = url
            storyData.isThumbUploaded = true
            self.saveChanges()
            self.isThumbCreated = true
            self.createStory()
            return nil
        }, failedBlock: { error in
            if error != nil {
                storyData.isThumbUploaded = false
                self.saveChanges()
                self.currentStoryData = nil
                self.currentStoryUploadData = nil
            }
            debugPrint(error?.localizedDescription ?? "")
        })
    }
    
    func createStory() {
        guard let storyData = currentStoryData,
            storyData.isThumbUploaded,
            storyData.isStoryUploaded else { return }
        var storyTagDict: [[String: Any]]?
        var storyHashTags: [String]?
        if let storyTagsSet = storyData.tags,
            let storyTags = Array(storyTagsSet) as? [StoryTag] {
            for tag in storyTags {
                var tagDict = [
                    "tagType": tag.tagType,
                    "tagFontSize": tag.tagFontSize,
                    "tagHeight": tag.tagHeight,
                    "tagWidth": tag.tagWidth,
                    "centerX": tag.centerX,
                    "centerY": tag.centerY,
                    "scaleX": tag.scaleX,
                    "scaleY": tag.scaleY,
                    "rotation": tag.rotation,
                    "tagText": tag.tagText ?? "",
                    "Latitude": tag.lattitude ,
                    "Longitude": tag.longitude ,
                    "themeType": tag.themeType,
                    "videoId": tag.videoID ?? "",
                    "userProfileURL": tag.userProfileURL ?? "",
                    "hasRatio": UIScreen.haveRatio
                    ] as [String: Any]
                if let postID = tag.postId {
                    tagDict["postId"] = postID
                }
                if let storyID = tag.storyId {
                    tagDict["storyId"] = storyID
                }
                if let tagUserId = tag.userId {
                    tagDict["userId"] = tagUserId
                }
                if let placeId = tag.placeId {
                    tagDict["placeId"] = placeId
                }
                if let playlistId = tag.playlistId {
                    tagDict["playListId"] = playlistId
                }
                if let sliderTag = tag.sliderTag,
                    let sliderTagDict = sliderTag.json2dict() {
                    tagDict["sliderTag"] = sliderTagDict
                }
                if let askQuestionTag = tag.askQuestionTag,
                    let askQuestionTagDict = askQuestionTag.json2dict() {
                    tagDict["askQuestionTag"] = askQuestionTagDict
                }
                if let pollTag = tag.pollTag,
                    let pollTagDict = pollTag.json2dict() {
                    tagDict["pollTag"] = pollTagDict
                }
                if storyTagDict == nil {
                    storyTagDict = [tagDict]
                } else {
                    storyTagDict?.append(tagDict)
                }
                if tag.tagType == StoryTagType.hashtag.rawValue {
                    if storyHashTags == nil {
                        storyHashTags = ["#\(tag.tagText ?? "")"]
                    } else {
                        storyHashTags?.append("#\(tag.tagText ?? "")")
                    }
                }
            }
        }

        if let hiddenHashtagsString = storyData.hiddenHashtags {
            let hiddenHashtags = hiddenHashtagsString.components(separatedBy: " ")
            for hiddenHashtag in hiddenHashtags {
                if storyHashTags == nil {
                    storyHashTags = [hiddenHashtag]
                } else {
                    storyHashTags?.append(hiddenHashtag)
                }
            }
        }
        
        ProManagerApi
            .createStory(url: storyData.serverURL ?? "",
                         duration: storyData.duration ?? "",
                         type: storyData.type ?? "",
                         storiType: Int(storyData.storiType),
                         user: storyData.userId ?? "",
                         thumb: storyData.thumbURL ?? "",
                         lat: (storyData.lat == nil || storyData.lat == "") ? "0.0" : storyData.lat ?? "0.0",
                         long: (storyData.long == nil || storyData.long == "") ? "0.0" : storyData.long ?? "0.0",
                         address: storyData.address ?? "",
                         tags: storyTagDict,
                         hashtags: storyHashTags,
                         publish: Int(storyData.publish))
            .request(Result<Story>.self)
            .subscribe(onNext: { (_) in
                debugPrint("Create Story Post")
                storyData.isCompleted = true
                self.saveChanges()
                self.isThumbCreated = false
                self.isStoryUploaded = false
                self.currentStoryData = nil
                self.currentStoryUploadData = nil
                StoryDataManager.shared.startUpload()
                Utils.deleteFileFromLocal(URL(string: storyData.url!)!.lastPathComponent)
                AppEventBus.post("ReloadStoryAfterPost", sender: self)
                
        }, onError: { _ in
            storyData.isCompleted = false
            self.saveChanges()
            self.isThumbCreated = false
            self.isStoryUploaded = false
            self.currentStoryData = nil
            self.currentStoryUploadData = nil
        }).disposed(by: (disposeBag))
      
    }
    
    func startUpload() {
        self.saveChanges()
        self.delegate?.didCompletedStory()
        guard currentStoryUploadData == nil else {
            return
        }
        let completedStoryData = self.getStoryUploadDataCompleted()
        let storyData = self.getStoryUploadDataNotCompleted()
        
        if storyData.count > 0 {
            self.currentStoryUploadData = storyData[0]
            debugPrint("uploadData -> \(storyData[0].priority)")
            debugPrint("\(completedStoryData.count)/\(self.getAllStoryUploadData().count)")
            if self.getStoryDataCompleted().count == self.getAllStoryData().count {
                storyData[0].isCompleted = true
                self.saveChanges()
                self.isThumbCreated = false
                self.isStoryUploaded = false
                self.currentStoryData = nil
                self.currentStoryUploadData = nil
                StoryDataManager.shared.startUpload()
            } else {
                if self.getStoryDataNotCompleted().count > 0 {
                    debugPrint("storyData -> \(self.getStoryDataNotCompleted()[0].priority)")
                    let remainString = "\(self.getStoryDataCompleted().count + 1)/\(self.getAllStoryData().count)"
                    debugPrint(remainString)
                    self.delegate?.didChangeStoryCount(remainString)
                    uploadStory(self.getStoryDataNotCompleted()[0])
                }
            }
            
        } else {
            self.delegate?.didChangeStoryCount("")
        }
    }
    
    func deleteAllRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetchPost = NSFetchRequest<NSFetchRequestResult>(entityName: StoryDataManager.storyDataEntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetchPost)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            debugPrint("There was an error")
        }
        
        let deleteFetchPostData = NSFetchRequest<NSFetchRequestResult>(entityName: StoryDataManager.storyExportEntityName)
        let deletePostRequest = NSBatchDeleteRequest(fetchRequest: deleteFetchPostData)
        
        do {
            try context.execute(deletePostRequest)
            try context.save()
        } catch {
            debugPrint("There was an error")
        }
        
        let deleteFetchStoryData = NSFetchRequest<NSFetchRequestResult>(entityName: StoryDataManager.storyUploadDataEntityName)
        let deleteStoryRequest = NSBatchDeleteRequest(fetchRequest: deleteFetchStoryData)
        
        do {
            try context.execute(deleteStoryRequest)
            try context.save()
        } catch {
            debugPrint("There was an error")
        }
        
        self.delegate?.didCompletedStory()
    }
}
