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
