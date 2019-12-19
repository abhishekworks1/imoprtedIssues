//
//  StickerViewController.swift
//  PhotoVideoEditor
//
//  Created by Jasmin Patel on 02/12/19.
//  Copyright © 2019 Jasmin Patel. All rights reserved.
//

import UIKit

class StickerEmojiCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var emojiLabel: UILabel!
}

protocol StickerDelegate {
    func didSelectSticker(_ sticker: StorySticker)
}

class StickerViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    @IBOutlet weak var stickerCollectionView: UICollectionView!
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!

    private var emojis: [String] {
        var emojis: [String] = []
        let emojiRanges = [
            0x1F601...0x1F64F, // emoticons
            0x1F30D...0x1F567, // Other additional symbols
            0x1F680...0x1F6C0, // Transport and map symbols
            0x1F681...0x1F6C5 // Additional transport and map symbols
        ]
        for range in emojiRanges {
            for index in range {
                let char = String(describing: UnicodeScalar(index)!)
                emojis.append(char)
            }
        }
        return emojis
    }

    private var stickers: [StorySticker] {
        var stickers: [StorySticker] = []
        for index in 0...31 {
            if let image = UIImage(named: "storySticker_\(index)") {
                let sticker = StorySticker(image: image,
                                           type: .image)
                stickers.append(sticker)
            }
        }
        return stickers
    }
    
    public var delegate: StickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func backClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension StickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == stickerCollectionView {
            return stickers.count
        }
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == stickerCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.stickerCollectionViewCell.identifier, for: indexPath) as? StickerCollectionViewCell else {
                fatalError("Cell with identifier \(R.reuseIdentifier.stickerCollectionViewCell.identifier) not Found")
            }
            cell.stickerImageView.image = stickers[indexPath.item].image
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.stickerEmojiCollectionViewCell.identifier, for: indexPath) as?  StickerEmojiCollectionViewCell else {
                fatalError("Cell with identifier \(R.reuseIdentifier.stickerEmojiCollectionViewCell.identifier) not Found")
        }
        cell.emojiLabel.text = emojis[indexPath.item]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == stickerCollectionView {
            delegate?.didSelectSticker(stickers[indexPath.item])
        } else {
            delegate?.didSelectSticker(StorySticker(emojiText: emojis[indexPath.item], type: .emoji))
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == stickerCollectionView {
            return CGSize(width: collectionView.frame.size.width/3, height: 100)
        }
        return CGSize(width: collectionView.frame.size.width/5, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension StickerViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let pageFraction = scrollView.contentOffset.x / pageWidth
        self.pageControl.currentPage = Int(round(pageFraction))
    }
    
}
