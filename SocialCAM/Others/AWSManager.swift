//
//  AWSManager.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 24/05/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import AWSS3
import AWSCore

/**
 Upload Progress Tracker Delegate. Each time an instance of SMAWSImageUploader receives a change in the progress uploaded, the progressUpdated function will be called. Conform to this delegate to receive updates on upload progress and then implement UI Progress View if desired.
 */
protocol AWSImageUploadProgressTrackerDelegate {
    func progressUpdated(currentProgress: Float)
}

class AWSManager {
    static var instance: AWSManager?

    var uploadProgressTrackerDelegate: AWSImageUploadProgressTrackerDelegate?
    var uploadRequests = [AWSS3TransferManagerUploadRequest?]()

    class func shareInstance() -> AWSManager {
        if instance == nil {
            instance = AWSManager()
        }
        return instance!
    }

    init() {
        let myIdentityPoolId = Constant.AWS.COGNITO_POOL_ID

        let credentialsProvider: AWSCognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest2, identityPoolId: myIdentityPoolId)

        let endpoint = AWSEndpoint.init(region: .USWest2, service: .S3, useUnsafeURL: false)
        let configuration = AWSServiceConfiguration.init(region: .USWest2, endpoint: endpoint, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func uploadImageToAmazon(currentFileName: String, soundFileURL: URL, contentType: String = "image/jpeg", _ bucket: String?, progressBlock: @escaping (Float) -> Void = { _ in }, otherProgressBlock: ((Float, Float, Float) -> Void)? = { _, _, _ in }, callBack: @escaping (_ url: String) -> Void?, failedBlock: @escaping (Error?) -> Void = { _ in }) {

        var S3BucketName = Constant.AWS.BUCKET_NAME
        if let bucketName = bucket {
            S3BucketName = bucketName
        }

        let remoteName = currentFileName

        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = soundFileURL
        uploadRequest?.key = remoteName
        uploadRequest?.bucket = S3BucketName
        uploadRequest?.contentType = contentType
        uploadRequest?.acl = .publicRead

        uploadRequests.append(uploadRequest)
        
        uploadRequest?.uploadProgress = { bytesSent, totalBytesSent, totalBytesExpectedToSend in
            DispatchQueue.main.async(execute: {
                if totalBytesSent != 0 {
                    progressBlock(Float(totalBytesSent * 100) / Float(totalBytesExpectedToSend))
                    otherProgressBlock?(Float(bytesSent), Float(totalBytesSent), Float(totalBytesExpectedToSend))
                }

                if self.uploadProgressTrackerDelegate != nil {
                    var uploadProgressPercentage: Float = 0
                    if totalBytesExpectedToSend > 0 {
                        uploadProgressPercentage = Float(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
                        self.uploadProgressTrackerDelegate?.progressUpdated(currentProgress: uploadProgressPercentage)
                    }
                }
                print("\(totalBytesSent)/\(totalBytesExpectedToSend)")
            })
        }

        let transferManager = AWSS3TransferManager.default()

        // Perform file upload
        transferManager.upload(uploadRequest!).continueWith(block: { task -> Any? in

            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }

            if task.result != nil {
                let stringURL = "\(Constant.AWS.baseUrl)\(S3BucketName)/\(currentFileName)"
                print("Uploaded to:\n\(stringURL)")
                
                DispatchQueue.main.async {
                    if let index = self.indexOfUploadRequest(self.uploadRequests, uploadRequest: uploadRequest) {
                        self.uploadRequests[index] = nil
                    }
                }
                
                // Remove locally stored file
                DispatchQueue.main.async {
                    callBack(stringURL)
                }
            } else {
                DispatchQueue.main.async {
                    failedBlock(task.error)
                }
                print("Unexpected empty result.")
            }
            return nil
        })
    }

    func uploadAudioToAmazon(currentFileName: String, soundFileURL: URL, contentType: String = "audio/m4a", progressBlock: @escaping (Float) -> Void = { _ in }, callBack: @escaping (_ url: String) -> Void?, failedBlock: @escaping (Error?) -> Void = { _ in }) {

        let S3BucketName = Constant.AWS.BUCKET_NAME
        let remoteName = currentFileName
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = soundFileURL
        uploadRequest?.key = remoteName
        uploadRequest?.bucket = S3BucketName
        uploadRequest?.contentType = contentType
        uploadRequest?.acl = .publicRead
        uploadRequest?.uploadProgress = { bytesSent, totalBytesSent, totalBytesExpectedToSend in
            DispatchQueue.main.async(execute: {
                progressBlock(Float(totalBytesSent * 100 / totalBytesExpectedToSend))
                print("\(totalBytesSent)/\(totalBytesExpectedToSend)")
                if self.uploadProgressTrackerDelegate != nil {
                    var uploadProgressPercentage: Float = 0
                    if totalBytesExpectedToSend > 0 {
                        uploadProgressPercentage = Float(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
                        self.uploadProgressTrackerDelegate?.progressUpdated(currentProgress: uploadProgressPercentage)
                    }
                }
            })
        }

        let transferManager = AWSS3TransferManager.default()

        // Perform file upload

        transferManager.upload(uploadRequest!).continueWith(block: { task -> Any? in

            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }

            if task.result != nil {
                let stringURL = "\(Constant.AWS.baseUrl)\(Constant.AWS.BUCKET_NAME)/\(currentFileName)"
                print("Uploaded to:\n\(stringURL)")

                // Remove locally stored file
                DispatchQueue.main.async {
                    callBack(stringURL)
                }

            } else {
                DispatchQueue.main.async {
                    failedBlock(task.error)
                }
                print("Unexpected empty result.")
            }
            return nil
        })
    }

    func indexOfUploadRequest(_ array: [AWSS3TransferManagerUploadRequest?], uploadRequest: AWSS3TransferManagerUploadRequest?) -> Int? {
        for (index, object) in array.enumerated() {
            if object == uploadRequest {
                return index
            }
        }
        return nil
    }

    func cancelAllUploads() {
        for (_, uploadRequest) in self.uploadRequests.enumerated() {
            if let uploadRequest = uploadRequest {
                uploadRequest.cancel()?.continueWith(block: { (task) -> Any? in
                    if let error = task.error {
                        debugPrint("cancel() failed: [\(error)]")
                    }
                    return task
                })
            }
        }
    }

}
