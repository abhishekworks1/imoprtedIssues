//
//  EmojiCollectionViewDelegate.swift
//  ProManager
//
//  Created by Jasmin Patel on 26/12/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation

class EmojiSlider {
    var emojis: [String]
    init(emojis: [String]) {
        self.emojis = emojis
    }
    
    static var data = [
        EmojiSlider(emojis: ["😍", "😂", "😀", "🔥", "😡", "😱", "😢", "🙌"]),
        EmojiSlider(emojis: ["❤️", "🎉", "👍", "💩", "💯", "🙏", "😮", "😋"])
    ]
}

//extension PhotoEditorViewController {
//    func configureEmojiCollectionView() {
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: (UIScreen.width - 20)/8,
//                                 height: (UIScreen.width - 20)/8)
//        layout.scrollDirection = .horizontal
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
//        emojiCollectionView.collectionViewLayout = layout
//        emojiCollectionView.isPagingEnabled = true
//        emojiCollectionViewDelegate = EmojiCollectionViewDelegate()
//        emojiCollectionViewDelegate.emojiDelegate = self
//        emojiCollectionView.delegate = emojiCollectionViewDelegate
//        emojiCollectionView.dataSource = emojiCollectionViewDelegate
//
//        emojiCollectionView.register(
//            UINib(resource: R.nib.queSliderCollectionViewCell),
//            forCellWithReuseIdentifier: R.nib.queSliderCollectionViewCell.identifier)
//    }
//}

//extension PhotoEditorViewController: EmojiDelegate {
//
//    func didSelectEmoji(emoji: String) {
//        if let queTagView = self.currentTagView as? StorySliderQueView {
//            DispatchQueue.main.async {
//                queTagView.slider.emojiText = emoji
//            }
//        }
//    }
//
//}

class EmojiCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var emojiDelegate: EmojiDelegate?
    /**
     Array of emojis that will show while typing
     */
    var emojis: [String] = ["😍", "😂", "😀", "🔥", "😡", "😱", "😢", "🙌", "❤️", "🎉", "👍", "💩", "💯", "🙏", "😮", "😢"]
    
    override init() {
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        emojiDelegate?.didSelectEmoji(emoji: emojis[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QueSliderCollectionViewCell", for: indexPath) as? QueSliderCollectionViewCell else {
            fatalError("Unable to find cell with 'QueSliderCollectionViewCell' reuseIdentifier")
        }
        cell.lblEmoji.text = emojis[indexPath.row]
        if indexPath.row == emojis.count - 1 {
            cell.lblEmoji.layer.borderColor = ApplicationSettings.appWhiteColor.cgColor
        } else {
            cell.lblEmoji.layer.borderColor = ApplicationSettings.appClearColor.cgColor
        }
        return cell
    }
    
}
