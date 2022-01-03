//
//  SampleHandler.swift
//  SocialScreenRecorderExtension
//
//  Created by Viraj Patel on 17/12/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import ReplayKit

class SampleHandler: RPBroadcastSampleHandler, UNUserNotificationCenterDelegate {
    
    var assetWriter: AVAssetWriter!
    var videoInput: AVAssetWriterInput!
    var audioWriterInput: AVAssetWriterInput!
    var isWritingStarted: Bool = false
    var fileName: String?
    var gfileURL: URL?
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        print("**extension***broadcastStarted")
        fileName = "test_file\(Int.random(in: 10 ..< 1000))"
        let fileURL = URL(fileURLWithPath: FileSystemUtil.filePath(fileName!))
        gfileURL = fileURL
        assetWriter = try? AVAssetWriter(outputURL: fileURL, fileType: AVFileType.mp4)
        
        let videoOutputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: UIScreen.main.bounds.size.width,
            AVVideoHeightKey: UIScreen.main.bounds.size.height
        ]
        videoInput  = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
        videoInput.expectsMediaDataInRealTime = true
        if assetWriter.canAdd(videoInput) {
            assetWriter.add(videoInput)
        }
        let audioOutputSettings: [String: Any] =
                    [AVFormatIDKey: kAudioFormatMPEG4AAC,
                      AVSampleRateKey: 44100,
                      AVNumberOfChannelsKey: 1,
                      AVEncoderBitRateKey: 64000]
                
        audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
        audioWriterInput.expectsMediaDataInRealTime = true
        
        if assetWriter.canAdd(audioWriterInput) {
            assetWriter.add(audioWriterInput)
        }
        
        assetWriter.startWriting()
        self.userNotificationCenter.delegate = self
        requestNotificationAuthorization()
        
    }
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (_, _) in
            
        }
        print("**extension***requestNotificationAuthorization")

    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        print("**extension***broadcastFinished")
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.videoInput.markAsFinished()
        self.audioWriterInput.markAsFinished()
        self.assetWriter.finishWriting {
            do {
                let sharedContainerURL :URL?  = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constant.Application.recordeGroupIdentifier)
                let sourceUrl = sharedContainerURL?.appendingPathComponent("\(self.fileName!).mp4")
                try FileManager.default.copyItem(at: self.gfileURL!, to: sourceUrl!)
                self.sendNotification()
            } catch (_) {
                
            }
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
    }
    
    func sendNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = R.string.localizable.screenRecoding()
        notificationContent.body = R.string.localizable.tapToViewScreenRecording()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: Constant.Application.screenRecodingNotification,
                                            content: notificationContent,
                                            trigger: trigger)
        
        userNotificationCenter.add(request) { (_) in
            
        }
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with bufferType: RPSampleBufferType) {
        super.processSampleBuffer(sampleBuffer, with: bufferType)
        //print("**extension***processSampleBuffer")

        if CMSampleBufferDataIsReady(sampleBuffer) {
            if !isWritingStarted {
                self.assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
                isWritingStarted = true
            }
            if self.assetWriter.status == AVAssetWriter.Status.failed {
                return
            }
            switch bufferType {
            case .video:
                if self.videoInput.isReadyForMoreMediaData {
                    self.videoInput.append(sampleBuffer)
                }
            case .audioApp:
                break
            case .audioMic:
                if self.audioWriterInput.isReadyForMoreMediaData {
                    self.audioWriterInput.append(sampleBuffer)
                }
            @unknown default:
                break
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("**extension***userNotificationCenter-didReceive")

        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("**extension***userNotificationCenter-willPresent")

        completionHandler([.alert, .badge, .sound])
    }
    
}
