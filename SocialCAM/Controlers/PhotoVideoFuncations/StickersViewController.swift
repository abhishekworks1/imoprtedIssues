//
//  StickersViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//  Credit https://github.com/AhmedElassuty/IOS-BottomSheet

import UIKit

enum AskQuestionType: Int {
    case slider = 0
    case poll
    case normal
}

public enum StoryStickerType {
    case image
    case youtube
    case hashtag
    case mension
    case location
    case day
    case time(date: Date)
    case weather(temperature: String)
    case askQuestion(type: Int)
    case camera
}

public class StorySticker {
    var type: StoryStickerType
    var image: UIImage?
    
    init(image: UIImage?, type: StoryStickerType) {
        self.image = image
        self.type = type
    }
}

class StickersViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var holdView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var collectionView: UICollectionView!
    var emojiscollectionView: UICollectionView!
    
    var emojisDelegate: EmojisCollectionViewDelegate!
    
    var stickers: [StorySticker] = []
    weak var stickersViewControllerDelegate: StickersViewControllerDelegate?
    
    let screenSize = UIScreen.main.bounds.size
    var temperature: String?
    
    let fullView: CGFloat = 0 // remainder of screen height
    var partialView: CGFloat {
        //        return UIScreen.main.bounds.height - 380
        return 0
    }
    var storiCamType: StoriCamType = .story
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if storiCamType != .chat && storiCamType != .chat {
            stickers.insert(StorySticker(image: R.image.ico_que_tag(), type: .askQuestion(type: AskQuestionType.normal.rawValue)), at: 0)
            stickers.insert(StorySticker(image: R.image.ico_poll_tag(), type: .askQuestion(type: AskQuestionType.poll.rawValue)), at: 0)
            stickers.insert(StorySticker(image: R.image.ico_sliderQue_tag(), type: .askQuestion(type: AskQuestionType.slider.rawValue)), at: 0)
        }
        if let temp = self.temperature {
            stickers.insert(StorySticker(image: weatherTagImage(temp: "\(Int(Double(temp) ?? 0))° C"), type: .weather(temperature: temp)), at: 0)
        }
        stickers.insert(StorySticker(image: timeTagImage(date: Date()), type: .time(date: Date())), at: 0)
        stickers.insert(StorySticker(image: dayTagImage(), type: .day), at: 0)
        stickers.insert(StorySticker(image: R.image.ico_cameraButton_tag(), type: .camera), at: 0)
        if storiCamType != .chat && storiCamType != .chat {
            stickers.insert(StorySticker(image: R.image.ico_Youtube_tag(), type: .youtube), at: 0)
            stickers.insert(StorySticker(image: R.image.ico_hashtag_tag(), type: .hashtag), at: 0)
            stickers.insert(StorySticker(image: R.image.ico_mention_tag(), type: .mension), at: 0)
            stickers.insert(StorySticker(image: R.image.ico_location_tag(), type: .location), at: 0)
        }
        for index in 0...31 {
            if let image = UIImage(named: "storySticker_\(index)") {
                stickers.append(StorySticker(image: image, type: StoryStickerType.image))
            }
        }
        configureCollectionViews()
        scrollView.contentSize = CGSize(width: 2.0 * screenSize.width,
                                        height: scrollView.frame.size.height)
        
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        pageControl.numberOfPages = 2
        
        holdView.layer.cornerRadius = 3
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(StickersViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    func updateTimeTag() {
        guard stickers.count > 5 else { return }
        stickers[6].image = timeTagImage(date: Date())
        stickers[6].type = .time(date: Date())
    }
    
    func dayTagImage() -> UIImage {
        let formatter = DateFormatter()
        formatter.dateFormat  = "EEEE"
        let dayString = formatter.string(from: Date())
        let tagView = StoryTagView.init(tagType: .youtube, isImage: false)
        self.view.addSubview(tagView)
        tagView.translatesAutoresizingMaskIntoConstraints = false
        // apply constraint
        tagView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        tagView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        tagView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        tagView.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.width - 10).isActive = true
        // set text
        tagView.text = dayString
        tagView.translatesAutoresizingMaskIntoConstraints = true
        tagView.completeEdit()
        tagView.layoutIfNeeded()
        tagView.center = self.view.center
        let tagImage = tagView.toImage()
        tagView.removeFromSuperview()
        return tagImage
    }
    
    func weatherTagImage(temp: String) -> UIImage {
        let tagView = StoryTagView.init(tagType: .youtube, isImage: false)
        self.view.addSubview(tagView)
        tagView.translatesAutoresizingMaskIntoConstraints = false
        // apply constraint
        tagView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        tagView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        tagView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        tagView.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.width - 10).isActive = true
        // set text
        tagView.text = temp
        tagView.translatesAutoresizingMaskIntoConstraints = true
        tagView.completeEdit()
        tagView.center = self.view.center
        let tagImage = tagView.toImage()
        tagView.removeFromSuperview()
        return tagImage
    }
    
    func timeTagImage(date: Date) -> UIImage {
        let aView = BaseTimeTagView.init(date: Date())
        
        aView.backgroundColor = ApplicationSettings.appClearColor
        self.view.addSubview(aView)
        aView.translatesAutoresizingMaskIntoConstraints = false
        aView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        aView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        aView.layoutIfNeeded()
        let tagImage = aView.toImage()
        aView.removeFromSuperview()
        return tagImage
    }
    
    func configureCollectionViews() {
        
        let frame = CGRect(x: 0,
                           y: 0,
                           width: UIScreen.main.bounds.width,
                           height: view.frame.height - 60)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        let width = (CGFloat) ((screenSize.width - 30) / 3.0)
        layout.itemSize = CGSize(width: width, height: 100)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = ApplicationSettings.appClearColor
        scrollView.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(R.nib.stickerCollectionViewCell)
        
        // -----------------------------------
        
        let emojisFrame = CGRect(x: scrollView.frame.size.width,
                                 y: 0,
                                 width: UIScreen.main.bounds.width,
                                 height: view.frame.height - 40)
        
        let emojislayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        emojislayout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        emojislayout.itemSize = CGSize(width: 70, height: 70)
        
        emojiscollectionView = UICollectionView(frame: emojisFrame, collectionViewLayout: emojislayout)
        emojiscollectionView.backgroundColor = ApplicationSettings.appClearColor
        scrollView.addSubview(emojiscollectionView)
        emojisDelegate = EmojisCollectionViewDelegate()
        emojisDelegate.stickersViewControllerDelegate = stickersViewControllerDelegate
        emojiscollectionView.delegate = emojisDelegate
        emojiscollectionView.dataSource = emojisDelegate
        emojiscollectionView.register(R.nib.storyEmojiCollectionViewCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.6) { [weak self] in
            guard let `self` = self else { return }
            let frame = self.view.frame
            let yComponent = self.partialView
            self.view.frame = CGRect(x: 0,
                                     y: yComponent,
                                     width: frame.width,
                                     height: UIScreen.main.bounds.height - self.partialView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect(x: 0,
                                      y: 0,
                                      width: UIScreen.main.bounds.width,
                                      height: view.frame.height - 60)
        
        emojiscollectionView.frame = CGRect(x: scrollView.frame.size.width,
                                            y: 0,
                                            width: UIScreen.main.bounds.width,
                                            height: view.frame.height - 60)
        
        scrollView.contentSize = CGSize(width: 2.0 * screenSize.width,
                                        height: scrollView.frame.size.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        removeBottomSheetView()
    }
    
    // MARK: Pan Gesture
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let minY = self.view.frame.minY
        if minY + translation.y >= fullView {
            let newMinY = minY + translation.y
            self.view.frame = CGRect(x: 0, y: newMinY, width: view.frame.width, height: UIScreen.main.bounds.height - newMinY)
            self.view.layoutIfNeeded()
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((minY - fullView) / -velocity.y) : Double((partialView - minY) / velocity.y)
            duration = duration > 1.3 ? 1 : duration
            // velocity is direction of gesture
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    if minY + translation.y >= self.partialView {
                        self.removeBottomSheetView()
                    } else {
                        self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.partialView)
                        self.view.layoutIfNeeded()
                    }
                } else {
                    if minY + translation.y >= self.partialView {
                        self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.partialView)
                        self.view.layoutIfNeeded()
                    } else {
                        self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.fullView)
                        self.view.layoutIfNeeded()
                    }
                }
                
            }, completion: nil)
        }
    }
    
    func removeBottomSheetView(_ duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.view.frame = frame
                        
        }, completion: { (_) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.stickersViewControllerDelegate?.stickersViewDidDisappear()
        })
    }
    
    func prepareBackgroundView() {
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        view.insertSubview(bluredView, at: 0)
    }
    
}

extension StickersViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let pageFraction = scrollView.contentOffset.x / pageWidth
        self.pageControl.currentPage = Int(round(pageFraction))
    }
    
}

// MARK: - UICollectionViewDataSource
extension StickersViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        stickersViewControllerDelegate?.didSelectImage(sticker: stickers[indexPath.item])
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.stickerCollectionViewCell.identifier, for: indexPath) as? StickerCollectionViewCell else {
            fatalError("Unable to find cell with '\(R.reuseIdentifier.stickerCollectionViewCell.identifier)' reuseIdentifier")
        }
        cell.stickerImage.image = stickers[indexPath.item].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
