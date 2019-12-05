//
// BlurredVideoView.swift
//
// Created by Greg Niemann on 10/4/17.
// Copyright (c) 2017 WillowTree, Inc. All rights reserved.
//

import UIKit
import AVKit
import CoreML

class MLVideoView: UIView {
    
    var player: AVPlayer!
    var selectedIndex: Int = 0

    private var output: AVPlayerItemVideoOutput!
    private var displayLink: CADisplayLink!
    private var context: CIContext = CIContext(options: [CIContextOption.workingColorSpace: NSNull()])
    private var playerItemObserver: NSKeyValueObservation?

    func play(asset: AVAsset, completion: (() -> Void)? = nil) {
        layer.isOpaque = true

        let item = AVPlayerItem(asset: asset)
        output = AVPlayerItemVideoOutput(outputSettings: nil)
        item.add(output)

        playerItemObserver = item.observe(\.status) { [weak self] item, _ in
            guard item.status == .readyToPlay else { return }
            self?.playerItemObserver = nil
            self?.setupDisplayLink()

            self?.player.play()
            completion?()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(finishVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

        player = AVPlayer(playerItem: item)
    }

    @objc func finishVideo() {
        self.player.seek(to: CMTime.zero)
        self.player.play()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func stop() {
        player.rate = 0
        displayLink.invalidate()
    }

    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkUpdated(link:)))
        displayLink.preferredFramesPerSecond = 20
        displayLink.add(to: .main, forMode: RunLoop.Mode.common)
    }

    @objc private func displayLinkUpdated(link: CADisplayLink) {
        let time = output.itemTime(forHostTime: CACurrentMediaTime())
        guard output.hasNewPixelBuffer(forItemTime: time),
              let pixbuf = output.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else { return }
        var mlBuffer: CVPixelBuffer?
        if #available(iOS 12.0, *) {
            if selectedIndex == -1 {
                mlBuffer = pixbuf
            } else {
                let model = StyleTransferModel43()
                do {
                    let styles = try MLMultiArray(shape: [43],
                                                  dataType: .double)
                    for index in 0..<styles.count {
                        styles[index] = 0.0
                    }
                    styles[selectedIndex] = 1.0
                    do {
                        let mlPredicationOptions = MLPredictionOptions.init()
                        mlPredicationOptions.usesCPUOnly = false
                        let input = StyleTransferModel43Input.init(image: pixbuf.mlPixelFormatBuffer(scale: 0.3)!, index: styles)
                        let predictionOutput = try model.prediction(input: input,
                                                                    options: mlPredicationOptions)
                        mlBuffer = predictionOutput.stylizedImage
                    } catch let error as NSError {
                        print("CoreML Model Error: \(error)")
                    }
                } catch let error {
                    print(error)
                }
            }
        } else {
            mlBuffer = pixbuf
        }
        let baseImg = CIImage(cvImageBuffer: mlBuffer!)
        
        guard let cgImg = context.createCGImage(baseImg, from: baseImg.extent) else { return }

        layer.contents = cgImg
    }
}
