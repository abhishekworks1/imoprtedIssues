//
//  ImageLibrary.swift
//  ProManager
//
//  Created by Viraj Patel on 03/05/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import Photos
import MobileCoreServices
import PhotosUI

public enum AssetType: Int {
    case image
    case video
    case both
}

class Once {
    var already: Bool = false

    func run(_ block: () -> Void) {
        guard !already else { return }

        block()
        already = true
    }
}

public func == (lhs: ImageAsset, rhs: ImageAsset) -> Bool {
    return lhs.asset == rhs.asset
}

struct PhotoLibraryPermission {
    var isAuthorized: Bool {
        return PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized
    }
    
    var isDenied: Bool {
        return PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.denied
    }
    
    func request(_ completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization({
            _ in
            DispatchQueue.main.async {
                completion(self.isAuthorized)
            }
        })
    }
}

/// Wrap a PHAsset
public class ImageAsset: Equatable {
   
    enum CloudDownloadState {
        case ready, progress, complete, failed
    }
    
    var state = CloudDownloadState.ready
    
    public let asset: PHAsset!
    public var selectedOrder: Int = 0
    public var assetType: AssetType = .image
    public var videoUrl: URL?
    public var thumbImage: UIImage = UIImage()
    
    // MARK: - Initialization

    init(asset: PHAsset) {
        self.asset = asset
        if asset.mediaSubtypes.contains(.photoLive) {
            assetType = .image
        } else if asset.mediaType == .video {
            assetType = .video
        } else {
            assetType = .image
        }
    }
    
    public var fullResolutionDownloadedImage: UIImage?
    
    public var fullResolutionImage: UIImage? {
        get {
            guard let phAsset = self.asset else { return nil }
            return fullResolutionImageData(asset: phAsset) ?? fullResolutionDownloadedImage
        }
    }
    
    public enum ImageExtType: String {
        case png, jpg, gif, heic
    }
    
    public var originalFileName: String? {
        get {
            guard let phAsset = self.asset, let resource = PHAssetResource.assetResources(for: phAsset).first else { return nil }
            return resource.originalFilename
        }
    }
    
    public func extType() -> ImageExtType {
        var ext = ImageExtType.png
        if let fileName = self.originalFileName, let extention = URL(string: fileName)?.pathExtension.lowercased() {
            ext = ImageExtType(rawValue: extention) ?? .png
        }
        return ext
    }
    
    public func cloudImageDownload(progressBlock: @escaping (Double) -> Void, completionBlock: @escaping (UIImage?) -> Void) -> PHImageRequestID? {
        guard let phAsset = self.asset else { return nil }
        return cloudImageDownload(asset: phAsset, progressBlock: progressBlock, completionBlock: completionBlock)
    }

    public func photoSize(options: PHImageRequestOptions? = nil, completion: @escaping ((Int) -> Void), livePhotoVideoSize: Bool = false) {
        guard let phAsset = self.asset, self.assetType == .image else {
            completion(-1)
            return
        }
        var resource: PHAssetResource?
        if phAsset.mediaSubtypes.contains(.photoLive) == true, livePhotoVideoSize {
            resource = PHAssetResource.assetResources(for: phAsset).filter { $0.type == .pairedVideo }.first
        } else {
            resource = PHAssetResource.assetResources(for: phAsset).filter { $0.type == .photo }.first
        }
        if let fileSize = resource?.value(forKey: "fileSize") as? Int {
            completion(fileSize)
        } else {
            PHImageManager.default().requestImageData(for: phAsset, options: nil) { (data, _, _, _) in
                var fileSize = -1
                if let data = data {
                    let bcf = ByteCountFormatter()
                    bcf.countStyle = .file
                    fileSize = data.count
                }
                DispatchQueue.main.async {
                    completion(fileSize)
                }
            }
        }
    }

    public func videoSize(options: PHVideoRequestOptions? = nil, completion: @escaping ((Int) -> Void)) {
        guard let phAsset = self.asset, self.assetType == .video else {
            completion(-1)
            return
        }
        let resource = PHAssetResource.assetResources(for: phAsset).filter { $0.type == .video }.first
        if let fileSize = resource?.value(forKey: "fileSize") as? Int {
            completion(fileSize)
        } else {
            PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { (avasset, _, info) in
                func fileSize(_ url: URL?) -> Int? {
                    do {
                        guard let fileSize = try url?.resourceValues(forKeys: [.fileSizeKey]).fileSize else { return nil }
                        return fileSize
                    } catch { return nil }
                }
                var url: URL?
                if let urlAsset = avasset as? AVURLAsset {
                    url = urlAsset.url
                } else if let sandboxKeys = info?["PHImageFileSandboxExtensionTokenKey"] as? String, let path = sandboxKeys.components(separatedBy: ";").last {
                    url = URL(fileURLWithPath: path)
                }
                let size = fileSize(url) ?? -1
                DispatchQueue.main.async {
                    completion(size)
                }
            }
        }
    }

    @discardableResult
    //convertLivePhotosToJPG
    // false : If you want mov file at live photos
    // true  : If you want png file at live photos ( HEIC )
    public func tempCopyMediaFile(asset: PHAsset?, videoRequestOptions: PHVideoRequestOptions? = nil, imageRequestOptions: PHImageRequestOptions? = nil, exportPreset: String = AVAssetExportPresetHighestQuality, convertLivePhotosToJPG: Bool = false, progressBlock: ((Double) -> Void)? = nil, completionBlock:@escaping ((URL, String) -> Void), failBlock:@escaping ((Bool) -> Void)) -> PHImageRequestID? {
        guard let phAsset = asset else {
            failBlock(false)
            return nil
        }
        var type: PHAssetResourceType?
        if phAsset.mediaSubtypes.contains(.photoLive) == true, convertLivePhotosToJPG == false {
            type = .pairedVideo
        } else {
            type = phAsset.mediaType == .video ? .video : .photo
        }
        guard let resource = (PHAssetResource.assetResources(for: phAsset).filter { $0.type == type }).first else {
            failBlock(false)
            return nil
        }
        let fileName = resource.originalFilename
        var writeURL: URL?
        if #available(iOS 10.0, *) {
            writeURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName)")
        } else {
            writeURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("\(fileName)")
        }
        if (writeURL?.pathExtension.uppercased() == "HEIC" || writeURL?.pathExtension.uppercased() == "HEIF") && convertLivePhotosToJPG {
            if let fileName2 = writeURL?.deletingPathExtension().lastPathComponent {
                writeURL?.deleteLastPathComponent()
                writeURL?.appendPathComponent("\(fileName2).jpg")
            }
        }
        guard let localURL = writeURL, let mimetype = MIMEType(writeURL) else {
            failBlock(false)
            return nil
        }
        switch phAsset.mediaType {
        case .video:
            var requestOptions = PHVideoRequestOptions()
            if let options = videoRequestOptions {
                requestOptions = options
            } else {
                requestOptions.isNetworkAccessAllowed = true
            }
            //iCloud download progress
            requestOptions.progressHandler = { (progress, error, stop, info) in
                DispatchQueue.main.async {
                    progressBlock?(progress)
                }
            }
            return PHImageManager.default().requestExportSession(forVideo: phAsset, options: requestOptions, exportPreset: exportPreset) { (session, _) in
                session?.outputURL = localURL
                session?.outputFileType = AVFileType.mov
                session?.exportAsynchronously(completionHandler: {
                    DispatchQueue.main.async {
                        completionBlock(localURL, mimetype)
                    }
                })
                
            }
        case .image:
            var requestOptions = PHImageRequestOptions()
            if let options = imageRequestOptions {
                requestOptions = options
            } else {
                requestOptions.isNetworkAccessAllowed = true
            }
            //iCloud download progress
            requestOptions.progressHandler = { (progress, error, stop, info) in
                DispatchQueue.main.async {
                    progressBlock?(progress)
                }
            }
            return PHImageManager.default().requestImageData(for: phAsset, options: requestOptions, resultHandler: { (data, _, _, _) in
                do {
                    var data = data
                    let needConvertLivePhotoToJPG = phAsset.mediaSubtypes.contains(.photoLive) == true && convertLivePhotosToJPG == true
                    if needConvertLivePhotoToJPG, let imgData = data, let rawImage = UIImage(data: imgData)?.upOrientationImage() {
                        data = rawImage.jpegData(compressionQuality: 1)
                    }
                    try data?.write(to: localURL)
                    DispatchQueue.main.async {
                        completionBlock(localURL, mimetype)
                    }
                } catch { }
            })
        default:
            return nil
        }
    }
    
    @discardableResult
    func cloudImageDownload(asset: PHAsset, size: CGSize = PHImageManagerMaximumSize, progressBlock: @escaping (Double) -> Void, completionBlock: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        options.version = .current
        options.resizeMode = .exact
        options.progressHandler = { (progress, error, stop, info) in
            progressBlock(progress)
        }
        let requestId = PHCachingImageManager().requestImageData(for: asset, options: options) { (imageData, _, _, info) in
            if let data = imageData, let _ = info {
                completionBlock(UIImage(data: data))
            } else {
                completionBlock(nil)// error
            }
        }
        return requestId
    }

    @discardableResult
    func fullResolutionImageData(asset: PHAsset) -> UIImage? {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .none
        options.isNetworkAccessAllowed = true
        options.version = .current
        var image: UIImage?
        _ = PHCachingImageManager().requestImageData(for: asset, options: options) { (imageData, _, _, _) in
            if let data = imageData {
                image = UIImage(data: data)
            }
        }
        return image
    }

    func MIMEType(_ url: URL?) -> String? {
        guard let ext = url?.pathExtension else { return nil }
        if !ext.isEmpty {

            let UTIRef = UTTypeCreatePreferredIdentifierForTag("public.filename-extension" as CFString, ext as CFString, nil)
            let UTI = UTIRef?.takeUnretainedValue()
            if let UTI = UTI {
                guard let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType) else { return nil }
                let MIMEType = MIMETypeRef.takeUnretainedValue()
                MIMETypeRef.release()
                return MIMEType as String
            }
        }
        return nil
    }

    // Apparently, this method is not be safety to export a video.
    // There is many way that export a video.
    // This method was one of them.
    public func exportVideoFile(options: PHVideoRequestOptions? = nil, progressBlock: ((Float) -> Void)? = nil, completionBlock: @escaping ((URL, String) -> Void)) {
        guard let phAsset = self.asset, phAsset.mediaType == .video else { return }
        var type = PHAssetResourceType.video
        guard let resource = (PHAssetResource.assetResources(for: phAsset).filter { $0.type == type }).first
            else { return }
        let fileName = resource.originalFilename
        var writeURL: URL?
        if #available(iOS 10.0, *) {
            writeURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName)")
        } else {
            writeURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("\(fileName)")
        }
        guard let localURL = writeURL, let mimetype = MIMEType(writeURL) else { return }
        var requestOptions = PHVideoRequestOptions()
        if let options = options {
            requestOptions = options
        } else {
            requestOptions.isNetworkAccessAllowed = true
        }
        // iCloud download progress
        options?.progressHandler = { (progress, error, stop, info) in

        }
       
        PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { (avasset, _, _) in
            guard let avasset = avasset else { return }
            if let asset = avasset as? AVURLAsset {
                completionBlock(asset.url, mimetype)
                return
                /* Create the layer now */
            }
            let exportSession = AVAssetExportSession.init(asset: avasset, presetName: AVAssetExportPresetHighestQuality)
            exportSession?.outputURL = localURL
            exportSession?.outputFileType = AVFileType.mp4
            exportSession?.exportAsynchronously(completionHandler: {
                let path = FileManager.documentsDir()
                let documentDirectory = URL(fileURLWithPath: path)
                let destinationPath = documentDirectory.appendingPathComponent(localURL.lastPathComponent)
                do {
                    try FileManager.default.moveItem(at: localURL, to: destinationPath)
                } catch let error {
                    print(error)
                }
                completionBlock(destinationPath, mimetype)
            })
            
            func checkExportSession() {
                DispatchQueue.global().async { [weak exportSession] in
                    guard let exportSession = exportSession else { return }
                    switch exportSession.status {
                    case .waiting, .exporting:
                        DispatchQueue.main.async {
                            progressBlock?(exportSession.progress)
                        }
                        checkExportSession()
                    default:
                        break
                    }
                }
            }
            
            checkExportSession()
        }
    }

}

class ImageAlbum {

    let collection: PHAssetCollection
    var items: [ImageAsset] = []

    // MARK: - Initialization

    init(collection: PHAssetCollection) {
        self.collection = collection
    }

    func reload(_ type: AssetType? = .image) {
        items = []

        let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: Utils.fetchOptions())
        itemsFetchResult.enumerateObjects({ (asset, _, _) in
            if asset.mediaType == .image && (type == .image || type == .both) {
                self.items.append(ImageAsset(asset: asset))
            }
            if asset.mediaType == .video && (type == .video || type == .both) {
                self.items.append(ImageAsset(asset: asset))
            }

        })
    }
}

class ImagesLibrary: NSObject, PHPhotoLibraryChangeObserver {
    
    var albums: [ImageAlbum] = []
    var albumsFetchResults = [PHFetchResult<PHAssetCollection>]()
    lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    private var fetchResult: PHFetchResult<PHAsset>?
    var lastImageDidUpdateInGalleryBlock: ((_ asset: PHAsset?) -> Void)?
    
    // MARK: - Initialization

    static let shared: ImagesLibrary = ImagesLibrary()
    
    override init() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1

        // Fetch the image assets
        fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        print("Deinit \(self.description)")
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - Logic

    func reload(_ type: AssetType? = .image, _ completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            self.reloadSync(type)
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func getLatestPhotos(completion completionBlock: ((PHAsset?) -> Void)) {
        guard let fetchResult = self.fetchResult else {
            return
        }
        if fetchResult.count > 0 {
            completionBlock(fetchResult.object(at: 0))
        } else {
            completionBlock(nil)
        }
    }
    
    fileprivate func reloadSync(_ type: AssetType? = .image) {
        let types: [PHAssetCollectionType] = [.smartAlbum, .album]

        albumsFetchResults = types.map {
            return PHAssetCollection.fetchAssetCollections(with: $0, subtype: .any, options: nil)
        }

        albums = []

        for result in albumsFetchResults {
            result.enumerateObjects({ (collection, _, _) in
                let album = ImageAlbum(collection: collection)
                album.reload(type)

                if !album.items.isEmpty {
                    self.albums.append(album)
                }
            })
        }

        // Move Camera Roll first
        
        albums.sort {
            $0.collection.localizedTitle! < $1.collection.localizedTitle!
        }
        
        if let index = albums.firstIndex(where: { $0.collection.assetCollectionSubtype == . smartAlbumUserLibrary }) {
            albums.g_moveToFirst(index)
        }
    }

    @discardableResult
    func videoAsset(asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), progressBlock: Photos.PHAssetImageProgressHandler? = nil, completionBlock: @escaping (AVPlayerItem?, [AnyHashable: Any]?) -> Void) -> PHImageRequestID {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .automatic
        options.progressHandler = progressBlock
        let requestId = self.imageManager.requestPlayerItem(forVideo: asset, options: options, resultHandler: { playerItem, info in
            completionBlock(playerItem, info)
        })
        return requestId
    }

    @discardableResult
    func imageAsset(asset: PHAsset, size: CGSize = CGSize(width: 160, height: 160), options: PHImageRequestOptions? = nil, completionBlock: @escaping (UIImage, Bool) -> Void) -> PHImageRequestID {
        var options = options
        if options == nil {
            options = PHImageRequestOptions()
            options?.isSynchronous = false
            options?.resizeMode = .exact
            options?.deliveryMode = .opportunistic
            options?.isNetworkAccessAllowed = true
        }
        let scale = min(UIScreen.main.scale, 2)
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        let requestId = self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, info in
            let complete = (info?["PHImageResultIsDegradedKey"] as? Bool) == false
            if let image = image {
                completionBlock(image, complete)
            }
        }
        return requestId
    }

    func cancelPHImageRequest(requestId: PHImageRequestID) {
        self.imageManager.cancelImageRequest(requestId)
    }

    @discardableResult
    class func fullResolutionImageData(asset: PHAsset) -> UIImage? {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .none
        options.isNetworkAccessAllowed = false
        options.version = .current
        var image: UIImage?
        _ = PHCachingImageManager().requestImageData(for: asset, options: options) { (imageData, _, _, _) in
            if let data = imageData {
                image = UIImage(data: data)
            }
        }
        return image
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult = self.fetchResult else {
            return
        }
        guard let changes = changeInstance.changeDetails(for: fetchResult) else {
            return
        }
        self.fetchResult = changes.fetchResultAfterChanges
        getLatestPhotos { (asset) in
            lastImageDidUpdateInGalleryBlock?(asset)
        }
    }

}

struct Constraint {
    static func on(constraints: [NSLayoutConstraint]) {
        constraints.forEach {
            ($0.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
            $0.isActive = true
        }
    }

    static func on(_ constraints: NSLayoutConstraint ...) {
        on(constraints: constraints)
    }
}
