//
//  StoryAskQuestionView.swift
//  ProManager
//
//  Created by Jasmin Patel on 27/12/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

class CornerButton: UIButton {
    
    private var corners: UIRectCorner = .allCorners
    
    private var radius: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(corners: UIRectCorner, radius: CGFloat) {
        self.init(frame: CGRect.zero)
        self.corners = corners
        self.radius = radius
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(corners, radius: radius)
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

class StoryAskQuestionView: BaseQuestionTagView {
    
    var textStartColor: UIColor = R.color.quetag_LightUrple() ?? UIColor.green
        
    var textEndColor: UIColor = R.color.storytag_watermelon() ?? UIColor.blue
    
    lazy var textView: StoryQueTextView = {
        let txtView = StoryQueTextView(frame: CGRect.zero)
        txtView.font = UIFont.systemFont(ofSize: 23)
        txtView.isScrollEnabled = false
        txtView.textAlignment = .center
        txtView.backgroundColor = ApplicationSettings.appClearColor
        txtView.textContainer.maximumNumberOfLines = 10
        txtView.placeHolder = "Ask me a question"
        txtView.autocorrectionType = .no
        return txtView
    }()
    
    lazy var replyTextView: StoryQueTextView = {
        let txtView = StoryQueTextView(frame: CGRect.zero)
        txtView.font = UIFont.systemFont(ofSize: 14)
        txtView.textColor = R.color.quetag_GreyishBrown()
        txtView.isScrollEnabled = false
        txtView.textAlignment = .center
        txtView.backgroundColor = ApplicationSettings.appClearColor
        txtView.textContainer.maximumNumberOfLines = 2
        txtView.placeHolder = "Viewers respond here"
        txtView.placeholderColor = R.color.quetag_GreyishBrown() ?? ApplicationSettings.appBlackColor.withAlphaComponent(0.5)
            
        txtView.isUserInteractionEnabled = false
        return txtView
    }()
    
    lazy var baseReplyView: UIView = {
        let sView = UIView()
        sView.backgroundColor = R.color.quetag_Ice()
        sView.layer.cornerRadius = 4.0
        return sView
    }()
    
    lazy var imageView: UIImageView = {
        let sView = UIImageView()
        if Defaults.shared.currentUser?.profileType == ProfilePicType.videoType.rawValue {
            sView.setImageFromURL(Defaults.shared.currentUser?.profileThumbnail)
        } else {
            sView.setImageFromURL(Defaults.shared.currentUser?.profileImageURL)
        }
        sView.backgroundColor = ApplicationSettings.appClearColor
        sView.layer.cornerRadius = 25.0
        sView.layer.borderColor = ApplicationSettings.appWhiteColor.cgColor
        sView.layer.borderWidth = 1.0
        sView.clipsToBounds = true
        return sView
    }()
    
    lazy var sendButton: CornerButton = {
        let sView = CornerButton.init(corners: [.bottomLeft, .bottomRight], radius: 10)
        sView.backgroundColor = ApplicationSettings.appPrimaryColor
        sView.setTitleColor(ApplicationSettings.appWhiteColor, for: .normal)
        sView.setTitle("Send", for: .normal)
        sView.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        sView.clipsToBounds = true
        sView.addTarget(self, action: #selector(onSend(_:)), for: .touchUpInside)
        sView.alpha = 0.5
        sView.isEnabled = false
        return sView
    }()
    
    var questionText: String {
        get {
            if textView.text.count == 0 {
                return textView.placeHolder ?? ""
            }
            return textView.text
        }
        set {
            textView.setTextViewWith(newValue)
        }
    }
    
    var isAnswerView: Bool = false
    
    var onReplyTap: ((StoryTags?, Story?) -> Swift.Void)? = nil
    
    var onReplySend: ((String) -> Swift.Void)? = nil
    
    var sendButtonHeightConstraint: NSLayoutConstraint?
    
    weak var storyTag: StoryTags?
    
    weak var story: Story?
    
    convenience init() {
        self.init(frame: CGRect.zero)
        self.layer.cornerRadius = 10.0
        self.backgroundColor = ApplicationSettings.appWhiteColor
        setupViews()
    }
    
    override func onTap(_ sender: UIButton) {
        guard !replyTextView.isFirstResponder else {
            return
        }
        if isAnswerView {
            onReplyTap?(storyTag, story)
        } else {
            super.onTap(sender)
        }
    }
    
    @objc func onSend(_ sender: UIButton) {
        onReplySend?(replyTextView.text)
    }
    
    func setupViews() {
        self.addSubview(textView)
        self.addSubview(baseReplyView)
        baseReplyView.addSubview(replyTextView)
        self.addSubview(imageView)
        self.addSubview(sendButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: -25),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            imageView.widthAnchor.constraint(equalToConstant: 50)
            ])
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            textView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 13)
            ])
        
        baseReplyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            baseReplyView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            baseReplyView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            ])
        
        baseReplyView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 13).isActive = true
        
        
        replyTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            replyTextView.leadingAnchor.constraint(equalTo: baseReplyView.leadingAnchor, constant: 0),
            replyTextView.trailingAnchor.constraint(equalTo: baseReplyView.trailingAnchor, constant: 0),
            replyTextView.bottomAnchor.constraint(equalTo: baseReplyView.bottomAnchor, constant: -3.5),
            replyTextView.topAnchor.constraint(equalTo: baseReplyView.topAnchor, constant: 3.5)
            ])
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -1),
            sendButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            sendButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            sendButton.topAnchor.constraint(equalTo: baseReplyView.bottomAnchor, constant: 15)
            ])
        sendButtonHeightConstraint = sendButton.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([sendButtonHeightConstraint!])
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChangeNotification(_:)), name: UITextView.textDidChangeNotification , object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func textDidChangeNotification(_ notification: Notification) {
        guard let txtView = notification.object as? StoryQueTextView,
            replyTextView == txtView else {
                return
        }
        let hasText = replyTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
        sendButton.alpha = hasText ? 1.0 : 0.5
        sendButton.isEnabled = hasText
    }
    
    func completeEdit() {
        self.tapEnable = true
        textView.resignFirstResponder()
        if textView.text.isEmpty {
            textView.placeholderColor = UIColor
                .gradientColorFrom(colors: [R.color.quetag_LightUrple() ?? UIColor.green,
                                            R.color.storytag_watermelon() ?? UIColor.blue],
                                   and: textView.bounds.size) ?? ApplicationSettings.appBlackColor
        }
    }
    
    func startEdit() {
        self.tapEnable = false
        textView.becomeFirstResponder()
        if textView.text.isEmpty {
            textView.textColor = UIColor
                .gradientColorFrom(colors: [R.color.quetag_LightUrple() ?? UIColor.green,
                                            R.color.storytag_watermelon() ?? UIColor.blue],
                                   and: textView.bounds.size) ?? ApplicationSettings.appBlackColor
            
            textView.placeholderColor = UIColor
                .gradientColorFrom(colors: [R.color.quetag_LightUrple() ?? UIColor.green,
                                            R.color.storytag_watermelon() ?? UIColor.blue],
                                   and: textView.bounds.size)?.withAlphaComponent(0.5) ?? ApplicationSettings.appBlackColor
        }
    }
    
    func startAnswerEdit() {
        replyTextView.becomeFirstResponder()
        sendButtonHeightConstraint?.constant = 40
        self.bringSubviewToFront(sendButton)
        for constraint in constraints {
            guard constraint.firstAnchor == heightAnchor else { continue }
            constraint.isActive = false
            break
        }
    }
    
    func completeAnswerEdit() {
        replyTextView.setTextViewWith("")
        replyTextView.resignFirstResponder()
        sendButtonHeightConstraint?.constant = 0
        self.sendSubviewToBack(sendButton)
        sendButton.alpha = 0.5
        sendButton.isEnabled = false
        for constraint in constraints {
            guard constraint.firstAnchor == heightAnchor else { continue }
            constraint.isActive = true
            break
        }
    }
}

class AskQuestionReplyView: UIView {
    
    lazy var textView: StoryQueTextView = {
        let txtView = StoryQueTextView(frame: CGRect.zero)
        txtView.font = UIFont.systemFont(ofSize: 23)
        txtView.isScrollEnabled = false
        txtView.textAlignment = .center
        txtView.backgroundColor = ApplicationSettings.appClearColor
        txtView.textContainer.maximumNumberOfLines = 10
        txtView.placeHolder = "Ask me a question"
        txtView.autocorrectionType = .no
        txtView.isEditable = false
        return txtView
    }()
    
    lazy var replyTextView: StoryQueTextView = {
        let txtView = StoryQueTextView(frame: CGRect.zero)
        txtView.font = UIFont.systemFont(ofSize: 23)
        txtView.isScrollEnabled = false
        txtView.textAlignment = .center
        txtView.backgroundColor = ApplicationSettings.appWhiteColor
        txtView.textContainer.maximumNumberOfLines = 10
        txtView.placeHolder = "Ask me a question"
        txtView.autocorrectionType = .no
        txtView.isEditable = false
        return txtView
    }()
    
    lazy var tapButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    var questionText: String {
        get {
            if textView.text.count == 0 {
                return textView.placeHolder ?? ""
            }
            return textView.text
        }
        set {
            textView.setTextViewWith(newValue)
        }
    }
    
    var answerText: String {
        get {
            if replyTextView.text.count == 0 {
                return replyTextView.placeHolder ?? ""
            }
            return replyTextView.text
        }
        set {
            replyTextView.setTextViewWith(newValue)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: .zero)
        setupViews()
    }
    
    func setupViews() {
        layer.cornerRadius = 10.0
        clipsToBounds = true
        addSubview(textView)
        addSubview(replyTextView)
        addSubview(tapButton)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
            ])
        replyTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            replyTextView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0),
            replyTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            replyTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            replyTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
            ])
        tapButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tapButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            tapButton.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            tapButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            tapButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
            ])
    }
    
    func updateColors() {
        textView.backgroundColor = UIColor
            .gradientColorFrom(colors: [R.color.quetag_LightUrple() ?? UIColor.green,
                                        R.color.storytag_watermelon() ?? UIColor.blue],
                               and: textView.bounds.size) ?? UIColor.green
        textView.textColor = ApplicationSettings.appWhiteColor
        
        replyTextView.textColor = UIColor
            .gradientColorFrom(colors: [R.color.quetag_LightUrple() ?? UIColor.green,
                                        R.color.storytag_watermelon() ?? UIColor.blue],
                               and: replyTextView.bounds.size) ?? UIColor.green
        replyTextView.backgroundColor = ApplicationSettings.appWhiteColor
    }
    
}
