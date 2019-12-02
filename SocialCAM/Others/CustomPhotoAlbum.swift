//
//  CustomPhotoAlbum.swift
//  ProManager
//
//  Created by Jasmin Patel on 30/04/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import Photos
import UIKit

class SCAlbum: NSObject {
    public var albumName = "\(Constant.Application.displayName)"
    static let shared = SCAlbum()
    
    private var assetCollection: PHAssetCollection!
    
    private override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
    private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (_) in
                self.checkAuthorizationWithHandler(completion: completion)
            })
        } else if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.createAlbumIfNeeded { (success) in
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
                
            }
            
        } else {
            completion(false)
        }
    }
    
    private func createAlbumIfNeeded(completion: @escaping ((_ success: Bool) -> Void)) {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            // Album already exists
            self.assetCollection = assetCollection
            completion(true)
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)   // create an asset collection with the album name
            }) { success, _ in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                    completion(true)
                } else {
                    // Unable to create album
                    completion(false)
                }
            }
        }
    }
    
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", self.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage) {
        self.checkAuthorizationWithHandler { (success) in
            if success, self.assetCollection != nil {
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection) {
                        let enumeration: NSArray = [assetPlaceHolder!]
                        albumChangeRequest.addAssets(enumeration)
                    }
                    
                }, completionHandler: { (success, error) in
                    if success {
                        print("Successfully saved image to Camera Roll.")
                    } else {
                        print("Error writing to image library: \(error!.localizedDescription)")
                    }
                })
                
            }
        }
    }

    func saveVideo(at fileURL: URL) throws -> PHObjectPlaceholder {
        var blockPlaceholder: PHObjectPlaceholder?
        
        try PHPhotoLibrary.shared().performChangesAndWait {
            let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            changeRequest?.creationDate = Date()
            blockPlaceholder = changeRequest?.placeholderForCreatedAsset
        }
        
        return blockPlaceholder!
    }
    
    func saveMovieToLibrary(movieURL: URL) {
        
        self.checkAuthorizationWithHandler(completion: { (_) in
            do {
                let placeholder = try self.saveVideo(at: movieURL)
                
                try PHPhotoLibrary.shared().performChangesAndWait {
                    let request = PHAssetCollectionChangeRequest(for: self.assetCollection)
                    request?.addAssets([placeholder] as NSArray)
                }
            } catch {
                
            }
        })
    }
}
