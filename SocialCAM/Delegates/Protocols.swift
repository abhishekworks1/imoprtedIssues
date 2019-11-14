//
//  Protocols.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 6/15/17.
//
//

import Foundation
import UIKit

protocol FinishedTag {
    func didFinish(isDone: Bool)
}

/**
 - didSelectView
 - didSelectImage
 - stickersViewDidDisappear
 */

public protocol PhotoEditorDelegate: class {
    /**
     - Parameter image: edited Image
     */
    func doneEditing(image: UIImage)
    /**
     StickersViewController did Disappear
     */
    func canceledEditing()
}


/**
 - didSelectView
 - didSelectImage
 - stickersViewDidDisappear
 */
protocol StickersViewControllerDelegate: class {
    /**
     - Parameter view: selected view from StickersViewController
     */
    func didSelectView(view: UIView)
    /**
     - Parameter image: selected Image from StickersViewController
     */
    func didSelectImage(sticker: StorySticker)
    /**
     StickersViewController did Disappear
     */
    func stickersViewDidDisappear()
}

/**
 - didSelectView
 - didSelectImage
 - stickersViewDidDisappear
 */
protocol HashTagViewControllerDelegate: class {
    /**
     - Parameter view: selected view from StickersViewController
     */
    func didHashTagSelectView(view: UIView)
    /**
     - Parameter image: selected Image from StickersViewController
     */
    func didHashTagSelectImage(image: UIImage)
    /**
     StickersViewController did Disappear
     */
    func hashTagViewDidDisappear()
}


/**
 - didSelectColor
 */
protocol ColorDelegate: class {
    func didSelectColor(color: UIColor)
}
/**
 - didSelectUser
 */
protocol MensionDelegate: class {
    func didSelectUser(user: Channel)
}
/**
 - didSelectEmoji
 */
protocol EmojiDelegate: class {
    func didSelectEmoji(emoji: String)
}


protocol CollageCellDelegate : class {
    func didSelectCell(cellId : Int)
}
