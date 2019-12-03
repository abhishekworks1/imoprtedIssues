//
//  StoryTagView.swift
//  ProManager
//
//  Created by Jasmin Patel on 12/12/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

class StoryTagTextField: UITextField {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
}

class StoryTagView: BaseStoryTagView {
    
    // MARK: UI
    lazy var leftView: UIImageView = {
        return UIImageView()
    }()
    
    lazy var textField: StoryTagTextField = {
        return StoryTagTextField()
    }()
    
    // MARK: Variables
    public var placeholder: String = ""
    
    public var startColor: UIColor {
        return getTagColors().0 ?? UIColor.red
    }
    
    public var middleColor: UIColor? {
        return getTagColors().1
    }
    
    public var endColor: UIColor {
        return getTagColors().2 ?? UIColor.blue
    }
    
    private var type: StoryTagType = .hashtag
    
    public var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue?.uppercased()
            self.layoutIfNeeded()
            textField.applyGradientWith(startColor: startColor,
                                        middleColor: middleColor,
                                        endColor: endColor)
            
        }
    }
    
    public var selectedMension: Channel?
    
    public var doneHandler: (() -> Swift.Void)?
    
    public var searchHandler: ((_ text: String) -> Swift.Void)?
    
    convenience init(tagType: StoryTagType, isImage: Bool = true) {
        self.init(frame: CGRect.zero)
        setupViews(isImage: isImage)
        type = tagType
        onFirstTap()
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func setupViews(isImage: Bool) {
        leftView = UIImageView()
        leftView.backgroundColor = ApplicationSettings.appClearColor
        leftView.contentMode = .scaleAspectFit
        if isImage {
            addSubview(leftView)
            leftView.translatesAutoresizingMaskIntoConstraints = false
            leftView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
            leftView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
            leftView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
            leftView.widthAnchor.constraint(equalToConstant: 26).isActive = true
        }
        
        // Add Textfield
        textField = StoryTagTextField()
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.minimumFontSize = 20
        textField.backgroundColor = ApplicationSettings.appClearColor
        textField.borderStyle = UITextField.BorderStyle.none
        textField.adjustsFontSizeToFitWidth = true
        textField.clipsToBounds = true
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        if !isImage {
            textField.textAlignment = .center
        }
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        if isImage {
            textField.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: 8).isActive = true
        } else {
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        }
        textField.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
    }
    
    func refreshLayout() {
        self.layoutIfNeeded()
        self.removeStoryGradientLayer()
        self.removeBlurEffect()
    }
    
    func setupViewsWith(sColor: UIColor, mColor: UIColor?, eColor: UIColor) {
        setPlaceholder()
        leftView.image = getTagImageFor(sColor, middleColor: mColor, endColor: eColor)
        textField.applyGradientWith(startColor: sColor, middleColor: mColor, endColor: eColor)
        textField.applyGradientPlaceholderWith(startColor: sColor, middleColor: mColor, endColor: eColor)
    }
    
    override func onTapWith(_ tapCount: Int) {
        super.onTapWith(tapCount)
        if self.tapCount % 3 == 1 {
            onFirstTap()
        } else if self.tapCount % 3 == 2 {
            onSecondTap()
        } else if self.tapCount % 3 == 0 {
            onThirdTap()
        }
    }
    
    func onFirstTap() {
        refreshLayout()
        self.backgroundColor = ApplicationSettings.appWhiteColor
        setupViewsWith(sColor: startColor,
                       mColor: middleColor,
                       eColor: endColor)
    }
    
    func onSecondTap() {
        refreshLayout()
        self.backgroundColor = ApplicationSettings.appBlackColor.withAlphaComponent(0.13)
        self.addBlurEffect()
        setupViewsWith(sColor: ApplicationSettings.appWhiteColor,
                       mColor: ApplicationSettings.appWhiteColor,
                       eColor: ApplicationSettings.appWhiteColor)
    }
    
    func onThirdTap() {
        refreshLayout()
        self.backgroundColor = ApplicationSettings.appWhiteColor
        self.addStoryGradientLayer(startColor: R.color.storytag_bluePurple() ?? ApplicationSettings.appWhiteColor,
                                   middleColor: R.color.storytag_fadedRed() ?? ApplicationSettings.appBlackColor,
                                   endColor: R.color.storytag_paleOrange() ?? ApplicationSettings.appWhiteColor)
        setupViewsWith(sColor: ApplicationSettings.appWhiteColor,
                       mColor: ApplicationSettings.appWhiteColor,
                       eColor: ApplicationSettings.appWhiteColor)
    }
    
    func gradientColorFrom(color color1: UIColor, toColor color2: UIColor, withSize size: CGSize) -> UIColor {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let colors = [color1.cgColor, color2.cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: colorspace,
                                  colors: colors,
                                  locations: nil)
        guard let cgGradient = gradient else {
            return ApplicationSettings.appWhiteColor
        }
        context?.drawLinearGradient(cgGradient,
                                    start: CGPoint(x: 0, y: 0),
                                    end: CGPoint(x: size.width, y: 0),
                                    options: CGGradientDrawingOptions(rawValue: UInt32(0)))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let aImage = image {
            return UIColor(patternImage: aImage)
        }
        return ApplicationSettings.appWhiteColor
    }
    
    func getTagImageFor(_ startColor: UIColor, middleColor: UIColor?, endColor: UIColor) -> UIImage? {
        var text = ""
        switch type {
        case .hashtag:
            text = "#"
        case .mension:
            text = "@"
        case .location:
            return R.image.ico_location_gradient()?.withImageTintColor(gradientColorFrom(color: startColor, toColor: endColor, withSize: R.image.ico_location_gradient()?.size ?? CGSize.zero))
        case .youtube:
            return R.image.youtubeFeedTabIcon()?.withImageTintColor(gradientColorFrom(color: startColor, toColor: endColor, withSize: R.image.youtubeFeedTabIcon()?.size ?? CGSize.zero))
        case .feed:
            return UIImage(named: "iconFeed")?.withImageTintColor(gradientColorFrom(color: startColor, toColor: endColor, withSize: UIImage(named: "iconFeed")?.size ?? CGSize.zero))
        case .story:
            return UIImage(named: "ico_stories")?.withImageTintColor(gradientColorFrom(color: startColor, toColor: endColor, withSize: UIImage(named: "ico_stories")?.size ?? CGSize.zero))
        case .playlist:
            return UIImage(named: "ico_playlist_tag")?.withImageTintColor(gradientColorFrom(color: startColor, toColor: endColor, withSize: UIImage(named: "ico_stories")?.size ?? CGSize.zero))
        default: break
        }
        let label = getLabelWith(text)
        label.applyGradientWith(startColor: startColor, middleColor: middleColor, endColor: endColor)
        return label.getImage()
    }
    
    func setPlaceholder() {
        switch type {
        case .hashtag:
            placeholder = "HASHTAG"
            break
        case .mension:
            placeholder = "MENTION"
            break
        default: break
        }
        textField.placeholder = placeholder
    }
    
    func getTagColors() -> (UIColor?, UIColor?, UIColor?) {
        switch type {
        case .hashtag:
            return (R.color.hashtag_lightGold(), nil, R.color.hashtag_orange())
        case .mension:
            return (R.color.mension_militaryGreen(), nil, R.color.mension_kiwiGreen())
        case .location:
            return (R.color.locationtag_sapphire(), nil, R.color.locationtag_orchid())
        case .youtube:
            return (R.color.youtubetag_lightRed(), nil, R.color.youtubetag_lightRed())
        case .feed:
            return (R.color.feedtag_skyblue(), nil, R.color.feedtag_red())
        case .story:
            return (R.color.storytag_lightRed(), nil, R.color.storytag_darkRed())
        case .playlist:
            return (R.color.playlisttag_pumpkinOrange(), nil, R.color.playlisttag_redOrange())
        default: break
        }
        return (R.color.storytag_lightPurple(), nil, R.color.storytag_watermelon())
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        var sColor = startColor
        var eColor = endColor
        var mColor = middleColor
        if self.tapCount % 3 == 2 {
            sColor = ApplicationSettings.appWhiteColor
            eColor = ApplicationSettings.appWhiteColor
            mColor = ApplicationSettings.appWhiteColor
        }
        textField.applyGradientWith(startColor: sColor, middleColor: mColor, endColor: eColor)
        searchText(textField.text ?? "")
    }
    
    func searchText(_ text: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(search), object: nil)
        self.perform(#selector(search), with: nil, afterDelay: 0.3)
    }
    
    @objc func search() {
        searchHandler?(textField.text ?? "")
    }
    
    private func getLabelWith(_ text: String) -> UILabel {
        let label = UILabel()
//        label.font = R.font.fontAwesome(size: 20)
        label.text = text
        label.sizeToFit()
        return label
    }
    
}

extension StoryTagView {
    
    public func completeEdit() {
        textField.resignFirstResponder()
        tapEnable = true
    }
    
    public func startEdit() {
        tapEnable = false
        textField.becomeFirstResponder()
    }
    
}

extension StoryTagView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if isBackSpace == -92 {
            textField.deleteBackward()
        } else if string == " " {
            return false
        } else if self.frame.width >= UIScreen.main.bounds.width - 10 {
            return false
        }
        textField.insertText(string.uppercased())
        if textField.text?.isEmpty ?? false {
            textField.placeholder = placeholder
        } else {
            textField.placeholder = nil
        }
        textField.applyGradientPlaceholderWith(startColor: startColor, middleColor: middleColor, endColor: endColor)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doneHandler?()
        return true
    }
    
}
