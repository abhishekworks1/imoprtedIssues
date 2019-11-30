//
//  PhotoEditorViewController+LifeCycle.swift
//  SocialCAM
//
//  Created by Viraj Patel on 04/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import IQKeyboardManagerSwift

extension PhotoEditorViewController {
    
    // LifeCycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        bottomToolbar.isHidden = (storiCamType == .chat || storiCamType == .feed)
       
        initLocation()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        setupColorSlider()
        setupFilter()
        setupSketchView()
        setupUIForStoryType()
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(longTap(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.8
        postStoryButton.addGestureRecognizer(longPressGestureRecognizer)
        
        setupStopMotionCollectionView()
        configureMensionCollectionView()
        configureEmojiCollectionView()
        
        stickersViewController = StickersViewController(nibName: "StickersViewController", bundle: Bundle(for: StickersViewController.self))
        
        tagVC = TagVC(nibName: "TagVC", bundle: Bundle(for: TagVC.self))
        
        setupExistingTags()
        if Defaults.shared.isPro {
            self.isProVersionApp(true)
        } else {
            self.isProVersionApp(false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentCamaraMode != .slideshow {
            if let player = scPlayer {
                player.play()
                startPlaybackTimeChecker()
                if let cell: ImageCollectionViewCell = self.stopMotionCollectionView.cellForItem(at: IndexPath.init(row: self.currentPage, section: 0)) as? ImageCollectionViewCell {
                    guard let startTime = cell.trimmerView.startTime else {
                        return
                    }
                    player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
                }
            }
        }
        
        isViewAppear = true
        addApplicationStateObserver()
        addKeyboardStateObserver()
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.outtakesFrame = CGRect.init(x: outtakesView.frame.origin.x, y: outtakesView.frame.origin.y + bottomToolbar.frame.origin.y + 20, width: outtakesView.frame.width, height: outtakesView.frame.height)
        self.notesFrame = CGRect.init(x: notesView.frame.origin.x, y: notesView.frame.origin.y + bottomToolbar.frame.origin.y + 20, width: notesView.frame.width, height: notesView.frame.height)
        self.chatFrame = CGRect.init(x: chatView.frame.origin.x, y: chatView.frame.origin.y + bottomToolbar.frame.origin.y + 20, width: chatView.frame.width, height: chatView.frame.height)
        self.feedFrame = CGRect.init(x: feedView.frame.origin.x, y: feedView.frame.origin.y + bottomToolbar.frame.origin.y + 20, width: feedView.frame.width, height: feedView.frame.height)
        self.youtubeFrame = CGRect.init(x: youTubeView.frame.origin.x, y: youTubeView.frame.origin.y + bottomToolbar.frame.origin.y + 20, width: youTubeView.frame.width, height: youTubeView.frame.height)
        self.storyFrame = CGRect.init(x: storyView.frame.origin.x, y: storyView.frame.origin.y + bottomToolbar.frame.origin.y + 20, width: storyView.frame.width, height: storyView.frame.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.deleterectFrame = deleteView.frame
        if !isPlayerInitialize {
            isPlayerInitialize = true
            if self.currentCamaraMode != .boomerang {
                connVideoPlay(isFirstTime: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = scPlayer {
            player.pause()
            stopPlaybackTimeChecker()
        }
        
        removeApplicationStateObserver()
        removeKeyboardStateObserver()
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPlaybackTimeChecker()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: KeyframePickerCursorVC.self) {
            self.cursorContainerViewController = segue.destination as? KeyframePickerCursorVC
        }
    }
    
}
