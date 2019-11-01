//
//  URL.swift
//  ProManager
//
//  Created by Jasmin Patel on 30/07/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import AVFoundation

extension URL {
    
    var duration: Double {
        let asset = AVAsset(url: self)
        
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        
        return durationTime
    }
    
}
