//
//  SegmentVideo.swift
//  ProManager
//
//  Created by Viraj Patel on 12/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import SCRecorder

public class SegmentVideo: NSObject, NSCopying {
    
    var id: String?
    var url: URL?
    var fileName: String? = nil
    var image: UIImage? = nil
    var lat: String?
    var long: String?
    var address: String?
    var uploadTime: Date = Date()
    var numberOfSegmentText: String? = ""
    var thumbTime: CMTime? = CMTime(value: 0, timescale: 1)
    var videoDuration: String? = "0.0"
    
    override init() {
        super.init()
    }
    
    init(segmentVideos: SegmentVideos) {
        super.init()
        id = segmentVideos.id
        url = segmentVideos.url
        fileName = segmentVideos.fileName
        image = segmentVideos.image
        lat = segmentVideos.lat
        long = segmentVideos.long
        address = segmentVideos.address
        uploadTime = segmentVideos.uploadTime
        numberOfSegmentText = segmentVideos.numberOfSegementtext
        thumbTime = segmentVideos.thumbTime
        videoDuration = segmentVideos.videoDuration
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copySegmentVideo = SegmentVideo()
        copySegmentVideo.id = id
        copySegmentVideo.url = url
        copySegmentVideo.fileName = fileName
        copySegmentVideo.image = image
        copySegmentVideo.lat = lat
        copySegmentVideo.long = long
        copySegmentVideo.address = address
        copySegmentVideo.uploadTime = uploadTime
        copySegmentVideo.numberOfSegmentText = numberOfSegmentText
        copySegmentVideo.thumbTime = thumbTime
        copySegmentVideo.videoDuration = videoDuration
        return copySegmentVideo
    }
    
}

enum ExportRecordState {
  case new, export, failed
}

public class SegmentVideos: NSObject, NSCopying {
    
    var state = ExportRecordState.new
    var id: String?
    var url: URL?
    var fileName: String? = nil
    var image: UIImage? = nil
    var lat: String?
    var long: String?
    var address: String?
    var uploadTime: Date = Date()
    var numberOfSegementtext: String? = ""
    var thumbTime: CMTime? = CMTime.init(value: 0, timescale: 1)
    var videoDuration: String? = "0.0"
    var videos: [SegmentVideo] = []
    var currentAsset: AVAsset?
    private let tokenLength = 20
    var isCombineOneVideo: Bool = false
    var isSelected = false
    
    // MARK: - INITIALIZATION
    override init() {
        super.init()
    }
    
    init(urlStr: URL, thumbimage: UIImage? = nil, latitued: String? = "", longitued: String? = "", placeAddress: String?  = "", numberOfSegement: String?  = "", videoduration: String?  = "0.0", combineOneVideo: Bool? = false){
        super.init()
        url = urlStr
        id = UUID().uuidString
        image = thumbimage
        lat = latitued
        long = longitued
        address = placeAddress
        numberOfSegementtext = numberOfSegement
        videoDuration = videoduration
        isCombineOneVideo = combineOneVideo!
        
        videos.append(SegmentVideo(segmentVideos: self))
        currentAsset = SegmentVideos.getRecordSession(videoModel: videos)
    }
    
    init(urlStr: URL, thumbimage: UIImage? = nil, latitued: String? = "", longitued: String? = "", placeAddress: String?  = "", numberOfSegement: String?  = "", videoduration: String?  = "0.0", allVideos : [SegmentVideo]) {
        super.init()
        url = urlStr
        id = UUID().uuidString
        image = thumbimage
        lat = latitued
        long = longitued
        address = placeAddress
        numberOfSegementtext = numberOfSegement
        videoDuration = videoduration
        videos = allVideos
        currentAsset = SegmentVideos.getRecordSession(videoModel: videos)
    }
    
    class func getRecordSession(videoModel: [SegmentVideo]) -> AVAsset {
        let recodeSession = SCRecordSession.init()
        for segementModel in videoModel {
            let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
            recodeSession.addSegment(segment)
        }
        return recodeSession.assetRepresentingSegments()
    }
   
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = SegmentVideos.init(urlStr: url!, thumbimage: image, latitued: lat, longitued: long, placeAddress: address, numberOfSegement: numberOfSegementtext, videoduration: videoDuration, allVideos : videos)
        return copy
    }
}
