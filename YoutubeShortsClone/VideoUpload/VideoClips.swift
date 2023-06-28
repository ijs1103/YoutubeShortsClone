//
//  VideoClips.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/21.
//

import UIKit
import AVKit

struct VideoClips: Equatable {
    let videoUrl: URL
    let cameraPosition: AVCaptureDevice.Position
    
    init(videoUrl: URL, cameraPosition: AVCaptureDevice.Position?) {
        self.videoUrl = videoUrl
        self.cameraPosition = cameraPosition ?? .back
    }
    static func ==(lhs: VideoClips, rhs: VideoClips) -> Bool {
        return lhs.videoUrl == rhs.videoUrl && lhs.cameraPosition == rhs.cameraPosition
    }
}
