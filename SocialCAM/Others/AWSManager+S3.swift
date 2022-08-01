//
//  APIManager+S3.swift
//  SocialCAM
//
//  Created by Viraj Patel on 20/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AWSS3
//import AWSCore
//import AVKit

class AWSManager {
    
    static let shared: AWSManager = AWSManager()
   
    func uploadImageToAmazon(currentFileName: String, soundFileURL: URL, contentType: String?, _ bucket: String?, progressBlock: @escaping (Float) -> Void = { _ in }, otherProgressBlock: ((Float, Float, Float) -> Void)? = { _, _, _ in }, callBack: @escaping (_ url: String) -> Void?, failedBlock: @escaping (Error?) -> Void = { _ in }) {

        // once the image is saved we can use the path to create a local fileurl
        let url: URL = soundFileURL
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        expression.progressBlock = {(task, progress) -> Void in
            print("Upload Progress : \(progress.fractionCompleted) - \(progress.completedUnitCount)/\(progress.totalUnitCount)")
            progressBlock(Float(progress.fractionCompleted))
            otherProgressBlock?(Float(progress.completedUnitCount), Float(progress.totalUnitCount), Float(progress.fractionCompleted))
        }
       
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock? = { (task, error) in
            if error != nil {
                DispatchQueue.main.async {
                    failedBlock(error)
                }
            } else {
                let stringURL = Constant.AWS.URL + Constant.AWS.NAME + "/" + soundFileURL.lastPathComponent
                print("Uploaded to:\n\(stringURL)")
                DispatchQueue.main.async {
                    callBack(stringURL)
                }
            }
        }
        
        /// AWSS3TransferUtility
        let transferTransferUtility: AWSS3TransferUtility = AWSS3TransferUtility.default()
        transferTransferUtility.uploadFile(url, bucket: Constant.AWS.NAME, key: Constant.AWS.NAME + "/" + soundFileURL.lastPathComponent, contentType: contentType ?? "image/jpeg", expression: expression, completionHandler: completionHandler)
    }
    
    func cancelAllUploads() {
//        AWSS3TransferUtility.default().enumerateToAssignBlocks(forUploadTask: { (uploadTask, _, _) in
//            uploadTask.cancel()
//        }, downloadTask: nil)
    }

//    func cancelAllUploads(withTaskId taskId: UInt) {
//        AWSS3TransferUtility.default().enumerateToAssignBlocks(forUploadTask: { (uploadTask, _, _) in
//            if uploadTask.taskIdentifier == taskId {
//                uploadTask.cancel()
//            }
//        }, downloadTask: nil)
//    }
//
//    func cancelOneFileUpload(_ itemUrl: String) {
//        AWSS3TransferUtility.default().enumerateToAssignBlocks(forUploadTask: { (uploadTask, _, _) in
//            if uploadTask.key.dropFirst(13) == URL.init(string: itemUrl)!.lastPathComponent {
//                uploadTask.cancel()
//                return
//            }
//        }, downloadTask: nil)
//    }
}
